import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_theme.dart';

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(AppTheme.lightTheme) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    
    if (userType == 'professional') {
      state = AppTheme.professionalTheme;
    } else {
      state = AppTheme.lightTheme;
    }
  }

  Future<void> updateThemeForUserType(String? userType) async {
    if (userType == 'professional') {
      state = AppTheme.professionalTheme;
    } else {
      state = AppTheme.lightTheme;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});


