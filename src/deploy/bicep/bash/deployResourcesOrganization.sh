#!/bin/bash


devBoxResourceGroupName="$1"
location="$2"

# Function to create an Azure resource group
createResourceGroup() {
    local resourceGroupName="$1"

    if [[ -z "$resourceGroupName" || -z "$location" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createResourceGroup <resourceGroupName> <location>"
        return 1
    fi

    echo "Creating Azure Resource Group: $resourceGroupName in $location"

    if az group create --name "$resourceGroupName" --location "$location" \
        --tags \
        "division=PlatformEngineeringTeam-DX" \
        "Environment=Production" \
        "offering=DevBox-as-a-Service"; then
        
        echo "Resource group '$resourceGroupName' created successfully."
    else
        echo "Error: Failed to create resource group '$resourceGroupName'."
        return 1
    fi
}

# Function to deploy resources for the organization
deployResourcesOrganization() {

    createResourceGroup "$devBoxResourceGroupName"
}

validateInputs() {
    if [[ -z "$devBoxResourceGroupName" || -z "$networkResourceGroupName" || -z "$managementResourceGroupName" || -z "$location" ]]; then
        devBoxResourceGroupName='PetDx-rg'
        networkResourceGroupName='PetDx-rg'
        managementResourceGroupName='PetDx-rg'
        location='westus3'
    fi
}

deployResourcesOrganization
