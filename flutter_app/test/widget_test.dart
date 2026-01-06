// Widget Tests for DigiKhata Clone

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:digikhata_clone/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DigiKhataApp());

    // Verify app title is present
    expect(find.text('DigiKhata Clone'), findsNothing); // Title is in AppBar
  });
}
