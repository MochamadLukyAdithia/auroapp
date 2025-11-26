import 'package:flutter/material.dart';
import 'package:pos_mobile/route/route.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _skipToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void initState() {
    super.initState();
    _checkFirstTimeAndLogin();
  }

  Future<void> _checkFirstTimeAndLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!hasSeenOnboarding) {
      return; // Tetap di onboarding
    }

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // 🆕 Validasi lebih ketat
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final currentUserData = prefs.getString('current_user_data');
    final accessToken = prefs.getString('access_token');

    // Cek apakah benar-benar ada session yang valid
    if (isLoggedIn && currentUserData != null && accessToken != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.homepage);
    } else {
      await prefs.clear();

      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _startApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button - hanya muncul di halaman 0 dan 1
            if (_currentPage < 2)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipToLogin,
                  child: const Text('Skip',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Segoe'
                    ),),

                ),
              )
            else
              const SizedBox(height: 48), // Spacing agar tidak shift layout

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(), // Smooth scrolling
                children: const [
                  SplashPage1(),
                  SplashPage2(),
                  SplashPage3(),
                ],
              ),
            ),

            // Indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.green
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Button "Mulai" hanya muncul di halaman terakhir
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedOpacity(
                opacity: _currentPage == 2 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _currentPage == 2 ? _startApp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text('Mulai'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ Splash Page 1 ============
class SplashPage1 extends StatelessWidget {
  const SplashPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.8;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icon/auropay_logo.png',
            width: logoWidth,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class SplashPage2 extends StatelessWidget {
  const SplashPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryBlueColor,
            primaryGreenColor,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Judul
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontType,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(text: 'SELAMAT DATANG\nDI '),
                    TextSpan(
                      text: 'AURO PAY',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Deskripsi
              Text(
                'Selamat datang para UMKM!\nSetiap usaha selalu dimulai dengan satu\nlangkah kecil, anda sudah satu langkah lebih maju.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.95),
                  fontFamily: fontType,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ============ Splash Page 3 ============
class SplashPage3 extends StatelessWidget {
  const SplashPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.rocket_launch,
              size: 100,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'SUDAH SIAP?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}