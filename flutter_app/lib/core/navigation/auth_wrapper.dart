import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/business/screens/business_bootstrap_screen.dart';
import '../../features/onboarding/screens/language_selection_screen.dart';
import '../di/injection.dart';
import '../storage/local_storage_service.dart';
import '../localization/app_localizations.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  AuthState? _lastStableState;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final storage = getIt<LocalStorageService>();
    if (storage.isFirstLaunch()) {
      return const LanguageSelectionScreen();
    }
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        // Keep last non-loading state to avoid blank/loading screens.
        if (state is! AuthLoading) {
          _lastStableState = state;
        }

        final effectiveState = state is AuthLoading && _lastStableState != null
            ? _lastStableState!
            : state;

        return _buildForState(context, effectiveState, loc);
      },
    );
  }

  Widget _buildForState(
    BuildContext context,
    AuthState state,
    AppLocalizations loc,
  ) {
    return switch (state) {
      AuthInitial() ||
      AuthLoading() =>
        const Scaffold(body: Center(child: CircularProgressIndicator())),
      AuthUnauthenticated() => _unauthenticated(),
      AuthAuthenticated() => const BusinessBootstrapScreen(),
      OtpRequested(:final phone) => OtpVerificationScreen(phone: phone),
      // Pin flows are triggered only while authenticated; keep user in app.
      PinSet() || PinVerified() => const BusinessBootstrapScreen(),
      AuthError(:final message) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context
                      .read<AuthBloc>()
                      .add(const CheckAuthStatusEvent()),
                  child: Text(loc.retry),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      context.read<AuthBloc>().add(const LogoutEvent()),
                  child: Text(loc.login),
                ),
              ],
            ),
          ),
        ),
      _ => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(loc.somethingWentWrong),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context
                      .read<AuthBloc>()
                      .add(const CheckAuthStatusEvent()),
                  child: Text(loc.retry),
                ),
              ],
            ),
          ),
        ),
    };
  }

  Widget _unauthenticated() {
    return const LoginScreen();
  }
}
