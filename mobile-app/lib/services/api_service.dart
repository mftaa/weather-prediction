import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

/// Service untuk menangani API calls dengan fallback ke endpoint cadangan
/// Jika endpoint utama gagal, otomatis dialihkan ke endpoint kedua
class ApiService {
  // Daftar endpoint API (utama dan cadangan)
  static const List<String> _endpoints = [
    'https://api.wrseno.my.id', // VPS - Primary
    'https://api.azanifattur.biz.id', // Personal Computer - Secondary
  ];

  // Index endpoint aktif saat ini
  static int _currentEndpointIndex = 0;

  // Timeout untuk request (dalam detik)
  static const int _requestTimeout = 10;

  // Getter untuk mendapatkan domain aktif saat ini
  static String get currentDomain => _endpoints[_currentEndpointIndex];

  // Getter untuk semua endpoints
  static List<String> get allEndpoints => List.unmodifiable(_endpoints);

  /// Reset ke endpoint utama
  static void resetToMainEndpoint() {
    _currentEndpointIndex = 0;
  }

  /// Switch ke endpoint berikutnya
  static void _switchToNextEndpoint() {
    _currentEndpointIndex = (_currentEndpointIndex + 1) % _endpoints.length;
    print('🔄 Switched to endpoint: ${_endpoints[_currentEndpointIndex]}');
  }

  /// Melakukan HTTP GET request dengan fallback
  static Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    int maxRetries = 2,
  }) async {
    Exception? lastException;
    int attempts = 0;
    int startingIndex = _currentEndpointIndex;

    while (attempts < _endpoints.length * maxRetries) {
      final url = '${_endpoints[_currentEndpointIndex]}$path';

      try {
        print('📡 GET Request: $url');

        final response = await http
            .get(Uri.parse(url), headers: headers)
            .timeout(Duration(seconds: _requestTimeout));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } else if (response.statusCode >= 500) {
          // Server error, coba endpoint lain
          throw Exception('Server error: ${response.statusCode}');
        } else {
          // Client error (4xx), return response tanpa retry
          return response;
        }
      } on TimeoutException {
        print('⏱️ Timeout on endpoint: ${_endpoints[_currentEndpointIndex]}');
        lastException = TimeoutException('Request timeout');
        _switchToNextEndpoint();
      } catch (e) {
        print('❌ Error on endpoint ${_endpoints[_currentEndpointIndex]}: $e');
        lastException = e is Exception ? e : Exception(e.toString());
        _switchToNextEndpoint();
      }

      attempts++;

      // Jika sudah kembali ke endpoint awal dan masih gagal
      if (_currentEndpointIndex == startingIndex &&
          attempts >= _endpoints.length) {
        break;
      }
    }

    throw lastException ?? Exception('All endpoints failed');
  }

  /// Melakukan HTTP POST request dengan fallback
  static Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    int maxRetries = 2,
  }) async {
    Exception? lastException;
    int attempts = 0;
    int startingIndex = _currentEndpointIndex;

    // Default headers untuk JSON
    final defaultHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    while (attempts < _endpoints.length * maxRetries) {
      final url = '${_endpoints[_currentEndpointIndex]}$path';

      try {
        print('📡 POST Request: $url');

        final response = await http
            .post(
              Uri.parse(url),
              headers: defaultHeaders,
              body: body is String ? body : jsonEncode(body),
            )
            .timeout(Duration(seconds: _requestTimeout));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } else if (response.statusCode >= 500) {
          // Server error, coba endpoint lain
          throw Exception('Server error: ${response.statusCode}');
        } else {
          // Client error (4xx), return response tanpa retry
          return response;
        }
      } on TimeoutException {
        print('⏱️ Timeout on endpoint: ${_endpoints[_currentEndpointIndex]}');
        lastException = TimeoutException('Request timeout');
        _switchToNextEndpoint();
      } catch (e) {
        print('❌ Error on endpoint ${_endpoints[_currentEndpointIndex]}: $e');
        lastException = e is Exception ? e : Exception(e.toString());
        _switchToNextEndpoint();
      }

      attempts++;

      // Jika sudah kembali ke endpoint awal dan masih gagal
      if (_currentEndpointIndex == startingIndex &&
          attempts >= _endpoints.length) {
        break;
      }
    }

    throw lastException ?? Exception('All endpoints failed');
  }

  /// Check kesehatan endpoint
  static Future<Map<String, bool>> checkEndpointsHealth() async {
    Map<String, bool> health = {};

    for (String endpoint in _endpoints) {
      try {
        final response = await http
            .get(Uri.parse('$endpoint/health'))
            .timeout(Duration(seconds: 5));
        health[endpoint] = response.statusCode == 200;
      } catch (e) {
        health[endpoint] = false;
      }
    }

    return health;
  }

  /// Pilih endpoint terbaik berdasarkan response time
  static Future<void> selectBestEndpoint() async {
    int bestIndex = 0;
    int bestTime = 999999;

    for (int i = 0; i < _endpoints.length; i++) {
      try {
        final stopwatch = Stopwatch()..start();
        final response = await http
            .get(Uri.parse('${_endpoints[i]}/health'))
            .timeout(Duration(seconds: 5));
        stopwatch.stop();

        if (response.statusCode == 200 &&
            stopwatch.elapsedMilliseconds < bestTime) {
          bestTime = stopwatch.elapsedMilliseconds;
          bestIndex = i;
        }
        print('📊 ${_endpoints[i]}: ${stopwatch.elapsedMilliseconds}ms');
      } catch (e) {
        print('❌ ${_endpoints[i]}: unavailable');
      }
    }

    _currentEndpointIndex = bestIndex;
    print('✅ Selected best endpoint: ${_endpoints[bestIndex]}');
  }
}
