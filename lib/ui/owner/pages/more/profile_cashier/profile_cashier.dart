import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/core/theme/theme.dart';
import 'package:pos_mobile/ui/owner/pages/more/profile_cashier/update_profile_cashier.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import '../../../../../blocs/cashier/cashier_bloc.dart';
import '../../../../../blocs/cashier/cashier_event.dart';
import '../../../../../blocs/cashier/cashier_state.dart';
import '../../../../../core/utils/auth_service.dart';
import '../../../../../data/models/cashier_model.dart';

class ProfileCashier extends StatefulWidget {
  const ProfileCashier({super.key});

  @override
  State<ProfileCashier> createState() => _ProfileCashierState();
}

class _ProfileCashierState extends State<ProfileCashier> {
  @override
  void initState() {
    super.initState();
    // 🔥 Fetch cashiers saat page dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CashierBloc>().add(const FetchCashiers());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'Profil Kasir'),
      body: BlocBuilder<CashierBloc, CashierState>(
        builder: (context, state) {
          if (state is CashierLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryGreenColor,
              ),
            );
          }

          if (state is CashierLoaded) {
            // 🔥 Ambil data user yang sedang login dari AuthService
            return FutureBuilder<Map<String, dynamic>?>(
              future: AuthService.getCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryGreenColor,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text('Data user tidak ditemukan'),
                  );
                }

                final userData = snapshot.data!;
                final currentUserId = userData['id'];

                // Cari cashier berdasarkan ID yang sedang login
                final cashier = state.cashiers.firstWhere(
                      (c) => c.id == currentUserId,
                  orElse: () =>
                      Cashier(
                        id: currentUserId,
                        fullName: userData['full_name'] ?? 'Kasir',
                        email: userData['email'] ?? 'email@example.com',
                        password: '',
                        passwordConfirmation: '',
                        phoneNumber: userData['phone_number'] ?? '-',
                        userAddress: userData['user_address'],
                      ),
                );

                return _buildContent(context, cashier);
              },
            );
          }

          if (state is CashierError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CashierBloc>().add(const FetchCashiers());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreenColor,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // Initial state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum ada data'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CashierBloc>().add(const FetchCashiers());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreenColor,
                  ),
                  child: const Text('Muat Data'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

    Widget _buildContent(BuildContext context, Cashier cashier) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryGreenColor,
                            primaryGreenColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: -20,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                        child: CashierAvatar(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    cashier.fullName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryBlueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: primaryBlueColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kasir',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryBlueColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CashierInfoCard(cashier: cashier),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        EditCashierButton(cashier: cashier),
      ],
    );
  }
}

class CashierAvatar extends StatelessWidget {
  const CashierAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          color: primaryBlueColor.withOpacity(0.1),
          child: Icon(
            Icons.person_rounded,
            size: 60,
            color: primaryBlueColor,
          ),
        ),
      ),
    );
  }
}

class CashierInfoCard extends StatelessWidget {
  final Cashier cashier;

  const CashierInfoCard({super.key, required this.cashier});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CashierInfoItem(
            icon: Icons.person_rounded,
            label: 'Nama Lengkap',
            value: cashier.fullName,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.grey[200], height: 1),
          ),
          CashierInfoItem(
            icon: Icons.email_rounded,
            label: 'Email',
            value: cashier.email,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.grey[200], height: 1),
          ),
          CashierInfoItem(
            icon: Icons.phone_rounded,
            label: 'Nomor Telepon',
            value: cashier.phoneNumber,
          ),
          if (cashier.userAddress != null && cashier.userAddress!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.grey[200], height: 1),
            ),
            CashierInfoItem(
              icon: Icons.location_on_rounded,
              label: 'Alamat',
              value: cashier.userAddress!,
            ),
          ],
        ],
      ),
    );
  }
}

class CashierInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const CashierInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryBlueColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryBlueColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Di dalam ProfileCashier, update bagian EditCashierButton:
class EditCashierButton extends StatelessWidget {
  final Cashier cashier;

  const EditCashierButton({super.key, required this.cashier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [primaryBlueColor, primaryBlueColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryBlueColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<CashierBloc>(),
                      child: UpdateProfileCashier(cashier: cashier),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: fontType,
                      color: Colors.white,
                    ),
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
