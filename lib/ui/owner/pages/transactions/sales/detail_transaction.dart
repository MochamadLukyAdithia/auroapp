import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transaction/transaction_cubit.dart';
import 'package:pos_mobile/route/route.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';

import '../../../../../core/theme/theme.dart';

class DetailTransaction extends StatelessWidget {
  const DetailTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Rincian Pembayaran'),
      body: Column(
        children: [
          const CustomerSelectionButton(),
          const Expanded(child: ItemListSection()),
          const BottomActionButtons(),
          BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, state) {
              final totalQty = state.selectedItems.fold<int>(
                  0, (sum, p) => sum + p.quantity);
              return PaymentButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.detailPayment);
                },
                quantity: totalQty,
                price: 'Rp ${state.totalPayment}',
                label: 'Bayar',
              );
            },
          ),
        ],
      ),
    );
  }
}

// pilih pelanggan
class CustomerSelectionButton extends StatelessWidget {
  const CustomerSelectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.chooseCustomer);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_outlined, color: primaryGreenColor, size: 24),
            SizedBox(width: 12),
            Text(
              'Pilih Pelanggan',
              style: TextStyle(
                fontFamily: fontType,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: primaryGreenColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// listnya nanti
class ItemListSection extends StatelessWidget{
  const ItemListSection({super.key});

  @override
  Widget build(BuildContext context){
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        // cek state nya dari function
        final selectedProducts = state.selectedItems.where((p) => p.quantity > 0).toList();
        if (selectedProducts.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada item ditambahkan',
              style: TextStyle(
                fontFamily: fontType,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: selectedProducts.length,
          itemBuilder: (context, index) {
            final product = selectedProducts[index];
            return ListTile(
              title: Text(
                product.name,
                style: const TextStyle(
                  fontFamily: fontType,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                'Qty: ${product.quantity}',
                style: const TextStyle(
                  fontFamily: fontType,
                  fontSize: 13,
                ),
              ),
              trailing: Text(
                'Rp ${product.price * product.quantity}',
                style: const TextStyle(
                  fontFamily: fontType,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            );
          },
        );
      },
    );

  }
}

// trio button dibawah
class BottomActionButtons extends StatelessWidget {
  const BottomActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white, // biar nyatu halus sama PaymentButton
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)), // soft line pemisah
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ActionButton(
              icon: Icons.percent_rounded,
              label: 'Diskon',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ActionButton(
              icon: Icons.receipt_long_rounded,
              label: 'Biaya Lain',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ActionButton(
              icon: Icons.delete_outline_rounded,
              label: 'Hapus',
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey.shade500, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: fontType,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// next bayar
class PaymentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int quantity;
  final String label;
  final String price;

  const PaymentButton({
    super.key,
    required this.onPressed,
    this.quantity = 1,
    this.label = 'Bayar',
    this.price = 'Rp 0',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryGreenColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(0),
        child: Material(
          color: Colors.transparent,
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
      ),
    );
  }
}