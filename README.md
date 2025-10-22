# Temzz Cloud — Azure Static Website (GROUP 3)

This project demonstrates deploying a static website to **Azure Blob Storage static website hosting** using:
- Azure CLI (bash provisioning script `deploy.sh`)
- Optional GitHub Actions workflow that deploys on push to `main`.

## Contents
- `site/` — static site (index.html, about.html, service.html, css)
- `deploy.sh` — bash script to create resource group, storage account, enable static website, and upload files.
- `.github/workflows/azure-static-deploy.yml` — GitHub Actions workflow (requires GitHub Secrets).
- `README.md` — this file.

## Quick local steps (using your Azure Free account)
1. Install Azure CLI and login: `az login`
2. Make sure you are on the right subscription: `az account show`
3. Run the deployment script:
   ```bash
   ./deploy.sh my-resource-group temzzstatic123 westus
   ```
   The script will output the website URL when finished.

## GitHub Actions (automation)
Set the following repository secrets in GitHub:
- `AZURE_CREDENTIALS` — JSON output of a service principal with access to your subscription (see `az ad sp create-for-rbac --name "my-app" --sdk-auth`).
- `AZURE_RESOURCE_GROUP` — resource group name (e.g., `temzz-rg`)
- `STORAGE_ACCOUNT_NAME` — storage account name (e.g., `temzzstatic123`)

Push to `main` and the workflow will upload the `site/` folder to the `$web` container.

## How to get the live site URL from Azure CLI
```bash
az storage account show -n <STORAGE_ACCOUNT_NAME> -g <RESOURCE_GROUP> --query "primaryEndpoints.web" -o tsv
```

## Notes
- Storage account name must be globally unique and 3-24 lowercase letters and numbers only.
- The workflow and scripts intentionally retrieve the storage account key at runtime so you don't have to store account keys in GitHub secrets.
- For production, follow least-privilege principles when creating service principals.

