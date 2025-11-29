import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/auth/verification/verification_bloc.dart';
import '../../../../blocs/auth/verification/verification_event.dart';
import '../../../../blocs/auth/verification/verification_state.dart';
import '../../../../core/theme/theme.dart';
import '../../../../route/route.dart';
import '../../../widgets/floating_message.dart';

class ResendOtpPage extends StatelessWidget {
  const ResendOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerificationBloc, VerificationState>(
      listener: (context, state) {
        if (state.resendStatus == ResendOtpStatus.success) {
          FloatingMessage.show(
            context,
            message: 'Kode OTP berhasil dikirim ke email Anda',
            backgroundColor: primaryGreenColor,
            icon: Icons.check_circle_outline,
            duration: const Duration(seconds: 2),
          );

          // Auto redirect ke verification page
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.verification,
                arguments: {
                  'userId': state.userId,
                  'email': state.email,
                },
              );
            }
          });
        } else if (state.resendStatus == ResendOtpStatus.failure) {
          FloatingMessage.show(
            context,
            message: state.errorMessage ?? 'Gagal mengirim OTP',
            backgroundColor: Colors.red,
            icon: Icons.error_outline,
            duration: const Duration(seconds: 3),
          );

          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              context.read<VerificationBloc>().add(const ResendOtpResetStatus());
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Kirim Ulang OTP',
            style: TextStyle(
              fontFamily: fontType,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryGreenColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 64,
                    color: primaryGreenColor,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Kirim Ulang Kode Verifikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: fontType,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  'Masukkan email Anda untuk menerima kode OTP verifikasi baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: fontType,
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // Email Input Field
                const _EmailField(),

                const SizedBox(height: 32),

                // Submit Button
                const _SubmitButton(),

                const SizedBox(height: 24),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pastikan email yang Anda masukkan adalah email yang digunakan saat registrasi',
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 13,
                            color: Colors.blue[700],
                            height: 1.4,
                          ),
                        ),
                      ),
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
}

// Email Field Widget
class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerificationBloc, VerificationState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (value) {
                context.read<VerificationBloc>().add(ResendOtpEmailChanged(value));
              },
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Masukkan email Anda',
                hintStyle: TextStyle(
                  fontFamily: fontType,
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Colors.grey[600],
                ),
                errorText: state.emailError,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: primaryGreenColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        );
      },
    );
  }
}

// Submit Button Widget
class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerificationBloc, VerificationState>(
      builder: (context, state) {
        final isLoading = state.status == ResendOtpStatus.loading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreenColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: isLoading
                ? null
                : () {
              context.read<VerificationBloc>().add(const ResendOtpSubmitted());
            },
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              'Kirim Kode OTP',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}