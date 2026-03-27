import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/banks/screens/banks_screen.dart';
import '../../features/cash/screens/cash_screen.dart';
import '../../features/customers/screens/customers_screen.dart';
import '../../features/expenses/screens/expenses_screen.dart';
import '../navigation/auth_wrapper.dart';
import '../../features/invoices/screens/create_invoice_screen.dart';
import '../../features/invoices/screens/invoices_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/reports/bloc/reports_bloc.dart';
import '../../data/repositories/reports_repository.dart';
import '../../features/cash/bloc/cash_bloc.dart';
import '../../data/repositories/cash_repository.dart';
import '../../features/invoices/bloc/invoice_bloc.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../features/stock/bloc/stock_bloc.dart';
import '../../data/repositories/stock_repository.dart';
import '../../features/customers/bloc/customer_bloc.dart';
import '../../data/repositories/customer_repository.dart';
import '../../features/suppliers/bloc/supplier_bloc.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../features/expenses/bloc/expense_bloc.dart';
import '../../data/repositories/expense_repository.dart';
import '../../features/staff/bloc/staff_bloc.dart';
import '../../data/repositories/staff_repository.dart';
import '../../features/banks/bloc/bank_bloc.dart';
import '../../data/repositories/bank_repository.dart';
import '../../core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/staff/screens/staff_screen.dart';
import '../../features/stock/screens/add_stock_item_screen.dart';
import '../../features/stock/screens/stock_screen.dart';
import '../../features/suppliers/screens/suppliers_screen.dart';
import '../../features/devices/screens/devices_screen.dart';
import '../../features/reminders/screens/reminders_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../localization/app_localizations.dart';

/// App Router
class AppRouter {
  AppRouter._();

  static const String root = '/';
  static const String login = '/login';
  static const String cash = '/cash';
  static const String stock = '/stock';
  static const String invoices = '/invoices';
  static const String customers = '/customers';
  static const String suppliers = '/suppliers';
  static const String expenses = '/expenses';
  static const String staff = '/staff';
  static const String banks = '/banks';
  static const String reports = '/reports';
  static const String addStockItem = '/stock/add-item';
  static const String createInvoice = '/invoices/create';
  static const String devices = '/devices';
  static const String reminders = '/reminders';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case root:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case cash:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<CashBloc>(
            create: (context) => CashBloc(
              cashRepository: getIt<CashRepository>(),
            ),
            child: const CashScreen(),
          ),
        );
      case stock:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<StockBloc>(
            create: (context) => StockBloc(
              stockRepository: getIt<StockRepository>(),
            ),
            child: const StockScreen(),
          ),
        );
      case invoices:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<InvoiceBloc>(
            create: (context) => InvoiceBloc(
              invoiceRepository: getIt<InvoiceRepository>(),
            ),
            child: const InvoicesScreen(),
          ),
        );
      case customers:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<CustomerBloc>(
            create: (context) => CustomerBloc(
              customerRepository: getIt<CustomerRepository>(),
            ),
            child: const CustomersScreen(),
          ),
        );
      case reports:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReportsBloc>(
            create: (context) => ReportsBloc(
              reportsRepository: getIt<ReportsRepository>(),
            ),
            child: const ReportsScreen(),
          ),
        );
      case suppliers:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<SupplierBloc>(
            create: (context) => SupplierBloc(
              supplierRepository: getIt<SupplierRepository>(),
            ),
            child: const SuppliersScreen(),
          ),
        );
      case expenses:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ExpenseBloc>(
            create: (context) => ExpenseBloc(
              expenseRepository: getIt<ExpenseRepository>(),
            ),
            child: const ExpensesScreen(),
          ),
        );
      case staff:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<StaffBloc>(
            create: (context) => StaffBloc(
              staffRepository: getIt<StaffRepository>(),
            ),
            child: const StaffScreen(),
          ),
        );
      case banks:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<BankBloc>(
            create: (context) => BankBloc(
              bankRepository: getIt<BankRepository>(),
            ),
            child: const BanksScreen(),
          ),
        );
      case addStockItem:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<StockBloc>(
            create: (context) => StockBloc(
              stockRepository: getIt<StockRepository>(),
            ),
            child: const AddStockItemScreen(),
          ),
        );
      case createInvoice:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<InvoiceBloc>(
            create: (context) => InvoiceBloc(
              invoiceRepository: getIt<InvoiceRepository>(),
            ),
            child: const CreateInvoiceScreen(),
          ),
        );
      case devices:
        return MaterialPageRoute(builder: (_) => const DevicesScreen());
      case reminders:
        return MaterialPageRoute(builder: (_) => const RemindersScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  final loc = AppLocalizations.of(context)!;
                  return Text(
                    loc.noRouteFor
                        .replaceAll('{route}', routeSettings.name ?? ''),
                  );
                },
              ),
            ),
          ),
        );
    }
  }
}
