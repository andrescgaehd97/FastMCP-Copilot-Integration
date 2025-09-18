"""
# Program: main.py
# Description: MCP Server using Fast MCP Library with the objective of connecting to a Sports API and providing real-time sports data to clients.
"""
import os
import logging
from fastmcp import FastMCP
from .api import API

try:    
    logging.basicConfig(level=logging.INFO)
    server = FastMCP(name="SoccerAPI",)
    soccerAPI = API()

    @server.tool(name="health", description="Health check endpoint for the application.")
    async def health_check():
        """Health check endpoint for load balancers and monitoring."""
        return {"status": "healthy", "service": "SoccerAPI"}

    @server.tool(name="get_team_info", description="Fetches basic information about a specific soccer team based on its name.")
    async def get_team_info(name: str):
        if not isinstance(name, str) or not name.strip():
            raise ValueError("The 'name' parameter must be a non-empty string.")
        """"Fetches basic information about a specific soccer team based on its name."""
        # API call to fetch team info
        return await soccerAPI.get_team_info(name)
    
    @server.tool(name="get_leagues_info", description="Fetches information about soccer leagues based on their name.")
    async def get_leagues_info(name: str):
        if not isinstance(name, str) or not name.strip():
            return {"error": "Parameter 'name' must be a non-empty string."}

        """"Fetches information about soccer leagues based on their name."""
        # API call to fetch leagues info
        return await soccerAPI.get_leagues_info(name)
    
    @server.tool(name="get_team_standings", description="Fetches the current standings of a specific team in a given league and season.")
    async def get_team_standings(team_id: int, league_id: int, season: int):
        if not all(isinstance(x, int) and x > 0 for x in [team_id, league_id, season]):
            return {"error": "Parameters 'team_id', 'league_id', and 'season' must be positive integers."}
        """"Fetches the current standings of a specific team in a given league and season."""
        # API call to fetch team standings
        return await soccerAPI.get_team_standings(team_id, league_id, season)
    
except Exception as e:
    logging.error(f"Error during server setup: {e}")
    
def main():
    """Main function to start the server."""
    import asyncio
    # Get port from environment variable (Azure App Service uses this)
    port = int(os.getenv("PORT", 8000))
    
    asyncio.run(server.run_async(
        transport="http",
        host="0.0.0.0",  # Listen on all interfaces for Azure
        port=port
    ))

if __name__ == "__main__":
    main()