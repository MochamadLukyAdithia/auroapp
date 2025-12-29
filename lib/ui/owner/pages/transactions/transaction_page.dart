import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transaction/transaction_cubit.dart';
import 'package:pos_mobile/core/theme/theme.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/detail_transaction.dart';
import 'package:pos_mobile/ui/widgets/floating_message.dart';
import '../../../../blocs/history_stock/stock_bloc.dart';
import '../../../../blocs/payment_method/payment_method_cubit.dart';
import '../../../../blocs/payment_method/payment_method_state.dart';
import '../../../../blocs/product/product_bloc.dart';
import '../../../../blocs/product/product_event.dart';
import '../../../../blocs/product/product_state.dart';
import '../../../../blocs/transaction/transaction_state.dart';
import '../../../../data/models/product_model.dart';
import '../../../widgets/custom_app_bar.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }


  void _loadProducts() {
    final productBloc = context.read<ProductBloc>();
    final productState = productBloc.state;
    final transactionCubit = context.read<TransactionCubit>();

    if (productState is ProductLoaded) {
      transactionCubit.loadProducts(productState.products);
    } else if (productState is ProductInitial || productState is ProductError) {
      productBloc.add(const LoadProducts());
    }

    final paymentMethodCubit = context.read<PaymentMethodCubit>();
    final paymentMethodState = paymentMethodCubit.state;
    if (paymentMethodState is PaymentMethodLoaded) {
      transactionCubit.loadPaymentMethods(paymentMethodState.paymentMethods);
    } else if (paymentMethodState is PaymentMethodInitial) {
      paymentMethodCubit.loadPaymentMethods();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // nge load data produk
        BlocListener<ProductBloc, ProductState>(
          listener: (context, productState) {
            if (productState is ProductLoaded) {
              context.read<TransactionCubit>().loadProducts(productState.products);
            }
          },
        ),
        BlocListener<PaymentMethodCubit, PaymentMethodState>(
          listener: (context, paymentMethodState) {
            if (paymentMethodState is PaymentMethodLoaded) {
              context.read<TransactionCubit>().loadPaymentMethods(
                paymentMethodState.paymentMethods,
              );
            }
          },
        ),
        BlocListener<TransactionCubit, TransactionState>(
          listener: (context, transactionState) {
            // Kalau flag shouldReloadProducts = true, reload products
            if (transactionState.shouldReloadProducts) {
              context.read<ProductBloc>().add(const LoadProducts());

              // Reset flag setelah 100ms biar ga loop
              Future.delayed(const Duration(milliseconds: 100), () {
                if (context.mounted) {
                  final cubit = context.read<TransactionCubit>();
                  cubit.emit(cubit.state.copyWith(shouldReloadProducts: false));
                }
              });
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Transaksi'),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            if (productState is ProductLoading) {
              return const Center(
                child: CircularProgressIndicator(color: primaryGreenColor),
              );
            }

            if (productState is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        context.read<ProductBloc>().add(const LoadProducts());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            return const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: SaleSection(),
            );
          },
        ),
        bottomNavigationBar:
        BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            final totalQuantity = state.selectedItems.fold<int>(
              0,
                  (sum, product) => sum + state.getQuantity(product.id.toString()),
            );

            if (totalQuantity == 0) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                child: const Text(
                  'Belum ada produk dipilih',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: fontType,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            return PaymentButton(
              onPressed: () async {  // ✅ TAMBAH async
                final state = context.read<TransactionCubit>().state;
                bool stockValid = true;
                String? errorMessage;

                for (var product in state.selectedItems) {
                  final qty = state.getQuantity(product.id.toString());
                  final stock = product.productStock;
                  if (qty > stock!) {
                    stockValid = false;
                    errorMessage = 'Stok ${product.productName} tidak mencukupi!\n'
                        'Tersedia: $stock, Dipilih: $qty';
                    break;
                  }
                }
                if (!stockValid) {
                  FloatingMessage.show(context, message: errorMessage, backgroundColor: Colors.red);
                  return;
                }

                // ✅ AWAIT hasil navigation
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(  // ✅ Ubah jadi MultiBlocProvider
                      providers: [
                        BlocProvider.value(value: context.read<TransactionCubit>()),
                        BlocProvider.value(value: context.read<ProductBloc>()),  // ✅ Tambah ini
                      ],
                      child: const DetailTransaction(),
                    ),
                  ),
                );

                // ✅ RELOAD products kalau transaksi berhasil
                if (result == true && context.mounted) {
                  context.read<ProductBloc>().add(const LoadProducts());
                }
              },
              quantity: totalQuantity,
              price: 'Rp ${state.totalPayment}',
            );
          },
        ),
      ),
    );
    }
  }


class SaleSection extends StatelessWidget {
  const SaleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final products = state.filteredProductsWithStock;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TransactionSearchBar(),
            const SizedBox(height: 20),

            if (products.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      state.searchQuery.isEmpty
                          ? 'Belum ada produk untuk dijual'
                          : 'Produk tidak ditemukan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryGreenColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.searchQuery.isEmpty
                          ? 'Silahkan tambahkan produk terlebih dahulu!'
                          : 'Coba kata kunci lain',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Produk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // ✅ Counter hasil search
                      if (state.searchQuery.isNotEmpty)
                        Text(
                          '${products.length} hasil',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisExtent: 115,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductTransactionCard(product: product);
                    },
                  ),
                  const SizedBox(height: 20),
                  // Text(
                  //   'Total: Rp ${state.totalPayment}',
                  //   style: const TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
          ],
        );
      },
    );
  }
}

// search bar nya
class TransactionSearchBar extends StatelessWidget {
  const TransactionSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
                  onChanged: (value) {
                    context.read<TransactionCubit>().setSearchQuery(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Cari nama atau kode barang',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              // ✅ Tombol clear (opsional)
              if (state.searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    context.read<TransactionCubit>().clearSearch();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class ProductTransactionCard extends StatelessWidget {
  final ProductModel product;

  const ProductTransactionCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // ✅ Wrap dengan BlocBuilder untuk akses state
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final quantity = state.getQuantity(product.id.toString());
        final currentStock = product.productStock;
        final remainingStock = currentStock! - quantity;
        final isLowStock = remainingStock > 0 && remainingStock <= 5;
        final isOutOfStock = quantity >= currentStock;
        final hasStock = product.productStock != null;
        final hasDiscount = product.productDiscount > 0;

        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: quantity > 0
                      ? primaryGreenColor.withOpacity(0.3)
                      : Colors.grey.shade200,
                  width: quantity > 0 ? 1.5 : 1,
                ),
                boxShadow: quantity > 0
                    ? [
                  BoxShadow(
                    color: primaryGreenColor.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // ✅ Langsung tambah produk saat di-klik
                    if (quantity == 0) {
                      context.read<TransactionCubit>().addProduct(product);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Gambar produk
                        Container(
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
                        const SizedBox(width: 12),

                        // Info produk
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.productName,
                                style: const TextStyle(
                                  fontFamily: fontType,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.productCode,
                                style: TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // ✅ Stock info dengan ukuran yang sama
                              Row(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    hasStock
                                        ? 'Stok: $remainingStock/$currentStock'
                                        : 'Stok: -',
                                    style: TextStyle(
                                      fontFamily: fontType,
                                      fontSize: 11,
                                      color: hasStock && isLowStock
                                          ? Colors.red.shade600
                                          : Colors.grey.shade600,
                                      fontWeight: hasStock && isLowStock
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // ✅ Progress bar selalu ditampilkan dengan ukuran sama
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: hasStock && currentStock > 0
                                      ? remainingStock / currentStock
                                      : 0,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    hasStock && isLowStock
                                        ? Colors.red.shade400
                                        : primaryGreenColor,
                                  ),
                                  minHeight: 3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Harga & Icon Add
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ✅ Tampilkan harga dengan diskon
                            if (hasDiscount) ...[
                              // Harga setelah diskon
                              Text(
                                'Rp ${(product.sellingPrice * (1 - product.productDiscount / 100)).toInt()}',
                                style: const TextStyle(
                                  fontFamily: fontType,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Harga asli coret + badge diskon
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Rp ${product.sellingPriceInt}',
                                    style: TextStyle(
                                      fontFamily: fontType,
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      '-${product.productDiscount.toInt()}%',
                                      style: TextStyle(
                                        fontFamily: fontType,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Harga normal (tanpa diskon)
                              Text(
                                'Rp ${product.sellingPriceInt}',
                                style: const TextStyle(
                                  fontFamily: fontType,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],

                            const SizedBox(height: 8),

                            // ✅ Icon + atau Quantity control
                            if (quantity == 0)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: primaryGreenColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: primaryGreenColor,
                                ),
                              )
                            else
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Tombol minus
                                    InkWell(
                                      onTap: () {
                                        context
                                            .read<TransactionCubit>()
                                            .removeQuantity(product);
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.remove,
                                          size: 16,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),

                                    // Quantity number
                                    Container(
                                      constraints:
                                      const BoxConstraints(minWidth: 28),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontFamily: fontType,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),

                                    // Tombol plus
                                    AnimatedScale(
                                      scale: isOutOfStock ? 0.95 : 1.0,
                                      duration:
                                      const Duration(milliseconds: 100),
                                      child: InkWell(
                                        onTap: isOutOfStock
                                            ? null
                                            : () {
                                          context
                                              .read<TransactionCubit>()
                                              .addQuantity(product);
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            Icons.add,
                                            size: 16,
                                            color: isOutOfStock
                                                ? Colors.grey.shade400
                                                : primaryGreenColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ✅ Badge stok menipis (pindahkan ke luar AnimatedContainer)
            if (hasStock && isLowStock)
              Positioned(
                top: 8,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Sisa $remainingStock',
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PaymentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int quantity;
  final String label;
  final String price;

  const PaymentButton({
    super.key,
    required this.onPressed,
    required this.quantity,
    required this.price,
    this.label = 'Bayar',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryGreenColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -1)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: onPressed,
          splashColor: Colors.white24,
          highlightColor: Colors.white12,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.white, size: 22),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: value, end: value),
      duration: duration,
      builder: (context, animatedValue, child) {
        return Text(
          '$animatedValue',
          style: style,
        );
      },
    );
  }
}