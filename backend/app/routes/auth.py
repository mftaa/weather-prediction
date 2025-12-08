"""
Authentication and user management routes
"""
from fastapi import APIRouter, HTTPException
from app.models import (
    UserCreate, UserLogin, UserUpdate, UserResponse,
    OTPRequest, OTPResponse, StatusResponse, MessageResponse
)
from app.services import (
    generate_and_send_otp,
    create_user,
    authenticate_user,
    get_user_info,
    reset_password
)

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/generate-otp", response_model=OTPResponse)
async def generate_otp_endpoint(request: OTPRequest):
    """Generate and send OTP to email"""
    return await generate_and_send_otp(request.email)

@router.post("/register", response_model=StatusResponse)
def register_user(user: UserCreate):
    """Register a new user with OTP verification"""
    return create_user(user)

@router.post("/login", response_model=MessageResponse)
async def login(credentials: UserLogin):
    """Authenticate user with username and password"""
    return authenticate_user(credentials)

@router.get("/user-info", response_model=UserResponse)
def get_user(username: str):
    """Get user information by username"""
    user_info = get_user_info(username)
    if not user_info:
        raise HTTPException(status_code=404, detail="User not found")
    return user_info

@router.post("/forgot-password", response_model=StatusResponse)
def forgot_password(user_update: UserUpdate):
    """Reset password using OTP verification"""
    return reset_password(user_update)

@router.options("/")
async def options_auth():
    """Handle OPTIONS request for CORS"""
    return {"allow": "GET, POST, PUT, DELETE, OPTIONS"}
