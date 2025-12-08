"""
Authentication and user management service
"""
import asyncio
from typing import Optional, Dict
from fastapi import HTTPException
from app.core.database import get_cursor
from app.utils import hash_password, verify_password, generate_otp, send_otp_email
from app.models import UserCreate, UserLogin, UserUpdate
from app.core.config import settings

# In-memory OTP storage (consider using Redis in production)
otp_storage: Dict[str, str] = {}

async def remove_otp_after_timeout(email: str, timeout: int = settings.OTP_EXPIRY_SECONDS):
    """Remove OTP from storage after timeout"""
    await asyncio.sleep(timeout)
    if email in otp_storage:
        del otp_storage[email]
        print(f"OTP for {email} has expired and been removed")

async def generate_and_send_otp(email: str) -> dict:
    """
    Generate OTP and send via email
    
    Args:
        email: User email address
    
    Returns:
        dict: Response message
    """
    # Validate email format
    if '@' not in email or '.' not in email:
        raise HTTPException(status_code=400, detail="Invalid email format")
    
    # Generate OTP
    otp = generate_otp()
    otp_storage[email] = otp
    
    # Schedule OTP removal
    asyncio.create_task(remove_otp_after_timeout(email))
    
    # Send email
    send_otp_email(otp, email)
    print(f"OTP for {email} is: {otp}")
    
    # Store in database
    try:
        with get_cursor() as cursor:
            # Try update first
            query = "UPDATE otp SET otp=%s, createAt=CURRENT_TIMESTAMP WHERE email=%s"
            cursor.execute(query, (otp, email))
            
            # If no rows affected, insert new record
            if cursor.rowcount == 0:
                query = "INSERT INTO otp(email, otp) VALUES (%s, %s)"
                cursor.execute(query, (email, otp))
    except Exception as e:
        print(f"Error storing OTP in database: {e}")
        # Don't fail the request if database storage fails
    
    return {"message": "OTP generated successfully."}

def verify_otp(email: str, otp: int) -> bool:
    """
    Verify OTP for email
    
    Args:
        email: User email
        otp: OTP to verify
    
    Returns:
        bool: True if OTP is valid
    """
    # Check in-memory storage first
    if email in otp_storage and otp_storage[email] == str(otp):
        return True
    
    # Check database as fallback
    try:
        with get_cursor() as cursor:
            query = "SELECT otp FROM otp WHERE email=%s"
            cursor.execute(query, (email,))
            row = cursor.fetchone()
            if row and str(row[0]) == str(otp):
                return True
    except Exception as e:
        print(f"Error verifying OTP from database: {e}")
    
    return False

def create_user(user: UserCreate) -> dict:
    """
    Create a new user
    
    Args:
        user: User creation data
    
    Returns:
        dict: Status response
    """
    # Verify OTP
    if not verify_otp(user.email, user.otp):
        return {'status': 403, 'msg': 'OTP not matched'}
    
    # Hash password
    hashed_password = hash_password(user.password)
    
    # Insert user into database
    try:
        with get_cursor() as cursor:
            query = "INSERT INTO users (username, password, email, role) VALUES (%s, %s, %s, %s)"
            cursor.execute(query, (user.username, hashed_password, user.email, user.role))
        
        return {'status': 200, 'msg': 'User created successfully'}
    
    except Exception as e:
        print(f"Error creating user: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to create user: {str(e)}")

def authenticate_user(credentials: UserLogin) -> dict:
    """
    Authenticate user with username and password
    
    Args:
        credentials: Login credentials
    
    Returns:
        dict: Success message
    
    Raises:
        HTTPException: If authentication fails
    """
    try:
        with get_cursor() as cursor:
            cursor.execute(
                "SELECT password FROM users WHERE username = %s", 
                (credentials.username,)
            )
            result = cursor.fetchone()
            
            if not result:
                raise HTTPException(status_code=401, detail="Invalid username or password")
            
            db_password = result[0]
            
            if not verify_password(credentials.password, db_password):
                raise HTTPException(status_code=401, detail="Invalid username or password")
            
            return {"message": "Login successful"}
    
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error during authentication: {e}")
        raise HTTPException(status_code=500, detail="Authentication failed")

def get_user_info(username: str) -> Optional[dict]:
    """
    Get user information by username
    
    Args:
        username: Username to lookup
    
    Returns:
        dict: User info or empty dict if not found
    """
    try:
        with get_cursor() as cursor:
            query = "SELECT username, email FROM users WHERE username=%s"
            cursor.execute(query, (username,))
            row = cursor.fetchone()
            
            if row:
                return {
                    "username": row[0],
                    "email": row[1],
                }
            return {}
    
    except Exception as e:
        print(f"Error getting user info: {e}")
        return {}

def reset_password(user_update: UserUpdate) -> dict:
    """
    Reset user password using OTP verification
    
    Args:
        user_update: User update data with new password and OTP
    
    Returns:
        dict: Status response
    """
    # Verify OTP
    if not verify_otp(user_update.email, user_update.otp):
        return {'status': 403, 'msg': 'OTP not matched'}
    
    # Hash new password
    hashed_password = hash_password(user_update.password)
    
    # Update password in database
    try:
        with get_cursor() as cursor:
            query = "UPDATE users SET password=%s WHERE email=%s"
            cursor.execute(query, (hashed_password, user_update.email))
        
        return {'status': 200, 'msg': 'Password updated successfully'}
    
    except Exception as e:
        print(f"Error resetting password: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to reset password: {str(e)}")
