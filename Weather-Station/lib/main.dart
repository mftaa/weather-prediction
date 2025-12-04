import 'package:flutter/material.dart';
import 'pages/dark_profile.dart';
import 'pages/dark_setting_page.dart';
import 'pages/loginpage.dart';
import 'pages/registration.dart';
import 'pages/home.dart';
import 'pages/settings.dart';
import 'pages/profile.dart';
import 'pages/dark_home.dart';
import 'pages/otp.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/reg': (context) => const RegistrationPage(),
        '/home': (context) => const HomePage(), // Add this line
        '/settings': (context) => const SettingsPage(),
        '/profile':(context) => const ProfilePage(),
        '/darksettings': (context) => const DarkSettingsPage(),
        '/darkhome': (context) => const DarkHomePage(),
        '/darkprofile': (context) => const DarkProfilePage(),
        '/otp': (context) => const OtpPage(),

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
    // After 1 seconds, navigate to the login page
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
