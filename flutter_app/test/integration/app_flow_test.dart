import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digikhata_clone/main.dart' as app;
import 'package:digikhata_clone/core/di/injection.dart';
import 'package:digikhata_clone/features/auth/bloc/auth_bloc.dart';
import 'package:digikhata_clone/features/auth/bloc/auth_state.dart';
import 'package:digikhata_clone/features/home/screens/home_screen.dart';
import 'package:digikhata_clone/features/invoices/screens/invoices_screen.dart';
import 'package:digikhata_clone/features/cash/screens/cash_screen.dart';
import 'package:digikhata_clone/features/customers/screens/customers_screen.dart';
import 'package:digikhata_clone/shared/models/auth_response_model.dart';
import 'package:digikhata_clone/shared/models/user_model.dart';

/// Integration tests for complete user flows
void main() {
  group('App Flow Integration Tests', () {
    testWidgets('App initializes and shows login screen when not authenticated', (tester) async {
      // Setup
      await tester.pumpWidget(const app.DigiKhataApp());
      await tester.pumpAndSettle();

      // Verify login screen is shown
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
    });

    testWidgets('Home screen displays dashboard correctly', (tester) async {
      // Setup with authenticated state
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: getIt(),
            )..emit(
                AuthAuthenticated(
                  authResponse: AuthResponseModel(
                    accessToken: 'test_token',
                    refreshToken: 'test_refresh',
                    tokenType: 'bearer',
                    user: const UserModel(
                      id: 1,
                      phone: '1234567890',
                      name: 'Test User',
                    ),
                  ),
                ),
              ),
            child: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dashboard elements
      expect(find.text('DigiKhata'), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Today\'s Summary'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('Navigation to invoices screen works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const InvoicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify invoices screen
      expect(find.text('Invoices'), findsOneWidget);
      expect(find.text('Create Invoice'), findsOneWidget);
    });

    testWidgets('Navigation to cash screen works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CashScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify cash screen
      expect(find.text('Cash Management'), findsOneWidget);
      expect(find.text('Add Transaction'), findsOneWidget);
    });

    testWidgets('Navigation to customers screen works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CustomersScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify customers screen
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Add Customer'), findsOneWidget);
    });

    testWidgets('Quick actions navigation from home screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: getIt(),
            )..emit(
                AuthAuthenticated(
                  authResponse: AuthResponseModel(
                    accessToken: 'test_token',
                    refreshToken: 'test_refresh',
                    tokenType: 'bearer',
                    user: const UserModel(
                      id: 1,
                      phone: '1234567890',
                      name: 'Test User',
                    ),
                  ),
                ),
              ),
            child: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify quick action buttons exist
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Stock'), findsOneWidget);
      expect(find.text('Invoices'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);
    });
  });

  group('Performance Tests', () {
    testWidgets('Home screen loads within acceptable time', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: getIt(),
            )..emit(
                AuthAuthenticated(
                  authResponse: AuthResponseModel(
                    accessToken: 'test_token',
                    refreshToken: 'test_refresh',
                    tokenType: 'bearer',
                    user: const UserModel(
                      id: 1,
                      phone: '1234567890',
                      name: 'Test User',
                    ),
                  ),
                ),
              ),
            child: const HomeScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      // Assert load time is acceptable (< 2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('Invoices screen loads within acceptable time', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        const MaterialApp(
          home: InvoicesScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      // Assert load time is acceptable (< 2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });

  group('Widget Interaction Tests', () {
    testWidgets('Refresh button triggers data reload', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InvoicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);
      
      await tester.tap(refreshButton);
      await tester.pump();
      
      // Verify loading state (if applicable)
      // This would depend on your BLoC implementation
    });

    testWidgets('Filter button opens filter dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InvoicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap filter button
      final filterButton = find.byIcon(Icons.filter_list);
      expect(filterButton, findsOneWidget);
      
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
      
      // Verify filter dialog appears
      expect(find.text('Filter Invoices'), findsOneWidget);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('Error widget displays on network failure', (tester) async {
      // This would require mocking the repository to return an error
      // For now, this is a placeholder structure
      
      await tester.pumpWidget(
        const MaterialApp(
          home: InvoicesScreen(),
        ),
      );
      
      // Test would verify error widget appears on failure
      // Implementation depends on your error handling strategy
    });
  });

  group('Accessibility Tests', () {
    testWidgets('All interactive elements have semantic labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InvoicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify semantic labels exist for screen readers
      final semantics = tester.getSemantics(find.byType(InvoicesScreen));
      // This would check for proper semantic labels
    });
  });
}
