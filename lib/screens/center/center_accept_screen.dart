import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';

class CenterAcceptScreen extends ConsumerStatefulWidget {
  final String? token;

  const CenterAcceptScreen({super.key, this.token});

  @override
  ConsumerState<CenterAcceptScreen> createState() => _CenterAcceptScreenState();
}

class _CenterAcceptScreenState extends ConsumerState<CenterAcceptScreen> {
  bool _isLoading = true;
  String? _error;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _acceptInvitation();
  }

  Future<void> _acceptInvitation() async {
    final token = widget.token;
    
    if (token == null || token.isEmpty) {
      setState(() {
        _error = 'Lien invalide';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.httpPost(
        '/public/center/accept?token=$token',
        {},
      );

      // Sauvegarder les tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', response['token'] ?? '');
      await prefs.setString('refreshToken', response['refreshToken'] ?? '');
      await prefs.setString('userType', 'center');

      setState(() {
        _success = true;
        _isLoading = false;
      });

      // Rediriger après un court délai
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.go('/center/dashboard');
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Lien expiré ou invalide: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Activation en cours…',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              )
            : _error != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade700),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Retour à la connexion'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 64, color: Colors.green.shade700),
                        const SizedBox(height: 16),
                        Text(
                          'Activation réussie !',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Redirection en cours...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

