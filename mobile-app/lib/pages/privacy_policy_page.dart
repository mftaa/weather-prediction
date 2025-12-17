import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utility/theme_provider.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildLastUpdated(),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: '1. Informasi yang Kami Kumpulkan',
                        content: [
                          '• Informasi akun (nama, email, password)',
                          '• Data lokasi untuk prediksi cuaca',
                          '• Data sensor cuaca dari perangkat IoT',
                          '• Preferensi pengaturan aplikasi',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '2. Penggunaan Informasi',
                        content: [
                          '• Menyediakan prediksi cuaca yang akurat',
                          '• Meningkatkan kualitas prediksi dengan ML',
                          '• Mengirim notifikasi cuaca penting',
                          '• Menganalisis tren dan pola cuaca',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '3. Keamanan Data',
                        content: [
                          '• Enkripsi data saat transmisi dan penyimpanan',
                          '• Akses terbatas ke data pribadi',
                          '• Pemantauan keamanan berkala',
                          '• Backup data teratur',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '4. Berbagi Informasi',
                        content: [
                          'Kami tidak menjual atau menyewakan data pribadi Anda.',
                          '',
                          'Data hanya dibagikan dengan:',
                          '• Persetujuan Anda',
                          '• Kewajiban hukum',
                          '• Data agregat untuk penelitian (tanpa identitas)',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '5. Hak Anda',
                        content: [
                          '• Mengakses dan memperbarui data pribadi',
                          '• Menghapus akun dan data',
                          '• Menolak penggunaan data tertentu',
                          '• Mengunduh data Anda',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '6. Kontak',
                        content: [
                          'Hubungi kami untuk pertanyaan:',
                          '',
                          'Email: privacy@weatherprediction.app',
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
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
                'Privacy Policy',
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

  Widget _buildLastUpdated() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Icon(Icons.update, color: Colors.white.withOpacity(0.9), size: 20),
          const SizedBox(width: 10),
          Text(
            'Last Updated: November 2025',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> content,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...content.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
