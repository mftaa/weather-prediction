"""
Pydantic models/schemas for request and response validation
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime

# ============== User Models ==============
class UserBase(BaseModel):
    """Base user model"""
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr

class UserCreate(UserBase):
    """User creation model"""
    password: str = Field(..., min_length=6)
    role: str = Field(default="user")
    otp: int = Field(..., ge=100000, le=999999)

class UserLogin(BaseModel):
    """User login model"""
    username: str
    password: str

class UserUpdate(BaseModel):
    """User update model"""
    password: str = Field(..., min_length=6)
    email: EmailStr
    otp: int = Field(..., ge=100000, le=999999)

class UserResponse(BaseModel):
    """User response model"""
    username: str
    email: str

# ============== OTP Models ==============
class OTPRequest(BaseModel):
    """OTP generation request"""
    email: EmailStr

class OTPResponse(BaseModel):
    """OTP generation response"""
    message: str

# ============== Weather Data Models ==============
class WeatherDataCreate(BaseModel):
    """Weather data creation model"""
    temp: Optional[float] = 0.0
    humidity: Optional[float] = 0.0
    isRaining: Optional[int] = 0
    lightIntensity: Optional[float] = 0.0
    windSpeed: Optional[float] = 0.0
    pressure: Optional[float] = 0.0

class WeatherDataResponse(BaseModel):
    """Weather data response model"""
    id: int
    temp: float
    humidity: float
    isRaining: int
    lightIntensity: float
    windSpeed: float
    airPressure: float

# ============== AI Prediction Models ==============
class HourlyPredictionRequest(BaseModel):
    """Request model untuk prediksi cuaca per jam"""
    model_config = {
        "json_schema_extra": {
            "examples": [{
                "day": 8,
                "month": 12,
                "year": 2025,
                "hour": 14,
                "num_hours": 24
            }]
        }
    }
    
    day: int = Field(..., ge=1, le=31, description="Day of month (1-31)")
    month: int = Field(..., ge=1, le=12, description="Month (1-12)")
    year: int = Field(..., ge=2000, description="Year (e.g., 2025)")
    hour: int = Field(default=0, ge=0, le=23, description="Starting hour (0-23)")
    num_hours: int = Field(default=24, ge=1, le=168, description="Number of hours to predict (1-168)")

class DailyPredictionRequest(BaseModel):
    """Request model untuk prediksi cuaca harian"""
    model_config = {
        "json_schema_extra": {
            "examples": [{
                "day": 8,
                "month": 12,
                "year": 2025,
                "num_days": 7
            }]
        }
    }
    
    day: int = Field(..., ge=1, le=31, description="Starting day of month (1-31)")
    month: int = Field(..., ge=1, le=12, description="Month (1-12)")
    year: int = Field(..., ge=2000, description="Year (e.g., 2025)")
    num_days: int = Field(default=3, ge=1, le=30, description="Number of days to predict (1-30)")

class HourlyPredictionData(BaseModel):
    """Single hourly prediction data"""
    datetime: str
    date_formatted: str
    conditions: str
    temp: float
    humidity: float
    windspeed: float
    sealevelpressure: float

class DailyPredictionData(BaseModel):
    """Single daily prediction data"""
    date: str
    conditions: str
    temp_min: float
    temp_max: float
    temp_mean: float
    humidity_avg: float
    windspeed_avg: float
    pressure_avg: float

class PredictionResponse(BaseModel):
    """Generic prediction response"""
    model_config = {"protected_namespaces": ()}
    
    status: int
    message: str
    model_version: str
    data: List[dict]

class ModelInfoResponse(BaseModel):
    """AI Model information response"""
    model_config = {"protected_namespaces": ()}
    
    status: int
    model_loaded: bool
    version: Optional[str] = None
    trained_date: Optional[str] = None
    hourly_features: Optional[List[str]] = None
    hourly_targets: Optional[List[str]] = None
    daily_features: Optional[List[str]] = None
    daily_targets: Optional[List[str]] = None

# ============== Generic Response Models ==============
class StatusResponse(BaseModel):
    """Generic status response"""
    status: int
    msg: Optional[str] = None
    message: Optional[str] = None

class MessageResponse(BaseModel):
    """Generic message response"""
    message: str
