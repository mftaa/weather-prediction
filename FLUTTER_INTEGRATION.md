# Flutter Integration Guide

## 🔗 Connecting Flutter App to Refactored Backend

### API Endpoint Changes

The new backend structure maintains **backward compatibility** with all existing endpoints. No changes required in Flutter app!

### Base URL Configuration

In `Weather-Station/lib/pages/variables.dart`:

```dart
// Production
String myDomain = "http://YOUR_SERVER_IP:8000";

// Local Development
String myDomain = "http://192.168.110.129:8000";

// Using new backend
String myDomain = "http://localhost:8000";  // If running main_new.py
```

## 📡 API Endpoints Mapping

### Old Endpoints → New Endpoints (Backward Compatible)

| Old Endpoint                   | New Endpoint                    | Status     |
| ------------------------------ | ------------------------------- | ---------- |
| `POST /generate_otp/`          | `POST /auth/generate-otp`       | ✅ Working |
| `POST /users/`                 | `POST /auth/register`           | ✅ Working |
| `POST /login/`                 | `POST /auth/login`              | ✅ Working |
| `GET /userInfo`                | `GET /auth/user-info`           | ✅ Working |
| `POST /forgot-password`        | `POST /auth/forgot-password`    | ✅ Working |
| `GET /weather-data/get/last`   | `GET /weather-data/last`        | ✅ Working |
| `GET /weather-data/line-chart` | `GET /weather-data/line-chart`  | ✅ Working |
| `GET /weather-data/create`     | `POST /weather-data/create`     | ✅ Working |
| `POST /ai-prediction/hourly`   | `POST /ai-prediction/hourly`    | ✅ Working |
| `POST /ai-prediction/daily`    | `POST /ai-prediction/daily`     | ✅ Working |
| `GET /ai-model/info`           | `GET /ai-prediction/model-info` | ✅ Working |

## 🔄 Migration Steps (Optional - for cleaner URLs)

If you want to use the new cleaner endpoint structure:

### 1. Update Authentication Service

**Old:**

```dart
final response = await http.post(
  Uri.parse('$myDomain/generate_otp/?email=$email'),
);
```

**New:**

```dart
final response = await http.post(
  Uri.parse('$myDomain/auth/generate-otp'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email}),
);
```

### 2. Update Weather Service

**Old:**

```dart
final response = await http.get(
  Uri.parse('$myDomain/weather-data/get/last?location=Gazipur'),
);
```

**New:**

```dart
final response = await http.get(
  Uri.parse('$myDomain/weather-data/last?location=Gazipur'),
);
```

### 3. Update Prediction Service

**Old:**

```dart
final response = await http.post(
  Uri.parse('$myDomain/ai-prediction/hourly'),
  body: jsonEncode({
    'day': day,
    'month': month,
    'year': year,
    'hour': hour,
    'num_hours': 24
  }),
);
```

**New:** (Same! Already using good structure)

```dart
final response = await http.post(
  Uri.parse('$myDomain/ai-prediction/hourly'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'day': day,
    'month': month,
    'year': year,
    'hour': hour,
    'num_hours': 24
  }),
);
```

## 📱 Recommended Flutter Service Structure

Create a clean API service in Flutter:

```dart
// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pages/variables.dart';

class ApiService {
  static const String baseUrl = myDomain; // From variables.dart

  // Authentication
  static Future<Map<String, dynamic>> generateOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/generate-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role,
    required int otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'otp': otp,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // Weather Data
  static Future<Map<String, dynamic>> getLastWeatherData({
    String location = 'Gazipur'
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather-data/last?location=$location'),
    );
    return jsonDecode(response.body);
  }

  static Future<List<double>> getLineChartData({
    String location = 'Gazipur',
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather-data/line-chart?location=$location&limit=$limit'),
    );
    return List<double>.from(jsonDecode(response.body));
  }

  // AI Predictions
  static Future<Map<String, dynamic>> predictHourly({
    required int day,
    required int month,
    required int year,
    int hour = 0,
    int numHours = 24,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai-prediction/hourly'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'day': day,
        'month': month,
        'year': year,
        'hour': hour,
        'num_hours': numHours,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> predictDaily({
    required int day,
    required int month,
    required int year,
    int numDays = 3,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai-prediction/daily'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'day': day,
        'month': month,
        'year': year,
        'num_days': numDays,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getModelInfo() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ai-prediction/model-info'),
    );
    return jsonDecode(response.body);
  }
}
```

## 🎯 Usage Example

```dart
// In your Flutter widget
import 'services/api_service.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    loadWeatherData();
  }

  Future<void> loadWeatherData() async {
    try {
      final data = await ApiService.getLastWeatherData();
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      print('Error loading weather data: $e');
    }
  }

  Future<void> getPrediction() async {
    try {
      final prediction = await ApiService.predictDaily(
        day: 8,
        month: 12,
        year: 2025,
        numDays: 3,
      );

      // Use prediction data
      print(prediction['data']);
    } catch (e) {
      print('Error getting prediction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather')),
      body: weatherData == null
          ? CircularProgressIndicator()
          : WeatherDisplay(data: weatherData!),
    );
  }
}
```

## 🔍 Testing API Endpoints

### Using cURL

```bash
# Test authentication
curl -X POST "http://localhost:8000/auth/generate-otp" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'

# Test weather data
curl "http://localhost:8000/weather-data/last?location=Gazipur"

# Test prediction
curl -X POST "http://localhost:8000/ai-prediction/daily" \
  -H "Content-Type: application/json" \
  -d '{
    "day": 8,
    "month": 12,
    "year": 2025,
    "num_days": 3
  }'
```

### Using Flutter

```dart
// Test connection
try {
  final response = await http.get(Uri.parse('$myDomain/health'));
  if (response.statusCode == 200) {
    print('✓ Backend connected');
  }
} catch (e) {
  print('✗ Backend connection failed: $e');
}
```

## 📝 Response Format

### Success Response

```json
{
  "status": 200,
  "message": "Success message",
  "data": [...] // or {}
}
```

### Error Response

```json
{
  "detail": "Error message"
}
```

## 🐛 Troubleshooting

### Connection Refused

```
✗ SocketException: Connection refused
```

**Solution:**

- Check if backend is running: `python main_new.py`
- Verify IP address in `variables.dart`
- Check firewall settings

### Invalid JSON

```
✗ FormatException: Unexpected character
```

**Solution:**

- Add `Content-Type: application/json` header
- Use `jsonEncode()` for request body

### CORS Error

```
✗ CORS policy: No 'Access-Control-Allow-Origin'
```

**Solution:** Already configured in new backend! Should work out of the box.

## 📚 Additional Resources

- API Documentation: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
- Backend README: `backend/README.md`
- Architecture: `backend/ARCHITECTURE.md`

## ✅ Checklist

Before deploying Flutter app with new backend:

- [ ] Update `myDomain` in `variables.dart`
- [ ] Test all API endpoints
- [ ] Verify authentication flow
- [ ] Test weather data retrieval
- [ ] Test AI predictions
- [ ] Handle error responses
- [ ] Add loading indicators
- [ ] Test on actual device (not just emulator)

---

**Note:** The refactored backend maintains 100% backward compatibility. Your existing Flutter app will work without any changes!
