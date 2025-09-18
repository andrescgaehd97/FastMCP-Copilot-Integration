@description('Name of the application')
param appName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('SKU for the App Service Plan')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1V2'
  'P2V2'
  'P3V2'
])
param appServicePlanSku string = 'B1'

@description('API Key for the Sports API')
@secure()
param apiKey string

@description('Base URL for the Sports API')
param baseUrl string

@description('API Version for the Sports API')
param apiVersion string

@description('Container image tag')
param imageTag string = 'latest'

// Variables
var acrName = '${appName}acr${uniqueString(resourceGroup().id)}'
var appServicePlanName = '${appName}-plan'
var webAppName = '${appName}-webapp'
var containerImageName = '${appName}-api'

// Azure Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Web App for Containers
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acr.properties.loginServer}/${containerImageName}:${imageTag}'
      appCommandLine: ''
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acr.properties.loginServer}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: acr.listCredentials().username
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: acr.listCredentials().passwords[0].value
        }
        {
          name: 'API_KEY'
          value: apiKey
        }
        {
          name: 'BASE_URL'
          value: baseUrl
        }
        {
          name: 'API_VERSION'
          value: apiVersion
        }
        {
          name: 'PORT'
          value: '8000'
        }
        {
          name: 'PYTHONUNBUFFERED'
          value: '1'
        }
        {
          name: 'PYTHONDONTWRITEBYTECODE'
          value: '1'
        }
      ]
      healthCheckPath: '/health'
    }
    httpsOnly: true
  }
}

// Outputs
output acrName string = acr.name
output acrLoginServer string = acr.properties.loginServer
output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output resourceGroupName string = resourceGroup().name