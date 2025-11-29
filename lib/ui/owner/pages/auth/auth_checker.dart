import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

      if (response.success) {
        // Cek apakah data company ada atau null
        if (response.data == null) {
          // User belum setup company, ke onboarding
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        } else {
          // User sudah setup company, ke homepage
          Navigator.pushReplacementNamed(context, AppRoutes.homepage);
        }
      } else {
        // Error, ke onboarding untuk safety
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    } catch (e) {
      if (!mounted) return;
      // Error, ke onboarding
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