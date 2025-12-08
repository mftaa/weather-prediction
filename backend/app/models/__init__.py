"""
Models package initialization
"""
from app.models.schemas import (
    UserCreate, UserLogin, UserUpdate, UserResponse,
    OTPRequest, OTPResponse,
    WeatherDataCreate, WeatherDataResponse,
    HourlyPredictionRequest, DailyPredictionRequest,
    HourlyPredictionData, DailyPredictionData,
    PredictionResponse, ModelInfoResponse,
    StatusResponse, MessageResponse
)

__all__ = [
    'UserCreate', 'UserLogin', 'UserUpdate', 'UserResponse',
    'OTPRequest', 'OTPResponse',
    'WeatherDataCreate', 'WeatherDataResponse',
    'HourlyPredictionRequest', 'DailyPredictionRequest',
    'HourlyPredictionData', 'DailyPredictionData',
    'PredictionResponse', 'ModelInfoResponse',
    'StatusResponse', 'MessageResponse'
]
