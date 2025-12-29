import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/route/route.dart';
import '../../../../blocs/auth/login/login_bloc.dart';
import '../../../../blocs/auth/login/login_event.dart';
import '../../../../blocs/auth/login/login_state.dart';
import '../../../../core/theme/theme.dart';
import '../../../widgets/floating_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // context.read<LoginBloc>().add(const LoginLoadCurrentUser());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Unfocus untuk dismiss keyboard
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();

    context.read<LoginBloc>().add(const LoginSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: _handleBlocListener,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              // Dismiss keyboard when tap outside
              _emailFocusNode.unfocus();
              _passwordFocusNode.unfocus();
            },
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const _LoginHeader(),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _EmailField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                onSubmitted: () => _passwordFocusNode.requestFocus(),
                              ),
                              const SizedBox(height: 24),
                              _PasswordField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                obscurePassword: _obscurePassword,
                                onToggleVisibility: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                                onSubmitted: _handleLogin,
                              ),
                              const SizedBox(height: 24),
                              const _SignUpPrompt(),
                              const SizedBox(height: 16),
                              const _ResendOtpPrompt(),
                              const SizedBox(height: 32),
                              _LoginButton(onPressed: _handleLogin),
                              const SizedBox(height: 16),
                              const _ForgotPasswordPrompt()
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleBlocListener(BuildContext context, LoginState state) {
    switch (state.status) {
      case LoginStatus.needsVerification:
        _navigateToVerification(context, state);
        break;
      case LoginStatus.success:
        _handleLoginSuccess(context);
        break;
      case LoginStatus.failure:
        if (state.errorMessage != null) {
          _showErrorMessage(context, state.errorMessage!);
        }
        break;
      default:
        break;
    }
  }

  void _navigateToVerification(BuildContext context, LoginState state) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.verification,
      arguments: {
        'userId': state.userId,
        'email': state.userEmail,
      },
    );
  }

  void _handleLoginSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login berhasil!'),
        backgroundColor: primaryGreenColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1500),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.authChecker);
      }
    });
  }

  void _showErrorMessage(BuildContext context, String message) {
    FloatingMessage.show(
      context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error_outline,
      duration: const Duration(seconds: 3),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.read<LoginBloc>().add(const LoginResetStatus());
      }
    });
  }
}

// ==================== HEADER ====================
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Hero(
            tag: 'app_logo',
            child: SizedBox(
              height: 95,
              width: 95,
              child: Image.asset(
                'assets/icon/auropay_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== EMAIL FIELD ====================
class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;

  const _EmailField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) =>
      previous.email != current.email ||
          previous.emailError != current.emailError,
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
              controller: controller,
              focusNode: focusNode,
              onChanged: (value) {
                context.read<LoginBloc>().add(LoginEmailChanged(value));
              },
              onFieldSubmitted: (_) => onSubmitted(),
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 15,
              ),
              decoration: _buildInputDecoration(
                hintText: 'Masukan Email',
                errorText: state.emailError,
                prefixIcon: Icons.email_outlined,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
            ),
          ],
        );
      },
    );
  }
}

// ==================== PASSWORD FIELD ====================
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmitted;

  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.obscurePassword,
    required this.onToggleVisibility,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) =>
      previous.password != current.password ||
          previous.passwordError != current.passwordError,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kata Sandi',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (value) {
                context.read<LoginBloc>().add(LoginPasswordChanged(value));
              },
              onFieldSubmitted: (_) => onSubmitted(),
              obscureText: obscurePassword,
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 15,
              ),
              decoration: _buildInputDecoration(
                hintText: 'Masukan Kata Sandi',
                errorText: state.passwordError,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: onToggleVisibility,
                ),
              ),
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableSuggestions: false,
            ),
          ],
        );
      },
    );
  }
}

// ==================== INPUT DECORATION ====================
InputDecoration _buildInputDecoration({
  required String hintText,
  String? errorText,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      fontFamily: fontType,
      color: Colors.grey[400],
      fontSize: 14,
    ),
    errorText: errorText,
    errorMaxLines: 2,
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: Colors.grey[600])
        : null,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: primaryGreenColor,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );
}

// ==================== SIGN UP PROMPT ====================
class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum punya akun? ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: fontType,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.register),
          child: const Text(
            'Daftar',
            style: TextStyle(
              fontSize: 14,
              color: primaryGreenColor,
              fontWeight: FontWeight.w600,
              fontFamily: fontType,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== RESEND OTP PROMPT ====================
class _ResendOtpPrompt extends StatelessWidget {
  const _ResendOtpPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum dapat kode OTP? ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: fontType,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.resendOtp),
          child: const Text(
            'Kirim Ulang',
            style: TextStyle(
              fontSize: 14,
              color: primaryGreenColor,
              fontWeight: FontWeight.w600,
              fontFamily: fontType,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== LOGIN BUTTON ====================
class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        final isLoading = state.status == LoginStatus.loading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreenColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text('Login'),
          ),
        );
      },
    );
  }
}

// ==================== FORGOT PASSWORD PROMPT ====================
class _ForgotPasswordPrompt extends StatelessWidget {
  const _ForgotPasswordPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
        child: const Text(
          'Lupa Kata Sandi?',
          style: TextStyle(
            fontSize: 14,
            color: primaryGreenColor,
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
      ),
    );
  }
}