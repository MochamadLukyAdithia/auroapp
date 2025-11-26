import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/data/models/shop.dart';
import '../../../../../../blocs/shop/shop_cubit.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../widgets/custom_app_bar.dart';
import 'dart:io';
import '../../../../../widgets/floating_message.dart';
import '../../../../../widgets/image_picker.dart';

class ShopPageUpdate extends StatefulWidget {
  final Shop? shop;

  const ShopPageUpdate({super.key, this.shop});

  @override
  State<ShopPageUpdate> createState() => _ShopPageUpdateState();
}

class _ShopPageUpdateState extends State<ShopPageUpdate> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  String? _photoUrl;
  File? _photoFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop?.shopName ?? '');
    _addressController = TextEditingController(text: widget.shop?.shopAddress ?? '');
    _phoneController = TextEditingController(text: widget.shop?.shopPhone ?? '');
    _photoUrl = widget.shop?.shopPhoto;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveShop() {
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

    // TODO: Jika ada _photoFile, upload dulu ke server
    // Untuk sementara gunakan path lokal atau URL yang sudah ada
    String finalPhotoUrl = _photoUrl ?? '';
    if (_photoFile != null) {
      // Sementara gunakan path lokal
      // Nanti diganti dengan URL hasil upload
      finalPhotoUrl = _photoFile!.path;
    }

    final shop = Shop(
      id: widget.shop?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      shopName: _nameController.text.trim(),
      shopPhoto: finalPhotoUrl,
      shopAddress: _addressController.text.trim(),
      shopPhone: _phoneController.text.trim(),
    );

    context.read<ShopCubit>().saveShop(shop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Update Profil Toko'),
      body: BlocListener<ShopCubit, ShopState>(
        listener: (context, state) {
          if (state is ShopSaved) {
            FloatingMessage.show(
              context,
              message: 'Profile toko berhasil disimpan',
              textOnly: true,
              backgroundColor: primaryGreenColor,
            );
            Navigator.pop(context);
          }
          if (state is ShopError) {
            FloatingMessage.show(
              context,
              message: 'Profile toko gagal diperbarui',
              textOnly: true,
              backgroundColor: Colors.red,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ShopPhotoSection(
                photoUrl: _photoUrl,
                photoFile: _photoFile,
                onImagePicked: (file) {
                  setState(() {
                    _photoFile = file;
                  });
                },
              ),
              const SizedBox(height: 16),
              ShopNameField(controller: _nameController),
              const SizedBox(height: 16),
              ShopAddress(controller: _addressController),
              const SizedBox(height: 16),
              ShopPhoneNumber(controller: _phoneController),
              const SizedBox(height: 16),
              SaveButton(onPressed: _saveShop),
            ],
          ),
        ),
      ),
    );
  }
}


// foto toko
class ShopPhotoSection extends StatelessWidget {
  final String? photoUrl;
  final File? photoFile;
  final Function(File) onImagePicked;

  const ShopPhotoSection({
    super.key,
    required this.onImagePicked,
    this.photoUrl,
    this.photoFile,
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
          imageUrl: photoUrl,
          imageFile: photoFile,
          onImagePicked: onImagePicked,
          width: 80,
          height: 80,
          uploadText: 'Upload',
        ),
        const SizedBox(height: 4),
        Text(
          'Format gambar .jpg .jpeg .png dan Ukuran file 5MB (Gunakan ukuran minimum 500 x 500 pxl).',
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

// nama toko
class ShopNameField extends StatelessWidget {
  final TextEditingController controller;

  const ShopNameField({super.key, required this.controller});

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
            hintText: 'Contoh: Toko 1',
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

// alamat toko
class ShopAddress extends StatelessWidget {
  final TextEditingController controller;

  const ShopAddress({super.key, required this.controller});

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

// nomor telpon toko
class ShopPhoneNumber extends StatelessWidget {
  final TextEditingController controller;

  const ShopPhoneNumber({super.key, required this.controller});

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
  final VoidCallback onPressed;

  const SaveButton({super.key, required this.onPressed});

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
        ),
        child: const Text(
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