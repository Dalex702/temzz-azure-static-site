#!/bin/bash
set -euo pipefail

# Usage:
# ./deploy.sh <resource-group> <storage-account-name> <location>
# Example: ./deploy.sh temzz-rg temzzstatic123 northeurope

RG="${1:-temzz-rg}"
SA="${2:-temzzstatic$((RANDOM % 10000))}"
LOCATION="${3:-northeurope}"

echo "Resource Group: $RG"
echo "Storage Account: $SA"
echo "Location: $LOCATION"

# 1) Create resource group
az group create --name "$RG" --location "$LOCATION"

# 2) Create storage account (general purpose v2, standard LRS)
az storage account create   --name "$SA"   --resource-group "$RG"   --location "$LOCATION"   --sku Standard_LRS   --kind StorageV2

# 3) Enable static website hosting
az storage blob service-properties update   --account-name "$SA"   --static-website   --index-document index.html   --404-document 404.html

# 4) Get storage account key (first key)
ACCOUNT_KEY=$(az storage account keys list -g "$RG" -n "$SA" --query "[0].value" -o tsv)

# 5) Upload site files to the $web container
# Assumes there is a local ./site folder next to this script
az storage blob upload-batch   --account-name "$SA"   --account-key "$ACCOUNT_KEY"   -s ./site   -d '$web'   --no-progress

# 6) Get the web endpoint
ENDPOINT=$(az storage account show -n "$SA" -g "$RG" --query "primaryEndpoints.web" -o tsv)
echo "Static website deployed! URL: $ENDPOINT"

# Output an example curl to verify
echo "Example: curl -I $ENDPOINT"