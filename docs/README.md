# Soccer API - Azure Deployment

Esta aplicación es un servidor MCP (Model Context Protocol) que proporciona datos de fútbol en tiempo real utilizando FastMCP y una API externa de deportes.

## Arquitectura

- **Azure Container Registry (ACR)**: Para almacenar la imagen Docker
- **Azure App Service (Web App for Containers)**: Para hospedar la aplicación
- **Docker**: Para containerización
- **Bicep**: Para Infrastructure as Code (IaC)

## Prerrequisitos

1. **Azure CLI** instalado y configurado
2. **Docker** instalado
3. **Cuenta de Azure** con permisos para crear recursos
4. **API Key** para la API de deportes (RapidAPI)

## Configuración

### 1. Configurar credenciales de API

Edita el archivo `main.parameters.json` y actualiza los siguientes valores:

```json
{
  "apiKey": {
    "value": "TU_API_KEY_AQUI"
  },
  "baseUrl": {
    "value": "https://api-football-v1.p.rapidapi.com/v3"
  },
  "apiVersion": {
    "value": "api-football-v1.p.rapidapi.com"
  }
}
```

### 2. Personalizar configuración (opcional)

En `main.parameters.json` puedes modificar:
- `appName`: Nombre de la aplicación (por defecto: "soccerapi")
- `location`: Región de Azure (por defecto: "East US")
- `appServicePlanSku`: SKU del App Service Plan (por defecto: "B1")

## Despliegue

### Opción 1: Script Batch (Windows)

```batch
deploy.bat
```

### Opción 2: Script PowerShell

```powershell
.\deploy.ps1
```

### Opción 3: Manual

1. **Login a Azure**:
   ```bash
   az login
   ```

2. **Crear grupo de recursos**:
   ```bash
   az group create --name rg-soccerapi-dev --location "East US"
   ```

3. **Desplegar infraestructura**:
   ```bash
   az deployment group create \
     --resource-group rg-soccerapi-dev \
     --template-file main.bicep \
     --parameters main.parameters.json
   ```

4. **Obtener información del ACR**:
   ```bash
   ACR_NAME=$(az deployment group show --resource-group rg-soccerapi-dev --name main --query properties.outputs.acrName.value -o tsv)
   ACR_LOGIN_SERVER=$(az deployment group show --resource-group rg-soccerapi-dev --name main --query properties.outputs.acrLoginServer.value -o tsv)
   ```

5. **Login al ACR**:
   ```bash
   az acr login --name $ACR_NAME
   ```

6. **Build y push de la imagen**:
   ```bash
   docker build -t $ACR_LOGIN_SERVER/soccerapi-api:latest .
   docker push $ACR_LOGIN_SERVER/soccerapi-api:latest
   ```

7. **Reiniciar la web app**:
   ```bash
   az webapp restart --resource-group rg-soccerapi-dev --name soccerapi-webapp
   ```

## Estructura de archivos

```
├── main.py                    # Aplicación principal con servidor MCP
├── api.py                     # Cliente API para datos deportivos
├── requirements.txt           # Dependencias Python
├── Dockerfile                # Configuración Docker optimizada para producción
├── main.bicep                # Template Bicep para infraestructura Azure
├── main.parameters.json      # Parámetros para el deployment
├── deploy.bat                # Script de despliegue (Batch)
├── deploy.ps1                # Script de despliegue (PowerShell)
└── README.md                 # Este archivo
```

## Endpoints disponibles

Después del despliegue, la aplicación estará disponible en `https://{app-name}-webapp.azurewebsites.net` con los siguientes endpoints:

- `/health` - Health check endpoint
- Endpoints MCP para datos deportivos (según la implementación de FastMCP)

## Características de seguridad implementadas

1. **Usuario no-root** en el contenedor Docker
2. **Variables de entorno** para credenciales sensibles
3. **HTTPS obligatorio** en Azure App Service
4. **Health check** configurado
5. **Optimizaciones Python** para producción

## Monitoreo y logs

Para ver los logs de la aplicación:

```bash
az webapp log tail --resource-group rg-soccerapi-dev --name soccerapi-webapp
```

Para acceder a los logs en Azure Portal:
1. Ve al App Service en Azure Portal
2. Selecciona "Log stream" en el menú lateral

## Troubleshooting

### La aplicación no inicia
- Verifica que las variables de entorno API_KEY, BASE_URL, y API_VERSION estén configuradas
- Revisa los logs de la aplicación

### Error de autenticación con ACR
- Asegúrate de estar logueado: `az acr login --name {acr-name}`
- Verifica que el ACR tenga habilitado el admin user

### Problemas con Docker
- Asegúrate de que Docker esté ejecutándose
- Verifica que puedas hacer pull/push a otros registros

## Limpieza de recursos

Para eliminar todos los recursos creados:

```bash
az group delete --name rg-soccerapi-dev --yes --no-wait
```

## Costos estimados

Con la configuración por defecto (App Service Plan B1):
- **App Service Plan B1**: ~$13.14/mes
- **Azure Container Registry (Basic)**: ~$5/mes
- **Total aproximado**: ~$18-20/mes

## Notas adicionales

- La aplicación usa el puerto 8000 internamente
- Azure App Service maneja automáticamente el puerto externo (80/443)
- El health check está configurado para ejecutarse cada 30 segundos
- Las credenciales del ACR se manejan automáticamente por Azure