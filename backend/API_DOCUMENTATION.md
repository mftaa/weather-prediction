# 🌦️ Weather Prediction API Documentation

## 📖 Overview

Weather Prediction API adalah REST API berbasis FastAPI yang menggunakan Machine Learning untuk prediksi cuaca. API ini dilengkapi dengan dokumentasi interaktif menggunakan Swagger UI dan ReDoc.

## 🚀 Quick Start

### 1. Akses Swagger UI

Buka browser dan akses:

```
http://localhost:8000/docs
```

Swagger UI menyediakan:

- ✅ Interactive API testing
- 📝 Detailed endpoint documentation
- 🎯 Request/Response examples
- 🧪 "Try it out" feature untuk testing langsung

### 2. Akses ReDoc (Alternative Documentation)

```
http://localhost:8000/redoc
```

ReDoc menyediakan dokumentasi yang lebih clean dan mudah dibaca.

## 🤖 AI Prediction Endpoints

### 1. Hourly Weather Prediction

**Endpoint:** `POST /ai-prediction/hourly`

Memprediksi cuaca per jam untuk N jam ke depan (maksimal 168 jam / 7 hari).

**Request Body:**

```json
{
  "day": 8,
  "month": 12,
  "year": 2025,
  "hour": 14,
  "num_hours": 24
}
```

**Response:**

```json
{
  "status": 200,
  "message": "Hourly prediction successful",
  "model_version": "v4_combined",
  "data": [
    {
      "datetime": "2025-12-08 14:00:00",
      "date_formatted": "Sunday, December 8, 2025 at 14:00",
      "conditions": "Partially cloudy",
      "temp": 28.5,
      "humidity": 75.2,
      "windspeed": 12.3,
      "sealevelpressure": 1013.2
    }
  ]
}
```

**Predicted Values:**

- 🌡️ **Temperature** (°C) - Real-time temperature
- 💧 **Humidity** (%) - Relative humidity percentage
- 💨 **Wind Speed** (km/h) - Wind velocity
- 🌊 **Sea Level Pressure** (hPa) - Atmospheric pressure
- ☁️ **Conditions** - Weather description (Clear, Rain, Overcast, etc.)

### 2. Daily Weather Prediction

**Endpoint:** `POST /ai-prediction/daily`

Memprediksi cuaca harian untuk N hari ke depan (maksimal 30 hari).

**Request Body:**

```json
{
  "day": 8,
  "month": 12,
  "year": 2025,
  "num_days": 7
}
```

**Response:**

```json
{
  "status": 200,
  "message": "Daily prediction successful",
  "model_version": "v4_combined",
  "data": [
    {
      "date": "2025-12-08",
      "date_formatted": "Sunday, December 8, 2025",
      "conditions": "Partially cloudy",
      "tempmax": 32.5,
      "tempmin": 24.1,
      "temp": 28.3,
      "humidity": 75.2,
      "windspeed": 12.3,
      "sealevelpressure": 1013.2
    }
  ]
}
```

**Predicted Values:**

- 🌡️ **Temperature Max** (°C) - Maximum daily temperature
- 🥶 **Temperature Min** (°C) - Minimum daily temperature
- 📊 **Temperature Average** (°C) - Average daily temperature
- 💧 **Humidity** (%) - Average relative humidity
- 💨 **Wind Speed** (km/h) - Average wind velocity
- 🌊 **Sea Level Pressure** (hPa) - Average atmospheric pressure
- ☁️ **Conditions** - Weather description for the day

### 3. Model Information

**Endpoint:** `GET /ai-prediction/model-info`

Mendapatkan informasi detail tentang AI model yang digunakan.

**Response:**

```json
{
  "status": 200,
  "model_loaded": true,
  "version": "v4_combined_random_forest",
  "trained_date": "2024-11-15",
  "hourly_features": ["day", "month", "year", "hour"],
  "hourly_targets": ["temp", "humidity", "windspeed", "pressure", "conditions"],
  "daily_features": ["day", "month", "year"],
  "daily_targets": [
    "tempmax",
    "tempmin",
    "temp",
    "humidity",
    "windspeed",
    "pressure",
    "conditions"
  ]
}
```

## 🔐 Authentication Endpoints

### 1. Register User

**Endpoint:** `POST /auth/register`

**Request Body:**

```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "securepass123",
  "role": "user",
  "otp": 123456
}
```

### 2. Login

**Endpoint:** `POST /auth/login`

**Request Body:**

```json
{
  "username": "john_doe",
  "password": "securepass123"
}
```

### 3. Send OTP

**Endpoint:** `POST /auth/send-otp`

**Request Body:**

```json
{
  "email": "john@example.com"
}
```

## 📊 Weather Data Endpoints

### 1. Add Weather Data

**Endpoint:** `POST /weather`

### 2. Get All Weather Data

**Endpoint:** `GET /weather`

### 3. Get Latest Weather

**Endpoint:** `GET /weather/latest`

### 4. Update Weather Data

**Endpoint:** `PUT /weather/{id}`

### 5. Delete Weather Data

**Endpoint:** `DELETE /weather/{id}`

## 🧠 AI Model Details

### Model Architecture

- **Type**: Random Forest Ensemble
- **Algorithm**: Combination of Decision Trees
- **Training**: Supervised Learning

### Training Data

- **Period**: 2000-2024
- **Records**: 227,353+ historical weather observations
- **Location**: Multiple weather stations
- **Features**: Date, Time, Temperature, Humidity, Wind, Pressure

### Model Files

```
ml-models/new/
├── combined.joblib          # Main combined model (81MB)
├── hourly.joblib           # Hourly predictor (74MB)
├── daily.joblib            # Daily predictor (7MB)
├── hourly_classifier.joblib
├── hourly_regressor.joblib
├── daily_classifier.joblib
└── daily_regressor.joblib
```

### Performance Metrics

- High accuracy for short-term predictions (1-7 days)
- Temperature predictions: ±1-2°C accuracy
- Humidity predictions: ±5-10% accuracy
- Weather condition classification: ~85% accuracy

## 🎯 Using Swagger UI

### Testing Endpoints

1. **Navigate to `/docs`**
2. **Select an endpoint** (e.g., `/ai-prediction/hourly`)
3. **Click "Try it out"**
4. **Fill in parameters** or use example values
5. **Click "Execute"**
6. **View response** with status code and data

### Authentication (if required)

1. Click **"Authorize"** button at top right
2. Enter credentials or API key
3. Click **"Authorize"**
4. Close dialog
5. Make authenticated requests

## 📚 Additional Resources

- **GitHub Repository**: https://github.com/mftaa/weather-prediction
- **Model Training Notebook**: `ml-models/model_training.ipynb`
- **Backend README**: `backend/README.md`
- **Model Guide**: `ml-models/MODEL_GUIDE.md`

## 🔧 Development

### Running Locally

```bash
cd backend
source venv/bin/activate
python main.py
```

### Access Points

- **API**: http://localhost:8000
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

## 📝 Notes

- All timestamps are in local timezone
- Temperature values are in Celsius (°C)
- Wind speed is in km/h
- Pressure is in hPa (hectopascals)
- Predictions are based on historical patterns and may vary

## 🆘 Support

Untuk pertanyaan atau issues:

1. Cek dokumentasi di `/docs`
2. Review `backend/README.md`
3. Open issue di GitHub repository

---

**Version**: 2.0.0  
**Last Updated**: December 8, 2025
