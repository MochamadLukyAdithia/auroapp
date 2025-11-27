import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../blocs/company/company_cubit.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../data/models/company_model.dart';
import '../../../../../widgets/custom_app_bar.dart';
import 'dart:io';
import '../../../../../widgets/floating_message.dart';
import '../../../../../widgets/image_picker.dart';

class CompanyPageUpdate extends StatefulWidget {
  final Company? company;

  const CompanyPageUpdate({super.key, this.company});

  @override
  State<CompanyPageUpdate> createState() => _CompanyPageUpdateState();
}

class _CompanyPageUpdateState extends State<CompanyPageUpdate> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  String? _logoUrl;
  File? _logoFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company?.name ?? '');
    _addressController = TextEditingController(text: widget.company?.address ?? '');
    _phoneController = TextEditingController(text: widget.company?.phone ?? '');
    _logoUrl = widget.company?.logo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveCompany() {
    // Validasi
    if (_nameController.text.trim().isEmpty) {
      FloatingMessage.show(
        context,
        message: 'Nama toko tidak boleh kosong',
        textOnly: true,
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      FloatingMessage.show(
        context,
        message: 'Alamat toko tidak boleh kosong',
        textOnly: true,
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      FloatingMessage.show(
        context,
        message: 'Nomor telephone tidak boleh kosong',
        textOnly: true,
        backgroundColor: Colors.red,
      );
      return;
    }

    // Panggil API update company
    context.read<CompanyCubit>().saveCompany(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      logo: _logoFile, // Kirim file jika ada
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Update Profil Toko'),
      body: BlocConsumer<CompanyCubit, CompanyState>(
        listener: (context, state) {
          if (state is CompanyLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is CompanySaved) {
            FloatingMessage.show(
              context,
              message: 'Profil toko berhasil disimpan',
              textOnly: true,
              backgroundColor: primaryGreenColor,
            );
            Navigator.pop(context);
          }

          if (state is CompanyError) {
            FloatingMessage.show(
              context,
              message: state.message,
              textOnly: true,
              backgroundColor: Colors.red,
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CompanyLogoSection(
                      logoUrl: _logoUrl,
                      logoFile: _logoFile,
                      onImagePicked: (file) {
                        setState(() {
                          _logoFile = file;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CompanyNameField(controller: _nameController),
                    const SizedBox(height: 16),
                    CompanyAddress(controller: _addressController),
                    const SizedBox(height: 16),
                    CompanyPhoneNumber(controller: _phoneController),
                    const SizedBox(height: 16),
                    SaveButton(
                      onPressed: _isLoading ? null : _saveCompany,
                      isLoading: _isLoading,
                    ),
                  ],
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
          );
        },
      ),
    );
  }
}

// Logo toko
class CompanyLogoSection extends StatelessWidget {
  final String? logoUrl;
  final File? logoFile;
  final Function(File) onImagePicked;

  const CompanyLogoSection({
    super.key,
    required this.onImagePicked,
    this.logoUrl,
    this.logoFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profil Toko',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        const SizedBox(height: 8),
        ImagePickerWidget(
          imageUrl: logoUrl,
          imageFile: logoFile,
          onImagePicked: onImagePicked,
          width: 80,
          height: 80,
          uploadText: 'Upload',
        ),
        const SizedBox(height: 4),
        Text(
          'Format gambar .jpg .jpeg .png dan Ukuran file 3MB (Gunakan ukuran minimum 500 x 500 pxl).',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontFamily: fontType,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

// Nama toko
class CompanyNameField extends StatelessWidget {
  final TextEditingController controller;

  const CompanyNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Toko',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: fontType),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Contoh: Toko Sumber Rejeki',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: fontType),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// Alamat toko
class CompanyAddress extends StatelessWidget {
  final TextEditingController controller;

  const CompanyAddress({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alamat toko',
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
            hintText: 'Masukan Alamat Toko',
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
          ),
          keyboardType: TextInputType.streetAddress,
        ),
      ],
    );
  }
}

// Nomor telpon toko
class CompanyPhoneNumber extends StatelessWidget {
  final TextEditingController controller;

  const CompanyPhoneNumber({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nomor Handphone Toko',
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
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Masukan Nomor Handphone Toko',
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
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

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
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBackgroundColor: Colors.grey[400],
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'Simpan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: fontType,
          ),
        ),
      ),
    );
  }
}