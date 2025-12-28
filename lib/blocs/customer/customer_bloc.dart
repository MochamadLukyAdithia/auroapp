// blocs/customer/customer_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _repository;

  CustomerBloc({CustomerRepository? repository})
      : _repository = repository ?? CustomerRepository(),
        super(CustomerInitial()) {
    on<FetchCustomers>(_onFetchCustomers);
    on<FetchCustomerById>(_onFetchCustomerById);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<SearchCustomer>(_onSearchCustomer);
  }

  Future<void> _onFetchCustomers(
      FetchCustomers event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerLoading());

    try {
      final result = await _repository.getCustomers(
        page: event.page ?? 1,
        limit: event.limit, // Tanpa default limit - ambil semua
        search: event.searchQuery,
      );

      if (result.success && result.data != null) {
        final customers = result.data!['customers'];
        final total = result.data!['total'];
        final currentPage = result.data!['current_page'];
        final lastPage = result.data!['last_page'];

        emit(CustomerLoaded(
          customers: customers,
          searchQuery: event.searchQuery,
          currentPage: currentPage,
          lastPage: lastPage,
          total: total,
        ));
      } else {
        emit(CustomerError(result.message));
      }
    } catch (e) {
      emit(CustomerError('Gagal memuat data pelanggan: ${e.toString()}'));
    }
  }

  Future<void> _onFetchCustomerById(
      FetchCustomerById event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerLoading());

    try {
      final result = await _repository.getCustomer(event.customerId);

      if (result.success && result.data != null) {
        emit(CustomerDetailLoaded(result.data!));
      } else {
        emit(CustomerError(result.message));
      }
    } catch (e) {
      emit(CustomerError('Gagal memuat detail pelanggan: ${e.toString()}'));
    }
  }

  Future<void> _onAddCustomer(
      AddCustomer event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerLoading());

    try {
      final result = await _repository.addCustomer(event.customer);

      if (result.success) {
        emit(CustomerOperationSuccess(
          result.message,
          customer: result.data,
        ));

        // Refresh customer list dengan search query yang ada
        final currentSearch = state is CustomerLoaded
            ? (state as CustomerLoaded).searchQuery
            : null;

        add(FetchCustomers(
          page: 1,
          limit: 20,
          searchQuery: currentSearch,
        ));
      } else {
        emit(CustomerError(result.message));

        // Return to previous state
        if (state is CustomerLoaded) {
          emit(state as CustomerLoaded);
        } else {
          add(const FetchCustomers(page: 1, limit: 20));
        }
      }
    } catch (e) {
      emit(CustomerError('Gagal menambahkan pelanggan: ${e.toString()}'));
      add(const FetchCustomers(page: 1, limit: 20));
    }
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomer event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerLoading());

    try {
      final result = await _repository.updateCustomer(event.customer);

      if (result.success) {
        emit(CustomerOperationSuccess(
          result.message,
          customer: result.data,
        ));

        // Refresh customer list dengan search query yang ada
        final currentSearch = state is CustomerLoaded
            ? (state as CustomerLoaded).searchQuery
            : null;

        add(FetchCustomers(
          page: 1,
          limit: 20,
          searchQuery: currentSearch,
        ));
      } else {
        emit(CustomerError(result.message));

        // Return to previous state
        if (state is CustomerLoaded) {
          emit(state as CustomerLoaded);
        } else {
          add(const FetchCustomers(page: 1, limit: 20));
        }
      }
    } catch (e) {
      emit(CustomerError('Gagal memperbarui pelanggan: ${e.toString()}'));
      add(const FetchCustomers(page: 1, limit: 20));
    }
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomer event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerLoading());

    try {
      final result = await _repository.deleteCustomer(event.customerId);

      if (result.success) {
        emit(CustomerOperationSuccess(result.message));

        // Refresh customer list dengan search query yang ada
        final currentSearch = state is CustomerLoaded
            ? (state as CustomerLoaded).searchQuery
            : null;

        add(FetchCustomers(
          page: 1,
          limit: 20,
          searchQuery: currentSearch,
        ));
      } else {
        emit(CustomerError(result.message));

        // Return to previous state
        if (state is CustomerLoaded) {
          emit(state as CustomerLoaded);
        } else {
          add(const FetchCustomers(page: 1, limit: 20));
        }
      }
    } catch (e) {
      emit(CustomerError('Gagal menghapus pelanggan: ${e.toString()}'));
      add(const FetchCustomers(page: 1, limit: 20));
    }
  }

  Future<void> _onSearchCustomer(
      SearchCustomer event,
      Emitter<CustomerState> emit,
      ) async {
    // Langsung fetch dengan query baru
    add(FetchCustomers(
      page: 1,
      limit: 20,
      searchQuery: event.query.isEmpty ? null : event.query,
    ));
  }
}