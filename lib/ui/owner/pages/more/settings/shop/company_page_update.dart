import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../blocs/company/company_cubit.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../core/utils/responsive_helper.dart';
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
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      FloatingMessage.show(
        context,
        message: 'Alamat toko tidak boleh kosong',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      FloatingMessage.show(
        context,
        message: 'Nomor telephone tidak boleh kosong',
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
    final r = context.responsive;

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
              backgroundColor: primaryGreenColor,
            );
            Navigator.pop(context);
          }

          if (state is CompanyError) {
            FloatingMessage.show(
              context,
              message: state.message,
              backgroundColor: Colors.red,
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(r.spacing(mobile: 16, tablet: 24)),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: r.isTablet ? 600 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      SizedBox(height: r.spacing(mobile: 16, tablet: 24)),
                      CompanyNameField(controller: _nameController),
                      SizedBox(height: r.spacing(mobile: 16, tablet: 24)),
                      CompanyAddress(controller: _addressController),
                      SizedBox(height: r.spacing(mobile: 16, tablet: 24)),
                      CompanyPhoneNumber(controller: _phoneController),
                      SizedBox(height: r.spacing(mobile: 24, tablet: 32)),
                      SaveButton(
                        onPressed: _isLoading ? null : _saveCompany,
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
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil Toko',
          style: TextStyle(
            fontSize: r.fontSize(mobile: 14, tablet: 16),
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        SizedBox(height: r.spacing(mobile: 8, tablet: 12)),
        ImagePickerWidget(
          imageUrl: logoUrl,
          imageFile: logoFile,
          onImagePicked: onImagePicked,
          width: r.isTablet ? 120 : 80,
          height: r.isTablet ? 120 : 80,
          uploadText: 'Upload',
        ),
        SizedBox(height: r.spacing(mobile: 4, tablet: 8)),
        Text(
          'Format gambar .jpg .jpeg .png dan Ukuran file 3MB (Gunakan ukuran minimum 500 x 500 pxl).',
          style: TextStyle(
            fontSize: r.fontSize(mobile: 11, tablet: 13),
            color: Colors.grey[600],
            fontFamily: fontType,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

// Nama Toko Field
class CompanyNameField extends StatelessWidget {
  final TextEditingController controller;

  const CompanyNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nama Toko',
          style: TextStyle(
            fontSize: r.fontSize(mobile: 14, tablet: 16),
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        SizedBox(height: r.spacing(mobile: 8, tablet: 12)),
        TextField(
          controller: controller,
          style: TextStyle(
            fontSize: r.fontSize(mobile: 14, tablet: 16),
            fontFamily: fontType,
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan nama toko',
            hintStyle: TextStyle(
              fontSize: r.fontSize(mobile: 14, tablet: 16),
              color: Colors.grey[400],
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
              borderSide: const BorderSide(color: primaryGreenColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: r.spacing(mobile: 12, tablet: 16),
              vertical: r.spacing(mobile: 12, tablet: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// Alamat Toko Field
class CompanyAddress extends StatelessWidget {
  final TextEditingController controller;

  const CompanyAddress({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alamat Toko',
          style: TextStyle(
            fontSize: r.fontSize(mobile: 14, tablet: 16),
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        SizedBox(height: r.spacing(mobile: 8, tablet: 12)),
        TextField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(
            fontSize: r.fontSize(mobile: 14, tablet: 16),
            fontFamily: fontType,
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan alamat toko',
            hintStyle: TextStyle(
              fontSize: r.fontSize(mobile: 14, tablet: 16),
              color: Colors.grey[400],
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
              borderSide: const BorderSide(color: primaryGreenColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: r.spacing(mobile: 12, tablet: 16),
              vertical: r.spacing(mobile: 12, tablet: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// Nomor Telepon Field
class CompanyPhoneNumber extends StatelessWidget {
  final TextEditingController controller;

  const CompanyPhoneNumber({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nomor Telepon',
          style: TextStyle(
            fontSize: r.fontSize(mobile: 14, tablet: 16),
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        SizedBox(height: r.spacing(mobile: 8, tablet: 12)),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: TextStyle(
            fontSize: r.fontSize(mobile: 14, tablet: 16),
            fontFamily: fontType,
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan nomor telepon',
            hintStyle: TextStyle(
              fontSize: r.fontSize(mobile: 14, tablet: 16),
              color: Colors.grey[400],
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
              borderSide: const BorderSide(color: primaryGreenColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: r.spacing(mobile: 12, tablet: 16),
              vertical: r.spacing(mobile: 12, tablet: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// Save Button
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
    final r = context.responsive;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: r.spacing(mobile: 14, tablet: 18),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: isLoading
            ? SizedBox(
          height: r.size(mobile: 20, tablet: 24),
          width: r.size(mobile: 20, tablet: 24),
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          'Simpan',
          style: TextStyle(
            fontSize: r.fontSize(mobile: 16, tablet: 18),
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
      ),
    );
  }
}