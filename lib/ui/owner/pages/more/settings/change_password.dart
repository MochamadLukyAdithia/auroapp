import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/owner/owner_cubit.dart';
import '../../../../../blocs/owner/owner_state.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../widgets/floating_message.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await context.read<ProfileCubit>().changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          // ✅ Handle response dari changePassword
          if (state is PasswordChanged) {
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
            // Success
            FloatingMessage.show(
              context,
              message: state.message,
              backgroundColor: primaryGreenColor,
              icon: Icons.check_circle_outline,
              duration: const Duration(seconds: 2),
            );
            // Clear form dan kembali
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          } else if (state is ProfileUpdateError) {
            // Error
            FloatingMessage.show(
              context,
              message: state.message,
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
        title: const Text(
          'Ubah Kata Sandi',
          style: TextStyle(
            fontFamily: fontType,
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
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
                    Icons.lock_outline,
                    size: 64,
                    color: primaryGreenColor,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Ubah Kata Sandi',
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
                  'Masukkan kata sandi lama dan kata sandi baru Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: fontType,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 40),

                // Current Password Field
                _buildPasswordField(
                  label: 'Kata Sandi Sekarang',
                  hint: 'Masukkan kata sandi sekarang',
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  onToggleVisibility: () {
                    setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi sekarang tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // New Password Field
                _buildPasswordField(
                  label: 'Kata Sandi Baru',
                  hint: 'Masukkan kata sandi baru',
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  onToggleVisibility: () {
                    setState(() => _obscureNewPassword = !_obscureNewPassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi baru tidak boleh kosong';
                    }
                    if (value.length < 8) {
                      return 'Kata sandi minimal 8 karakter';
                    }
                    if (value == _currentPasswordController.text) {
                      return 'Kata sandi baru tidak boleh sama dengan yang lama';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Confirm Password Field
                _buildPasswordField(
                  label: 'Konfirmasi Kata Sandi Baru',
                  hint: 'Masukkan ulang kata sandi baru',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi kata sandi tidak boleh kosong';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Konfirmasi kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
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
                    ),
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Ubah Kata Sandi',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
                          'Kata sandi harus minimal 8 karakter dan tidak boleh sama dengan kata sandi sebelumnya',
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
    )
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?)? validator,
  }) {
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
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: fontType,
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Colors.grey[600],
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: onToggleVisibility,
            ),
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
            errorMaxLines: 2,
          ),
          validator: validator,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}