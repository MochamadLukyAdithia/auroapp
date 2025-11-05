import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AddPricePage extends StatefulWidget {
  const AddPricePage({super.key});

  @override
  State<AddPricePage> createState() => _AddPricePageState();
}

class _AddPricePageState extends State<AddPricePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tipe Harga'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MinimalOrderField(),
            SizedBox(height: 16),
            PricePerProductField(),
            SizedBox(height: 32),
            SaveButton(),
          ],
        ),
      ),
    );
  }
}

// ---------------- Widget ----------------

class MinimalOrderField extends StatelessWidget {
  const MinimalOrderField({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
        labelText: 'Jumlah minimal order',
        hintText: 'Masukkan jumlah minimal order',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.text,
    );
  }
}

class PricePerProductField extends StatelessWidget {
  const PricePerProductField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Harga Per Produk',
        hintText: 'Rp 0',
        border: OutlineInputBorder(),
        isDense: true,
      ),
        keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, //kasih otomatis rupiah nanti jangna lupa
      ],
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
