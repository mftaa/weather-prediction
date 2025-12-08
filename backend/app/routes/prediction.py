"""
AI prediction routes for weather forecasting
"""
from fastapi import APIRouter
from app.models import (
    HourlyPredictionRequest,
    DailyPredictionRequest,
    PredictionResponse,
    ModelInfoResponse
)
from app.services import (
    predict_hourly_weather,
    predict_daily_weather,
    get_model_info
)

router = APIRouter(prefix="/ai-prediction", tags=["AI Prediction"])

@router.post("/hourly", response_model=PredictionResponse)
def predict_hourly(request: HourlyPredictionRequest):
    """
    Predict hourly weather using AI model
    
    Example request:
    ```json
    {
        "day": 8,
        "month": 12,
        "year": 2025,
        "hour": 10,
        "num_hours": 24
    }
    ```
    """
    return predict_hourly_weather(request)

@router.post("/daily", response_model=PredictionResponse)
def predict_daily(request: DailyPredictionRequest):
    """
    Predict daily weather using AI model
    
    Example request:
    ```json
    {
        "day": 8,
        "month": 12,
        "year": 2025,
        "num_days": 3
    }
    ```
    """
    return predict_daily_weather(request)

@router.get("/model-info", response_model=ModelInfoResponse)
def model_info():
    """Get information about the loaded AI model"""
    return get_model_info()
