import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/category/category_cubit.dart';
import 'package:pos_mobile/ui/owner/pages/products_categories/products/add_product.dart';
import 'package:pos_mobile/ui/owner/pages/products_categories/products/filter_product.dart';
import 'package:pos_mobile/ui/owner/pages/products_categories/products/product_detail.dart';
import 'package:pos_mobile/ui/widgets/floating_message.dart';
import '../../../../blocs/category/category_bloc.dart';
import '../../../../blocs/category/category_event.dart';
import '../../../../blocs/category/category_state.dart';
import '../../../../blocs/product/product_bloc.dart';
import '../../../../blocs/product/product_cubit.dart';
import '../../../../blocs/product/product_event.dart';
import '../../../../blocs/product/product_state.dart';
import '../../../../core/theme/theme.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/filter_button.dart';
import 'categories/add_category_page.dart';


class ProductCategoryPage extends StatefulWidget {
  const ProductCategoryPage({super.key});

  @override
  State<ProductCategoryPage> createState() => _ProductCategoryPageState();
}

class _ProductCategoryPageState extends State<ProductCategoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFabProcessing = false;
  int _currentTabIndex = 0;
  bool _isTabAnimating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChange);  // ✅ Pisahkan ke method tersendiri
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(const LoadProducts());
      context.read<CategoryBloc>().add(const LoadCategories());
    });
  }

  void _handleTabChange() {
    // ✅ Track animasi tab
    if (_tabController.indexIsChanging) {
      setState(() {
        _isTabAnimating = true;
      });
    } else {
      if (_tabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = _tabController.index;
          _isTabAnimating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);  // ✅ Remove listener
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Produk & Kategori',
        tabs: const ['Produk', 'Kategori'],
        tabController: _tabController,
      ),
      floatingActionButton: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, productState) {
          return BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, categoryState) {
              bool showFab = false;

              if (_currentTabIndex == 0) {
                showFab = productState is ProductLoaded && productState.products.isNotEmpty;
              } else {
                showFab = categoryState is CategoryLoaded && categoryState.categories.isNotEmpty;
              }

              if (!showFab) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: FloatingActionButton(
                  key: ValueKey('fab_$_currentTabIndex'),  // ✅ Ubah dari heroTag ke key
                  onPressed: (_isFabProcessing || _isTabAnimating) ? null : () async {
                    setState(() => _isFabProcessing = true);
                    final currentTab = _currentTabIndex;

                    try {
                      if (currentTab == 0) {
                        // Tab Produk
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                  value: context.read<CategoryBloc>(),
                                ),
                                BlocProvider.value(
                                  value: context.read<ProductBloc>(),
                                ),
                              ],
                              child: const AddProductPage(),
                            ),
                          ),
                        );
                        if (result == true && context.mounted) {
                          context.read<ProductBloc>().add(const LoadProducts());
                        }
                      } else {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddCategoryPage()),
                        );
                        if (result == true && context.mounted) {
                          context.read<CategoryBloc>().add(const LoadCategories());
                        }
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isFabProcessing = false);
                      }
                    }
                  },
                  backgroundColor: primaryGreenColor,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              );
            },
          );
        },
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          ProductSection(),
          CategorySection(),
        ],
      ),
    );
  }
}

// ==================== PRODUCT SECTION ====================
class ProductSection extends StatelessWidget {
  const ProductSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductActionSuccess) {
          context.read<ProductBloc>().add(const LoadProducts());
          FloatingMessage.show(context, message: state.message, backgroundColor: primaryGreenColor);
        }
        if (state is ProductLoaded) {
          context.read<ProductSearchCubit>().setProducts(state.products);
        }
        if (state is ProductError) {
          FloatingMessage.show(context, message: state.message, backgroundColor: Colors.red);
        }
      },
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductEmpty) {
            return const EmptyProductSection();
          } else if (state is ProductLoaded) {
            return const ProductListSection();
          } else if (state is ProductError) {
            context.read<ProductBloc>().add(const LoadProducts());
          }
          return const EmptyProductSection();
        },
      ),
    );
  }
}

class EmptyProductSection extends StatelessWidget {
  const EmptyProductSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Belum ada produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryGreenColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Silahkan tambahkan produk mu, ya!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreenColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Produk',
                style: TextStyle(
                  fontFamily: 'Segoe',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value: context.read<CategoryBloc>(),
                        ),
                        BlocProvider.value(
                          value: context.read<ProductBloc>(),
                        ),
                      ],
                      child: const AddProductPage(),
                    ),
                  ),
                );
                if (result == true && context.mounted) {
                  context.read<ProductBloc>().add(const LoadProducts());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Updated ProductListSection dengan Active Filter Chips

class ProductListSection extends StatefulWidget {
  const ProductListSection({super.key});

  @override
  State<ProductListSection> createState() => _ProductListSectionState();
}

class _ProductListSectionState extends State<ProductListSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 SEARCH BAR + FILTER BUTTON
        BlocBuilder<ProductSearchCubit, ProductSearchState>(
          builder: (context, searchState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      hintText: 'Cari nama atau kode barang',
                      currentQuery: searchState.query,
                      onChanged: (value) {
                        context.read<ProductSearchCubit>().searchProducts(value);
                      },
                      onClear: () {
                        context.read<ProductSearchCubit>().clearSearch();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilterButton(
                    hasActiveFilter: searchState.filterState.hasActiveFilter,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductFilterPage(
                            currentFilter: searchState.filterState,
                          ),
                        ),
                      );

                      if (result != null && result is ProductFilterState) {
                        if (context.mounted) {
                          context.read<ProductSearchCubit>().applyFilter(result);
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),

        // 🏷️ ACTIVE FILTER CHIPS
        BlocBuilder<ProductSearchCubit, ProductSearchState>(
          builder: (context, searchState) {
            return ActiveFilterChips(
              filterState: searchState.filterState,
            );
          },
        ),

        // 📋 PRODUCT LIST
        Expanded(
          child: BlocBuilder<ProductSearchCubit, ProductSearchState>(
            builder: (context, searchState) {
              final products = searchState.filteredProducts;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // 🔢 Product Count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            searchState.query.isEmpty
                                ? '${products.length} Produk'
                                : '${products.length} hasil dari "${searchState.query}"',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 📭 Empty State atau List
                    if (products.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Produk tidak ditemukan',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 150),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _buildProductCard(context, product);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final stock = product.productStock;
    Color stockColor;
    String stockText;

    if (stock == 0) {
      stockColor = Colors.red;
      stockText = 'Habis';
    } else if (stock! <= 5) {
      stockColor = Colors.orange;
      stockText = 'Stok: $stock';
    } else {
      stockColor = Colors.green;
      stockText = 'Stok: $stock';
    }

    return InkWell(
      onTap: () {
        // Navigate ke Product Detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: context.read<CategoryBloc>(),
                ),
                BlocProvider.value(
                  value: context.read<ProductBloc>(),
                ),
              ],
              child: ProductDetailPage(product: product),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 🖼️ Thumbnail
                  ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: product.productPhoto != null && product.productPhoto!.isNotEmpty
                        ? Image.network(
                      product.productPhoto!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image, color: Colors.grey[400], size: 28);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        );
                      },
                    )
                        : Icon(Icons.image, color: Colors.grey[400], size: 28),
                  ),
                ),
                const SizedBox(width: 12),

              // 🏷️ Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.productCode,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // 💰 Price & Stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ✅ Tampilkan harga dengan diskon (jika ada)
                  if (product.productDiscount !> 0) ...[
                    // Harga setelah diskon
                    Text(
                      'Rp ${(product.sellingPrice * (1 - product.productDiscount !/ 100)).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Harga asli (coret)
                    Text(
                      'Rp ${product.sellingPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ] else ...[
                    // Harga normal (tanpa diskon)
                    Text(
                      'Rp ${product.sellingPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),

                  // ✅ Row untuk Stock Badge + Discount Badge
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stock Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: stockColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stockText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: stockColor,
                          ),
                        ),
                      ),

                      // ✅ Discount Badge (jika ada)
                      if (product.productDiscount !> 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product.productDiscount?.toInt()}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// // ===================== DELETE BUTTON WIDGET =====================
// class DeleteProductButton extends StatelessWidget {
//   final String productName;
//   final String productId;
//
//   const DeleteProductButton({
//     super.key,
//     required this.productName,
//     required this.productId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
//       padding: EdgeInsets.zero,
//       constraints: const BoxConstraints(),
//       onPressed: () {
//         showDialog(
//           context: context,
//           builder: (ctx) => _DeleteProductDialog(
//             productName: productName,
//             productId: productId,
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ===================== DELETE DIALOG =====================
// class _DeleteProductDialog extends StatelessWidget {
//   final String productName;
//   final String productId;
//
//   const _DeleteProductDialog({
//     required this.productName,
//     required this.productId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.warning_amber_rounded,
//                 color: Colors.red.shade400, size: 50),
//             const SizedBox(height: 12),
//             Text(
//               'Hapus Produk',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Apakah kamu yakin ingin menghapus "$productName"?',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[700],
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // Tombol Batal
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: primaryGreenColor, width: 1.5),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: const Text(
//                       'Batal',
//                       style: TextStyle(
//                         color: primaryGreenColor,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 // Tombol Hapus
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       context.read<ProductBloc>().add(DeleteProduct(productId: productId));
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red.shade600,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: const Text(
//                       'Hapus',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//


// ==================== CATEGORY SECTION ====================
class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryLoaded) {
          context.read<CategorySearchCubit>().setCategories(state.categories);
        }
      },
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoryEmpty) {
            return const EmptyCategorySection();
          } else if (state is CategoryLoaded) {
            return CategoryListSection(categories: state.categories);
          } else if (state is CategoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CategoryBloc>().add(const LoadCategories());
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          return const EmptyCategorySection();
        },
      ),
    );
  }
}

class EmptyCategorySection extends StatelessWidget {
  const EmptyCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Belum ada kategori',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryGreenColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Silahkan tambahkan kategori mu, ya!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreenColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Kategori',
                style: TextStyle(
                  fontFamily: 'Segoe',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCategoryPage()),
                );
                if (result == true && context.mounted) {
                  context.read<CategoryBloc>().add(const LoadCategories());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}


class CategoryListSection extends StatefulWidget {
  final List<CategoryModel> categories;

  const CategoryListSection({super.key, required this.categories});

  @override
  State<CategoryListSection> createState() => _CategoryListSectionState();
}

class _CategoryListSectionState extends State<CategoryListSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CategorySearchCubit>().setCategories(widget.categories);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 SEARCH BAR - TAMBAH INI
        BlocBuilder<CategorySearchCubit, CategorySearchState>(
          builder: (context, searchState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                hintText: 'Cari kategori...',
                currentQuery: searchState.query,
                onChanged: (value) {
                  context.read<CategorySearchCubit>().searchCategories(value);
                },
                onClear: () {
                  context.read<CategorySearchCubit>().clearSearch();
                },
              ),
            );
          },
        ),

        // 🔢 HEADER - UPDATE DENGAN LOGIC PENCARIAN
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: BlocBuilder<CategorySearchCubit, CategorySearchState>(
            builder: (context, searchState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    searchState.query.isEmpty
                        ? 'Nama'
                        : '${searchState.filteredCategories.length} hasil dari "${searchState.query}"',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  if (searchState.query.isEmpty)
                    const Text(
                      'Produk Terdaftar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        // 📋 CATEGORY LIST - GUNAKAN FILTERED CATEGORIES
        Expanded(
          child: BlocBuilder<CategorySearchCubit, CategorySearchState>(
            builder: (context, searchState) {
              final categories = searchState.filteredCategories;
              final productState = context.watch<ProductBloc>().state;

              // 📭 Empty State
              if (categories.isEmpty) {
                return Center(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Kategori tidak ditemukan',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isFirst = index == 0;

                  final productCount = (productState is ProductLoaded)
                      ? productState.products.where((p) => p.categoryId == category.id).length
                      : 0;

                  return CategoryItemCard(
                    category: category,
                    productCount: productCount,
                    isFirst: isFirst,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class CategoryItemCard extends StatelessWidget {
  final CategoryModel category;
  final int productCount;
  final bool isFirst;

  const CategoryItemCard({
    super.key,
    required this.category,
    required this.productCount,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: isFirst ? 4 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          category.categoryName,
          style: const TextStyle(
            fontFamily: fontType,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: primaryGreenColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primaryGreenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$productCount',
                style: const TextStyle(
                  fontFamily: fontType,
                  fontSize: 13,
                  color: primaryGreenColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 🆕 Edit Button
            InkWell(
              onTap: () {
                _showUpdateDialog(context, category);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryGreenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: primaryGreenColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Delete Button
            InkWell(
              onTap: () {
                _showDeleteCategoryDialog(context, category, productCount);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Arahkan ke halaman detail kategori (jika perlu)
        },
      ),
    );
  }

  // 🆕 Show update dialog
  void _showUpdateDialog(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CategoryBloc>(),
        child: UpdateCategoryDialog(category: category),
      ),
    );
  }

  void _showDeleteCategoryDialog(
      BuildContext context,
      CategoryModel category,
      int productCount,
      ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Hapus Kategori',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔹 Body text
              Text(
                'Apakah Anda yakin ingin menghapus kategori "${category.categoryName}"?',
                style: const TextStyle(
                  fontFamily: fontType,
                  fontSize: 14.5,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),

              // 🔸 Peringatan produk terikat
              if (productCount > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Kategori ini sedang digunakan oleh $productCount produk. Hapus produk tersebut terlebih dahulu sebelum menghapus kategori ini.',
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 13.5,
                            color: Colors.orange.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 🔹 Tombol aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryGreenColor, width: 1.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontFamily: fontType,
                        color: primaryGreenColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: productCount > 0
                        ? null
                        : () {
                      context.read<CategoryBloc>().add(
                        DeleteCategory(category.id!),
                      );
                      Navigator.pop(ctx);
                      FloatingMessage.show(
                        context,
                        message: 'Kategori "${category.categoryName}" berhasil dihapus',
                        backgroundColor: primaryGreenColor,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      productCount > 0 ? Colors.grey.shade300 : Colors.red,
                      disabledBackgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      productCount > 0 ? 'Tidak Bisa Hapus' : 'Hapus',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontWeight: FontWeight.w600,
                        color: productCount > 0 ? Colors.grey.shade600 : Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class UpdateCategoryDialog extends StatefulWidget {
  final CategoryModel category;

  const UpdateCategoryDialog({
    super.key,
    required this.category,
  });

  @override
  State<UpdateCategoryDialog> createState() => _UpdateCategoryDialogState();
}

class _UpdateCategoryDialogState extends State<UpdateCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.categoryName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      final updatedCategory = widget.category.copyWith(
        categoryName: _nameController.text.trim(),
      );

      context.read<CategoryBloc>().add(UpdateCategory(category: updatedCategory));
      FloatingMessage.show(
        context,
        message: 'Kategori berhasil dipebarui',
        backgroundColor: primaryGreenColor,
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryGreenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: primaryGreenColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Edit Kategori',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Nama Kategori
              const Text(
                'Nama Kategori',
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama kategori',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: primaryGreenColor,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama kategori tidak boleh kosong';
                  }
                  if (value.trim().length < 2) {
                    return 'Nama kategori minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryGreenColor, width: 1.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontFamily: fontType,
                        color: primaryGreenColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreenColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// search bar nya
class SearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final String currentQuery;

  const SearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    this.currentQuery = '',
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentQuery);
  }

  @override
  void didUpdateWidget(SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentQuery != oldWidget.currentQuery) {
      _controller.text = widget.currentQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // ✅ Tombol clear
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                _controller.clear();
                widget.onClear();
                setState(() {});
              },
            ),
        ],
      ),
    );
  }
}