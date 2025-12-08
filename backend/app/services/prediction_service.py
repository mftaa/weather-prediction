"""
AI Prediction service for weather forecasting
"""
import joblib
import pandas as pd
from datetime import datetime, timedelta
from typing import Optional, List
from fastapi import HTTPException
from app.core.config import settings
from app.models import HourlyPredictionRequest, DailyPredictionRequest

# Global AI model instance
ai_model: Optional[dict] = None

def load_ai_model() -> bool:
    """
    Load AI model from file
    
    Returns:
        bool: True if model loaded successfully
    """
    global ai_model
    
    try:
        ai_model = joblib.load(settings.MODEL_PATH)
        print(f"✓ AI Model loaded successfully from {settings.MODEL_PATH}")
        return True
    except Exception as e:
        print(f"✗ Failed to load AI model: {e}")
        print(f"  Model path: {settings.MODEL_PATH}")
        return False

def get_model_info() -> dict:
    """
    Get information about the loaded AI model
    
    Returns:
        dict: Model information
    """
    if ai_model is None:
        return {
            'status': 400,
            'message': 'Model not loaded',
            'model_loaded': False
        }
    
    return {
        'status': 200,
        'model_loaded': True,
        'version': ai_model.get('version', 'unknown'),
        'trained_date': ai_model.get('trained_date', 'unknown'),
        'hourly_features': ai_model['hourly']['feature_columns'],
        'hourly_targets': ai_model['hourly']['target_regression'],
        'daily_features': ai_model['daily']['feature_columns'],
        'daily_targets': ai_model['daily']['target_regression'],
    }

def predict_hourly_weather(request: HourlyPredictionRequest) -> dict:
    """
    Predict hourly weather using AI model
    
    Args:
        request: Hourly prediction request parameters
    
    Returns:
        dict: Prediction results
    
    Raises:
        HTTPException: If model not loaded or prediction fails
    """
    if ai_model is None:
        raise HTTPException(status_code=500, detail="AI Model is not loaded")
    
    try:
        # Validate input
        if not (1 <= request.day <= 31 and 1 <= request.month <= 12 and request.year >= 2000):
            raise HTTPException(status_code=400, detail="Invalid date input")
        
        # Create start datetime
        start_date = datetime(request.year, request.month, request.day, request.hour or 0)
        
        # Generate future datetimes
        future_dates = [start_date + timedelta(hours=i) for i in range(request.num_hours)]
        
        # Create input DataFrame
        X_input = pd.DataFrame({
            'day': [d.day for d in future_dates],
            'month': [d.month for d in future_dates],
            'year': [d.year for d in future_dates],
            'hour': [d.hour for d in future_dates]
        })
        
        # Ensure column order matches model
        hourly_features = ai_model['hourly']['feature_columns']
        X_input = X_input[hourly_features]
        
        # Make predictions
        h_reg = ai_model['hourly']['regressor']
        h_clf = ai_model['hourly']['classifier']
        
        # Predict numerical values
        pred_reg = h_reg.predict(X_input)
        
        # Predict conditions (encoded)
        pred_clf_encoded = h_clf.predict(X_input)
        
        # Decode conditions
        label_encoder = ai_model['label_encoder_hourly']
        pred_conditions = label_encoder.inverse_transform(pred_clf_encoded.astype(int))
        
        # Format results
        results = []
        target_cols = ai_model['hourly']['target_regression']
        
        for i, future_date in enumerate(future_dates):
            result = {
                'datetime': future_date.isoformat(),
                'date_formatted': future_date.strftime('%Y-%m-%d %H:%M'),
                'conditions': str(pred_conditions[i]),
            }
            
            # Add predicted numerical values
            for j, col in enumerate(target_cols):
                result[col] = float(round(pred_reg[i][j], 2))
            
            results.append(result)
        
        return {
            'status': 200,
            'message': 'Hourly prediction successful',
            'model_version': ai_model.get('version', 'unknown'),
            'data': results
        }
    
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error in hourly prediction: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

def predict_daily_weather(request: DailyPredictionRequest) -> dict:
    """
    Predict daily weather using AI model
    
    Args:
        request: Daily prediction request parameters
    
    Returns:
        dict: Prediction results
    
    Raises:
        HTTPException: If model not loaded or prediction fails
    """
    if ai_model is None:
        raise HTTPException(status_code=500, detail="AI Model is not loaded")
    
    try:
        # Validate input
        if not (1 <= request.day <= 31 and 1 <= request.month <= 12 and request.year >= 2000):
            raise HTTPException(status_code=400, detail="Invalid date input")
        
        # Create start date
        start_date = datetime(request.year, request.month, request.day)
        
        # Generate future dates
        future_dates = [start_date + timedelta(days=i) for i in range(request.num_days)]
        
        # Create input DataFrame
        X_input = pd.DataFrame({
            'day': [d.day for d in future_dates],
            'month': [d.month for d in future_dates],
            'year': [d.year for d in future_dates],
        })
        
        # Ensure column order matches model
        daily_features = ai_model['daily']['feature_columns']
        X_input = X_input[daily_features]
        
        # Make predictions
        d_reg = ai_model['daily']['regressor']
        d_clf = ai_model['daily']['classifier']
        
        # Predict numerical values
        pred_reg = d_reg.predict(X_input)
        
        # Predict conditions (encoded)
        pred_clf_encoded = d_clf.predict(X_input)
        
        # Decode conditions
        label_encoder = ai_model['label_encoder_daily']
        pred_conditions = label_encoder.inverse_transform(pred_clf_encoded.astype(int))
        
        # Format results
        results = []
        target_cols = ai_model['daily']['target_regression']
        
        for i, future_date in enumerate(future_dates):
            result = {
                'date': future_date.strftime('%Y-%m-%d'),
                'conditions': str(pred_conditions[i]),
            }
            
            # Add predicted numerical values
            for j, col in enumerate(target_cols):
                result[col] = float(round(pred_reg[i][j], 2))
            
            results.append(result)
        
        return {
            'status': 200,
            'message': 'Daily prediction successful',
            'model_version': ai_model.get('version', 'unknown'),
            'data': results
        }
    
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error in daily prediction: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")
