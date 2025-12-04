import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                const CircleAvatar(
                  radius: 70,
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
                      // Name and Email Box
                      const Column(
                        children: [
                          Text(
                            'Mamur Sayor',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '1901029@iot.bdu.ac.bd',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 24.0),
                        ],
                      ),

                      // Edit Profile Box
                      ListTile(
                        title: const Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: const Icon(Icons.edit, color: Colors.white),
                        onTap: () {
                          // Handle profile editing
                        },
                      ),
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
