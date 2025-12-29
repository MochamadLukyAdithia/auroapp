import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/core/theme/theme.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../blocs/category/category_state.dart';
import '../../../../../blocs/product/product_bloc.dart';
import '../../../../../blocs/product/product_event.dart';
import '../../../../../blocs/product/product_state.dart';
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

// IMPROVED PRODUCT SECTION WIDGET

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
    return Column(
      children: [
        // 🖼️ IMPROVED Product Image Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
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
            children: [
              // Image Preview
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 280, // 🆕 Fixed width
                    height: 280, // 🆕 Fixed height - aspect ratio 1:1
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: product.productPhoto != null && product.productPhoto!.isNotEmpty
                        ? Image.network(
                      product.productPhoto!,
                      fit: BoxFit.cover, // Cover untuk fill container
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                                color: primaryGreenColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const ImprovedPlaceholderImage();
                      },
                    )
                        : const ImprovedPlaceholderImage(),
                  ),
                ),
              ),

              // 🆕 Image Caption (Optional)
              if (product.productPhoto != null && product.productPhoto!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Foto Produk',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Product Information Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Informasi Produk',
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Details
              DetailRow(label: "Nama Produk", value: product.productName),
              const Divider(height: 1),
              DetailRow(label: "Kategori", value: getCategoryName()),
              const Divider(height: 1),
              DetailRow(label: "Kode", value: product.productCode),
              const Divider(height: 1),
              DetailRow(label: "Harga Dasar", value: formatCurrency(product.costPrice)),
              const Divider(height: 1),
              DetailRow(label: "Harga Jual", value: formatCurrency(product.sellingPrice)),
              const Divider(height: 1),
              DetailRow(label: "Satuan", value: product.productUnits),
              const Divider(height: 1),
              DetailRow(label: "Diskon", value: "${product.productDiscount?.toInt() ?? 0}%"),
              const Divider(height: 1),
              DetailRow(
                label: "Keterangan",
                value: product.productDescription ?? "-",
              ),
              const Divider(height: 1),
              DetailRow(
                label: "Stok",
                value: "${product.productStock} item",
                valueColor: product.productStock! < 10 ? Colors.red : primaryGreenColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// IMPROVED DETAIL ROW
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

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
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// IMPROVED PLACEHOLDER IMAGE
class ImprovedPlaceholderImage extends StatelessWidget {
  const ImprovedPlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada gambar',
            style: TextStyle(
              fontFamily: fontType,
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
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
            fontFamily: fontType,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class DeleteProductButton extends StatelessWidget {
  final ProductModel product;

  const DeleteProductButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final hasTransactions = product.hasTransactions == true;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: hasTransactions
                ? null // Disable kalau ada transaksi
                : () {
              showDialog(
                context: context,
                builder: (ctx) => BlocProvider.value(
                  value: context.read<ProductBloc>(),
                  child: DeleteProductDialog(
                    productId: product.id!,
                    productName: product.productName,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: hasTransactions ? Colors.grey[300]! : Colors.red,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: hasTransactions ? Colors.grey[100] : null,
            ),
            child: Text(
              'Hapus Produk',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: hasTransactions ? Colors.grey[400] : Colors.red,
              ),
            ),
          ),
        ),

        // Info kenapa disabled
        if (hasTransactions)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Produk tidak dapat dihapus karena sudah memiliki riwayat transaksi',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// GANTI DeleteProductDialog
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
    return BlocConsumer<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductCannotDelete) {
          // Tutup dialog konfirmasi
          Navigator.pop(context);

          // Tampilkan dialog error
          Future.delayed(const Duration(milliseconds: 200), () {
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (ctx) => CannotDeleteProductDialog(
                  productName: productName,
                  message: state.message,
                ),
              );
            }
          });
        } else if (state is ProductActionSuccess) {
          Navigator.pop(context); // Tutup dialog
          Navigator.pop(context, true); // Kembali ke halaman sebelumnya
        } else if (state is ProductError) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProductLoading;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Hapus Produk",
            style: TextStyle(
              fontFamily: fontType,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            "Yakin ingin menghapus '$productName'?",
            style: TextStyle(
              fontFamily: fontType,
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: TextStyle(
                  fontFamily: fontType,
                  color: isLoading ? Colors.grey : Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                context.read<ProductBloc>().add(
                  DeleteProduct(productId),
                );
              },
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              )
                  : const Text(
                "Hapus",
                style: TextStyle(
                  fontFamily: fontType,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// TAMBAHKAN CannotDeleteProductDialog
class CannotDeleteProductDialog extends StatelessWidget {
  final String productName;
  final String message;

  const CannotDeleteProductDialog({
    super.key,
    required this.productName,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: Colors.orange[700],
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Tidak Dapat Menghapus",
              style: TextStyle(
                fontFamily: fontType,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Produk '$productName' tidak dapat dihapus.",
            style: const TextStyle(
              fontFamily: fontType,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: primaryGreenColor,
          ),
          child: const Text(
            "OK, Mengerti",
            style: TextStyle(
              fontFamily: fontType,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}