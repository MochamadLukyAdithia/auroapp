import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/cashier_repository.dart';
import 'data/repositories/stock_history_repository.dart';
import 'data/repositories/company_repository.dart';
import 'data/repositories/payment_method_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/transaction_sales_repository.dart';
import 'data/repositories/finance_repository.dart';
import 'data/repositories/outcome_repository.dart';
import 'data/repositories/flow_repository.dart';
import 'data/repositories/profile_repository.dart';

// Blocs & Cubits
import 'blocs/auth/login/login_bloc.dart';
import 'blocs/auth/register/register_bloc.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/product/product_event.dart';
import 'blocs/product/product_cubit.dart';
import 'blocs/category/category_bloc.dart';
import 'blocs/category/category_event.dart';
import 'blocs/category/category_cubit.dart';
import 'blocs/customer/customer_bloc.dart';
import 'blocs/customer/customer_event.dart';
import 'blocs/cashier/cashier_bloc.dart';
import 'blocs/cashier/cashier_event.dart';
import 'blocs/history_stock/stock_bloc.dart';
import 'blocs/owner/owner_cubit.dart';
import 'blocs/payment_method/payment_method_cubit.dart';
import 'blocs/sales_report/sales_report_cubit.dart';
import 'blocs/flow_report/flow_report_cubit.dart';
import 'blocs/financials/finance_bloc.dart';
import 'blocs/financials/finance_event.dart';
import 'blocs/transaction/transaction_cubit.dart';
import 'blocs/company/company_cubit.dart';

// UI & route
import 'route/route.dart';
import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: prefs),
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => ProductRepository()),
        RepositoryProvider(create: (_) => CategoryRepository()),
        RepositoryProvider(create: (_) => CashierRepository()),
        RepositoryProvider(create: (_) => StockRepository()),
        RepositoryProvider(create: (_) => CompanyRepository()),
        RepositoryProvider(create: (_) => PaymentMethodRepository()),
        RepositoryProvider(create: (_) => TransactionRepository()),
        RepositoryProvider(create: (_) => TransactionReportRepository()),
        RepositoryProvider(create: (_) => FinanceRepository()),
        RepositoryProvider(create: (_) => OutcomeRepository()),
        RepositoryProvider(create: (_) => CashFlowRepository()),
        RepositoryProvider(create: (_) => ProfileRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
            ProductBloc(context.read<ProductRepository>())
              ..add(const LoadProducts()),
          ),
          BlocProvider(
            create: (context) =>
            CategoryBloc(context.read<CategoryRepository>())
              ..add(const LoadCategories()),
          ),
          BlocProvider(create: (_) => ProductSearchCubit()),
          BlocProvider(create: (_) => CategorySearchCubit()),
          BlocProvider(
            create: (context) =>
            CustomerBloc()..add(const FetchCustomers()),
          ),
          BlocProvider(
            create: (context) =>
            PaymentMethodCubit(context.read<PaymentMethodRepository>())
              ..loadPaymentMethods(),
          ),
          BlocProvider(
            create: (context) =>
            CashierBloc(context.read<CashierRepository>())
              ..add(const FetchCashiers()),
          ),
          BlocProvider(
            create: (_) => FinanceBloc(
              repository: FinanceRepository(),
              outcomeRepository: OutcomeRepository(),
            )..add(const FetchFinances()),
          ),
          BlocProvider(
            create: (context) =>
                SalesReportCubit(context.read<TransactionReportRepository>()),
          ),
          BlocProvider(
            create: (_) => FinancialReportCubit(
              cashFlowRepository: CashFlowRepository(),
              transactionReportRepository: TransactionReportRepository(),
            ),
          ),
          BlocProvider(
            create: (context) =>
            CompanyCubit(context.read<CompanyRepository>())..loadCompany(),
          ),
          BlocProvider(
            create: (context) =>
            ProfileCubit(context.read<ProfileRepository>())..loadProfile(),
          ),
          BlocProvider(
            create: (context) =>
                RegisterBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                LoginBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                StockBloc(context.read<StockRepository>()),
          ),
          BlocProvider(
            create: (context) => TransactionCubit(
              stockBloc: context.read<StockBloc>(),
              repository: context.read<TransactionRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            MonthYearPickerLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('id', 'ID'),
            Locale('en', 'US'),
          ],
          title: 'Aero Pay Mobile (DEMO)',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: primaryGreenColor),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
