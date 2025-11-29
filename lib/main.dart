import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pos_mobile/blocs/cashier/cashier_event.dart';
import 'package:pos_mobile/blocs/financials/finance_bloc.dart';
import 'package:pos_mobile/blocs/financials/finance_event.dart';
import 'package:pos_mobile/blocs/sales_report/sales_report_cubit.dart';
import 'package:pos_mobile/blocs/transaction/transaction_cubit.dart';
import 'package:pos_mobile/data/repositories/cashier_repository.dart';
import 'package:pos_mobile/data/repositories/category_repository.dart';
import 'package:pos_mobile/data/repositories/customer_repository.dart';
import 'package:pos_mobile/data/repositories/finance_repository.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';
import 'package:pos_mobile/data/repositories/stock_history_repository.dart';
import 'package:pos_mobile/route/route.dart';
import 'package:pos_mobile/blocs/category/category_bloc.dart';
import 'package:pos_mobile/blocs/product/product_bloc.dart';
import 'blocs/auth/login/login_bloc.dart';
import 'blocs/auth/register/register_bloc.dart';
import 'blocs/cashier/cashier_bloc.dart';
import 'blocs/category/category_cubit.dart';
import 'blocs/category/category_event.dart';
import 'blocs/company/company_cubit.dart';
import 'blocs/customer/customer_bloc.dart';
import 'blocs/customer/customer_event.dart';
import 'blocs/flow_report/flow_report_cubit.dart';
import 'blocs/history_stock/stock_bloc.dart';
import 'blocs/owner/owner_cubit.dart';
import 'blocs/payment_method/payment_method_cubit.dart';
import 'blocs/product/product_cubit.dart';
import 'blocs/product/product_event.dart';
import 'core/theme/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/company_repository.dart';
import 'data/repositories/payment_method_repository.dart';
import 'data/repositories/profile_repository.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider(
          create: (context) => ProductRepository(),
        ),
        RepositoryProvider(
          create: (context) => CategoryRepository(),
        ),
        RepositoryProvider(
          create: (context) => CashierRepository(),
        ),
        RepositoryProvider(
          create: (context) => StockRepository(),
        ),
        RepositoryProvider(
          create: (context) => CompanyRepository(),
        ),
        RepositoryProvider(
          create: (context) => PaymentMethodRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ProductBloc( // ✅ Ganti _ jadi context
              context.read<ProductRepository>(),
            )..add(const LoadProducts()),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => CategoryBloc( // ✅ Ganti _ jadi context
              context.read<CategoryRepository>(),
            )..add(const LoadCategories()),
            lazy: false,
          ),
          BlocProvider(
            create: (_) => ProductSearchCubit(),
          ),
          BlocProvider(
            create: (_) => CategorySearchCubit(),
          ),
          BlocProvider(
            create: (_) => CustomerBloc()..add(const FetchCustomers()),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => PaymentMethodCubit(
              context.read<PaymentMethodRepository>(),
            )..loadPaymentMethods(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => CashierBloc(
              context.read<CashierRepository>(),
            )..add(const FetchCashiers()),
          ),
          BlocProvider(
            create: (_) => FinanceBloc(
              repository: FinanceRepository()
            )..add(const FetchFinances())
          ),
          BlocProvider(
            create: (_) => SalesReportCubit(),
          ),
          BlocProvider(
            create: (_) => FinancialReportCubit(),
          ),
          BlocProvider(
            create: (context) => CompanyCubit(CompanyRepository())..loadCompany(),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(ProfileRepository())..loadProfile(),
          ),
          BlocProvider(
            create: (context) => RegisterBloc(
              context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => LoginBloc(
              context.read<AuthRepository>(),
            ),
            lazy: false,
          ),
          // ✅ Pindahkan StockBloc & TransactionCubit ke sini (tidak perlu Builder lagi)
          BlocProvider(
            create: (context) => StockBloc(
              context.read<StockRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => TransactionCubit(
              stockBloc: context.read<StockBloc>(),
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
        ),
      ),
    );
  }
}