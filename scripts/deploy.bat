@echo off
REM Script for deploying the Soccer API to Azure using ACR and Bicep
REM Make sure you have Azure CLI installed and are logged in

echo ========================================
echo    Soccer API Azure Deployment Script
echo ========================================

REM Configuration variables - Modify these as needed
set RESOURCE_GROUP_NAME=rg-soccerapi-dev
set APP_NAME=soccerapi
set LOCATION=East US
set ACR_NAME=
set IMAGE_NAME=soccerapi-api

REM Check if logged in to Azure
echo Checking Azure login status...
az account show >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Please login to Azure first: az login
    exit /b 1
)

REM Create resource group if it doesn't exist
echo Creating resource group if it doesn't exist...
az group create --name %RESOURCE_GROUP_NAME% --location "%LOCATION%"

# Deploy Bicep template
echo Deploying infrastructure with Bicep...
az deployment group create ^
  --resource-group %RESOURCE_GROUP_NAME% ^
  --template-file ../infrastructure/main.bicep ^
  --parameters ../infrastructure/main.parameters.json ^
  --parameters appName=%APP_NAME%

if %ERRORLEVEL% neq 0 (
    echo Failed to deploy infrastructure
    exit /b 1
)

REM Get ACR name from deployment
echo Getting ACR information...
for /f "tokens=*" %%i in ('az deployment group show --resource-group %RESOURCE_GROUP_NAME% --name main --query properties.outputs.acrName.value -o tsv') do set ACR_NAME=%%i
for /f "tokens=*" %%i in ('az deployment group show --resource-group %RESOURCE_GROUP_NAME% --name main --query properties.outputs.acrLoginServer.value -o tsv') do set ACR_LOGIN_SERVER=%%i

echo ACR Name: %ACR_NAME%
echo ACR Login Server: %ACR_LOGIN_SERVER%

REM Login to ACR
echo Logging into Azure Container Registry...
az acr login --name %ACR_NAME%

REM Build and push Docker image
echo Building Docker image...
docker build -t %ACR_LOGIN_SERVER%/%IMAGE_NAME%:latest .

echo Pushing image to ACR...
docker push %ACR_LOGIN_SERVER%/%IMAGE_NAME%:latest

REM Restart the web app to use the new image
echo Restarting web app...
az webapp restart --resource-group %RESOURCE_GROUP_NAME% --name %APP_NAME%-webapp

REM Get the web app URL
for /f "tokens=*" %%i in ('az deployment group show --resource-group %RESOURCE_GROUP_NAME% --name main --query properties.outputs.webAppUrl.value -o tsv') do set WEB_APP_URL=%%i

echo ========================================
echo    Deployment completed successfully!
echo ========================================
echo Web App URL: %WEB_APP_URL%
echo ACR Name: %ACR_NAME%
echo Resource Group: %RESOURCE_GROUP_NAME%
echo.
echo Don't forget to:
echo 1. Update main.parameters.json with your actual API credentials
echo 2. Test the health endpoint: %WEB_APP_URL%/health
echo ========================================