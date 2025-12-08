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
    🌤️ Predict Hourly Weather Using AI Model
    
    Predicts weather conditions for the next N hours using Random Forest ensemble model.
    
    **Predictions include:**
    - 🌡️ Temperature (°C)
    - 💧 Humidity (%)
    - 💨 Wind Speed (km/h)
    - 🌊 Sea Level Pressure (hPa)
    - ☁️ Weather Conditions (Clear, Rain, Overcast, etc.)
    
    **Request Parameters:**
    - `day`: Day of month (1-31)
    - `month`: Month (1-12)
    - `year`: Year (e.g., 2025)
    - `hour`: Starting hour (0-23)
    - `num_hours`: Number of hours to predict (1-168)
    
    **Example Request:**
    ```json
    {
        "day": 8,
        "month": 12,
        "year": 2025,
        "hour": 10,
        "num_hours": 24
    }
    ```
    
    **Example Response:**
    ```json
    {
        "status": 200,
        "message": "Hourly prediction successful",
        "model_version": "v4_combined",
        "data": [
            {
                "date": "2025-12-08",
                "time": "10:00",
                "temp": 28.5,
                "humidity": 75.2,
                "windspeed": 12.3,
                "pressure": 1013.2,
                "conditions": "Partially cloudy"
            }
        ]
    }
    ```
    """
    return predict_hourly_weather(request)

@router.post("/daily", response_model=PredictionResponse)
def predict_daily(request: DailyPredictionRequest):
    """
    🌅 Predict Daily Weather Using AI Model
    
    Predicts daily weather conditions for the next N days using Random Forest ensemble model.
    
    **Predictions include:**
    - 🌡️ Temperature Max/Min/Average (°C)
    - 💧 Humidity (%)
    - 💨 Wind Speed (km/h)
    - 🌊 Sea Level Pressure (hPa)
    - ☁️ Weather Conditions (Clear, Rain, Overcast, etc.)
    
    **Request Parameters:**
    - `day`: Starting day of month (1-31)
    - `month`: Month (1-12)
    - `year`: Year (e.g., 2025)
    - `num_days`: Number of days to predict (1-30)
    
    **Example Request:**
    ```json
    {
        "day": 8,
        "month": 12,
        "year": 2025,
        "num_days": 7
    }
    ```
    
    **Example Response:**
    ```json
    {
        "status": 200,
        "message": "Daily prediction successful",
        "model_version": "v4_combined",
        "data": [
            {
                "date": "2025-12-08",
                "tempmax": 32.5,
                "tempmin": 24.1,
                "temp": 28.3,
                "humidity": 75.2,
                "windspeed": 12.3,
                "pressure": 1013.2,
                "conditions": "Partially cloudy"
            }
        ]
    }
    ```
    """
    return predict_daily_weather(request)

@router.get("/model-info", response_model=ModelInfoResponse)
def model_info():
    """
    📊 Get AI Model Information
    
    Returns detailed information about the loaded AI/ML model.
    
    **Response includes:**
    - ✅ Model loaded status
    - 📌 Model version
    - 📅 Training date
    - 📈 Feature names for hourly predictions
    - 📉 Target variables for hourly predictions
    - 📊 Feature names for daily predictions
    - 🎯 Target variables for daily predictions
    
    **Example Response:**
    ```json
    {
        "status": 200,
        "model_loaded": true,
        "version": "v4_combined_random_forest",
        "trained_date": "2024-11-15",
        "hourly_features": ["day", "month", "year", "hour"],
        "hourly_targets": ["temp", "humidity", "windspeed", "pressure", "conditions"],
        "daily_features": ["day", "month", "year"],
        "daily_targets": ["tempmax", "tempmin", "temp", "humidity", "windspeed", "pressure", "conditions"]
    }
    ```
    
    **Use cases:**
    - Verify model is loaded before making predictions
    - Check model version for debugging
    - Understand input/output structure for predictions
    """
    return get_model_info()
