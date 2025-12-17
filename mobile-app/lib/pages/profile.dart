import 'package:provider/provider.dart';
import '../utility/theme_provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'variables.dart'; // To access myUsername

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = "Loading...";
  String _email = "Loading...";
  bool _isLoading = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _fetchUserProfile();
  }

  void _loadNotificationSettings() {
    setState(() {
      _notificationsEnabled = NotificationService().notificationsEnabled;
    });
  }

  Future<void> _fetchUserProfile() async {
    if (myUsername.isEmpty) {
      setState(() {
        _username = "Guest";
        _email = "Not logged in";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.get('/auth/user-info?username=$myUsername');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _username = data['username'] ?? "Unknown";
            _email = data['email'] ?? "No Email";
            _isLoading = false;
          });
        }
      } else {
        _handleError("Failed to load profile");
      }
    } catch (e) {
      _handleError("Connection error");
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _username = myUsername;
        _email = "Error loading data";
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    NotificationService().toggleNotifications(value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Notifications enabled' : 'Notifications disabled',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // --- Password Reset Logic ---

  Future<void> _startResetPasswordFlow() async {
    // Step 1: Confirm Email & Send OTP
    final emailController = TextEditingController(text: _email != "Loading..." && _email != "Error loading data" ? _email : "");
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your email to receive an OTP."),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty) return;
              Navigator.pop(context); // Close dialog
              await _sendOtp(emailController.text);
            },
            child: const Text("Send OTP"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOtp(String email) async {
    _showLoadingDialog("Sending OTP...");
    try {
      final response = await ApiService.post(
        '/auth/generate-otp',
        body: {'email': email},
      );
      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        _showResetPasswordForm(email);
      } else {
        _showErrorDialog("Failed to send OTP. Please check the email.");
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog("Connection error.");
    }
  }

  void _showResetPasswordForm(String email) {
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Enter New Password"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("OTP sent to $email"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: otpController,
                    decoration: const InputDecoration(
                      labelText: "OTP Code",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setStateDialog(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (otpController.text.isEmpty || newPasswordController.text.isEmpty) return;
                  Navigator.pop(context); // Close form
                  await _submitPasswordReset(email, otpController.text, newPasswordController.text);
                },
                child: const Text("Reset Password"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitPasswordReset(String email, String otp, String newPassword) async {
    _showLoadingDialog("Resetting password...");
    try {
      final response = await ApiService.post(
        '/auth/forgot-password',
        body: {
          'email': email,
          'otp': int.tryParse(otp) ?? 0,
          'password': newPassword,
        },
      );
      Navigator.pop(context); // Close loading

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successfully!")),
        );
      } else {
         final errorData = json.decode(response.body);
        _showErrorDialog(errorData['detail'] ?? "Failed to reset password.");
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog("Connection error during reset.");
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
          const SizedBox(width: 44), 
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
          Text(
            _username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _email,
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
          _buildResetPasswordTile(),
          _buildNotificationTile(),
        ],
      ),
    );
  }

  Widget _buildResetPasswordTile() {
    return _buildMenuListTile(
      icon: Icons.lock_reset_outlined,
      title: 'Reset Password',
      onTap: _startResetPasswordFlow,
      isLast: false,
    );
  }

  Widget _buildNotificationTile() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
         decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          ),
        child: Row(
          children: [
            const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
            const SizedBox(width: 20),
            const Expanded(
              child: Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF5B9FE3),
            ),
          ],
        ),
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
        // Clear global state if needed
        myUsername = "";
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
