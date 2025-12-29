import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../blocs/auth/verification/verification_bloc.dart';
import '../../../../blocs/auth/verification/verification_event.dart';
import '../../../../blocs/auth/verification/verification_state.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../route/route.dart';
import '../../../../core/theme/theme.dart';
import '../../../widgets/floating_message.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_countdown > 0) {
          setState(() => _countdown--);
        } else {
          setState(() => _canResend = true);
          timer.cancel();
        }
      }
    });
  }

  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Map<String, dynamic>) {
      return _buildErrorPage(
        'Parameter tidak valid',
        AppRoutes.login,
        'Kembali ke Login',
      );
    }

    final userId = args['userId'] as int?;
    final email = args['email'] as String?;

    if (userId == null || email == null) {
      return _buildErrorPage(
        'Data registrasi tidak lengkap',
        AppRoutes.register,
        'Registrasi Ulang',
      );
    }

    // ✅ BlocProvider di level paling atas
    return BlocProvider(
      create: (context) => VerificationBloc(
        authRepository: context.read<AuthRepository>(),
        userId: userId,
        email: email,
      ),
      // ✅ Content dalam builder baru
      child: Builder(
        builder: (context) => BlocListener<VerificationBloc, VerificationState>(
          listener: (context, state) {
            if (state.status == VerificationStatus.success) {
              FloatingMessage.show(
                context,
                message: 'Verifikasi berhasil! Silakan login',
                backgroundColor: primaryGreenColor,
                icon: Icons.check_circle_outline,
                duration: const Duration(seconds: 2),
              );

              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              });
            } else if (state.status == VerificationStatus.failure) {
              FloatingMessage.show(
                context,
                message: state.errorMessage ?? 'Verifikasi gagal',
                backgroundColor: Colors.red,
                icon: Icons.error_outline,
                duration: const Duration(seconds: 3),
              );
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
                        Icons.mail_outline,
                        size: 64,
                        color: primaryGreenColor,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Verifikasi Email',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    BlocBuilder<VerificationBloc, VerificationState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            const Text(
                              'Kode verifikasi telah dikirim ke',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: fontType,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.email,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: fontType,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: primaryGreenColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // OTP Input Boxes
                  SizedBox(
                      width: double.infinity,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ✅ Ubah ke spaceEvenly
                          children: List.generate(
                              6,
                                  (index) => Flexible( // ✅ Tambah Flexible
                                  child: Container(
                                      constraints: const BoxConstraints(maxWidth: 50), // ✅ Batasi width
                                      margin: const EdgeInsets.symmetric(horizontal: 4), // ✅ Ganti padding dengan margin
                                      child: _OTPBox(
                                          controller: _controllers[index],
                                          focusNode: _focusNodes[index],
                              onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              }
                              if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }

                              final otp = _controllers.map((c) => c.text).join();
                              context.read<VerificationBloc>().add(
                                VerificationOtpChanged(otp),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                      ),
                  ),

                    const SizedBox(height: 40),

                    // Verify Button
                    BlocBuilder<VerificationBloc, VerificationState>(
                      builder: (context, state) {
                        final isLoading = state.status == VerificationStatus.loading;

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
                              context.read<VerificationBloc>().add(
                                const VerificationSubmitted(),
                              );
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
                              'Verifikasi',
                              style: TextStyle(
                                fontFamily: fontType,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Resend OTP Section
                    BlocBuilder<VerificationBloc, VerificationState>(
                      builder: (context, state) {
                        final isLoading = state.status == VerificationStatus.loading;

                        return Column(
                          children: [
                            if (!_canResend)
                              Text(
                                'Kirim ulang kode dalam $_countdown detik',
                                style: TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Tidak menerima kode? ',
                                    style: TextStyle(
                                      fontFamily: fontType,
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                      _clearOtpFields();
                                      context.read<VerificationBloc>().add(
                                        const VerificationResendOtp(),
                                      );
                                      _startCountdown();
                                    },
                                    child: isLoading
                                        ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: primaryGreenColor,
                                      ),
                                    )
                                        : const Text(
                                      'Kirim Ulang',
                                      style: TextStyle(
                                        fontFamily: fontType,
                                        fontSize: 14,
                                        color: primaryGreenColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

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
                              'Periksa folder spam jika tidak menerima email',
                              style: TextStyle(
                                fontFamily: fontType,
                                fontSize: 13,
                                color: Colors.blue[700],
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
        ),
      ),
    );
  }

  Widget _buildErrorPage(String message, String route, String buttonText) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Error',
          style: TextStyle(
            fontFamily: fontType,
            color: Colors.black87,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: fontType,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
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
                  onPressed: () => Navigator.pushReplacementNamed(context, route),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OTPBox extends StatelessWidget {
  const _OTPBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusNode.hasFocus ? primaryGreenColor : Colors.grey[300]!,
          width: focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontFamily: fontType,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: onChanged,
      ),
    );
  }
}