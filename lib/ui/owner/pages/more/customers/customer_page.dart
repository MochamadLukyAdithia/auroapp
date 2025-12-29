// ui/pages/customer/customer_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import 'package:pos_mobile/ui/widgets/floating_message.dart';
import '../../../../../blocs/customer/customer_bloc.dart';
import '../../../../../blocs/customer/customer_event.dart';
import '../../../../../blocs/customer/customer_state.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/utils/auth_service.dart';
import '../../../../../data/models/customer_model.dart';
import '../../../../../route/route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerPage extends StatefulWidget {
  final bool isSelectionMode;

  const CustomerPage({
    super.key,
    this.isSelectionMode = false,
  });

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerBloc>().add(const FetchCustomers());
    });
  }

  void _onScroll() {
    // Scroll listener dihapus karena tidak pakai pagination
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerError) {
          FloatingMessage.show(
            context,
            message: state.message,
            backgroundColor: Colors.red,
          );
        }
        if (state is CustomerOperationSuccess) {
          FloatingMessage.show(
            context,
            message: state.message,
            backgroundColor: primaryGreenColor,
          );
        }
        if (state is CustomerLoaded) {
          setState(() => _isLoadingMore = false);
        }
      },
      builder: (context, state) {
        Widget body = const EmptyCustomerSection();
        Widget? floatingButton;

        if (state is CustomerLoading) {
          body = const Center(
            child: CircularProgressIndicator(color: primaryGreenColor),
          );
        } else if (state is CustomerLoaded) {
          final customers = state.customers;

          if (customers.isEmpty && (state.searchQuery?.isEmpty ?? true)) {
            body = const EmptyCustomerSection();
          } else {
            body = Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CustomerSearchBar(),
                      const SizedBox(height: 4),
                      Text(
                        'Total: ${state.total} pelanggan',
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: customers.isEmpty
                      ? const Center(
                    child: Text(
                      'Pelanggan tidak ditemukan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : CustomerListView(
                    controller: _scrollController,
                    customers: customers,
                    isSelectionMode: widget.isSelectionMode,
                    onCustomerSelected: widget.isSelectionMode
                        ? (customer) {
                      Navigator.pop(context, customer);
                    }
                        : null,
                  ),
                ),
              ],
            );

            // FAB hanya muncul di view only mode
            if (!widget.isSelectionMode) {
              floatingButton = FloatingActionButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.addCustomer);
                  if (mounted) {
                    // Refresh dengan search query yang ada
                    final currentState = context.read<CustomerBloc>().state;
                    final searchQuery = currentState is CustomerLoaded
                        ? currentState.searchQuery
                        : null;

                    context.read<CustomerBloc>().add(
                      FetchCustomers(
                        searchQuery: searchQuery,
                      ),
                    );
                  }
                },
                backgroundColor: primaryGreenColor,
                child: const Icon(Icons.add, color: Colors.white),
              );
            }
          }
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: widget.isSelectionMode ? 'Pilih Pelanggan' : 'Data Pelanggan',
          ),
          body: body,
          floatingActionButton: floatingButton,
        );
      },
    );
  }
}

class EmptyCustomerSection extends StatelessWidget {
  const EmptyCustomerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Data Pelanggan Kosong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryGreenColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba masukan data pelanggan, ya',
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
                'Tambah Pelanggan',
                style: TextStyle(
                  fontFamily: 'Segoe',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.addCustomer);
                if (context.mounted) {
                  context.read<CustomerBloc>().add(const FetchCustomers());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerSearchBar extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;

  const CustomerSearchBar({
    super.key,
    this.onSearchChanged,
  });

  @override
  State<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends State<CustomerSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Sync dengan state yang ada
    final state = context.read<CustomerBloc>().state;
    if (state is CustomerLoaded && state.searchQuery != null) {
      _controller.text = state.searchQuery!;
    }

    // Listen ke perubahan controller
    _controller.addListener(() {
      setState(() {}); // Untuk update suffixIcon
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        autofocus: false,
        style: const TextStyle(
          fontFamily: fontType,
          color: Colors.black87,
          fontSize: 14,
        ),
        onChanged: (value) {

          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            if (widget.onSearchChanged != null) {
              widget.onSearchChanged!(value);
            } else {
              context.read<CustomerBloc>().add(SearchCustomer(value));
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari pelanggan...',
          hintStyle: const TextStyle(
            fontFamily: fontType,
            color: Colors.grey,
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _controller.clear();
              context.read<CustomerBloc>().add(const SearchCustomer(''));
            },
          )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

class CustomerListView extends StatelessWidget {
  final ScrollController controller;
  final List<Customer> customers;
  final bool isSelectionMode;
  final Function(Customer)? onCustomerSelected;

  const CustomerListView({
    super.key,
    required this.controller,
    required this.customers,
    this.isSelectionMode = false,
    this.onCustomerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return CustomerCard(
          customer: customer,
          isSelectionMode: isSelectionMode,
          onTap: isSelectionMode && onCustomerSelected != null
              ? () => onCustomerSelected!(customer)
              : null,
        );
      },
    );
  }
}

class CustomerCard extends StatefulWidget {
  final Customer customer;
  final bool isSelectionMode;
  final VoidCallback? onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    this.isSelectionMode = false,
    this.onTap,
  });

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  bool _isOwner = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final isOwner = await AuthService.isOwner();
    setState(() {
      _isOwner = isOwner;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
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
                    widget.customer.name.isNotEmpty
                        ? widget.customer.name.substring(0, 1).toUpperCase()
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
                      widget.customer.name,
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (widget.customer.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            widget.customer.phone,
                            style: const TextStyle(
                              fontFamily: fontType,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.customer.email?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.customer.email!,
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
                    if (widget.customer.address?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.customer.address!,
                              style: const TextStyle(
                                fontFamily: fontType,
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons - hanya muncul di view mode & owner
              if (!widget.isSelectionMode && _isOwner) ...[
                const SizedBox(width: 8),
                // Edit Button
                InkWell(
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRoutes.updateCustomer,
                      arguments: widget.customer,
                    );

                    if (result != null && context.mounted) {
                      // Refresh dengan search query yang ada
                      final currentState = context.read<CustomerBloc>().state;
                      final searchQuery = currentState is CustomerLoaded
                          ? currentState.searchQuery
                          : null;

                      context.read<CustomerBloc>().add(
                        FetchCustomers(
                          searchQuery: searchQuery,
                        ),
                      );
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
                  onTap: () => _showDeleteDialog(context, widget.customer),
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

              // Chevron icon hanya muncul di selection mode
              if (widget.isSelectionMode)
                const Icon(
                  Icons.chevron_right,
                  color: primaryGreenColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus Pelanggan?',
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
              'Apakah Anda yakin ingin menghapus pelanggan "${customer.name}"?',
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
              context.read<CustomerBloc>().add(DeleteCustomer(customer.id!));
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
}