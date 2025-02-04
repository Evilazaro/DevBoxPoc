#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail

# Azure Resource Group Names Constants
solutionName="Contoso"
devBoxResourceGroupName="${solutionName}-DevExp-RG"
networkResourceGroupName="${solutionName}-DevExp-Connectivity-RG"

# Identity Parameters Constants
customRoleName="ContosoDevCenterDevBoxRole"

subscriptionId=$(az account show --query id --output tsv)

# Function to delete a resource group
delete_resource_group() {
    local resourceGroupName=$1

    groupExists=$(az group exists --name "$resourceGroupName")

    if [ "$groupExists" == "true" ]; then
        # List and delete all deployments in the resource group
        deployments=$(az deployment group list --resource-group "$resourceGroupName" --query "[].name" -o tsv)
        for deployment in $deployments; do
            echo "Deleting deployment: $deployment"
            az deployment group delete --resource-group "$resourceGroupName" --name "$deployment"
            echo "Deployment $deployment deleted."
        done
        sleep 10
        echo "Deleting resource group: $resourceGroupName..."
        az group delete --name "$resourceGroupName" --yes --no-wait
        echo "Resource group $resourceGroupName deletion initiated."
    else
        echo "Resource group $resourceGroupName does not exist. Skipping deletion."
    fi
}

# Function to remove a role assignment
remove_role_assignment() {
    local roleId=$1
    local subscription=$2

    echo "Checking the role assignments for the identity..."

    if [ -z "$roleId" ]; then
        echo "Role not defined. Skipping role assignment deletion."
        return
    fi

    assignmentExists=$(az role assignment list --role "$roleId" --scope "/subscriptions/$subscription")
    if [ -z "$assignmentExists" ] || [ "$assignmentExists" == "[]" ]; then
        echo "'$roleId' role assignment does not exist. Skipping deletion."
    else
        echo "Removing '$roleId' role assignment from the identity..."
        az role assignment delete --role "$roleId"
        echo "'$roleId' role assignment successfully removed."
    fi
}

# Function to delete a custom role
delete_custom_role() {
    local roleName=$1

    echo "Deleting the '$roleName' role..."
    roleExists=$(az role definition list --name "$roleName")

    if [ -z "$roleExists" ] || [ "$roleExists" == "[]" ]; then
        echo "'$roleName' role does not exist. Skipping deletion."
        return
    fi

    az role definition delete --name "$roleName"

    while [ "$(az role definition list --name "$roleName" --query "[].roleName" -o tsv)" == "$roleName" ]; do
        echo "Waiting for the role to be deleted..."
        sleep 10
    done
    echo "'$roleName' role successfully deleted."
}

# Function to delete role assignments
delete_role_assignments() {
    # Deleting role assignments and role definitions
    roles=("Owner" "Managed Identity Operator" "$customRoleName" "ContosoDx-identity-customRole" "ContosoIpeDx-identity-customRole" "Deployment Environments Reader" "Deployment Environments User")
    for roleName in "${roles[@]}"; do
        echo "Getting the role ID for '$roleName'..."
        roleId=$(az role definition list --name "$roleName" --query "[].name" --output tsv)
        if [ -z "$roleId" ]; then
            echo "Role ID for '$roleName' not found. Skipping role assignment deletion."
            continue
        else
            echo "Role ID for '$roleName' is '$roleId'."
            echo "Removing '$roleName' role assignment..."
        fi
        remove_role_assignment "$roleId" "$subscriptionId"
    done
}

# Function to clean up resources
clean_up_resources() {
    clear
    delete_role_assignments
    delete_resource_group "$devBoxResourceGroupName"
    delete_resource_group "$networkResourceGroupName"
    delete_resource_group "NetworkWatcherRG"
    delete_resource_group "Default-ActivityLogAlerts"
    delete_resource_group "DefaultResourceGroup-WUS2"
    delete_custom_role "$customRoleName"
    delete_custom_role "ContosoDx-identity-customRole"
    delete_custom_role "ContosoIpeDx-identity-customRole"
}

# Main script execution
clean_up_resources