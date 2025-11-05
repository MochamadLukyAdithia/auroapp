import 'package:flutter/material.dart';
import 'package:pos_mobile/core/theme/theme.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Tambah Pelanggan'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 20),
              CustomerNameField(),
              SizedBox(height: 24),
              CustomerAddressField(),
              SizedBox(height: 24),
              CustomerPhoneField(),
              SizedBox(height: 24),
              CustomerEmailField(),
              SizedBox(height: 32),
              SaveButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// Nama pelanggan
class CustomerNameField extends StatelessWidget {
  const CustomerNameField({super.key});

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
  const CustomerAddressField({super.key});

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
  const CustomerPhoneField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nomor Telepon Pelanggan',
          style: TextStyle(
            fontFamily: fontType,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: TextInputType.phone,
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
  const CustomerEmailField({super.key});

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
          keyboardType: TextInputType.emailAddress,
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
  const SaveButton({super.key});

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
        onPressed: () {
          // TODO: handle save logic
        },
        child: const Text('Simpan Data Pelanggan'),
      ),
    );
  }
}
