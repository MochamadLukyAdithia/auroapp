import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_mobile/route/route.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _checkFirstTimeAndLogin();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstTimeAndLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (hasSeenOnboarding) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final accessToken = prefs.getString('access_token');
      final needsVerification = prefs.getBool('needs_verification') ?? false;

      final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;

      if (needsVerification) {
        await prefs.remove('needs_verification');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
      else if (isLoggedIn && accessToken != null && hasCompletedOnboarding) {
        Navigator.pushReplacementNamed(context, AppRoutes.homepage);
      }
      else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
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

  void _startApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: const [
              SplashPage1(),
              SplashPage2(),
              SplashPage3(),
            ],
          ),

          // Skip button (hanya di halaman 1 & 2)
          if (_currentPage < 2)
            Positioned(
              top: MediaQuery.of(context).padding.top + (isLandscape ? 8 : r.spacing(mobile: 16, tablet: 24)),
              right: r.spacing(mobile: 20, tablet: 32),
              child: Material(
                color: _currentPage == 0
                    ? Colors.grey.shade200
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: _skipToLogin,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.spacing(mobile: 20, tablet: 28),
                      vertical: r.spacing(mobile: 8, tablet: 12),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: r.fontSize(mobile: 14, tablet: 18),
                        color: _currentPage == 0 ? Colors.grey.shade700 : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Segoe',
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Bottom section: Indicator + Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + (isLandscape ? 12 : r.spacing(mobile: 20, tablet: 32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(
                          horizontal: r.spacing(mobile: 4, tablet: 6),
                        ),
                        width: _currentPage == index
                            ? r.size(mobile: 32, tablet: 40)
                            : r.size(mobile: 8, tablet: 12),
                        height: r.size(mobile: 8, tablet: 12),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? (_currentPage == 1 ? Colors.white : primaryGreenColor)
                              : (_currentPage == 1 ? Colors.white.withOpacity(0.4) : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(
                            r.size(mobile: 4, tablet: 6),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isLandscape ? 16 : r.spacing(mobile: 24, tablet: 32)),

                  // Button "Mulai" (hanya di halaman 3)
                  if (_currentPage == 2)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.spacing(mobile: 40, tablet: 60),
                      ),
                      child: AnimatedOpacity(
                        opacity: _currentPage == 2 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: SizedBox(
                          width: r.isTablet ? 400 : double.infinity,
                          child: ElevatedButton(
                            onPressed: _startApp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreenColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: isLandscape ? 12 : r.spacing(mobile: 16, tablet: 20),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Mulai Sekarang',
                              style: TextStyle(
                                fontSize: r.fontSize(mobile: 16, tablet: 18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(height: isLandscape ? 48 : r.spacing(mobile: 56, tablet: 68)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Splash Page 1 - Logo ============
class SplashPage1 extends StatelessWidget {
  const SplashPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo dengan animasi subtle
                Container(
                  // padding: EdgeInsets.all(isLandscape ? 30 : r.spacing(mobile: 40, tablet: 60)),
                  // decoration: BoxDecoration(
                  //   color: Colors.grey.shade100,
                  //   shape: BoxShape.circle,
                  // ),
                  child: Image.asset(
                    'assets/icon/auropay_logo.png',
                    width: isLandscape
                        ? r.screenWidth * 0.3
                        : (r.isTablet ? r.screenWidth * 0.4 : r.screenWidth * 0.6),
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: isLandscape ? 20 : r.spacing(mobile: 40, tablet: 60)),
                // Tagline
                // Text(
                //   'Solusi Kasir Digital Anda',
                //   style: TextStyle(
                //     fontSize: isLandscape ? 14 : r.fontSize(mobile: 16, tablet: 22),
                //     color: Colors.grey.shade700,
                //     fontWeight: FontWeight.w500,
                //     letterSpacing: 1.2,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============ Splash Page 2 - Selamat Datang ============
class SplashPage2 extends StatelessWidget {
  const SplashPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryBlueColor, primaryGreenColor],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: r.spacing(mobile: 40, tablet: 80),
                  vertical: isLandscape ? 20 : 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(isLandscape ? 16 : r.spacing(mobile: 24, tablet: 32)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.handshake_rounded,
                        size: isLandscape ? 60 : r.size(mobile: 80, tablet: 120),
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: isLandscape ? 24 : r.spacing(mobile: 40, tablet: 60)),

                    // Title
                    Text(
                      'SELAMAT DATANG',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLandscape ? 24 : r.fontSize(mobile: 32, tablet: 48),
                        fontWeight: FontWeight.bold,
                        fontFamily: fontType,
                        color: Colors.white,
                        letterSpacing: 2,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: isLandscape ? 8 : r.spacing(mobile: 12, tablet: 16)),

                    Text(
                      'DI AURO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLandscape ? 24 : r.fontSize(mobile: 32, tablet: 48),
                        fontWeight: FontWeight.bold,
                        fontFamily: fontType,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        letterSpacing: 2,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: isLandscape ? 20 : r.spacing(mobile: 32, tablet: 48)),

                    // Description
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.spacing(mobile: 24, tablet: 40),
                        vertical: isLandscape ? 12 : r.spacing(mobile: 16, tablet: 24),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Selamat datang para UMKM!\n\nSetiap usaha selalu dimulai dengan satu langkah kecil, anda sudah satu langkah lebih maju.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isLandscape ? 12 : r.fontSize(mobile: 14, tablet: 18),
                          color: Colors.white.withOpacity(0.95),
                          fontFamily: fontType,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Splash Page 3 - Sudah Siap ============
class SplashPage3 extends StatelessWidget {
  const SplashPage3({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: r.spacing(mobile: 40, tablet: 80),
              vertical: isLandscape ? 20 : 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rocket icon with glow effect
                Container(
                  width: isLandscape ? 120 : r.size(mobile: 180, tablet: 260),
                  height: isLandscape ? 120 : r.size(mobile: 180, tablet: 260),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryGreenColor.withOpacity(0.2),
                        primaryBlueColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    size: isLandscape ? 70 : r.size(mobile: 100, tablet: 140),
                    color: primaryGreenColor,
                  ),
                ),

                SizedBox(height: isLandscape ? 24 : r.spacing(mobile: 48, tablet: 64)),

                // Title
                Text(
                  'SUDAH SIAP?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isLandscape ? 28 : r.fontSize(mobile: 36, tablet: 52),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                    letterSpacing: 2,
                  ),
                ),

                SizedBox(height: isLandscape ? 12 : r.spacing(mobile: 20, tablet: 28)),

                // Description
                Text(
                  'Mari kita mulai perjalanan bisnis Anda bersama AURO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isLandscape ? 13 : r.fontSize(mobile: 16, tablet: 20),
                    color: Colors.grey.shade700,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: isLandscape ? 8 : r.spacing(mobile: 12, tablet: 16)),

                // Features
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: r.spacing(mobile: 20, tablet: 40),
                  ),
                  padding: EdgeInsets.all(isLandscape ? 12 : r.spacing(mobile: 20, tablet: 28)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildFeature(r, isLandscape, Icons.speed_rounded, 'Transaksi Cepat'),
                      SizedBox(height: isLandscape ? 8 : r.spacing(mobile: 12, tablet: 16)),
                      _buildFeature(r, isLandscape, Icons.analytics_rounded, 'Laporan Real-time'),
                      SizedBox(height: isLandscape ? 8 : r.spacing(mobile: 12, tablet: 16)),
                      _buildFeature(r, isLandscape, Icons.security_rounded, 'Aman & Terpercaya'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(ResponsiveHelper r, bool isLandscape, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryGreenColor,
          size: isLandscape ? 20 : r.size(mobile: 24, tablet: 32),
        ),
        SizedBox(width: isLandscape ? 8 : r.spacing(mobile: 12, tablet: 16)),
        Text(
          text,
          style: TextStyle(
            fontSize: isLandscape ? 12 : r.fontSize(mobile: 14, tablet: 18),
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}