import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final Function(File) onImagePicked;
  final double width;
  final double height;
  final String uploadText;
  final String? helperText;

  const ImagePickerWidget({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.onImagePicked,
    this.width = 60,
    this.height = 60,
    this.uploadText = 'Upload',
    this.helperText,
  });

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    // Show bottom sheet untuk pilih sumber
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Validasi ekstensi file
        final String extension = pickedFile.path.split('.').last.toLowerCase();
        final List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'svg'];

        if (!allowedExtensions.contains(extension)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Format file tidak didukung. Gunakan .jpg, .jpeg, .png, atau .svg'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Validasi ukuran file (max 5MB)
        final File file = File(pickedFile.path);
        final int fileSizeInBytes = await file.length();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran file maksimal 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        onImagePicked(file);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          image: _getImageDecoration(),
        ),
        child: _buildContent(),
      ),
    );
  }

  DecorationImage? _getImageDecoration() {
    if (imageFile != null) {
      return DecorationImage(
        image: FileImage(imageFile!),
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(imageUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget? _buildContent() {
    if (imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty)) {
      return null;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          color: Colors.grey[600],
          size: 24,
        ),
        const SizedBox(height: 2),
        Text(
          uploadText,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}