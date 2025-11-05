import 'package:flutter/material.dart';
import 'package:pos_mobile/ui/owner/pages/auth/register_page.dart';
import 'package:pos_mobile/ui/owner/pages/finances/add_finance.dart';
import 'package:pos_mobile/ui/owner/pages/finances/filtered_finance_date.dart';
import 'package:pos_mobile/ui/owner/pages/finances/finance_page.dart';
import 'package:pos_mobile/ui/owner/pages/finances/update_finance.dart';
import 'package:pos_mobile/ui/owner/pages/more/settings/cashiers/add_cashier.dart';
import 'package:pos_mobile/ui/owner/pages/more/settings/payment_methods/add_payment_method_page.dart';
import 'package:pos_mobile/ui/owner/pages/more/settings/payment_methods/payment_method_page.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/payment/bank.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/payment/cash.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/choose_customer.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/detail_payment.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/detail_transaction.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/payment/e-wallet.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/payment/transaction_success.dart';
import '../ui/owner/pages/auth/login_page.dart';
import '../ui/owner/pages/auth/verification_page.dart';
import '../ui/owner/pages/more/about/about_page.dart';
import '../ui/owner/pages/more/customers/add_customer_page.dart';
import '../ui/owner/pages/more/customers/customer_page.dart';
import '../ui/owner/pages/more/guide/guide_page.dart';
import '../ui/owner/pages/more/more_page.dart';
import '../ui/owner/pages/more/purchases/purchase_completed.dart';
import '../ui/owner/pages/more/purchases/purchase_detail.dart';
import '../ui/owner/pages/more/purchases/purchase_page.dart';
import '../ui/owner/pages/more/purchases/purchase_payment.dart';
import '../ui/owner/pages/more/report/flow_report.dart';
import '../ui/owner/pages/more/report/expenditure_report.dart';
import '../ui/owner/pages/more/report/report_page.dart';
import '../ui/owner/pages/more/report/sales_report.dart';
import '../ui/owner/pages/more/settings/cashiers/cashier_page.dart';
import '../ui/owner/pages/more/settings/setting_page.dart';
import '../ui/owner/pages/more/settings/shop/shop_page.dart';
import '../ui/owner/pages/more/suppliers/add_supplier.dart';
import '../ui/owner/pages/more/suppliers/supplier_page.dart';
import '../ui/owner/pages/products_categories/categories/add_category_page.dart';
import '../ui/owner/pages/products_categories/product_category.dart';
import '../ui/owner/pages/products_categories/products/add_price_page.dart';
import '../ui/owner/pages/products_categories/products/add_product.dart';
import '../ui/owner/pages/splash_screen.dart';
import '../ui/owner/pages/transactions/preorders/perorder.dart';
import '../ui/owner/pages/transactions/sales/sale.dart';
import '../ui/owner/pages/transactions/transaction_page.dart';
import '../ui/widgets/bottom_bar.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/auth/login/';
  static const String register = '/auth/register';
  static const String verification = '/auth/register/verification';
  static const String homepage = '/bottom_bar';

  //---------------- PRODUCTS PAGE ----------------
  static const String product = '/product';
  static const String addProduct = '/product/add_product';
  static const String addPrice = '/product/add_product/add_price';
  static const String addCategory = '/category/add_category';

  //---------------- TRANSACTION PAGE ----------------
  static const String transaction = '/transaction';
  static const String sale = '/transaction/sale';
  static const String detailTransaction = '/transaction/sale/detail_transaction';
  static const String chooseCustomer = '/transaction/sale/detail_transaction/choose_customer';
  static const String detailPayment = '/transaction/sale/detail_transaction/detail_payment';
  static const String cashPayment = '/transaction/sale/detail_transaction/detail_payment/cash_payment';
  static const String bankPayment = '/transaction/sale/detail_transaction/detail_payment/bank_payment';
  static const String ewalletPayment = '/transaction/sale/detail_transaction/detail_payment/ewallet_payment';
  static const String transactionSuccess = '/transaction/sale/detail_transaction/detail_payment/transaction_success';

  // static const String preorder = '/transaction/preorder';
  // static const String QR = '/transaction/QR';

  //---------------- FINANCE PAGE ----------------
  static const String finance = '/finance';
  static const String addFinance = '/finance/add_finance';
  static const String filteredFinance = '/finance/filtered_finance';
  static const String updateFinance = '/finance/update_finance';

  //---------------- MORE PAGE ----------------
  static const String more = '/more';
  static const String customer = '/more/customer';
  static const String addCustomer = '/more/customer/add_customer';

  // static const String supplier = '/more/supplier'; //Tidak terpakai
  // static const String addSupplier = '/more/customer/add_supplier'; //Tidak terpakai

  static const String purchase = '/more/purchase';
  static const String purchaseDetail = '/more/purchase/purchase_detail';
  static const String purchaseCompleted = '/more/purchase/purchase_completed';
  static const String purchasePayment = '/more/purchase/purchase_payment';

  static const String report= '/more/report';
  static const String flowReport = '/more/report/flow_report';
  static const String expenditureReport = '/more/report/expenditure_report';
  static const String salesReport = '/more/report/sales_report';

  static const String setting = '/more/setting';
  static const String cashier = '/more/setting/cashier';
  static const String addCashier = '/more/setting/cashier/add_cashier';
  static const String paymentMethod = '/more/setting/payment_method';
  static const String addPaymentMethod = '/more/setting/payment_method/add_payment_method';
  static const String shop = '/more/setting/shop';

  static const String guide = '/more/guide';
  static const String about = '/more/about';

  // Generate Routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case verification:
        return MaterialPageRoute(builder: (_) => const VerificationPage());

      case homepage:
        return MaterialPageRoute(builder: (_) => const BottomBar());

    // ============ PRODUCTS ============
      case product:
        return MaterialPageRoute(builder: (_) => const ProductCategoryPage());

      case addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductPage());

      case addPrice:
        return MaterialPageRoute(builder: (_) => const AddPricePage());

      // case category:
      //   return MaterialPageRoute(builder: (_) => const CategoryPage());

      case addCategory:
        return MaterialPageRoute(builder: (_) => const AddCategoryPage());

    // ============ TRANSACTION ============
      case transaction:
        return MaterialPageRoute(builder: (_) => const TransactionPage());

      case sale:
        return MaterialPageRoute(builder: (_) => const SalePage());

      case detailTransaction:
        return MaterialPageRoute(builder: (_) => const DetailTransaction());

      case chooseCustomer:
        return MaterialPageRoute(builder: (_) => const ChooseCustomer());

      case detailPayment:
        return MaterialPageRoute(builder: (_) => const DetailPayment());

      case cashPayment:
        return MaterialPageRoute(builder: (_) => const CashPayment());

      case bankPayment:
        return MaterialPageRoute(builder: (_) => const BankTransferPayment());

      case ewalletPayment:
        return MaterialPageRoute(builder: (_) => const EwalletPayment());

      case transactionSuccess:
        return MaterialPageRoute(builder: (_) => const TransactionSuccess());

      // case preorder:
      //   return MaterialPageRoute(builder: (_) => const PreorderPage());
      //
      // case QR:
      //   return MaterialPageRoute(builder: (_) => const QrScanner());

    // ============ FINANCE ============
      case finance:
        return MaterialPageRoute(builder: (_) => const FinancePage());

      case addFinance:
        return MaterialPageRoute(builder: (_) => const AddFinance());

      case filteredFinance:
        return MaterialPageRoute(builder: (_) => const FilteredFinancesPage());

      case updateFinance:
        return MaterialPageRoute(builder: (_) => const UpdateFinance());

    // ============ MORE ============
      case more:
        return MaterialPageRoute(builder: (_) => const MorePage());

      case customer:
        return MaterialPageRoute(builder: (_) => const CustomerPage());

      case addCustomer:
        return MaterialPageRoute(builder: (_) => const AddCustomerPage());

      // case supplier:
      //   return MaterialPageRoute(builder: (_) => const SupplierPage());
      //
      // case addSupplier:
      //   return MaterialPageRoute(builder: (_) => const AddSupplierPage());

      // case purchase:
      //   return MaterialPageRoute(builder: (_) => const PurchasePage());
      //
      // case purchaseDetail:
      //   return MaterialPageRoute(builder: (_) => const PurchaseDetail());
      //
      // case purchaseCompleted:
      //   return MaterialPageRoute(builder: (_) => const PurchaseCompleted());
      //
      // case purchasePayment:
      //   return MaterialPageRoute(builder: (_) => const PurchasePayment());

      case report:
        return MaterialPageRoute(builder: (_) => const ReportPage());

      case flowReport:
        return MaterialPageRoute(builder: (_) => const FlowReportPage());

      case expenditureReport:
        return MaterialPageRoute(builder: (_) => const ExpenditureReportPage());

      case setting:
        return MaterialPageRoute(builder: (_) => const SettingPage());

      case cashier:
        return MaterialPageRoute(builder: (_) => const CashierPage());

      case addCashier:
        return MaterialPageRoute(builder: (_) => const AddCashierPage());

      case paymentMethod:
        return MaterialPageRoute(builder: (_) => const PaymentMethodPage());

      case addPaymentMethod:
        return MaterialPageRoute(builder: (_) => const AddPaymentMethodPage());

      case shop:
        return MaterialPageRoute(builder: (_) => const ShopPage());

      case salesReport:
        return MaterialPageRoute(builder: (_) => const SalesReportPage());

      case guide:
        return MaterialPageRoute(builder: (_) => const GuidePage());

      case about:
        return MaterialPageRoute(builder: (_) => const AboutPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

}