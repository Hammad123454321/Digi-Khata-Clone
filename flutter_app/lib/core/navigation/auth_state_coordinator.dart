import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../routes/app_router.dart';

class AuthStateCoordinator extends StatefulWidget {
  const AuthStateCoordinator({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<AuthStateCoordinator> createState() => _AuthStateCoordinatorState();
}

class _AuthStateCoordinatorState extends State<AuthStateCoordinator> {
  bool _navigationInProgress = false;

  void _navigateToRootAuth() {
    if (_navigationInProgress) return;
    final navigator = widget.navigatorKey.currentState;
    if (navigator == null || !mounted) return;

    _navigationInProgress = true;
    navigator.pushNamedAndRemoveUntil(
      AppRouter.root,
      (route) => false,
    );
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      _navigationInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthUnauthenticated && previous is! AuthUnauthenticated,
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          _navigateToRootAuth();
        }
      },
      child: widget.child,
    );
  }
}
