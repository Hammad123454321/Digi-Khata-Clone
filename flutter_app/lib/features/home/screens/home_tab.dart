import 'package:flutter/material.dart';

import 'home_screen.dart';

/// Thin wrapper so Home content can be used as a tab inside the main shell.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
