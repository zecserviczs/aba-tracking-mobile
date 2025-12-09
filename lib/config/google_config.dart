/// Configuration Google Sign-In
/// 
/// Pour configurer Google Sign-In :
/// 1. Créez un projet dans Google Cloud Console
/// 2. Créez un OAuth 2.0 Client ID pour Android et iOS
/// 3. Ajoutez les Client IDs ci-dessous
/// 4. Suivez les instructions dans GOOGLE_SIGNIN_SETUP.md
class GoogleConfig {
  // Client ID par défaut (utilisé si androidClientId ou iosClientId ne sont pas définis)
  // Format: xxxxxx-xxxxxxxxxxxxxxxx.apps.googleusercontent.com
  static const String? clientId = null; // À configurer
  
  // Client ID spécifique pour Android (recommandé)
  // Obtenez-le depuis Google Cloud Console > Credentials > OAuth 2.0 Client ID (Android)
  // Vous devez aussi ajouter le SHA-1 fingerprint de votre application
  // Voir GOOGLE_SIGNIN_SETUP.md pour les instructions complètes
  static const String? androidClientId = null; // À configurer
  
  // Client ID spécifique pour iOS (recommandé)
  // Obtenez-le depuis Google Cloud Console > Credentials > OAuth 2.0 Client ID (iOS)
  // Vous devez aussi configurer le Bundle ID dans Info.plist
  // Voir GOOGLE_SIGNIN_SETUP.md pour les instructions complètes
  static const String? iosClientId = null; // À configurer
  
  /// Retourne le Client ID inversé pour iOS (nécessaire pour CFBundleURLSchemes)
  /// Exemple: Si Client ID = "123456-abc.apps.googleusercontent.com"
  ///          Alors inversé = "com.googleusercontent.apps.123456-abc"
  static String? getReversedClientId(String? clientId) {
    if (clientId == null || clientId.isEmpty) return null;
    
    // Enlever .apps.googleusercontent.com
    String withoutSuffix = clientId.replaceAll('.apps.googleusercontent.com', '');
    
    // Inverser: abc-123456 -> com.googleusercontent.apps.abc-123456
    return 'com.googleusercontent.apps.$withoutSuffix';
  }
}
