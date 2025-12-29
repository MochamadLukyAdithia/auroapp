import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/theme.dart';
import '../../../../data/repositories/company_repository.dart';
import '../../../../route/route.dart';

/// Widget untuk mengecek apakah user sudah setup company atau belum
/// Jika belum, redirect ke OnboardingPage
/// Jika sudah, redirect ke Homepage
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    _checkCompanyStatus();
  }

  Future<void> _checkCompanyStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // ✅ Tambah ini

      final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;

      if (!hasCompletedOnboarding) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        return;
      }
      // Cek API untuk memastikan data masih ada
      final companyRepo = context.read<CompanyRepository>();
      final response = await companyRepo.getCompany();

      if (!mounted) return;

      if (response.success && response.data != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.homepage);
      } else {
        // Data hilang dari backend, minta setup ulang
        await prefs.setBool('onboarding_completed', false);
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

    @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: primaryGreenColor,
        ),
      ),
    );
  }
}