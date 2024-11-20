#!/bin/sh

infrastructure_version=terraform  # options: terraform / bicep
project_type=classical  # options: classical / cv / nlp
mlops_version=aml-cli-v2  # options: aml-cli-v2 / python-sdk-v1 / python-sdk-v2 / rai-aml-cli-v2
orchestration=azure-devops  # options: github-actions / azure-devops
git_folder_location='path/to/local/root/folder'  # replace with the local root folder location where you want to create the project folder
project_name=project-name  # replace with your project name
github_org_name=organization-name  # replace with your GitHub Organization name
project_template_github_url=https://github.com/azure/mlops-project-template  # replace with the url for the project template for your organization or leave for demo purposes

env_path="mlops-v2/.env"

# Check if .env file exists
if [ -f "$env_path" ]; then
    echo "Reading credentials from .env file..."

    # Read Dev environment variables
    clientId_dev=$(grep '^clientId=' $env_path | sed -n '1p' | cut -d '=' -f2-)
    clientSecret_dev=$(grep '^clientSecret=' $env_path | sed -n '1p' | cut -d '=' -f2-)
    subscriptionId_dev=$(grep '^subscriptionId=' $env_path | sed -n '1p' | cut -d '=' -f2-)
    tenantId_dev=$(grep '^tenantId=' $env_path | sed -n '1p' | cut -d '=' -f2-)

    # Read Prod environment variables
    clientId_prod=$(grep '^clientId=' $env_path | sed -n '2p' | cut -d '=' -f2-)
    clientSecret_prod=$(grep '^clientSecret=' $env_path | sed -n '2p' | cut -d '=' -f2-)
    subscriptionId_prod=$(grep '^subscriptionId=' $env_path | sed -n '2p' | cut -d '=' -f2-)
    tenantId_prod=$(grep '^tenantId=' $env_path | sed -n '2p' | cut -d '=' -f2-)
else
    echo ".env file not found!"
    exit 1
fi

# Create JSON object for AZURE_CREDENTIALS_DEV
AZURE_CREDENTIALS_DEV=$(cat <<EOF
{
  "clientId": "$clientId_dev",
  "clientSecret": "$clientSecret_dev",
  "subscriptionId": "$subscriptionId_dev",
  "tenantId": "$tenantId_dev",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
EOF
)

# Create JSON object for AZURE_CREDENTIALS_PROD
AZURE_CREDENTIALS_PROD=$(cat <<EOF
{
  "clientId": "$clientId_prod",
  "clientSecret": "$clientSecret_prod",
  "subscriptionId": "$subscriptionId_prod",
  "tenantId": "$tenantId_prod",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
EOF
)

# Output to verify (optional)
echo "AZURE_CREDENTIALS_DEV = $AZURE_CREDENTIALS_DEV"
echo "AZURE_CREDENTIALS_PROD = $AZURE_CREDENTIALS_PROD"

cd $git_folder_location

# Clone MLOps Project Template Repository
git clone \
    --branch 'main' \
    --depth 1 \
    --filter=blob:none \
    --sparse \
    $project_template_github_url \
    $project_name

cd $project_name

git sparse-checkout init --cone
git sparse-checkout set .github/ infrastructure/$infrastructure_version $project_type/$mlops_version

# Move files to appropiate level
mv $project_type/$mlops_version/data-science data-science
mv $project_type/$mlops_version/mlops mlops
mv $project_type/$mlops_version/data data

if [[ "$mlops_version" == "python-sdk-v1" ]]
then
  echo "mlops_version=python-sdk-v1"
  mv $project_type/$mlops_version/config-aml.yml config-aml.yml
fi
rm -rf $project_type

mv infrastructure/$infrastructure_version $infrastructure_version
rm -rf infrastructure
# Rename to infrastructure
mv $infrastructure_version infrastructure

if [[ "$orchestration" == "github-actions" ]]
then
  echo "github-actions"
  rm -rf mlops/devops-pipelines
  mkdir -p .github/workflows/
  mv mlops/github-actions/* .github/workflows/
  rm -rf mlops/github-actions

  mv infrastructure/github-actions/* .github/workflows/
  rm -rf infrastructure/devops-pipelines
  rm -rf infrastructure/github-actions
fi

if [[ "$orchestration" == "azure-devops" ]]
then
  echo "azure-devops"
  rm -rf mlops/github-actions
  rm -rf infrastructure/github-actions
fi

# Upload to custom repository in GitHub
rm -rf .git
git init -b main

gh repo create $github_org_name/$project_name --private

git remote add origin git@github.com:$github_org_name/$project_name.git
git add . && git commit -m 'initial commit'
git push --set-upstream origin main

# Add GitHub Action Secrets
gh secret set AZURE_CREDENTIALS_DEV -b"$AZURE_CREDENTIALS_DEV"
gh secret set AZURE_CREDENTIALS_PROD -b"$AZURE_CREDENTIALS_PROD"
