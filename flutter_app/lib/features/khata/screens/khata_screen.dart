import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../data/repositories/bank_repository.dart';
import '../../customers/bloc/customer_bloc.dart';
import '../../suppliers/bloc/supplier_bloc.dart';
import '../../banks/bloc/bank_bloc.dart';
import '../../customers/screens/customers_screen.dart';
import '../../suppliers/screens/suppliers_screen.dart';
import '../../banks/screens/banks_screen.dart';
import '../../../core/localization/app_localizations.dart';

class KhataScreen extends StatelessWidget {
  const KhataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CustomerBloc>(
            create: (context) => CustomerBloc(
              customerRepository: getIt<CustomerRepository>(),
            ),
          ),
          BlocProvider<SupplierBloc>(
            create: (context) => SupplierBloc(
              supplierRepository: getIt<SupplierRepository>(),
            ),
          ),
          BlocProvider<BankBloc>(
            create: (context) => BankBloc(
              bankRepository: getIt<BankRepository>(),
            ),
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.khata),
            bottom: TabBar(
              tabs: [
                Tab(text: AppLocalizations.of(context)!.customers),
                Tab(text: AppLocalizations.of(context)!.suppliers),
                Tab(text: AppLocalizations.of(context)!.banks),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              CustomersScreen(),
              SuppliersScreen(),
              BanksScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
