import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../security/app_lock_service.dart';
import '../../features/auth/screens/app_lock_screen.dart';
import '../../features/home/screens/main_shell.dart';

class AppLockWrapper extends StatefulWidget {
  const AppLockWrapper({super.key});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  final AppLockService _lockService = getIt<AppLockService>();

  bool _checking = true;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final enabled = await _lockService.isLockEnabled();
    if (mounted) {
      setState(() {
        _locked = enabled;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_locked) {
      return AppLockScreen(
        onUnlocked: () => setState(() => _locked = false),
      );
    }

    return const MainShell();
  }
}
