# Weather Prediction System 🌦️

A comprehensive weather prediction system using AI/ML models with FastAPI backend and Flutter mobile frontend.

## 📋 Project Overview

This project consists of:

- **Backend API**: FastAPI REST API with AI/ML weather prediction
- **Frontend Mobile**: Flutter application for Android/iOS
- **AI Model**: Random Forest-based weather prediction model (v4)
- **Database**: MySQL for data storage

## 🏗️ Architecture

```
weather-prediction/
├── backend/                    # FastAPI Backend (NEW STRUCTURE)
│   ├── app/
│   │   ├── core/              # Configuration & database
│   │   ├── models/            # Pydantic schemas
│   │   ├── routes/            # API endpoints
│   │   ├── services/          # Business logic
│   │   └── utils/             # Helper functions
│   ├── main_new.py            # Entry point (refactored)
│   ├── main.py                # Entry point (legacy)
│   └── requirements.txt       # Python dependencies
├── Weather-Station/           # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart          # App entry point
│   │   ├── pages/             # UI screens
│   │   ├── services/          # API services
│   │   └── utility/           # Utilities
│   └── pubspec.yaml           # Flutter dependencies
└── models - Random Forest - Prediksi cuma pake tanggal/
    ├── new/                   # AI Model v4 (CURRENT)
    │   └── v4_weather_model_combined.joblib
    ├── historical_data_2000_2024_v2.csv
    └── model_weather_training_v4-FINISH.ipynb
```

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- MySQL 8.0+
- Flutter 3.0+ (for mobile app)
- Git

### 1. Backend Setup

```bash
# Clone repository
git clone https://github.com/mftaa/weather-prediction.git
cd weather-prediction

# Setup Python virtual environment
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Setup database
mysql -u root -p < weather_app_bd.sql

# Run server
python main_new.py
```

API will be available at: `http://localhost:8000`
Documentation: `http://localhost:8000/docs`

### 2. Frontend Setup (Flutter)

```bash
cd Weather-Station

# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Or build APK
flutter build apk --release
```

## 📡 API Endpoints

### Base URL

```
http://localhost:8000
```

### Endpoints

#### Authentication

- `POST /auth/generate-otp` - Generate OTP
- `POST /auth/register` - Register user
- `POST /auth/login` - User login
- `GET /auth/user-info` - Get user info
- `POST /auth/forgot-password` - Reset password

#### Weather Data

- `GET /weather-data/last` - Get latest weather
- `GET /weather-data/line-chart` - Chart data
- `POST /weather-data/create` - Insert data

#### AI Predictions

- `POST /ai-prediction/hourly` - Hourly forecast
- `POST /ai-prediction/daily` - Daily forecast
- `GET /ai-prediction/model-info` - Model info

## 🤖 AI Model Details

### Model v4 Features

- **Type**: Random Forest Ensemble
- **Input Features**:
  - Hourly: day, month, year, hour
  - Daily: day, month, year
- **Predictions**:
  - Temperature (min, max, mean)
  - Humidity
  - Wind speed
  - Sea level pressure
  - Weather conditions

### Model Performance

- Training data: 2000-2024 historical weather data
- Location: Semarang, Indonesia
- Accuracy: High for 3-7 day forecasts

## 🔧 Configuration

### Backend Configuration

Edit `backend/app/core/config.py` or create `.env`:

```env
# Database
DB_HOST=127.0.0.1
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=weather_app_bd

# Server
HOST=0.0.0.0
PORT=8000

# Email (for OTP)
EMAIL_USERNAME=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
```

### Flutter Configuration

Edit `Weather-Station/lib/pages/variables.dart`:

```dart
String myDomain = "http://YOUR_IP:8000";
```

## 📱 Mobile App Features

- ✅ User authentication
- ✅ Real-time weather display
- ✅ AI-powered predictions
- ✅ Interactive charts
- ✅ Beautiful UI/UX
- ✅ Offline support

## 🗂️ Database Schema

### Required Tables

- `users` - User accounts
- `otp` - OTP verification
- `weather_data` - Real-time sensor data
- `historical_dataset` - Training data

See `backend/weather_app_bd.sql` for complete schema.

## 📊 Development Workflow

### Backend Development

1. Create feature branch
2. Add/modify services in `app/services/`
3. Add routes in `app/routes/`
4. Update models in `app/models/`
5. Test with `/docs`
6. Commit and push

### Frontend Development

1. Create feature branch
2. Add UI in `lib/pages/`
3. Add services in `lib/services/`
4. Test on device
5. Commit and push

## 🧪 Testing

### Backend Tests

```bash
cd backend
pytest tests/
```

### Frontend Tests

```bash
cd Weather-Station
flutter test
```

## 📈 Roadmap

- [ ] Add user dashboard
- [ ] Implement push notifications
- [ ] Add weather alerts
- [ ] Multi-location support
- [ ] Weather map visualization
- [ ] API rate limiting
- [ ] Redis caching
- [ ] Docker deployment

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 🐛 Known Issues

- Email OTP may be slow (SMTP delay)
- Model loading takes ~5 seconds on startup
- Large predictions (>30 days) may timeout

## 📝 Changelog

### v2.0.0 (2025-12-08) - Major Refactoring

- ✅ Restructured backend with clean architecture
- ✅ Separated concerns (routes, services, models)
- ✅ Removed redundant files
- ✅ Improved code documentation
- ✅ Added type hints throughout
- ✅ Better error handling

### v1.0.0 (2024)

- Initial release
- Basic prediction functionality
- Flutter app integration

## 📄 License

This project is licensed under the MIT License.

## 👥 Team

- Backend: FastAPI + ML Team
- Frontend: Flutter Team
- AI/ML: Data Science Team

## 📞 Support

For issues and questions:

- GitHub Issues: https://github.com/mftaa/weather-prediction/issues
- Email: support@weatherprediction.com

## 🙏 Acknowledgments

- Visual Crossing API for historical data
- FastAPI framework
- Flutter framework
- Scikit-learn ML library

---

**Made with ❤️ by Weather Prediction Team**
