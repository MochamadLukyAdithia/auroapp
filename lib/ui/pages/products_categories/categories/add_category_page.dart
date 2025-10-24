import 'package:flutter/material.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kategori'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CategoryNameField(),
            SizedBox(height: 20),
            SaveButton(),
          ],
        ),
      ),
    );
  }
}

// ---------------- Widget ----------------

class CategoryNameField extends StatelessWidget {
  const CategoryNameField({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
        labelText: 'Nama Kategori',
        hintText: 'Masukkan nama kategori',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.text,
    );
  }
}


class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Simpan'),
      ),
    );
  }
}