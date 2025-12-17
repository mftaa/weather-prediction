import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../utility/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class HomePageNew extends StatefulWidget {
  const HomePageNew({super.key});

  @override
  _HomePageNewState createState() => _HomePageNewState();
}

class _HomePageNewState extends State<HomePageNew> {
  bool _isLoading = true;
  Map<String, dynamic>? _currentWeather;
  List<dynamic> _hourlyForecast = [];
  List<dynamic> _dailyForecast = [];
  List<double> _chartData = [];
  String _location = "Semarang"; // Default location

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      // Menggunakan ApiService dengan fallback otomatis
      // Jika endpoint pertama gagal, akan otomatis beralih ke endpoint kedua

      // 1. SIAPKAN SEMUA REQUEST dengan ApiService
      final requestCurrent = ApiService.get(
        '/weather-data/last?location=$_location',
      );

      final requestHourly = ApiService.post(
        '/ai-prediction/hourly',
        body: {
          'day': now.day,
          'month': now.month,
          'year': now.year,
          'hour': now.hour,
          'num_hours': 24,
        },
      );

      final requestDaily = ApiService.post(
        '/ai-prediction/daily',
        body: {
          'day': now.day,
          'month': now.month,
          'num_days': 7,
          'year': now.year,
        },
      );

      final requestChart = ApiService.get(
        '/weather-data/line-chart?location=$_location&limit=10',
      );

      // 2. JALANKAN SEMUA BERSAMAAN
      final results = await Future.wait([
        requestCurrent,
        requestHourly,
        requestDaily,
        requestChart,
      ]);

      // 3. OLAH HASILNYA
      final currentResponse = results[0];
      final hourlyResponse = results[1];
      final dailyResponse = results[2];
      final chartResponse = results[3];

      setState(() {
        if (currentResponse.statusCode == 200) {
          _currentWeather = json.decode(currentResponse.body);
        }
        if (hourlyResponse.statusCode == 200) {
          final data = json.decode(hourlyResponse.body);
          _hourlyForecast = data['data'] ?? [];
        }
        if (dailyResponse.statusCode == 200) {
          final data = json.decode(dailyResponse.body);
          _dailyForecast = data['data'] ?? [];
        }
        if (chartResponse.statusCode == 200) {
           final List<dynamic> data = json.decode(chartResponse.body);
           _chartData = data.map((e) => (e as num).toDouble()).toList();
        }
      });
    } catch (e) {
      print('Error fetching weather: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : RefreshIndicator(
                  onRefresh: _fetchWeatherData,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 20),
                                _buildMainWeatherCard(),
                                const SizedBox(height: 15),
                                _buildStatsCard(),
                                const SizedBox(height: 20),
                                _buildHourlyForecast(),
                                const SizedBox(height: 20),

                                // Bagian ini yang sudah diperbarui
                                _buildOtherCitiesSection(),
                                
                                const SizedBox(height: 20),
                                _buildChartSection(),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  void _showMenuOptions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Garis kecil di atas (UX Handle)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Menu 1: Refresh
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9FE3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.refresh, color: Color(0xFF5B9FE3)),
              ),
              title: Text('Refresh Data',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context); // Tutup menu
                _fetchWeatherData(); // Panggil fungsi refresh
              },
            ),
            const SizedBox(height: 8),

            // Menu 2: Profile
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9FE3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.person_outline, color: Color(0xFF5B9FE3)),
              ),
              title: Text('Profile',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            const SizedBox(height: 8),

            // Menu 3: Settings
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9FE3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.settings_outlined,
                    color: Color(0xFF5B9FE3)),
              ),
              title: Text('Settings',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const SizedBox(height: 8),

            // Menu 4: Logout
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, color: Colors.redAccent),
              ),
              title: Text('Logout',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                // Navigasi balik ke Login & hapus history stack
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat('EEEE, d MMMM · HH:mm').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _showMenuOptions(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.more_vert, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainWeatherCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final weather = _currentWeather ?? {};
    final tempRaw = weather['temp'];
    final temp = _convertTemp(tempRaw, themeProvider.isCelsius);

    final isRaining = weather['isRaining'] ?? 0;
    final lightIntensity = weather['lightIntensity'];

    String conditionText = 'Cloudy';
    IconData conditionIcon = Icons.cloud;
    Color iconColor = Colors.white;

    if (isRaining == 1) {
      conditionText = 'Rainy';
      conditionIcon = Icons.grain;
    } else if (lightIntensity is num && lightIntensity < 500) {
      conditionText = 'Sunny';
      conditionIcon = Icons.wb_sunny;
      iconColor = const Color(0xFFFDB813);
    } else {
      conditionText = 'Cloudy';
      conditionIcon = Icons.cloud;
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
                        temp,
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    conditionText,
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
                        conditionIcon,
                        size: 70,
                        color: iconColor,
                      ),
                    ),
                    if (conditionText != 'Sunny')
                      Positioned(
                        left: 0,
                        bottom: 10,
                        child: Icon(
                          Icons.cloud,
                          size: 50,
                          color: Colors.white.withOpacity(0.5),
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

    final weather = _currentWeather ?? {};
    final humRaw = weather['humidity'];
    final humidity = (humRaw is num) ? humRaw.toStringAsFixed(0) : '0';
    final windRaw = weather['windSpeed'];
    final windSpeed = (windRaw is num) ? windRaw.toStringAsFixed(1) : '0';
    final pressureRaw = weather['airPressure'];
    final airPressure =
        (pressureRaw is num) ? pressureRaw.toStringAsFixed(0) : '0';

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
          _buildStatItem(Icons.opacity, '$humidity%', 'Humidity', isDark),
          _buildStatItem(Icons.air, '$windSpeed km/h', 'Wind speed', isDark),
          _buildStatItem(Icons.speed, '$airPressure hPa', 'Air pressure', isDark),
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

  Widget _buildHourlyForecast() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final nowWIB = DateTime.now().toUtc().add(const Duration(hours: 7));
    final currentHour = nowWIB.hour;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.pushNamed(context, '/forecast');
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '7-Day Forecasts',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white.withOpacity(0.8),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hourlyForecast.isEmpty ? 24 : _hourlyForecast.length,
            itemBuilder: (context, index) {
              final forecast =
                  _hourlyForecast.isNotEmpty && index < _hourlyForecast.length
                      ? _hourlyForecast[index]
                      : {};

              String hourDisplay;
              if (forecast['time'] != null) {
                String rawTime = forecast['time'].toString();
                hourDisplay =
                    rawTime.length > 5 ? rawTime.substring(0, 5) : rawTime;
              } else {
                int calculatedHour = (currentHour + index) % 24;
                hourDisplay = '${calculatedHour.toString().padLeft(2, '0')}:00';
              }

              var tempRaw = forecast['temp'];
              String temp = _convertTemp(tempRaw, themeProvider.isCelsius);

              final condition = forecast['conditions'] ?? 'Cloudy';
              final isActive = index == 0;

              return Container(
                width: 65,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF5A9FE8), Color(0xFF7BB5F0)],
                        )
                      : null,
                  color: isActive ? null : Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(30),
                  border: isActive
                      ? null
                      : Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      hourDisplay,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      _getWeatherIcon(condition),
                      color: isActive ? Colors.white : const Color(0xFFFDB813),
                      size: 26,
                    ),
                    Text(
                      '$temp°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- BAGIAN BARU: OTHER CITIES SECTION ---
  Widget _buildOtherCitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Other Cities',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Tombol Add City (Optional, bisa dihilangkan jika mau pakai List saja)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feature coming soon! 🚧')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Kota 1: Jakarta (Contoh AVAILABLE / AKTIF)
        _buildCityCard(
          city: 'Jakarta',
          condition: 'Thunderstorm',
          temp: '29',
          isAvailable: false,
        ),

        const SizedBox(height: 12),

        // Kota 2: Bandung (Contoh UNAVAILABLE / LOCKED)
        _buildCityCard(
          city: 'Bandung',
          condition: 'Light Rain',
          temp: '24',
          isAvailable: false, // Set ke false biar ada gembok
        ),

        const SizedBox(height: 12),

        // Kota 3: Surabaya (Contoh UNAVAILABLE / LOCKED)
        _buildCityCard(
          city: 'Surabaya',
          condition: 'Sunny',
          temp: '32',
          isAvailable: false,
        ),
      ],
    );
  }

  // --- REUSABLE WIDGET: CITY CARD YANG BARU ---
  Widget _buildCityCard({
    required String city,
    required String condition,
    required String temp,
    required bool isAvailable,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final displayTemp = _convertTemp(temp, themeProvider.isCelsius);

    return GestureDetector(
      onTap: () {
        if (isAvailable) {
          // Logic ganti lokasi jika available
          setState(() {
            _location = city;
          });
          _fetchWeatherData();
        } else {
          // Logic feedback jika unavailable (UX Improvement)
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Sabar ya! Data cuaca untuk $city sedang disiapkan 🚧'),
              backgroundColor: Colors.grey[800],
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Opacity(
        // Efek visual: Kalau tidak available, opacity turun (agak transparan)
        opacity: isAvailable ? 1.0 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF5A9FE8),
                Color(0xFF7BB5F0),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A90E2).withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Ikon berubah jadi Gembok jika !isAvailable
                    Icon(
                      isAvailable ? Icons.location_on : Icons.lock_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Kondisi cuaca diganti "Coming Soon" jika unavailable
                        isAvailable
                            ? Text(
                                condition,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              )
                            : Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4)),
                                child: const Text(
                                  'Coming Soon',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '$displayTemp°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.cloud,
                      color: Colors.white.withOpacity(0.8),
                      size: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wind Speed Trend',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: _chartData.isEmpty
              ? const Center(
                  child: Text(
                    'No Data Available',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: _chartData.length.toDouble() - 1,
                    minY: 0,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _chartData
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        color: Colors.white,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  String _convertTemp(dynamic value, bool isCelsius) {
    double? temp;
    if (value is num) {
      temp = value.toDouble();
    } else if (value is String) {
      temp = double.tryParse(value);
    }

    if (temp == null) return '-';

    if (!isCelsius) {
      temp = (temp * 9 / 5) + 32;
    }

    return temp.round().toString();
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('clear') || condition.contains('sunny')) {
      return Icons.wb_sunny;
    } else if (condition.contains('cloud')) {
      return Icons.cloud;
    } else if (condition.contains('rain') || condition.contains('shower')) {
      return Icons.grain;
    } else if (condition.contains('thunder')) {
      return Icons.flash_on;
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return Icons.cloud_queue;
    } else if (condition.contains('snow')) {
      return Icons.ac_unit;
    }
    return Icons.wb_cloudy;
  }
}
