// ui/pages/customer/update_customer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/core/theme/theme.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import 'package:pos_mobile/ui/widgets/floating_message.dart';
import '../../../../../blocs/customer/customer_bloc.dart';
import '../../../../../blocs/customer/customer_event.dart';
import '../../../../../blocs/customer/customer_state.dart';
import '../../../../../data/models/customer_model.dart';

class UpdateCustomerPage extends StatefulWidget {
  final Customer customer;

  const UpdateCustomerPage({
    super.key,
    required this.customer,
  });

  @override
  State<UpdateCustomerPage> createState() => _UpdateCustomerPageState();
}

class _UpdateCustomerPageState extends State<UpdateCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _addressController = TextEditingController(text: widget.customer.address ?? '');
    _phoneController = TextEditingController(text: widget.customer.phone);
    _emailController = TextEditingController(text: widget.customer.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      final updatedCustomer = widget.customer.copyWith(
        name: _nameController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );

      setState(() => _isLoading = true);
      context.read<CustomerBloc>().add(UpdateCustomer(updatedCustomer));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is CustomerOperationSuccess) {
          FloatingMessage.show(
            context,
            message: state.message,
            backgroundColor: primaryGreenColor,
          );
          Navigator.pop(context, state.customer);
        } else if (state is CustomerError) {
          FloatingMessage.show(
            context,
            message: state.message,
            backgroundColor: Colors.red,
          );
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Edit Pelanggan'),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CustomerNameField(controller: _nameController),
                    const SizedBox(height: 24),
                    CustomerAddressField(controller: _addressController),
                    const SizedBox(height: 24),
                    CustomerPhoneField(controller: _phoneController),
                    const SizedBox(height: 24),
                    CustomerEmailField(controller: _emailController),
                    const SizedBox(height: 32),
                    SaveButton(
                      onPressed: _isLoading ? null : _saveCustomer,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: primaryGreenColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Nama pelanggan
class CustomerNameField extends StatelessWidget {
  final TextEditingController controller;
  const CustomerNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Lengkap Pelanggan*',
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
              return 'Nama pelanggan wajib diisi';
            }
            return null;
          },
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Contoh: Mochammad Athar Humam',
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
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: primaryGreenColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Alamat
class CustomerAddressField extends StatelessWidget {
  final TextEditingController controller;
  const CustomerAddressField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alamat Pelanggan',
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
          maxLines: 3,
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan alamat lengkap pelanggan',
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
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: primaryGreenColor,
                width: 2,
              ),
            ),
          ),
          keyboardType: TextInputType.streetAddress,
        ),
      ],
    );
  }
}

// Nomor Telepon
class CustomerPhoneField extends StatelessWidget {
  final TextEditingController controller;
  const CustomerPhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nomor Telepon Pelanggan*',
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
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nomor Telepon Wajib Diisi';
            }
            return null;
          },
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan nomor telepon aktif',
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
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: primaryGreenColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Email
class CustomerEmailField extends StatelessWidget {
  final TextEditingController controller;
  const CustomerEmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Pelanggan',
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
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return null;
            }
            final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
            if (!emailRegex.hasMatch(value.trim())) {
              return 'Format email tidak valid';
            }
            return null;
          },
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan email pelanggan (opsional)',
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
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: primaryGreenColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Tombol Simpan
class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SaveButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

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
        ),
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text('Simpan Perubahan'),
      ),
    );
  }
}