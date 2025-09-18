
# Soccer API - Azure Deployment with GitHub Copilot Integration

This application is an MCP (Model Context Protocol) server that provides real-time football data using FastMCP and the [API-FOOTBALL](https://www.api-football.com/) external sports API. The project is designed for seamless integration with GitHub Copilot, enabling AI-powered code suggestions and automation throughout development and deployment.

## Project Structure

```
├── src/                          # Application source code
│   ├── __init__.py
│   ├── main.py                   # Main MCP server
│   └── api.py                    # API client for sports data
├── infrastructure/               # Infrastructure as Code (IaC)
│   ├── main.bicep                # Bicep template for Azure resources
│   └── main.parameters.json      # Deployment parameters
├── scripts/                      # Automation scripts
│   ├── deploy.bat                # Windows Batch deployment script
│   └── deploy.ps1                # PowerShell deployment script
├── docs/                         # Documentation
│   └── README.md                 # Detailed documentation
├── app.py                        # Main entry point
├── requirements.txt              # Python dependencies
├── Dockerfile                    # Docker configuration
└── README.md                     # This file
```

## Integration with GitHub Copilot

- **Copilot Usage:** The project is structured to maximize GitHub Copilot's capabilities for code completion, refactoring, and deployment automation.
- **Configuration Guidance:** Copilot can assist in editing configuration files, writing deployment scripts, and generating infrastructure code.
- **API Integration:** Copilot helps streamline the integration with the API-FOOTBALL service, including authentication and endpoint management.

## API Configuration

The application uses the [API-FOOTBALL](https://www.api-football.com/) service for sports data. To configure the API:

1. **Edit Credentials:**
   Update `infrastructure/main.parameters.json` with your API key and base URL:
   ```json
   {
     "apiKey": {
       "value": "YOUR_API_KEY_HERE"
     },
     "baseUrl": {
       "value": "https://api-football-v1.p.rapidapi.com/v3"
     },
     "apiVersion": {
       "value": "api-football-v1.p.rapidapi.com"
     }
   }
   ```

2. **Environment Variables:**
   Set the following environment variables for local development or deployment:
   - `API_KEY`: Your API-FOOTBALL key
   - `BASE_URL`: `https://api-football-v1.p.rapidapi.com/v3`
   - `API_VERSION`: `api-football-v1.p.rapidapi.com`

## Azure Deployment (Docker & AKS)

### Automated Deployment

- **Batch Script (Windows):**
  ```batch
  cd scripts
  deploy.bat
  ```

- **PowerShell Script:**
  ```powershell
  cd scripts
  .\deploy.ps1
  ```

### Manual Deployment Steps

1. **Login to Azure:**
   ```
   az login
   ```

2. **Create Resource Group:**
   ```
   az group create --name rg-soccerapi-dev --location "East US"
   ```

3. **Deploy Infrastructure:**
   ```
   az deployment group create --resource-group rg-soccerapi-dev --template-file infrastructure/main.bicep --parameters infrastructure/main.parameters.json
   ```

4. **Build and Push Docker Image:**
   ```
   docker build -t <ACR_LOGIN_SERVER>/soccerapi-api:latest .
   docker push <ACR_LOGIN_SERVER>/soccerapi-api:latest
   ```

5. **Restart Web App:**
   ```
   az webapp restart --resource-group rg-soccerapi-dev --name soccerapi-webapp
   ```

### Deploying with AKS (Azure Kubernetes Service)

- You can adapt the Bicep template and deployment scripts to provision AKS clusters and deploy the containerized application for scalable, managed orchestration.

## Endpoints

After deployment, the application will be available at `https://{app-name}-webapp.azurewebsites.net` with endpoints such as:
- `/health` — Health check endpoint
- MCP endpoints for sports data (see FastMCP implementation)

## Security Features

- Non-root user in Docker container
- Sensitive credentials managed via environment variables
- HTTPS enforced in Azure App Service
- Health check endpoint
- Production-ready Python optimizations

## Monitoring & Logs

- View logs:
  ```
  az webapp log tail --resource-group rg-soccerapi-dev --name soccerapi-webapp
  ```
- Access logs via Azure Portal: Go to App Service > "Log stream"

## Resource Cleanup

To delete all resources:
```
az group delete --name rg-soccerapi-dev --yes --no-wait
```


## MCP Server Configuration for Copilot

To enable Copilot to interact with your MCP server, configure the `.vscode/mcp.json` file in your project root. This file defines the MCP server endpoint for Copilot:

```json
{
  "servers": {
    "sports-mcp": {
      "type": "http",
      "url": "http://127.0.0.1:8000/mcp/"
    }
  }
}
```

**Instructions:**
- Place this file at `.vscode/mcp.json`.
- For local development, use `http://127.0.0.1:8000/mcp/` as the URL.
- For production, update the URL to your deployed server (e.g., Azure Web App or AKS endpoint).

This setup allows GitHub Copilot to send requests to your MCP server, enabling AI-powered features and real-time football data integration in your development workflow.

## Estimated Costs

- **App Service Plan B1:** ~$13.14/month
- **Azure Container Registry (Basic):** ~$5/month
- **Total:** ~$18-20/month

---

This README is optimized for GitHub Copilot workflows and Azure cloud deployment. For more details, see `docs/README.md`.