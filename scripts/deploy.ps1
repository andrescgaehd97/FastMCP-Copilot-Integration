# Soccer API Azure Deployment Script (PowerShell)
# Make sure you have Azure CLI installed and are logged in

param(
    [string]$ResourceGroupName = "rg-soccerapi-dev",
    [string]$AppName = "soccerapi",
    [string]$Location = "East US",
    [string]$ImageName = "soccerapi-api"
)

Write-Host "========================================" -ForegroundColor Green
Write-Host "   Soccer API Azure Deployment Script" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Check if logged in to Azure
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
try {
    $account = az account show | ConvertFrom-Json
    Write-Host "Logged in as: $($account.user.name)" -ForegroundColor Green
} catch {
    Write-Error "Please login to Azure first: az login"
    exit 1
}

# Create resource group if it doesn't exist
Write-Host "Creating resource group if it doesn't exist..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

# Deploy Bicep template
Write-Host "Deploying infrastructure with Bicep..." -ForegroundColor Yellow
$deployResult = az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file ../infrastructure/main.bicep `
    --parameters ../infrastructure/main.parameters.json `
    --parameters appName=$AppName `
    --output json | ConvertFrom-Json

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to deploy infrastructure"
    exit 1
}

# Get ACR information from deployment outputs
$acrName = $deployResult.properties.outputs.acrName.value
$acrLoginServer = $deployResult.properties.outputs.acrLoginServer.value
$webAppUrl = $deployResult.properties.outputs.webAppUrl.value

Write-Host "ACR Name: $acrName" -ForegroundColor Green
Write-Host "ACR Login Server: $acrLoginServer" -ForegroundColor Green

# Login to ACR
Write-Host "Logging into Azure Container Registry..." -ForegroundColor Yellow
az acr login --name $acrName

# Build and push Docker image
Write-Host "Building Docker image..." -ForegroundColor Yellow
docker build -t "$acrLoginServer/${ImageName}:latest" .

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to build Docker image"
    exit 1
}

Write-Host "Pushing image to ACR..." -ForegroundColor Yellow
docker push "$acrLoginServer/${ImageName}:latest"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to push image to ACR"
    exit 1
}

# Restart the web app to use the new image
Write-Host "Restarting web app..." -ForegroundColor Yellow
az webapp restart --resource-group $ResourceGroupName --name "$AppName-webapp"

Write-Host "========================================" -ForegroundColor Green
Write-Host "   Deployment completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Web App URL: $webAppUrl" -ForegroundColor Cyan
Write-Host "ACR Name: $acrName" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Cyan
Write-Host ""
Write-Host "Don't forget to:" -ForegroundColor Yellow
Write-Host "1. Update main.parameters.json with your actual API credentials" -ForegroundColor Yellow
Write-Host "2. Test the health endpoint: $webAppUrl/health" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Green