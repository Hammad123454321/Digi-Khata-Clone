import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/repositories/reports_repository.dart';
import '../../invoices/bloc/invoice_bloc.dart';
import '../../reports/bloc/reports_bloc.dart';
import '../../invoices/screens/invoices_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../more/screens/more_screen.dart';
import '../../../core/localization/locale_bloc.dart';
import '../../business/bloc/business_bloc.dart';
import '../../business/bloc/business_state.dart';
import 'home_tab.dart';
import '../../../core/localization/app_localizations.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Match screenshot: Home, Sale, Money, More
  final _tabs = const [
    HomeTab(),
    InvoicesScreen(), // Sale/Bill Book
    ReportsScreen(), // Money/Reports
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<InvoiceBloc>(
          create: (context) => InvoiceBloc(
            invoiceRepository: getIt<InvoiceRepository>(),
          ),
        ),
        BlocProvider<ReportsBloc>(
          create: (context) => ReportsBloc(
            reportsRepository: getIt<ReportsRepository>(),
          ),
        ),
      ],
      child: BlocListener<BusinessBloc, BusinessState>(
        listener: (context, state) {
          // Update locale when business changes
          if (state is BusinessLoaded) {
            final currentBusiness = state.currentBusiness;
            if (currentBusiness != null &&
                currentBusiness.languagePreference != null) {
              final langCode = currentBusiness.languagePreference!;
              // Only update locale if it's different to avoid unnecessary rebuilds
              final currentLocale = context.read<LocaleBloc>().state.locale;
              if (currentLocale.languageCode != langCode) {
                context.read<LocaleBloc>().add(ChangeLocale(Locale(langCode)));
              }
            }
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.3 : 0.08,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: theme.colorScheme.surface,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.onSurfaceVariant,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              iconSize: 22,
              landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
              selectedIconTheme: const IconThemeData(size: 22),
              unselectedIconTheme: const IconThemeData(size: 20),
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                      _currentIndex == 0 ? Icons.home : Icons.home_outlined),
                  label: loc.home,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                      _currentIndex == 1 ? Icons.store : Icons.store_outlined),
                  label: 'Sale', // Match screenshot
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    _currentIndex == 2
                        ? Icons.account_balance_wallet
                        : Icons.account_balance_wallet_outlined,
                  ),
                  label: 'Money', // Match screenshot
                ),
                BottomNavigationBarItem(
                  icon: Icon(_currentIndex == 3
                      ? Icons.grid_view
                      : Icons.grid_view_outlined),
                  label: loc.more,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
