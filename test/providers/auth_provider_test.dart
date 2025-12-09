import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aba_tracking_mobile/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthProvider', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should not be authenticated', () {
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, isNull);
    });

    test('should clear error', () {
      final notifier = container.read(authProvider.notifier);
      notifier.clearError();
      
      final state = container.read(authProvider);
      expect(state.error, isNull);
    });
  });
}

