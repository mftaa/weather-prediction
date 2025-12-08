"""
Services package initialization
"""
from app.services.auth_service import (
    generate_and_send_otp,
    create_user,
    authenticate_user,
    get_user_info,
    reset_password
)
from app.services.weather_service import (
    get_last_weather_data,
    get_line_chart_data,
    create_weather_data
)
from app.services.prediction_service import (
    load_ai_model,
    get_model_info,
    predict_hourly_weather,
    predict_daily_weather
)

__all__ = [
    'generate_and_send_otp',
    'create_user',
    'authenticate_user',
    'get_user_info',
    'reset_password',
    'get_last_weather_data',
    'get_line_chart_data',
    'create_weather_data',
    'load_ai_model',
    'get_model_info',
    'predict_hourly_weather',
    'predict_daily_weather'
]
