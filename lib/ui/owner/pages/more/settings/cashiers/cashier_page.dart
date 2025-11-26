import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/ui/owner/pages/more/settings/cashiers/add_cashier.dart';
import 'package:pos_mobile/ui/owner/pages/more/settings/cashiers/update_cashier.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';

import '../../../../../../blocs/cashier/cashier_bloc.dart';
import '../../../../../../blocs/cashier/cashier_event.dart';
import '../../../../../../blocs/cashier/cashier_state.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../data/models/cashier_model.dart';
import '../../../../../widgets/floating_message.dart';

class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CashierBloc>().add(const FetchCashiers());
    });
  }

  void _showDeleteConfirmation(BuildContext context, Cashier cashier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus Kasir?',
          style: TextStyle(
            fontFamily: fontType,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus kasir "${cashier.fullName}"?',
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Data yang dihapus tidak dapat dikembalikan',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 12,
                        color: Colors.red,
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: fontType,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              context.read<CashierBloc>().add(DeleteCashier(cashier.id!));
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontFamily: fontType,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CashierBloc, CashierState>(
      listener: (context, state) {
        if (state is CashierOperationSuccess) {
          FloatingMessage.show(
            context,
            message: state.message,
            backgroundColor: primaryGreenColor,
          );
        } else if (state is CashierError) {
          FloatingMessage.show(
            context,
            message: state.message,
            backgroundColor: Colors.red,
          );
        }
      },
      builder: (context, state) {
        Widget body = const EmptyCashierSection();
        Widget? floatingButton;

        if (state is CashierLoading) {
          body = const Center(
            child: CircularProgressIndicator(color: primaryGreenColor),
          );
        } else if (state is CashierLoaded) {
          final cashiers = state.filteredCashiers;

          if (cashiers.isEmpty && (state.searchQuery?.isEmpty ?? true)) {
            body = const EmptyCashierSection();
          } else {
            body = Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CashierSearchBar(),
                ),
                Expanded(
                  child: cashiers.isEmpty
                      ? const Center(
                    child: Text(
                      'Kasir tidak ditemukan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : CashierListView(
                    cashiers: cashiers,
                    onDelete: (cashier) =>
                        _showDeleteConfirmation(context, cashier),
                  ),
                ),
              ],
            );

            floatingButton = FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCashierPage()),
                );
              },
              backgroundColor: primaryGreenColor,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
        }

        return Scaffold(
          appBar: const CustomAppBar(title: 'Manajemen Kasir'),
          body: body,
          floatingActionButton: floatingButton,
        );
      },
    );
  }
}

class EmptyCashierSection extends StatelessWidget {
  const EmptyCashierSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Belum ada Kasir',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryGreenColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba masukan data kasir, ya',
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
                'Tambah Kasir',
                style: TextStyle(
                  fontFamily: 'Segoe',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                  await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCashierPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CashierSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;

  const CashierSearchBar({
    super.key,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: TextField(
        onChanged: (value) {
          context.read<CashierBloc>().add(SearchCashier(value));
        },
        decoration: const InputDecoration(
          hintText: 'Cari kasir...',
          hintStyle: TextStyle(
            fontFamily: fontType,
            color: Colors.grey,
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

class CashierListView extends StatelessWidget {
  final List<Cashier> cashiers;
  final Function(Cashier) onDelete;

  const CashierListView({
    super.key,
    required this.cashiers,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(
      left: 16,
      right: 16,
      bottom: 100, // ⭐ Tambahkan padding bawah
    ),
      itemCount: cashiers.length,
      itemBuilder: (context, index) {
        final cashier = cashiers[index];
        return CashierCard(
          cashier: cashier,
          onDelete: () => onDelete(cashier),
        );
      },
    );
  }
}

class CashierCard extends StatelessWidget {
  final Cashier cashier;
  final VoidCallback onDelete;

  const CashierCard({
    super.key,
    required this.cashier,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryGreenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  cashier.fullName.isNotEmpty
                      ? cashier.fullName.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontFamily: fontType,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryGreenColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cashier.fullName,
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (cashier.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cashier.email,
                            style: const TextStyle(
                              fontFamily: fontType,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (cashier.phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          cashier.phoneNumber,
                          style: const TextStyle(
                            fontFamily: fontType,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (cashier.userAddress?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cashier.userAddress!,
                            style: const TextStyle(
                              fontFamily: fontType,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // 🆕 Action Buttons (Edit & Delete)
            const SizedBox(width: 8),

            // Edit Button
            InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpdateCashierPage(cashier: cashier),
                  ),
                );

                if (result == true && context.mounted) {
                  context.read<CashierBloc>().add(const FetchCashiers());
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
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
            const SizedBox(width: 8),
            // Delete Button
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
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
      ),
    );
  }
}