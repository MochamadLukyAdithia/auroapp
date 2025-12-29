import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/route/route.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../blocs/payment_method/payment_method_cubit.dart';
import '../../../../../../blocs/payment_method/payment_method_state.dart';
import '../../../../../../data/models/payment_method_model.dart';
import '../../../../../widgets/floating_message.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentMethodCubit>().loadPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Metode Pembayaran'),
      body: BlocConsumer<PaymentMethodCubit, PaymentMethodState>(
        listener: (context, state) {
          if (state is PaymentMethodOperationSuccess) {
            FloatingMessage.show(context, message: state.message, backgroundColor: primaryGreenColor);
          } else if (state is PaymentMethodError) {
            FloatingMessage.show(context, message: state.message, backgroundColor: Colors.red);
          }
        },
        builder: (context, state) {
          if (state is PaymentMethodLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentMethodLoaded) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // QRIS Section
                if (state.qrisMethods.isNotEmpty) ...[
                  const PaymentSectionHeader(title: 'QRIS'),
                  const SizedBox(height: 12),
                  ...state.qrisMethods.map((method) => PaymentMethodItem(
                    paymentMethod: method,
                    onChanged: (value) {
                      context.read<PaymentMethodCubit>().togglePaymentMethod(method.id);
                    },
                  )),
                  const SizedBox(height: 32),
                ],

                // E-Wallet Section
                if (state.ewalletMethods.isNotEmpty) ...[
                  const PaymentSectionHeader(title: 'E-WALLET'),
                  const SizedBox(height: 12),
                  ...state.ewalletMethods.map((method) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PaymentMethodItem(
                      paymentMethod: method,
                      onChanged: (value) {
                        context.read<PaymentMethodCubit>().togglePaymentMethod(method.id);
                      },
                    ),
                  )),
                  const SizedBox(height: 32),
                ],

                // Bank Transfer Section
                if (state.bankMethods.isNotEmpty) ...[
                  const PaymentSectionHeader(title: 'TRANSFER BANK'),
                  const SizedBox(height: 12),
                  ...state.bankMethods.map((method) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PaymentMethodItem(
                      paymentMethod: method,
                      onChanged: (value) {
                        context.read<PaymentMethodCubit>().togglePaymentMethod(method.id);
                      },
                    ),
                  )),
                  const SizedBox(height: 32),
                ],

                const SizedBox(height: 24),
              ],
            );
          }

          return const Center(child: Text('Tidak ada metode pembayaran'));
        },
      ),
    );
  }
}

class PaymentSectionHeader extends StatelessWidget {
  final String title;

  const PaymentSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: 0.5,
        fontFamily: fontType,
      ),
    );
  }
}

class PaymentMethodItem extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final ValueChanged<bool> onChanged;

  const PaymentMethodItem({
    super.key,
    required this.paymentMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              paymentMethod.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontFamily: fontType,
              ),
            ),
          ),
          // ✅ Langsung toggle tanpa loading
          Switch(
            value: paymentMethod.isEnabled,
            onChanged: onChanged, // ✅ Langsung panggil callback
            activeColor: Colors.white,
            activeTrackColor: primaryGreenColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}