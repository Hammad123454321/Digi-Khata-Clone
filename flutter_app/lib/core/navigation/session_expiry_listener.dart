import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/injection.dart';
import '../network/api_client.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';

class SessionExpiryListener extends StatefulWidget {
  const SessionExpiryListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<SessionExpiryListener> createState() => _SessionExpiryListenerState();
}

class _SessionExpiryListenerState extends State<SessionExpiryListener> {
  StreamSubscription<void>? _sessionExpirySub;

  @override
  void initState() {
    super.initState();
    _sessionExpirySub = getIt<ApiClient>().sessionExpiredStream.listen((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(const CheckAuthStatusEvent());
    });
  }

  @override
  void dispose() {
    _sessionExpirySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
