import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utility/theme_provider.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
                      _buildIntroduction(),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '1. Penerimaan Ketentuan',
                        content: [
                          'Dengan menggunakan aplikasi Weather Prediction, Anda setuju dengan ketentuan layanan ini. Kami berhak mengubah ketentuan kapan saja.',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '2. Layanan',
                        content: [
                          'Weather Prediction menyediakan:',
                          '• Prediksi cuaca berbasis IoT dan ML',
                          '• Data cuaca real-time',
                          '• Prediksi per jam dan harian',
                          '• Notifikasi cuaca',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '3. Akun Pengguna',
                        content: [
                          'Anda bertanggung jawab untuk:',
                          '• Menjaga kerahasiaan akun',
                          '• Semua aktivitas di akun Anda',
                          '• Memberikan informasi akurat',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '4. Penggunaan yang Dapat Diterima',
                        content: [
                          'Anda TIDAK boleh:',
                          '• Menggunakan layanan untuk tujuan ilegal',
                          '• Mengganggu sistem kami',
                          '• Mengakses sistem tanpa izin',
                          '• Menyalahgunakan data',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '5. Akurasi Prediksi',
                        content: [
                          'PENTING:',
                          '• Prediksi adalah perkiraan, bukan jaminan',
                          '• Kami tidak menjamin 100% akurasi',
                          '• Kondisi cuaca dapat berubah tiba-tiba',
                          '• Jangan jadikan satu-satunya dasar keputusan kritis',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '6. Hak Kekayaan Intelektual',
                        content: [
                          'Semua konten dilindungi hak cipta.',
                          '',
                          'Anda tidak boleh:',
                          '• Menyalin atau memodifikasi konten',
                          '• Melakukan reverse engineering',
                          '• Menggunakan merek kami tanpa izin',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '7. Pembatasan Tanggung Jawab',
                        content: [
                          '• Layanan disediakan "sebagaimana adanya"',
                          '• Kami tidak bertanggung jawab atas kerugian',
                          '• Tidak ada jaminan bebas dari kesalahan',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '8. Penghentian',
                        content: [
                          'Kami dapat menangguhkan akses Anda kapan saja untuk pelanggaran ketentuan atau pemeliharaan sistem.',
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSection(
                        title: '9. Kontak',
                        content: [
                          'Untuk pertanyaan:',
                          '',
                          'Email: support@weatherprediction.app',
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
                'Terms of Service',
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

  Widget _buildIntroduction() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Ketentuan Layanan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Selamat datang di Weather Prediction. Mohon baca Ketentuan Layanan ini dengan seksama sebelum menggunakan aplikasi kami.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 14,
              height: 1.5,
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
