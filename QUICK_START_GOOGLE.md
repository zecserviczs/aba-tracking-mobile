# Configuration rapide Google Sign-In

## ⚠️ Problème actuel
La connexion Google ne fonctionne pas car les Client IDs ne sont pas configurés.

## ✅ Solution rapide (3 étapes)

### 1. Créer les Client IDs dans Google Cloud Console

1. Allez sur https://console.cloud.google.com/
2. Créez un projet ou sélectionnez-en un
3. Activez "Google Sign-In API"
4. Allez dans **APIs & Services** > **Credentials**

#### Pour Android :
- Cliquez **Create Credentials** > **OAuth 2.0 Client ID**
- Type: **Android**
- Package name: Trouvez-le dans `android/app/build.gradle` (cherchez `applicationId`)
- SHA-1: Exécutez `cd android && ./gradlew signingReport` (ou `.\gradlew signingReport` sur Windows)
- Copiez le **Client ID** généré

#### Pour iOS :
- Cliquez **Create Credentials** > **OAuth 2.0 Client ID**  
- Type: **iOS**
- Bundle ID: Trouvez-le dans Xcode ou `ios/Runner/Info.plist`
- Copiez le **Client ID** généré

### 2. Configurer dans le code

Ouvrez `lib/config/google_config.dart` et ajoutez :

```dart
static const String? androidClientId = 'VOTRE_CLIENT_ID_ANDROID.apps.googleusercontent.com';
static const String? iosClientId = 'VOTRE_CLIENT_ID_IOS.apps.googleusercontent.com';
```

### 3. Configurer iOS Info.plist (iOS uniquement)

1. Ouvrez `ios/Runner/Info.plist`
2. Trouvez la section `<key>CFBundleURLTypes</key>`
3. Remplacez `YOUR_REVERSED_CLIENT_ID` par votre Client ID inversé

Pour inverser le Client ID :
- Si Client ID = `123456-abc.apps.googleusercontent.com`
- Alors inversé = `com.googleusercontent.apps.123456-abc`

Ou utilisez la fonction helper dans `google_config.dart` :
```dart
GoogleConfig.getReversedClientId('VOTRE_CLIENT_ID_IOS')
```

### 4. Tester

```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Documentation complète

Pour plus de détails, consultez `GOOGLE_SIGNIN_SETUP.md`

