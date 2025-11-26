import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../blocs/cashier/cashier_bloc.dart';
import '../../../../../../blocs/cashier/cashier_event.dart';
import '../../../../../../blocs/cashier/cashier_state.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../data/models/cashier_model.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/floating_message.dart';

class UpdateCashierPage extends StatefulWidget {
  final Cashier? cashier; // 🆕 Terima cashier data (nullable untuk add mode)

  const UpdateCashierPage({super.key, this.cashier});

  @override
  State<UpdateCashierPage> createState() => _UpdateCashierPageState();
}

class _UpdateCashierPageState extends State<UpdateCashierPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // 🆕 Pre-fill form jika edit mode
    if (widget.cashier != null) {
      _nameController.text = widget.cashier!.fullName;
      _emailController.text = widget.cashier!.email;
      _phoneController.text = widget.cashier!.phoneNumber;
      _addressController.text = widget.cashier!.userAddress ?? '';

    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final cashier = Cashier(
        id: widget.cashier?.id,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: '',
        passwordConfirmation: '',
        phoneNumber: _phoneController.text.trim(),
        userAddress: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );
      // Mode ADD
      if (widget.cashier == null) {
        context.read<CashierBloc>().add(
          AddCashier(
            cashier: cashier,
            password: _passwordController.text,
            passwordConfirmation: _passwordConfirmationController.text, // 🆕
          ),
        );
      }
      // Mode UPDATE
      else {
        context.read<CashierBloc>().add(
          UpdateCashier(
            cashier: cashier,
            password: _passwordController.text.isEmpty
                ? null
                : _passwordController.text,
            passwordConfirmation: _passwordConfirmationController.text.isEmpty
                ? null
                : _passwordConfirmationController.text, // 🆕
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.cashier != null; // 🆕 Check mode

    return BlocListener<CashierBloc, CashierState>(
      listener: (context, state) {
        if (state is CashierLoaded) {
          Navigator.of(context).pop(true);
        } else if (state is CashierError) {
          FloatingMessage.show(
            context,
            message: state.message,
            backgroundColor: Colors.red,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: isEditMode ? 'Edit Kasir' : 'Registrasi Kasir', // 🆕 Dynamic title
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  CashierNameField(controller: _nameController),
                  const SizedBox(height: 24),
                  CashierEmail(controller: _emailController),
                  const SizedBox(height: 24),
                  CashierPassword(
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    isEditMode: isEditMode, // 🆕 Pass mode
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  CashierPasswordConfirmation(
                    passwordConfirmationController: _passwordConfirmationController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    isEditMode: isEditMode,
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  CashierPhoneNumber(controller: _phoneController),
                  const SizedBox(height: 24),
                  CashierAddress(controller: _addressController),
                  const SizedBox(height: 32),
                  BlocBuilder<CashierBloc, CashierState>(
                    builder: (context, state) {
                      final isLoading = state is CashierLoading;
                      return CashierRegisterButton(
                        onPressed: isLoading ? null : _handleSubmit,
                        isLoading: isLoading,
                        buttonText: isEditMode ? 'Simpan Perubahan' : 'Daftarkan Kasir', // 🆕 Dynamic text
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class CashierNameField extends StatelessWidget {
  final TextEditingController controller;

  const CashierNameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Cashier*',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama kasir harus diisi';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Contoh: Cashier 1',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: fontType,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class CashierEmail extends StatelessWidget {
  final TextEditingController controller;

  const CashierEmail({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
          controller: controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email harus diisi';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Format email tidak valid';
            }
            return null;
          },
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Masukan Email',
            hintStyle: TextStyle(
              fontFamily: fontType,
              color: Colors.grey[400],
              fontSize: 14,
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
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}

class CashierPassword extends StatelessWidget {
  const CashierPassword({
    super.key,
    required TextEditingController passwordController,
    required this.obscurePassword,
    required this.onToggleVisibility,
    this.isEditMode = false,
  }) : _passwordController = passwordController;

  final TextEditingController _passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;
  final bool isEditMode;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditMode
              ? 'Kata Sandi Baru (kosongkan jika tidak ingin mengubah)' // 🆕
              : 'Kata Sandi untuk Kasir*',
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: obscurePassword,
          validator: (value) {
            // 🆕 Skip validation jika edit mode dan password kosong
            if (isEditMode && (value == null || value.isEmpty)) {
              return null; // OK, keep old password
            }
            if (!isEditMode && (value == null || value.isEmpty)) {
              return 'Kata sandi harus diisi';
            }
            if (value != null && value.isNotEmpty && value.length < 6) {
              return 'Kata sandi minimal 6 karakter';
            }
            return null;
          },
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Masukan Kata Sandi untuk Kasir',
            hintStyle: TextStyle(
              fontFamily: fontType,
              color: Colors.grey[400],
              fontSize: 14,
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
                color: Color(0xFF4CAF50),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}

class CashierPasswordConfirmation extends StatelessWidget {
  const CashierPasswordConfirmation({
    super.key,
    required TextEditingController passwordConfirmationController,
    required TextEditingController passwordController,
    required this.obscurePassword,
    required this.onToggleVisibility,
    this.isEditMode = false,
  }) : _passwordConfirmationController = passwordConfirmationController,
        _passwordController = passwordController;

  final TextEditingController _passwordConfirmationController;
  final TextEditingController _passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditMode
              ? 'Konfirmasi Kata Sandi Baru'
              : 'Konfirmasi Kata Sandi*',
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordConfirmationController,
          obscureText: obscurePassword,
          validator: (value) {
            // Skip validation jika edit mode dan password kosong
            if (isEditMode && _passwordController.text.isEmpty) {
              return null;
            }

            if (!isEditMode && (value == null || value.isEmpty)) {
              return 'Konfirmasi kata sandi harus diisi';
            }

            if (value != null && value.isNotEmpty && value != _passwordController.text) {
              return 'Konfirmasi kata sandi tidak sesuai';
            }
            return null;
          },
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Ulangi Kata Sandi',
            hintStyle: TextStyle(
              fontFamily: fontType,
              color: Colors.grey[400],
              fontSize: 14,
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
                color: Color(0xFF4CAF50),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}

class CashierPhoneNumber extends StatelessWidget {
  final TextEditingController controller;

  const CashierPhoneNumber({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nomor Handphone Kasir*',
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nomor handphone harus diisi';
            }
            if (!RegExp(r'^[0-9+]+$').hasMatch(value)) {
              return 'Nomor handphone tidak valid';
            }
            return null;
          },
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Masukan Nomor Handphone Kasir',
            hintStyle: TextStyle(
              fontFamily: fontType,
              color: Colors.grey[400],
              fontSize: 14,
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
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class CashierAddress extends StatelessWidget {
  final TextEditingController controller;

  const CashierAddress({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alamat dari kasir',
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
          // validator: (value) {
          //   if (value == null || value.trim().isEmpty) {
          //     return 'Alamat harus diisi';
          //   }
          //   return null;
          // },
          maxLines: 3,
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Masukan Alamat dari kasir',
            hintStyle: TextStyle(
              fontFamily: fontType,
              color: Colors.grey[400],
              fontSize: 14,
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
          ),
          keyboardType: TextInputType.streetAddress,
        ),
      ],
    );
  }
}

class CashierRegisterButton extends StatelessWidget {
  const CashierRegisterButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.buttonText = 'Ubah Data Kasir',
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
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
          disabledBackgroundColor: Colors.grey[300],
        ),
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(buttonText),
      ),
    );
  }
}