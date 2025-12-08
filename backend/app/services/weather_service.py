"""
Weather data service for managing sensor data
"""
from typing import Optional, List
from app.core.database import get_cursor
from app.models import WeatherDataCreate

def get_last_weather_data(location: str = "Gazipur") -> dict:
    """
    Get the most recent weather data for a location
    
    Args:
        location: Location name
    
    Returns:
        dict: Weather data or empty dict if not found
    """
    try:
        with get_cursor() as cursor:
            query = "SELECT * FROM weather_data WHERE location=%s ORDER BY id DESC LIMIT 1"
            cursor.execute(query, (location,))
            row = cursor.fetchone()
            
            if row:
                return {
                    "id": row[0],
                    "temp": row[1],
                    "humidity": row[2],
                    "isRaining": row[3],
                    "lightIntensity": row[4],
                    "windSpeed": row[5],
                    "airPressure": row[6],
                }
            return {}
    
    except Exception as e:
        print(f"Error getting last weather data: {e}")
        return {}

def get_line_chart_data(location: str = "Gazipur", limit: int = 10) -> List[float]:
    """
    Get wind speed data for line chart
    
    Args:
        location: Location name
        limit: Number of records to retrieve
    
    Returns:
        list: Wind speed values
    """
    try:
        with get_cursor() as cursor:
            query = "SELECT windSpeed FROM weather_data WHERE location=%s ORDER BY id DESC LIMIT %s"
            cursor.execute(query, (location, limit))
            rows = cursor.fetchall()
            
            return [row[0] for row in rows]
    
    except Exception as e:
        print(f"Error getting line chart data: {e}")
        return []

def create_weather_data(data: WeatherDataCreate) -> dict:
    """
    Insert new weather data record
    
    Args:
        data: Weather data to insert
    
    Returns:
        dict: Status response
    """
    try:
        with get_cursor() as cursor:
            query = """
                INSERT INTO weather_data(temp, humidity, isRaining, lightIntensity, windSpeed, airPressure) 
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(query, (
                data.temp,
                data.humidity,
                data.isRaining,
                data.lightIntensity,
                data.windSpeed,
                data.pressure
            ))
            
            if cursor.rowcount == 1:
                return {"status": 200, "message": "Weather data created successfully"}
            else:
                return {"status": 403, "message": "Failed to create weather data"}
    
    except Exception as e:
        print(f"Error creating weather data: {e}")
        return {"status": 500, "message": f"Error: {str(e)}"}
