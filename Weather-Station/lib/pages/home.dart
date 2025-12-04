import 'package:demo1/pages/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

String _latitude = '';
String _longitude = '';

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  double rating = 0.0;
  TextEditingController searchController = TextEditingController();
  Timer? _autoRefreshTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  dynamic userInfo;

  Future<void> fetchUserInfo() async {
    final response =
        await http.get(Uri.parse('$myDomain/userInfo?username=$myUsername'));
    if (response.statusCode == 200) {
      setState(() {
        userInfo = json.decode(response.body)['records'];
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  dynamic weatherSummaryStatus = "";
  List<dynamic> weatherData = [];
  List<dynamic> weatherForecastData = [];

  Future<void> fetchWeatherData() async {
    try {
      final response = await http
          .get(Uri.parse('$myDomain/weather-data/get/last?location=Gazipur'));

      if (response.statusCode == 200) {
        setState(() {
          // Bungkus response dalam list untuk kompatibilitas dengan struktur kode
          weatherData = [json.decode(response.body)];
        });

        // Cek apakah data berhasil masuk
        if (weatherData.isNotEmpty) {
          // Cek key 'isRaining' untuk menentukan status cuaca
          if (weatherData[0]['isRaining'] == 0) {
            setState(() {
              weatherSummaryStatus = "Sunny";
            });
          } else {
            setState(() {
              weatherSummaryStatus = "Raining";
            });
          }
        }
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      // Jangan throw exception agar app tidak crash
    }
  }

  Future<void> fetchWeatherForecast() async {
    try {
      // Get current date
      final now = DateTime.now();
      final response = await http.get(Uri.parse(
          '$myDomain/weather-data/get-predicted-data?day=${now.day}&month=${now.month}&year=${now.year}'));

      if (response.statusCode == 200) {
        setState(() {
          weatherForecastData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load weather forecast data');
      }
    } catch (e) {
      print('Error fetching weather forecast: $e');
      // Jangan throw exception agar app tidak crash
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitude = 'Latitude: ${position.latitude}';
        _longitude = 'Longitude: ${position.longitude}';
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('My Location'),
            content: Text('$_latitude\n$_longitude'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Auto-refresh data setiap 30 detik
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.wait([
      fetchWeatherData(),
      fetchUserInfo(),
      fetchWeatherForecast(),
    ]);
    setState(() {
      _isLoading = false;
    });
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather Station",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: <Widget>[
                        const SizedBox(height: 8.0),
                        // Search Bar
                        _buildSearchBar(),
                        const SizedBox(height: 20.0),
                        // Weather Data Cards - Row 1
                        if (weatherData.isNotEmpty) _buildWeatherRow1(),
                        const SizedBox(height: 16.0),
                        // Weather Data Cards - Row 2
                        if (weatherData.isNotEmpty) _buildWeatherRow2(),
                        const SizedBox(height: 24.0),
                        // Summary Circle
                        _buildCircularSummary(),
                        const SizedBox(height: 24.0),
                        // 7-Day Forecast
                        _buildSevenDayForecastTable(),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      resizeToAvoidBottomInset: false,
      drawer: _buildDrawer(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search for cities',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) {
          // Handle search logic here
        },
      ),
    );
  }

  Widget _buildWeatherRow1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _buildInfoCard(
            "Temperature",
            '${weatherData[0]['temp']}°C',
            Icons.thermostat,
            const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _buildInfoCard(
            "Humidity",
            "${weatherData[0]['humidity']}%",
            Icons.opacity,
            const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _buildInfoCard(
            "Light",
            "${weatherData[0]['lightIntensity']} Lux",
            Icons.lightbulb,
            const Color(0xFFFFE66D),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherRow2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _buildInfoCard(
            "Air Pressure",
            "${weatherData[0]['airPressure']} hPa",
            Icons.compress,
            const Color(0xFF95E1D3),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _buildInfoCard(
            "Wind Speed",
            "${weatherData[0]['windSpeed']} m/s",
            Icons.air,
            const Color(0xFFAA96DA),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _buildInfoCard(
            "Rain",
            weatherData[0]['isRaining'] == 0 ? "No Rain" : "Raining",
            Icons.umbrella,
            const Color(0xFF6C5CE7),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData iconData, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: color, size: 28.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCircularSummary() {
    return Container(
      width: 200.0,
      height: 200.0,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Summary",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: weatherSummaryStatus == "Sunny"
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                weatherSummaryStatus == "Sunny"
                    ? Icons.wb_sunny
                    : Icons.umbrella,
                color: weatherSummaryStatus == "Sunny"
                    ? Colors.orange
                    : Colors.blue,
                size: 40.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              weatherSummaryStatus,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSevenDayForecastTable() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: Color(0xFF2196F3), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Weather Forecast',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFF2196F3).withOpacity(0.1),
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Max Temp',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Min Temp',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Conditions',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: weatherForecastData.map<DataRow>((record) {
                return DataRow(
                  cells: [
                    DataCell(Text(
                      '${record['date']}',
                      style: const TextStyle(color: Colors.black87),
                    )),
                    DataCell(Text(
                      '${record['tempmax']}°C',
                      style: const TextStyle(color: Colors.black87),
                    )),
                    DataCell(Text(
                      '${record['tempmin']}°C',
                      style: const TextStyle(color: Colors.black87),
                    )),
                    DataCell(Text(
                      '${record['conditions']}',
                      style: const TextStyle(color: Colors.black87),
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            if (userInfo != null)
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 50, color: Color(0xFF2196F3)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${userInfo[0]['username']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userInfo[0]['email']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title:
                  const Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title:
                  const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon:
                  const Icon(Icons.share, size: 28.0, color: Color(0xFF2196F3)),
              onPressed: () {
                launch(
                    'https://play.google.com/store/games?hl=en_US&gl=US&pli=1');
              },
            ),
            IconButton(
              icon: const Icon(Icons.location_on,
                  size: 28.0, color: Color(0xFF2196F3)),
              onPressed: () {
                _getCurrentLocation();
              },
            ),
            IconButton(
              icon:
                  const Icon(Icons.star, size: 28.0, color: Color(0xFF2196F3)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Rate Us'),
                      content: RatingBar.builder(
                        initialRating: rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 40.0,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (value) {
                          setState(() {
                            rating = value;
                          });
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            print('User Rating: $rating');
                            Navigator.pop(context);
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
