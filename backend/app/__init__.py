"""
FastAPI application factory and initialization
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.routes import api_router
from app.services import load_ai_model

def create_app() -> FastAPI:
    """
    Create and configure FastAPI application
    
    Returns:
        FastAPI: Configured application instance
    """
    # API metadata
    description = """
## 🌦️ Weather Prediction API

AI-powered weather forecasting system using Machine Learning.

### 🚀 Features

* **🔐 User Authentication** - Secure registration and login with OTP verification
* **🌡️ Weather Data Management** - Real-time weather data storage and retrieval
* **🤖 AI Predictions** - Machine learning-based weather forecasting
  * Hourly predictions (1-168 hours)
  * Daily predictions (1-30 days)
* **📊 Model Information** - Get details about the trained AI model

### 🧠 AI Model

* **Type**: Random Forest Ensemble
* **Version**: v4 Combined Model
* **Training Data**: Historical weather data from 2000-2024
* **Predictions**: Temperature, Humidity, Wind Speed, Pressure, Conditions

### 📚 API Documentation

* **Swagger UI**: `/docs` (this page)
* **ReDoc**: `/redoc` (alternative documentation)

### 🔗 Quick Links

* [GitHub Repository](https://github.com/mftaa/weather-prediction)
* [Model Training Notebook](../ml-models/model_training.ipynb)
    """
    
    # Create FastAPI app
    app = FastAPI(
        title="🌤️ " + settings.API_TITLE,
        version=settings.API_VERSION,
        description=description,
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_tags=[
            {
                "name": "Authentication",
                "description": "User registration, login, and OTP verification"
            },
            {
                "name": "Weather Data",
                "description": "Manage weather data and historical records"
            },
            {
                "name": "AI Prediction",
                "description": "🤖 AI-powered weather forecasting for hourly and daily predictions"
            }
        ]
    )
    
    # Configure CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=settings.CORS_CREDENTIALS,
        allow_methods=settings.CORS_METHODS,
        allow_headers=settings.CORS_HEADERS,
    )
    
    # Include API routes
    app.include_router(api_router)
    
    # Startup event: Load AI model
    @app.on_event("startup")
    async def startup_event():
        """Load AI model on application startup"""
        print("=" * 60)
        print(f"Starting {settings.API_TITLE} v{settings.API_VERSION}")
        print("=" * 60)
        load_ai_model()
        print("=" * 60)
        print(f"Server running on http://{settings.HOST}:{settings.PORT}")
        print(f"API Documentation: http://{settings.HOST}:{settings.PORT}/docs")
        print("=" * 60)
    
    # Root endpoint
    @app.get("/", tags=["Root"])
    def read_root():
        """API root endpoint"""
        return {
            "name": settings.API_TITLE,
            "version": settings.API_VERSION,
            "description": settings.API_DESCRIPTION,
            "docs": "/docs",
            "redoc": "/redoc"
        }
    
    # Health check endpoint
    @app.get("/health", tags=["Health"])
    def health_check():
        """Health check endpoint"""
        return {
            "status": "healthy",
            "version": settings.API_VERSION
        }
    
    return app
