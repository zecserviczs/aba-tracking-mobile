import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aba_tracking_mobile/screens/login_screen.dart';
import 'package:aba_tracking_mobile/providers/auth_provider.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display login form', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify that email field is present
      expect(find.byType(TextFormField), findsWidgets);
      
      // Verify that login button is present
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Find email field and enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      await tester.pump();

      // Try to submit
      final loginButton = find.text('Se connecter');
      await tester.tap(loginButton);
      await tester.pump();

      // Form should not submit with invalid email
      // (This depends on your validation logic)
    });

    testWidgets('should show Google sign in button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify Google sign in button is present
      expect(find.text('Se connecter avec Google'), findsOneWidget);
    });
  });
}

