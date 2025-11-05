import 'package:flutter/material.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../route/route.dart';

class EwalletPayment extends StatelessWidget {
  const EwalletPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Pilih E-Wallet'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih E-Wallet',
                style: TextStyle(
                  fontFamily: fontType,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              EwalletListWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class EwalletListWidget extends StatelessWidget {
  EwalletListWidget({super.key});

  final List<Map<String, String>> ewallets = [
    {
      'name': 'GoPay',
      'code': 'GOPAY',
      'color': '0xFF00AA13',
      'icon': 'motorcycle'
    },
    {
      'name': 'OVO',
      'code': 'OVO',
      'color': '0xFF4B2D83',
      'icon': 'account_balance_wallet'
    },
    {
      'name': 'DANA',
      'code': 'DANA',
      'color': '0xFF118EEA',
      'icon': 'account_balance_wallet'
    },
    {
      'name': 'ShopeePay',
      'code': 'SHOPEEPAY',
      'color': '0xFFEE4D2D',
      'icon': 'shopping_bag'
    },
    {
      'name': 'LinkAja',
      'code': 'LINKAJA',
      'color': '0xFFE31E24',
      'icon': 'link'
    },
    {
      'name': 'Sakuku (BCA)',
      'code': 'SAKUKU',
      'color': '0xFF0066CC',
      'icon': 'account_balance_wallet'
    },
    {
      'name': 'i.saku (Indomaret)',
      'code': 'ISAKU',
      'color': '0xFFE31E24',
      'icon': 'store'
    },
    {
      'name': 'Jenius Pay',
      'code': 'JENIUS',
      'color': '0xFF00C2A8',
      'icon': 'credit_card'
    },
    {
      'name': 'AstraPay',
      'code': 'ASTRAPAY',
      'color': '0xFFCC0000',
      'icon': 'account_balance_wallet'
    },
    {
      'name': 'Gopay Later',
      'code': 'GOPAY_LATER',
      'color': '0xFF00AA13',
      'icon': 'payment'
    },
    {
      'name': 'SPayLater',
      'code': 'SPAYLATER',
      'color': '0xFFEE4D2D',
      'icon': 'payment'
    },
    {
      'name': 'BluePay (BCA Digital)',
      'code': 'BLUEPAY',
      'color': '0xFF0066CC',
      'icon': 'account_balance_wallet'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ewallets.map((ewallet) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: EwalletItem(
            ewalletName: ewallet['name']!,
            ewalletCode: ewallet['code']!,
            ewalletColor: Color(int.parse(ewallet['color']!)),
            iconName: ewallet['icon']!,
            onTap: () {
              // TODO: Nanti dispatch event ke Bloc atau navigate ke halaman konfirmasi
              _showEwalletConfirmation(
                  context, ewallet['name']!, ewallet['code']!);
            },
          ),
        );
      }).toList(),
    );
  }

  void _showEwalletConfirmation(
      BuildContext context, String ewalletName, String ewalletCode) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Konfirmasi E-Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anda memilih:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              ewalletName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Minta customer untuk melakukan pembayaran melalui e-wallet yang dipilih',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreenColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.transactionSuccess);


            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }
}

class EwalletItem extends StatelessWidget {
  final String ewalletName;
  final String ewalletCode;
  final Color ewalletColor;
  final String iconName;
  final VoidCallback onTap;

  const EwalletItem({
    super.key,
    required this.ewalletName,
    required this.ewalletCode,
    required this.ewalletColor,
    required this.iconName,
    required this.onTap,
  });

  IconData _getIcon(String name) {
    switch (name) {
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'link':
        return Icons.link;
      case 'store':
        return Icons.store;
      case 'credit_card':
        return Icons.credit_card;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Logo E-Wallet (Placeholder dengan icon)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ewalletColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getIcon(iconName),
                    color: ewalletColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // E-Wallet Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ewalletName,
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ewalletCode,
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}