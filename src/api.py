import os
import requests

class API:
    """
    API client for interacting with a sports data provider.

    This class handles authentication, request headers, and provides asynchronous methods
    to fetch soccer team information, league details, and team standings.

    Environment Variables:
        API_KEY (str): The API key for authentication.
        BASE_URL (str): The base URL of the sports API.
        API_VERSION (str): The API version or host identifier.

    Raises:
        ValueError: If required environment variables are not set.
    """
    
    def __init__(self):
        self.apiKey = os.getenv("API_KEY") 
        self.baseUrl = os.getenv("BASE_URL")
        self.apiVersion = os.getenv("API_VERSION")
        
        #Validate environment variables
        if not all([self.apiKey, self.baseUrl, self.apiVersion]):
            raise ValueError("API_KEY, BASE_URL, and API_VERSION must be set in environment variables.")
        
        self.headers = {
            "x-rapidapi-host": self.apiVersion,
            "x-rapidapi-key": self.apiKey
        }
    
    async def get_team_info(self, name: str):
        # Get team info from the API
        try:
            response = requests.get(self.baseUrl + f"/teams", headers=self.headers, params={"name": name})
            if response.status_code == 200:
                return response.json()
            return {"error": "Failed to fetch team info"}
        except Exception as e:
            return {"error": str(e)}
        
    async def get_leagues_info(self, name: str):
        # Get leagues info from the API
        try:
            response = requests.get(self.baseUrl + f"/leagues", headers=self.headers,params={"name": name})
            if response.status_code == 200:
                return response.json()
            return {"error": "Failed to fetch leagues info"}
        except Exception as e:
            return {"error": str(e)}
    
    async def get_team_standings(self, team_id: int, league_id: int, season: int):
        # Get team standings from the API
        try:
            response = requests.get(self.baseUrl + f"/standings", headers=self.headers,params={"team": team_id, "league": league_id, "season": season})
            if response.status_code == 200:
                return response.json()
            return {"error": "Failed to fetch team standings"}
        except Exception as e:
            return {"error": str(e)}