import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/core/theme/theme.dart';
import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../blocs/category/category_event.dart';
import '../../../../../blocs/category/category_state.dart';
import '../../../../../blocs/product/product_bloc.dart';
import '../../../../../blocs/product/product_event.dart';
import '../../../../../blocs/product/product_state.dart';
import '../../../../../data/models/product_model.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../../../../widgets/floating_message.dart';
import '../categories/add_category_page.dart';

class EditProductPage extends StatefulWidget {
  final ProductModel product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _basePriceController;
  late TextEditingController _sellingPriceController;
  // late TextEditingController _stockController;
  late TextEditingController _unitController;
  late TextEditingController _discountController;
  late TextEditingController _descriptionController;

  int? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing product data
    _nameController = TextEditingController(text: widget.product.productName);
    _codeController = TextEditingController(text: widget.product.productCode);
    _basePriceController = TextEditingController(
      text: widget.product.costPrice.toStringAsFixed(0),
    );
    _sellingPriceController = TextEditingController(
      text: widget.product.sellingPrice.toStringAsFixed(0),
    );
    // _stockController = TextEditingController(
    //   text: widget.product.stock.toString(),
    // );
    _unitController = TextEditingController(text: widget.product.productUnits);
    _discountController = TextEditingController(
      text: widget.product.productDiscount.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product.productDescription ?? '',
    );

    _selectedCategoryId = widget.product.categoryId;

    // Load categories
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _basePriceController.dispose();
    _sellingPriceController.dispose();
    // _stockController.dispose();
    _unitController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateProduct() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        FloatingMessage.show(
          context,
          message: 'Pilih kategori terlebih dahulu',
          textOnly: true,
          backgroundColor: primaryGreenColor,
        );

        return;
      }

      final updatedProduct = ProductModel(
        id: widget.product.id,
        productName: _nameController.text.trim(),
        categoryId: _selectedCategoryId!,
        productCode: _codeController.text.trim(),
        costPrice: double.parse(_basePriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        productStock: widget.product.productStock,
        productUnits: _unitController.text.trim(),
        productDiscount: _discountController.text.isEmpty
            ? 0
            : double.parse(_discountController.text),
        productDescription: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: widget.product.createdAt,
      );

      context.read<ProductBloc>().add(
        UpdateProduct(product: updatedProduct),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Produk'),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductActionSuccess) {
            Navigator.pop(context, true);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UploadPhotoSection(),
                const SizedBox(height: 16),
                ProductNameField(controller: _nameController),
                const SizedBox(height: 16),
                CategoryAndCodeField(
                  codeController: _codeController,
                  selectedCategoryId: _selectedCategoryId,
                  selectedCategoryName: _selectedCategoryName,
                  onCategorySelected: (categoryId, categoryName) {
                    setState(() {
                      _selectedCategoryId = categoryId as int?;
                      _selectedCategoryName = categoryName;
                    });
                  },
                ),
                const SizedBox(height: 16),
                PriceField(
                  basePriceController: _basePriceController,
                  sellingPriceController: _sellingPriceController,
                ),
                const SizedBox(height: 16),
                // StockAndUnitField(
                //   stockController: _stockController,
                //   unitController: _unitController,
                // ),
                const SizedBox(height: 16),
                DiscountField(controller: _discountController),
                const SizedBox(height: 16),
                DescriptionField(controller: _descriptionController),
                const SizedBox(height: 60),
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    return SaveButton(
                      onPressed: _updateProduct,
                      isLoading: state is ProductLoading,
                      buttonText: 'Update',
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- Reusable Widgets --------------------

class UploadPhotoSection extends StatelessWidget {
  const UploadPhotoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Produk',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  color: Colors.grey[600], size: 24),
              const SizedBox(height: 2),
              Text(
                'Upload',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontFamily: fontType,
                ),
              ),
            ],
          ),
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

class ProductNameField extends StatelessWidget {
  final TextEditingController controller;

  const ProductNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Produk',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama produk tidak boleh kosong';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Contoh: Hot Cappucino',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: fontType,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class CategoryAndCodeField extends StatelessWidget {
  final TextEditingController codeController;
  final int? selectedCategoryId;
  final String? selectedCategoryName;
  final Function(int categoryId, String categoryName) onCategorySelected;

  const CategoryAndCodeField({
    super.key,
    required this.codeController,
    required this.selectedCategoryId,
    required this.selectedCategoryName,
    required this.onCategorySelected,
  });

  void _showCategoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return BlocProvider.value(
              value: BlocProvider.of<CategoryBloc>(modalContext),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pilih Kategori",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: fontType,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is CategoryEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.category_outlined,
                                      size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Belum ada kategori',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tambahkan kategori terlebih dahulu',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      Navigator.pop(modalContext);
                                      final result = await Navigator.push(
                                        modalContext,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const AddCategoryPage(),
                                        ),
                                      );
                                      if (result == true &&
                                          modalContext.mounted) {
                                        modalContext
                                            .read<CategoryBloc>()
                                            .add(const LoadCategories());
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreenColor,
                                    ),
                                    icon: const Icon(Icons.add,
                                        color: Colors.white),
                                    label: const Text(
                                      'Tambah Kategori',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (state is CategoryLoaded) {
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: state.categories.length + 1,
                              itemBuilder: (context, index) {
                                if (index == state.categories.length) {
                                  return Card(
                                    color: primaryGreenColor.withOpacity(0.1),
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.add_circle,
                                        color: primaryGreenColor,
                                      ),
                                      title: const Text(
                                        'Tambah Kategori Baru',
                                        style: TextStyle(
                                          color: primaryGreenColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onTap: () async {
                                        Navigator.pop(modalContext);
                                        final result = await Navigator.push(
                                          modalContext,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                            const AddCategoryPage(),
                                          ),
                                        );
                                        if (result == true &&
                                            modalContext.mounted) {
                                          modalContext
                                              .read<CategoryBloc>()
                                              .add(const LoadCategories());
                                        }
                                      },
                                    ),
                                  );
                                }

                                final category = state.categories[index];
                                return Card(
                                  child: ListTile(
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: primaryGreenColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.category,
                                        color: primaryGreenColor,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(category.categoryName),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                    onTap: () {
                                      onCategorySelected(
                                          category.id!, category.categoryName);
                                      Navigator.pop(modalContext);
                                    },
                                  ),
                                );
                              },
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: fontType,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  String displayName = selectedCategoryName ?? 'Pilih kategori';

                  // Jika categoryName belum di-set tapi categoryId ada, cari dari state
                  if (selectedCategoryName == null &&
                      selectedCategoryId != null &&
                      state is CategoryLoaded) {
                    final category = state.categories.firstWhere(
                          (cat) => cat.id == selectedCategoryId,
                      orElse: () => state.categories.first,
                    );
                    displayName = category.categoryName;
                  }

                  return GestureDetector(
                    onTap: () => _showCategoryBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                color: selectedCategoryId != null
                                    ? Colors.black
                                    : Colors.grey[400],
                                fontSize: 14,
                                fontFamily: fontType,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kode',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: fontType,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: codeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kode wajib diisi';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '001',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: fontType,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PriceField extends StatelessWidget {
  final TextEditingController basePriceController;
  final TextEditingController sellingPriceController;

  const PriceField({
    super.key,
    required this.basePriceController,
    required this.sellingPriceController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Harga Dasar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: fontType,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: basePriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga dasar wajib diisi';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Harga harus > 0';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Rp 0',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: fontType,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Harga Jual',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: fontType,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: sellingPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga jual wajib diisi';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Harga harus > 0';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Rp 0',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: fontType,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StockAndUnitField extends StatelessWidget {
  final TextEditingController stockController;
  final TextEditingController unitController;

  const StockAndUnitField({
    super.key,
    required this.stockController,
    required this.unitController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stok',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: fontType,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok wajib diisi';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: fontType,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Satuan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: fontType,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: unitController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Satuan wajib diisi';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'PCS',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: fontType,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DiscountField extends StatelessWidget {
  final TextEditingController controller;

  const DiscountField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diskon (%)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: fontType,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: fontType,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keterangan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Contoh: Produk andalan',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: fontType,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String buttonText;

  const SaveButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.buttonText = 'Simpan',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBackgroundColor: primaryGreenColor.withOpacity(0.5),
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
            : Text(
          buttonText,
          style: const TextStyle(
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