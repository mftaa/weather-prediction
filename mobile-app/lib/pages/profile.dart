import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
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
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildMenuCard(context),
                    const SizedBox(height: 20),
                    _buildLogoutButton(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 44), // To balance the back button
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: const CircleAvatar(
              radius: 46,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?u=a042581f4e29026704d',
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Mamur Sayor',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '1901029@iot.bdu.ac.bd',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildMenuListTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {},
          ),
          _buildMenuListTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {},
          ),
          _buildMenuListTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: isLast 
            ? const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
            : BorderRadius.zero,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.2))),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
      icon: const Icon(Icons.logout, color: Color(0xFF5B9FE3)),
      label: const Text(
        'Logout',
        style: TextStyle(
          color: Color(0xFF5B9FE3),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
    );
  }
}