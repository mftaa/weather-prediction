"""
Routes package initialization
"""
from fastapi import APIRouter
from app.routes import auth, weather, prediction

# Create main API router
api_router = APIRouter()

# Include all route modules
api_router.include_router(auth.router)
api_router.include_router(weather.router)
api_router.include_router(prediction.router)

__all__ = ['api_router']
