# Soccer API - Azure Container Deployment

Un servidor MCP (Model Context Protocol) que proporciona datos de fútbol en tiempo real usando Azure Container Registry y Azure App Service.

## 📁 Estructura del Proyecto

```
├── src/                          # Código fuente de la aplicación
│   ├── __init__.py              # Inicialización del paquete
│   ├── main.py                  # Servidor MCP principal
│   └── api.py                   # Cliente API para datos deportivos
├── infrastructure/              # Infraestructura como código (IaC)
│   ├── main.bicep              # Template Bicep para recursos Azure
│   └── main.parameters.json    # Parámetros de configuración
├── scripts/                     # Scripts de automatización
│   ├── deploy.bat              # Script de despliegue (Windows Batch)
│   └── deploy.ps1              # Script de despliegue (PowerShell)
├── docs/                       # Documentación
│   └── README.md               # Documentación detallada
├── app.py                      # Punto de entrada principal
├── requirements.txt            # Dependencias Python
├── Dockerfile                  # Configuración Docker
└── README.md                   # Este archivo
```

## 🚀 Inicio Rápido

### 1. Configurar Credenciales
Edita `infrastructure/main.parameters.json` con tu API key:

```json
{
  "parameters": {
    "apiKey": {
      "value": "TU_API_KEY_AQUI"
    }
  }
}
```

### 2. Desplegar en Azure

**Opción A: Script Batch**
```batch
cd scripts
deploy.bat
```

**Opción B: Script PowerShell**
```powershell
cd scripts
.\deploy.ps1
```

### 3. Desarrollo Local

```bash
# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
set API_KEY=tu_api_key
set BASE_URL=https://api-football-v1.p.rapidapi.com/v3
set API_VERSION=api-football-v1.p.rapidapi.com

# Ejecutar aplicación
python app.py
```

## 🏗️ Arquitectura

- **Azure Container Registry (ACR)**: Almacena la imagen Docker
- **Azure App Service**: Hospeda la aplicación containerizada
- **FastMCP**: Framework para el servidor MCP
- **Docker**: Containerización de la aplicación

## 📚 Documentación

Para documentación detallada, consulta [docs/README.md](docs/README.md)

## 🔧 Tecnologías

- **Python 3.11** con FastMCP
- **Azure Bicep** para IaC
- **Docker** para containerización
- **Azure CLI** para despliegue

## 📝 Variables de Entorno

| Variable | Descripción | Requerido |
|----------|-------------|-----------|
| `API_KEY` | Clave API para el servicio deportivo | ✅ |
| `BASE_URL` | URL base de la API | ✅ |
| `API_VERSION` | Versión de la API | ✅ |
| `PORT` | Puerto del servidor (Azure lo configura automáticamente) | ❌ |

## 🏃‍♂️ Comandos Útiles

```bash
# Ver logs de la aplicación
az webapp log tail --resource-group rg-soccerapi-dev --name soccerapi-webapp

# Reiniciar la aplicación
az webapp restart --resource-group rg-soccerapi-dev --name soccerapi-webapp

# Eliminar todos los recursos
az group delete --name rg-soccerapi-dev --yes --no-wait
```

## 📄 Licencia

Este proyecto es para propósitos educativos y de demostración.