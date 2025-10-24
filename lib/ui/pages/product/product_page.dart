import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UploadPhotoSection(),
            SizedBox(height: 20),
            ProductNameField(),
            SizedBox(height: 20),
            CategoryAndCodeField(),
            SizedBox(height: 20),
            PriceField(),
            SizedBox(height: 20),
            WeightAndUnitField(),
            SizedBox(height: 20),
            DiscountAndShelfField(),
            SizedBox(height: 20),
            DescriptionField(),
            SizedBox(height: 20),
            AddPriceTypeButton(),
            SizedBox(height: 150),
            SaveButton(),
          ],
        ),
      ),
    );
  }
}

// -------------------- Widgets --------------------

class UploadPhotoSection extends StatelessWidget {
  const UploadPhotoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Foto Produk'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload),
          label: const Text('Upload'),
        ),
        const SizedBox(height: 4),
        const Text(
          'Format gambar .jpg, .jpeg, .png dan ukuran file 5MB (Gunakan ukuran minimum 500 x 500 pxl).',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class ProductNameField extends StatelessWidget {
  const ProductNameField({super.key});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Nama Produk',
        hintText: 'Contoh: Beras',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        isDense: true,
      ),
    );
  }
}

class CategoryAndCodeField extends StatelessWidget {
  const CategoryAndCodeField({super.key});

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Kategori",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 20, // SEMENTARA
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Kategori ${index + 1}'),
                          onTap: () => Navigator.pop(context, index + 1),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dropdown kategori — klik akan buka bottom sheet
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _showBottomSheet(context),
            child: AbsorbPointer(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Pilih Kategori')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Kode Produk',
              border: OutlineInputBorder(),
              contentPadding:
              EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class PriceField extends StatelessWidget {
  const PriceField({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Harga Dasar',
              hintText: 'Rp 0',
              border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                isDense: true
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Harga Jual',
              hintText: 'Rp 0',
              border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                isDense: true
            ),
          ),
        ),
      ],
    );
  }
}

class WeightAndUnitField extends StatelessWidget {
  const WeightAndUnitField({super.key});

  void _showUnitBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Pilih Satuan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        final unitName = ['Kg', 'Gram', 'Pcs', 'Sachet', 'Gelas', 'lainnya',][index];
                        return ListTile(
                          title: Text(unitName),
                          onTap: () => Navigator.pop(context, unitName),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Kolom Berat
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Berat',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Kolom Satuan (klik => buka bottom sheet)
        Expanded(
          child: GestureDetector(
            onTap: () => _showUnitBottomSheet(context),
            child: AbsorbPointer(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Satuan',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Pilih')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class DiscountAndShelfField extends StatelessWidget {
  const DiscountAndShelfField({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Diskon (%)',
              border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                isDense: true
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Letak Rak',
              border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                isDense: true
            ),
          ),
        ),
      ],
    );
  }
}

class DescriptionField extends StatelessWidget {
  const DescriptionField({super.key});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Keterangan',
        hintText: 'Contoh: Produk andalan',
        border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          isDense: true
      ),
    );
  }
}

class AddPriceTypeButton extends StatelessWidget {
  const AddPriceTypeButton({super.key});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      child: const Text('Tambah Tipe Harga?'),
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
