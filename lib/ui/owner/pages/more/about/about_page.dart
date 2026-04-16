import 'package:flutter/material.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../guide/guide_page.dart';
// import 'guide_page.dart'; // arahkan ke halaman PDF kamu

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Tentang Aplikasi'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Judul
            const Text(
              'AURO App',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Deskripsi
            const Text(
              'AURO merupakan sistem digital yang dirancang untuk membantu pengelolaan bisnis secara lebih efisien dan terintegrasi. '
                  'Melalui aplikasi ini, pengguna dapat memantau performa bisnis, mengelola data toko, serta menganalisis laporan transaksi '
                  'dalam satu platform yang mudah digunakan.\n\n'
                  'Aplikasi ini menyediakan berbagai fitur seperti dashboard monitoring, manajemen toko, serta laporan transaksi yang '
                  'dapat digunakan sebagai dasar dalam pengambilan keputusan bisnis secara lebih cepat dan akurat.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),

            const SizedBox(height: 24),

            // 🔹 Tombol buka panduan PDF
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GuidePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Lihat Panduan Pengguna'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}