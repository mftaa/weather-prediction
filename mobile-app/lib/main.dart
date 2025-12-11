import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/loginpage.dart';
import 'pages/registration.dart';
import 'pages/home_new.dart';
import 'pages/settings.dart';
import 'pages/profile.dart';
import 'pages/otp.dart';
import 'pages/weather_forecast_page.dart';
import 'utility/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      home: const SplashScreen(),
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFF121212),
        // Further customizations for dark theme
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/reg': (context) => const RegistrationPage(),
        '/home': (context) => const HomePageNew(),
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfilePage(),
        '/otp': (context) => const OtpPage(),
        '/forecast': (context) => const WeatherForecastPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-navigation removed to allow user to click "Get Start"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF63B3ED),
              Color(0xFF90CDF4),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Weather icon
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.wb_sunny_outlined,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              // Title
              Text(
                'Weather',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Forecasts',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 20),
              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Lorem ipsum is simply dummy text of the printing and typesetting standard text over the 1500s',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 60),
              // Get Start button
              Material(
                color: Color(0xFFFDB813),
                borderRadius: BorderRadius.circular(30),
                elevation: 8,
                shadowColor: Color(0xFFFDB813).withOpacity(0.5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Container(
                    width: 200,
                    height: 55,
                    alignment: Alignment.center,
                    child: Text(
                      'Get Start',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
}
