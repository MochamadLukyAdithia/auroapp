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

      final companyRepo = context.read<CompanyRepository>();
      final response = await companyRepo.getCompany();

      if (!mounted) return;

      if (response.success && response.data != null) {

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_completed', true);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.homepage);
      } else {

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_completed', false);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    } catch (e) {
      // Kalau error network, fallback ke SharedPreferences
      // supaya tidak selalu ke onboarding saat offline
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool('onboarding_completed') ?? false;

      if (!mounted) return;

      if (hasCompletedOnboarding) {
        Navigator.pushReplacementNamed(context, AppRoutes.homepage);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
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