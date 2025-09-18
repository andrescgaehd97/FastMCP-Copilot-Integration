"""
Soccer API Package

This package contains the MCP server implementation for providing real-time soccer data.
"""

from .api import API
from .main import main

__all__ = ["API", "main"]