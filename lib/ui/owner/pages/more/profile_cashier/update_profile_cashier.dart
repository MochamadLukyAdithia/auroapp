import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/core/theme/theme.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import 'package:pos_mobile/ui/widgets/floating_message.dart';
import '../../../../../../blocs/cashier/cashier_bloc.dart';
import '../../../../../../blocs/cashier/cashier_event.dart';
import '../../../../../../blocs/cashier/cashier_state.dart';
import '../../../../../../data/models/cashier_model.dart';

class UpdateProfileCashier extends StatefulWidget {
  final Cashier? cashier;

  const UpdateProfileCashier({super.key, this.cashier});

  @override
  State<UpdateProfileCashier> createState() => _UpdateProfileCashierState();
}

class _UpdateProfileCashierState extends State<UpdateProfileCashier> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  bool _isPasswordVisible = false;

  bool get isUpdate => widget.cashier != null;

  @override
  void initState() {
    super.initState();

    if (widget.cashier != null) {
      _nameController.text = widget.cashier!.fullName;
      _phoneController.text = widget.cashier!.phoneNumber;
      _addressController.text = widget.cashier!.userAddress ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final cashier = Cashier(
        id: widget.cashier?.id,
        fullName: _nameController.text.trim(),
        email: widget.cashier?.email ?? '',
        password: '',
        passwordConfirmation: '',
        phoneNumber: _phoneController.text.trim(),
        userAddress: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        createdAt: widget.cashier?.createdAt,
        updatedAt: DateTime.now(),
      );

      // ADD
      if (!isUpdate) {
        context.read<CashierBloc>().add(
          AddCashier(
            cashier: cashier,
            password: _passwordController.text,
            passwordConfirmation: _passwordConfirmationController.text,
          ),
        );
      }

      // UPDATE
      else {
        context.read<CashierBloc>().add(
          UpdateCashier(
            cashier: cashier,
            password: _passwordController.text.isEmpty
                ? null
                : _passwordController.text,
            passwordConfirmation: _passwordConfirmationController.text.isEmpty
                ? null
                : _passwordConfirmationController.text,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: isUpdate ? 'Edit Profil Kasir' : 'Tambah Kasir',
      ),
      body: BlocListener<CashierBloc, CashierState>(
        listener: (context, state) {
          if (state is CashierLoaded && state.successMessage != null) {
            FloatingMessage.show(
              context,
              message: state.successMessage!,
              backgroundColor: primaryGreenColor,
            );
            Navigator.pop(context);
          } else if (state is CashierError) {
            FloatingMessage.show(
              context,
              message: state.message,
              backgroundColor: Colors.red,
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InputField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        icon: Icons.person_rounded,
                        hint: 'Masukkan nama lengkap',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama lengkap tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      /// PASSWORD
                      _InputField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_rounded,
                        hint: isUpdate
                            ? 'Kosongkan jika tidak ingin ubah password'
                            : 'Masukkan password',
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Colors.grey[600],
                          ),
                          onPressed: () =>
                              setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),

                        /// VALIDATOR PASSWORD OPTIONAL SAAT UPDATE
                        validator: (value) {
                          if (!isUpdate) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (value.length < 8) {
                              return 'Password minimal 8 karakter';
                            }
                          }

                          if (isUpdate && value!.isNotEmpty && value.length < 8) {
                            return 'Password minimal 8 karakter';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      /// KONFIRMASI
                      _InputField(
                        controller: _passwordConfirmationController,
                        label: 'Konfirmasi Password',
                        icon: Icons.lock_outline_rounded,
                        hint: isUpdate
                            ? 'Kosongkan jika tidak ubah password'
                            : 'Ulangi password',
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Colors.grey[600],
                          ),
                          onPressed: () =>
                              setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),

                        /// VALIDATOR (OPTIONAL SAAT UPDATE)
                        validator: (value) {
                          if (!isUpdate) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password tidak boleh kosong';
                            }
                          }

                          if (value != _passwordController.text &&
                              value!.isNotEmpty) {
                            return 'Konfirmasi password tidak sesuai';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _InputField(
                        controller: _phoneController,
                        label: 'Nomor Telepon',
                        icon: Icons.phone_rounded,
                        hint: 'Masukkan nomor telepon',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor telepon tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _InputField(
                        controller: _addressController,
                        label: 'Alamat',
                        icon: Icons.location_on_rounded,
                        hint: 'Masukkan alamat lengkap (opsional)',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _SaveButton(
              isUpdate: isUpdate,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: primaryGreenColor),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
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
              borderSide: BorderSide(color: primaryGreenColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isUpdate;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isUpdate,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CashierBloc, CashierState>(
      builder: (context, state) {
        final isLoading = state is CashierLoading;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    primaryGreenColor,
                    primaryGreenColor.withOpacity(0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreenColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isUpdate
                            ? 'Simpan Perubahan'
                            : 'Tambah Kasir',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontType,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}