import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/core/theme/theme.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../blocs/category/category_state.dart';
import '../../../../../blocs/product/product_bloc.dart';
import '../../../../../blocs/product/product_event.dart';
import '../../../../../data/models/product_model.dart';
import 'edit_product.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'Detail Produk'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductSection(
              product: product,
              getCategoryName: () => _getCategoryName(context),
              formatCurrency: _formatCurrency,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UpdateProductButton(product: product),
                  const SizedBox(height: 12),
                  DeleteProductButton(product: product),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper
  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}';
  }

  String _getCategoryName(BuildContext context) {
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryLoaded) {
      final category = categoryState.categories.firstWhere(
            (cat) => cat.id == product.categoryId,
        orElse: () => categoryState.categories.first,
      );
      return category.categoryName;
    }
    return "Minuman";
  }
}

// PRODUCT SECTION WIDGET

class ProductSection extends StatelessWidget {
  final ProductModel product;
  final String Function() getCategoryName;
  final String Function(double amount) formatCurrency;

  const ProductSection({
    super.key,
    required this.product,
    required this.getCategoryName,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 🖼️ Product Image - UPDATE INI
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.productPhoto != null && product.productPhoto!.isNotEmpty
                  ? Image.network(
                product.productPhoto!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const PlaceholderImage();
                },
              )
                  : const PlaceholderImage(),
            ),
          ),

          const SizedBox(height: 16),

          // Product Information
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                DetailRow(label: "Nama Produk", value: product.productName),
                DetailRow(label: "Kategori", value: getCategoryName()),
                DetailRow(label: "Kode", value: product.productCode),
                DetailRow(label: "Harga dasar", value: formatCurrency(product.costPrice)),
                DetailRow(label: "Harga jual", value: formatCurrency(product.sellingPrice)),
                DetailRow(label: "Satuan", value: product.productUnits),
                DetailRow(label: "Diskon", value: "${product.productDiscount?.toInt()}%"),
                DetailRow(
                    label: "Keterangan",
                    value: product.productDescription ?? "-"
                ),
                DetailRow(
                  label: "Stok",
                  value: "${product.productStock} item",
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// UPDATE PRODUCT BUTTON
class UpdateProductButton extends StatelessWidget {
  final ProductModel product;

  const UpdateProductButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<CategoryBloc>()),
                  BlocProvider.value(value: context.read<ProductBloc>()),
                ],
                child: EditProductPage(product: product),
              ),
            ),
          );

          if (result == true && context.mounted) {
            context.read<ProductBloc>().add(const LoadProducts());
            Navigator.pop(context, true);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Update Produk',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white
          ),
        ),
      ),
    );
  }
}

// DELETE PRODUCT BUTTON
class DeleteProductButton extends StatelessWidget {
  final ProductModel product;

  const DeleteProductButton({super.key, required this.product});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => DeleteProductDialog(
              productId: product.id!,
              productName: product.productName,
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          // backgroundColor: Colors.transparent,
          side: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Hapus Produk',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 80,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}

class DeleteProductDialog extends StatelessWidget {
  final String productName;
  final int productId;

  const DeleteProductDialog({
    super.key,
    required this.productName,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Hapus Produk",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Text(
        "Yakin ingin menghapus '$productName'?",
        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Batal", style: TextStyle(color: Colors.grey[600])),
        ),
        TextButton(
          onPressed: () {
            context.read<ProductBloc>().add(DeleteProduct(productId));
            Navigator.pop(context);
            Navigator.pop(context, true);
          },
          child: const Text(
            "Hapus",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
