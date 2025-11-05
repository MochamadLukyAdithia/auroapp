import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transaction/transaction_cubit.dart';
import 'package:pos_mobile/core/theme/theme.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/detail_transaction.dart';
import '../../../../route/route.dart';
import '../../../widgets/custom_app_bar.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionCubit(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Transaksi'),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: SaleSection(),
        ),
        bottomNavigationBar: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            final totalQuantity = state.selectedItems.fold<int>(
              0,
                  (sum, p) => sum + p.quantity,
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
              onPressed: () {
                final transactionCubit = context.read<TransactionCubit>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: transactionCubit,
                      child: const DetailTransaction(),
                    ),
                  ),
                );
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          final products = state.products;
          final selectedItems = state.selectedItems;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TransactionSearchBar(
                onSearchChanged: (value) {
                  // nanti bisa pakai untuk filter produk
                },
              ),
              const SizedBox(height: 20),
              if (products.isEmpty)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Belum ada produk untuk dijual',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryGreenColor,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Silahkan tambahkan produk terlebih dahulu!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftar Produk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final isSelected = selectedItems.any((p) => p.id == product.id);
                        final quantity = selectedItems
                            .firstWhere((p) => p.id == product.id, orElse: () => Product(id: '', name: '', price: 0))
                            .quantity;

                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text('Rp ${product.price}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    context.read<TransactionCubit>().removeQuantity(product);
                                  },
                                ),
                              if (isSelected)
                                Text('$quantity'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  if (isSelected) {
                                    context.read<TransactionCubit>().addQuantity(product);
                                  } else {
                                    context.read<TransactionCubit>().addProduct(product);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Total: Rp ${state.totalPayment}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class TransactionSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;

  const TransactionSearchBar({super.key, this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
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
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Cari nama atau kode barang',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
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
