import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

import 'core/di/injection.dart';
import 'core/routes/app_router.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_bloc.dart';
import 'core/theme/theme_bloc.dart';
import 'core/storage/local_storage_service.dart';
import 'core/analytics/analytics_service.dart';
import 'core/sync/background_sync_service.dart';
import 'core/navigation/auth_state_coordinator.dart';
import 'core/navigation/session_expiry_listener.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/business_repository.dart';

import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/business/bloc/business_bloc.dart';

import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await setupDependencyInjection();

  getIt<BackgroundSyncService>().startBackgroundSync();
  getIt<AnalyticsService>().trackEvent('app_launched');

  runApp(const EnshaalKhataApp());
}

class EnshaalKhataApp extends StatelessWidget {
  const EnshaalKhataApp({super.key});
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LocaleBloc(
            localStorageService: getIt<LocalStorageService>(),
          )..add(const LoadSavedLocale()),
        ),
        BlocProvider(
          create: (_) => ThemeBloc(
            localStorageService: getIt<LocalStorageService>(),
          )..add(const LoadSavedTheme()),
        ),
        BlocProvider(
          create: (_) => AuthBloc(
            authRepository: getIt<AuthRepository>(),
          )..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (_) => BusinessBloc(
            businessRepository: getIt<BusinessRepository>(),
          ),
        ),
      ],
      child: SessionExpiryListener(
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LocaleBloc, LocaleState>(
              builder: (context, localeState) {
                final locale = localeState.locale;
                final isRtl =
                    locale.languageCode == 'ur' || locale.languageCode == 'ar';

                return Directionality(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: AuthStateCoordinator(
                    navigatorKey: _navigatorKey,
                    child: MaterialApp(
                      navigatorKey: _navigatorKey,
                      debugShowCheckedModeBanner: false,
                      title: 'Enshaal Khata',
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeState.themeMode,
                      locale: locale,
                      supportedLocales: AppLocalizations.supportedLocales,
                      localizationsDelegates: const [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      onGenerateRoute: AppRouter.generateRoute,
                      initialRoute: AppRouter.root,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
