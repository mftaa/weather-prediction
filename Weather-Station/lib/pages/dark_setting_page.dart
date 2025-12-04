import 'package:flutter/material.dart';

class DarkSettingsPage extends StatefulWidget {
  const DarkSettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<DarkSettingsPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [


          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Weather Station Settings",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // 50% transparent black
                    borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Existing settings
                      ListTile(
                        title: const Text(
                          "Temperature Unit",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: const Text(
                          "Celsius",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                        onTap: () {
                          // Handle temperature unit selection
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "Notification Settings",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: const Text(
                          "Receive weather updates",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                        onTap: () {
                          // Handle notification settings
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "Permissions",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: const Text(
                          "Location, Gyroscope",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                        onTap: () {
                          // Handle notification settings
                        },
                      ),

                      // Dark Mode Switch
                      ListTile(
                        title: const Text(
                          "Light Mode",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              isDarkMode = value;
                              if (isDarkMode) {
                                // Navigate to the /darksettings page
                                Navigator.pushNamed(context, '/home');
                              }
                            });
                          },
                          activeThumbColor: Colors.white,
                          activeTrackColor: Colors.grey,
                        ),
                      ),
                      // Add more settings as needed
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
