import 'package:provider/provider.dart';
import '../utility/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class WeatherForecastPage extends StatefulWidget {
  const WeatherForecastPage({super.key});

  @override
  State<WeatherForecastPage> createState() => _WeatherForecastPageState();
}

class _WeatherForecastPageState extends State<WeatherForecastPage> {
  // Default range: Hari ini sampai 6 hari ke depan (Total 7 hari)
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 6));

  List<Map<String, dynamic>> _forecastData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchForecastData();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B9FE3),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _fetchForecastData();
    }
  }

  // --- LOGIC PERBAIKAN: SINGLE REQUEST (BULK DATA) ---
  Future<void> _fetchForecastData() async {
    setState(() {
      _isLoading = true;
      _forecastData.clear();
    });

    try {
      // 1. Hitung jumlah hari (num_days) berdasarkan range tanggal yang dipilih
      final int numDays =
          _selectedEndDate.difference(_selectedStartDate).inDays + 1;

      // 2. Kirim Request dengan ApiService (fallback otomatis)
      final response = await ApiService.post(
        '/ai-prediction/daily',
        body: {
          'day': _selectedStartDate.day,
          'month': _selectedStartDate.month,
          'year': _selectedStartDate.year,
          'num_days': numDays, // Request sejumlah hari sekaligus
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        // 3. Ambil array 'data' dari response JSON
        final List<dynamic> rawDataList = result['data'] ?? [];
        final List<Map<String, dynamic>> parsedForecasts = [];

        for (var item in rawDataList) {
          // Parsing Tanggal dari String "YYYY-MM-DD" ke DateTime
          // JSON kamu: "date": "2025-12-08"
          DateTime itemDate;
          if (item['date'] != null) {
            itemDate = DateTime.parse(item['date']);
          } else {
            itemDate = DateTime.now(); // Fallback
          }

          parsedForecasts.add({
            'date': itemDate,
            'conditions': item['conditions'] ?? 'Cloudy',
            // Parsing angka (handle int/double dengan aman)
            'temp_min': item['temp_min'] ?? 0,
            'temp_max': item['temp_max'] ?? 0,
            'temp_mean': item['temp_mean'] ?? 0,
            'humidity_avg': item['humidity_avg'] ?? 0,
            'windspeed_avg': item['windspeed_avg'] ?? 0,
            'pressure_avg': item['pressure_avg'] ?? 0,
          });
        }

        setState(() {
          _forecastData = parsedForecasts;
        });

        // Check for rain in the first forecast item (Today/Tomorrow)
        if (parsedForecasts.isNotEmpty) {
          final firstForecast = parsedForecasts[0];
          final condition =
              (firstForecast['conditions'] as String).toLowerCase();
          if (condition.contains('rain') ||
              condition.contains('shower') ||
              condition.contains('thunder')) {
            NotificationService().showRainAlert(
              'Rain Alert',
              'Rain is predicted for ${DateFormat('EEEE').format(firstForecast['date'])}. Prepare your umbrella!',
            );
          }
        }
      } else {
        throw Exception('Failed to load forecast: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A1A),
                    Color(0xFF2C2C2C),
                    Color(0xFF3D3D3D),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF5B9FE3),
                    Color(0xFF7AB8F5),
                    Color(0xFFB8D4F0),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : RefreshIndicator(
                        onRefresh: _fetchForecastData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTomorrowCard(),
                                const SizedBox(height: 15),
                                _buildStatsCard(),
                                const SizedBox(height: 20),
                                _buildDateRangeSelector(),
                                const SizedBox(height: 20),
                                _buildDailyForecastList(),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    '7-Day Forecast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Semarang', // Lokasi Hardcoded sesuai konteks
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _selectDateRange,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.date_range, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTomorrowCard() {
    if (_forecastData.isEmpty) return const SizedBox.shrink();

    // Data index 0 = Hari pertama dalam range (Besok atau Hari ini)
    final forecast = _forecastData[0];
    final date = forecast['date'] as DateTime;

    // Parsing angka agar aman (handle int/double)
    final rawMax = forecast['temp_max'];
    final rawMin = forecast['temp_min'];
    final tempMax = (rawMax is num) ? rawMax.toStringAsFixed(0) : '0';
    final tempMin = (rawMin is num) ? rawMin.toStringAsFixed(0) : '0';

    final condition = forecast['conditions'] as String;

    String dayLabel = DateFormat('EEEE').format(date); // Nama hari lengkap
    if (date.day == DateTime.now().day) {
      dayLabel = 'Today';
    } else if (date.day == DateTime.now().add(const Duration(days: 1)).day) {
      dayLabel = 'Tomorrow';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5A9FE8),
            Color(0xFF7BB5F0),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            dayLabel,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tempMax,
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const Text(
                        '°',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '/$tempMin°',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    condition,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(
                        _getWeatherIcon(condition),
                        size: 70,
                        color: _getIconColor(condition),
                      ),
                    ),
                    if (condition.toLowerCase().contains('cloud'))
                      Positioned(
                        left: 0,
                        bottom: 10,
                        child: Icon(
                          Icons.cloud,
                          size: 50,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (_forecastData.isEmpty) return const SizedBox.shrink();

    final forecast = _forecastData[0];
    // Parsing angka agar aman
    final rawHum = forecast['humidity_avg'];
    final rawWind = forecast['windspeed_avg'];

    final humidity = (rawHum is num) ? rawHum.toStringAsFixed(0) : '0';
    final windSpeed = (rawWind is num) ? rawWind.toStringAsFixed(0) : '0';

    // Estimasi precipitation dari kondisi
    String precip = '10%';
    final cond = (forecast['conditions'] as String).toLowerCase();
    if (cond.contains('rain'))
      precip = '90%';
    else if (cond.contains('cloud')) precip = '40%';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.water_drop_outlined, precip, 'Precipitation', isDark),
          _buildStatItem(Icons.opacity, '$humidity%', 'Humidity', isDark),
          _buildStatItem(Icons.air, '$windSpeed km/h', 'Wind speed', isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF7AB5F0), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white70 : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _selectDateRange,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM d').format(_selectedStartDate)} - ${DateFormat('MMM d, yyyy').format(_selectedEndDate)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_calendar,
                        color: Color(0xFF5B9FE3), size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Change',
                      style: TextStyle(
                        color: Color(0xFF5B9FE3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyForecastList() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (_forecastData.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.wb_sunny_outlined, size: 64, color: Colors.white70),
            SizedBox(height: 16),
            Text(
              'No forecast data available',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: _forecastData.asMap().entries.map((entry) {
          final index = entry.key;
          final forecast = entry.value;

          final date = forecast['date'] as DateTime;
          final dayName = _getDayName(date, index);
          final condition = forecast['conditions'] as String;

          final rawMax = forecast['temp_max'];
          final rawMin = forecast['temp_min'];
          final tempMax = (rawMax is num) ? rawMax.toStringAsFixed(0) : '0';
          final tempMin = (rawMin is num) ? rawMin.toStringAsFixed(0) : '0';

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: index < _forecastData.length - 1
                  ? Border(
                      bottom: BorderSide(color: isDark ? Colors.white24 : Colors.grey[200]!, width: 1),
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Day name
                SizedBox(
                  width: 50,
                  child: Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Weather icon
                Icon(
                  _getWeatherIcon(condition),
                  color: _getIconColor(condition),
                  size: 26,
                ),
                const SizedBox(width: 12),
                // Condition
                Expanded(
                  child: Text(
                    condition,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Temperature
                Text(
                  '$tempMax / $tempMin',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getDayName(DateTime date, int index) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (date.day == tomorrow.day &&
        date.month == tomorrow.month &&
        date.year == tomorrow.year) {
      return 'Tmrw';
    }
    return DateFormat('EEE').format(date);
  }

  IconData _getWeatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('clear') || c.contains('sunny')) return Icons.wb_sunny;
    if (c.contains('cloud')) return Icons.cloud;
    if (c.contains('rain') || c.contains('shower')) return Icons.grain;
    if (c.contains('thunder')) return Icons.flash_on;
    if (c.contains('fog') || c.contains('mist')) return Icons.cloud_queue;
    if (c.contains('snow')) return Icons.ac_unit;
    if (c.contains('overcast')) return Icons.cloud;
    return Icons.wb_cloudy;
  }

  Color _getIconColor(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('clear') || c.contains('sunny'))
      return const Color(0xFFFDB813);
    if (c.contains('rain') || c.contains('shower'))
      return const Color(0xFF5B9FE3);
    if (c.contains('thunder')) return const Color(0xFFFFB300);
    if (c.contains('cloud') || c.contains('overcast')) return Colors.grey;
    return const Color(0xFFFDB813);
  }
}
