import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/route/route.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import '../../../../blocs/auth/register/register_bloc.dart';
import '../../../../blocs/auth/register/register_event.dart';
import '../../../../blocs/auth/register/register_state.dart';
import '../../../../core/theme/theme.dart';
import '../../../widgets/floating_message.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<RegisterBloc>().add(const RegisterReset());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.hasExistingOwner) {
          FloatingMessage.show(
            context,
            message: 'Akun owner sudah terdaftar: ${state.existingOwnerEmail}',
            backgroundColor: Colors.red,
            icon: Icons.error_outline,
            duration: const Duration(seconds: 3),
          );
          return;
        }

        if (state.status == RegisterStatus.success) {
          final userId = state.userId;
          // ✅ ambil email dari state (sudah disimpan di bloc saat success)
          final email = state.email;

          FloatingMessage.show(
            context,
            message: 'Registrasi berhasil! Silakan verifikasi email',
            backgroundColor: primaryGreenColor,
            icon: Icons.check_circle_outline,
            duration: const Duration(seconds: 2),
          );

          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.verification,
                arguments: {
                  'userId': userId,
                  'email': email,
                },
              );
            }
          });
        } else if (state.status == RegisterStatus.failure &&
            state.errorMessage != null) {
          FloatingMessage.show(
            context,
            message: state.errorMessage!,
            backgroundColor: Colors.red,
            icon: Icons.error_outline,
            duration: const Duration(seconds: 3),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: 'Registrasi'),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const _FullNameField(),
                  const SizedBox(height: 24),
                  const _EmailField(),
                  const SizedBox(height: 24),
                  _PasswordField(
                    label: 'Kata Sandi*',
                    hint: 'Masukkan Kata Sandi',
                    obscureText: _obscurePassword,
                    onChanged: (value) {
                      context
                          .read<RegisterBloc>()
                          .add(RegisterPasswordChanged(value));
                    },
                    onToggleVisibility: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    errorSelector: (state) => state.passwordError,
                  ),
                  const SizedBox(height: 24),
                  _PasswordField(
                    label: 'Konfirmasi Kata Sandi*',
                    hint: 'Masukkan Konfirmasi Kata Sandi',
                    obscureText: _obscureConfirmPassword,
                    onChanged: (value) {
                      context
                          .read<RegisterBloc>()
                          .add(RegisterConfirmPasswordChanged(value));
                    },
                    onToggleVisibility: () {
                      setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    errorSelector: (state) => state.confirmPasswordError,
                  ),
                  const SizedBox(height: 24),
                  const _PhoneField(),
                  const SizedBox(height: 24),
                  // ✅ FIX: gunakan _SourceInfoDropdown yang terhubung ke BLoC
                  const _SourceInfoDropdown(),
                  const SizedBox(height: 24),
                  const _LoginPrompt(),
                  const SizedBox(height: 32),
                  const _RegisterButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- Source Info Dropdown ----------------
// ✅ FIX: sekarang stateless & terhubung ke BLoC
class _SourceInfoDropdown extends StatelessWidget {
  const _SourceInfoDropdown();

  static const List<String> _items = [
    "Kementerian",
    "UMKM",
    "Teman/Saudara",
    "Website",
    "Tiktok",
    "Instagram",
    "Facebook",
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (prev, curr) =>
      prev.source != curr.source || prev.sourceError != curr.sourceError,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dari mana Anda mengetahui informasi tentang AURO?',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              // ✅ value diambil dari state BLoC, bukan local state
              value: state.source,
              hint: const Text(
                "Pilih sumber informasi",
                style: TextStyle(fontFamily: fontType),
              ),
              items: _items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontFamily: fontType),
                  ),
                );
              }).toList(),
              // ✅ FIX: dispatch event ke BLoC saat nilai berubah
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<RegisterBloc>()
                      .add(RegisterSourceChanged(value));
                }
              },
              decoration: InputDecoration(
                // ✅ tampilkan error dari state
                errorText: state.sourceError,
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
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------- Full Name Field ----------------
class _FullNameField extends StatelessWidget {
  const _FullNameField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (prev, curr) => prev.nameError != curr.nameError,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nama Lengkap*',
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
                context.read<RegisterBloc>().add(RegisterNameChanged(value));
              },
              style: const TextStyle(fontFamily: fontType, fontSize: 15),
              decoration: _buildInputDecoration(
                hintText: 'Masukan Nama Lengkap',
                errorText: state.nameError,
              ),
              keyboardType: TextInputType.name,
            ),
          ],
        );
      },
    );
  }
}

// ---------------- Email Field ----------------
class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (prev, curr) => prev.emailError != curr.emailError,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email*',
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
                context.read<RegisterBloc>().add(RegisterEmailChanged(value));
              },
              style: const TextStyle(fontFamily: fontType, fontSize: 15),
              decoration: _buildInputDecoration(
                hintText: 'Masukan Email',
                errorText: state.emailError,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        );
      },
    );
  }
}

// ---------------- Password Field ----------------
class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscureText;
  final Function(String) onChanged;
  final VoidCallback onToggleVisibility;
  final String? Function(RegisterState) errorSelector;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.obscureText,
    required this.onChanged,
    required this.onToggleVisibility,
    required this.errorSelector,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: onChanged,
              obscureText: obscureText,
              style: const TextStyle(fontFamily: fontType, fontSize: 15),
              decoration: _buildInputDecoration(
                hintText: hint,
                errorText: errorSelector(state),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: onToggleVisibility,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------- Phone Field ----------------
class _PhoneField extends StatelessWidget {
  const _PhoneField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (prev, curr) => prev.phoneError != curr.phoneError,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nomor Handphone*',
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
                context.read<RegisterBloc>().add(RegisterPhoneChanged(value));
              },
              style: const TextStyle(fontFamily: fontType, fontSize: 15),
              decoration: _buildInputDecoration(
                hintText: 'Masukan Nomor Handphone',
                errorText: state.phoneError,
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        );
      },
    );
  }
}

// ---------------- Input Decoration Helper ----------------
InputDecoration _buildInputDecoration({
  required String hintText,
  String? errorText,
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
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      borderSide: const BorderSide(color: primaryGreenColor, width: 2),
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

// ---------------- Login Prompt ----------------
class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sudah punya akun? ',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Login',
            style: TextStyle(
              fontSize: 14,
              color: primaryGreenColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------- Register Button ----------------
class _RegisterButton extends StatelessWidget {
  const _RegisterButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) {
        final isLoading = state.status == RegisterStatus.loading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreenColor,
              foregroundColor: Colors.white,
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
            onPressed: isLoading
                ? null
                : () {
              context
                  .read<RegisterBloc>()
                  .add(const RegisterSubmitted());
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
                : const Text('Daftar'),
          ),
        );
      },
    );
  }
}