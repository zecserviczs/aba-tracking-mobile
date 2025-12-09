import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import 'theme_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Logger _logger = Logger();
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final userType = prefs.getString('userType');
      
      if (token != null && userType != null) {
        // Pour les enfants, on ne charge pas les données utilisateur de la même façon
        if (userType == 'child') {
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
          );
        } else {
          final user = await ApiService.getCurrentUser(userType: userType);
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      _logger.e('Auth check error: $e');
      state = state.copyWith(
        error: e.toString(),
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await ApiService.login(
        email: email,
        password: password,
        userType: userType,
      );
      
      // Stocker le type d'utilisateur
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', userType);
      
      // Pour les enfants, on ne charge pas les données utilisateur de la même façon
      if (userType == 'child') {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        final user = await ApiService.getCurrentUser(userType: userType);
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      }
      
      // Mettre à jour le thème selon le type d'utilisateur
      _ref.read(themeProvider.notifier).updateThemeForUserType(userType);
      
      return true;
    } catch (e) {
      _logger.e('Login error: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> loginWithGoogle({
    required String idToken,
    required String userType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await ApiService.loginWithGoogle(
        idToken: idToken,
        userType: userType,
      );
      
      // Stocker le type d'utilisateur
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', userType);
      
      // Pour les enfants, on ne charge pas les données utilisateur de la même façon
      if (userType == 'child') {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        final user = await ApiService.getCurrentUser(userType: userType);
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      }
      
      // Mettre à jour le thème selon le type d'utilisateur
      _ref.read(themeProvider.notifier).updateThemeForUserType(userType);
      
      return true;
    } catch (e) {
      _logger.e('Google login error: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    state = AuthState();
    
    // Remettre le thème par défaut
    _ref.read(themeProvider.notifier).updateThemeForUserType(null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

