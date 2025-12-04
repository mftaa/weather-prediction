import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DarkHomePage extends StatefulWidget {
  const DarkHomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<DarkHomePage> {
  double rating = 0.0;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather Station",
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the icon color to white
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[

            Column(
              children: [
                const SizedBox(height: 8.0), // Add space above the search bar
                Container(
                  color: Colors.black.withOpacity(0.0),
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    decoration: InputDecoration(
                      hintText: 'Search for cities',
                      hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon:
                      Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        // Adjust the radius as needed
                      ),
                    ),
                    onChanged: (value) {
                      // Handle search logic here
                    },
                  ),
                ),
                const SizedBox(height: 8.0), // Add space between the search bar and information boxes
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  color: Colors.black.withOpacity(0.0),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoBox("Temperature", "25°C", Icons.thermostat),
                      const SizedBox(width: 8.0), // Add space between Temperature and Humidity boxes
                      _buildInfoBox("Humidity", "60%", Icons.opacity),
                      const SizedBox(width: 8.0), // Add space between Humidity and Light Intensity boxes
                      _buildInfoBox("Wind Speed", "21 km/hr", Icons.wind_power),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0), // Add space below the information boxes and before the new information boxes
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  color: Colors.black.withOpacity(0.0),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoBox("Air Pressure", "1012 hPa", Icons.compress),
                      const SizedBox(width: 8.0), // Add space between Air Pressure and Visibility boxes
                      _buildInfoBox("Visibility", "10 km", Icons.visibility),
                      const SizedBox(width: 8.0), // Add space between Visibility and Rain boxes
                      _buildInfoBox("Rain", "5 mm", Icons.beach_access),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0), // Add space below the new information boxes and before the circular summary section
                _buildCircularSummary(),
                const SizedBox(height: 16.0), // Add space between the circular summary and the forecast table
                _buildSevenDayForecastTable(),
              ],
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Mamur Sayor',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '1901029@iot.bdu.ac.bd',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/darkprofile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/darksettings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 50.0,
              height: 60.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white,size: 30.0),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Share App'),
                            content: const Text('Share the app logic goes here.'),
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
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 50.0,
              height: 60.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.feedback,color: Colors.white,size: 30.0 ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String userFeedback = '';

                          return AlertDialog(
                            title: const Text('Feedback'),
                            content: SizedBox(
                              height: 150.0,
                              child: Column(
                                children: [
                                  const SizedBox(height: 6.0),
                                  TextField(
                                    maxLines: 4,
                                    onChanged: (value) {
                                      userFeedback = value;
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Type your feedback here...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  print('User Feedback: $userFeedback');
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
            SizedBox(
              width: 60.0,
              height: 60.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.star, color: Colors.white,size: 30.0),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Rating'),
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
          ],
        ), // Set the BottomAppBar background color to black
      ),
    );
  }

  Widget _buildInfoBox(String title, String value, IconData iconData) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Icon(iconData, color: Colors.white, size: 30.0),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4.0),
            Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularSummary() {
    return Container(
      width: 180.0,
      height: 180.0,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            // Add your circular summary widgets here
            Icon(Icons.cloud, color: Colors.white, size: 30.0),
            SizedBox(height: 4.0),
            Text(
              'Cloudy',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSevenDayForecastTable() {
    // Add your 7-day forecast table here
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '7 Day Forecast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 150.0),

          // Add your 7-day forecast table widgets here
        ],
      ),
    );
  }


}
