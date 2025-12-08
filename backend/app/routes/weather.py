"""
Weather data management routes
"""
from fastapi import APIRouter, Query
from typing import List
from app.models import WeatherDataCreate, WeatherDataResponse, StatusResponse
from app.services import (
    get_last_weather_data,
    get_line_chart_data,
    create_weather_data
)

router = APIRouter(prefix="/weather-data", tags=["Weather Data"])

@router.get("/last", response_model=WeatherDataResponse)
def get_last_data(location: str = Query(default="Gazipur")):
    """Get the most recent weather data for a location"""
    data = get_last_weather_data(location)
    if not data:
        return {}
    return data

@router.get("/line-chart", response_model=List[float])
def get_chart_data(location: str = Query(default="Gazipur"), limit: int = Query(default=10)):
    """Get wind speed data for line chart"""
    return get_line_chart_data(location, limit)

@router.get("/create", response_model=StatusResponse)
def create_data(
    temp: float = Query(default=0.0),
    humidity: float = Query(default=0.0),
    isRaining: int = Query(default=0),
    lightIntensity: float = Query(default=0.0),
    windSpeed: float = Query(default=0.0),
    pressure: float = Query(default=0.0),
):
    """Create new weather data record (legacy endpoint using GET)"""
    data = WeatherDataCreate(
        temp=temp,
        humidity=humidity,
        isRaining=isRaining,
        lightIntensity=lightIntensity,
        windSpeed=windSpeed,
        pressure=pressure
    )
    return create_weather_data(data)

@router.post("/create", response_model=StatusResponse)
def create_data_post(data: WeatherDataCreate):
    """Create new weather data record (recommended POST method)"""
    return create_weather_data(data)
