# Configuration Google Sign-In pour l'application mobile Flutter

## 1. Créer un projet OAuth 2.0 dans Google Cloud Console

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Activez l'API "Google Sign-In API" ou "Identity Toolkit API"
4. Allez dans **APIs & Services** > **Credentials**

## 2. Configuration Android

### Étape 1 : Obtenir le SHA-1 fingerprint

```bash
# Pour Windows (PowerShell)
cd android
.\gradlew signingReport

# Pour Mac/Linux
cd android
./gradlew signingReport
```

Cherchez dans la sortie la ligne avec `SHA1:` sous `Variant: debug` et `Variant: release`.

Exemple: `SHA1: A1:B2:C3:D4:E5:F6:...`

### Étape 2 : Créer un OAuth 2.0 Client ID pour Android

1. Dans Google Cloud Console, cliquez sur **Create Credentials** > **OAuth 2.0 Client ID**
2. Sélectionnez **Application type**: **Android**
3. Entrez:
   - **Name**: ABA Tracking Android
   - **Package name**: `com.zecservices.aba_tracking_mobile` (vérifiez dans `android/app/build.gradle`)
   - **SHA-1 certificate fingerprint**: Collez le SHA-1 obtenu à l'étape 1
4. Cliquez sur **Create**
5. **Copiez le Client ID** (format: `xxxxxx-xxxxxxxxxxxxxxxx.apps.googleusercontent.com`)

### Étape 3 : Configurer dans l'application

Ouvrez `lib/config/google_config.dart` et mettez à jour :

```dart
static const String? androidClientId = 'VOTRE_CLIENT_ID_ANDROID.apps.googleusercontent.com';
```

## 3. Configuration iOS

### Étape 1 : Obtenir le Bundle ID

Le Bundle ID se trouve dans `ios/Runner.xcodeproj/project.pbxproj` ou dans Xcode.

Exemple: `com.zecservices.abaTrackingMobile`

### Étape 2 : Créer un OAuth 2.0 Client ID pour iOS

1. Dans Google Cloud Console, cliquez sur **Create Credentials** > **OAuth 2.0 Client ID**
2. Sélectionnez **Application type**: **iOS**
3. Entrez:
   - **Name**: ABA Tracking iOS
   - **Bundle ID**: Votre Bundle ID iOS
4. Cliquez sur **Create**
5. **Copiez le Client ID**

### Étape 3 : Configurer dans l'application

Ouvrez `lib/config/google_config.dart` et mettez à jour :

```dart
static const String? iosClientId = 'VOTRE_CLIENT_ID_IOS.apps.googleusercontent.com';
```

### Étape 4 : Configurer Info.plist

Ouvrez `ios/Runner/Info.plist` et ajoutez avant `</dict>` :

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.VOTRE_CLIENT_ID_INVERSE</string>
        </array>
    </dict>
</array>
```

**Important**: Pour le `CFBundleURLSchemes`, utilisez le Client ID **inversé** (sans le `.apps.googleusercontent.com`).

Exemple: Si votre Client ID est `123456789-abcdefg.apps.googleusercontent.com`, 
le scheme sera: `com.googleusercontent.apps.123456789-abcdefg`

## 4. Configuration du backend

Assurez-vous que le backend accepte les tokens Google. Le client ID doit être configuré dans `application.properties` :

```properties
google.client-id=VOTRE_CLIENT_ID_WEB.apps.googleusercontent.com
```

**Note**: Vous pouvez utiliser le même Client ID Web pour le backend, ou créer un Client ID séparé de type "Web application".

## 5. Test

1. Redémarrez l'application Flutter
2. Cliquez sur "Se connecter avec Google"
3. Sélectionnez votre compte Google
4. Vérifiez que la connexion fonctionne

## Dépannage

### Erreur: "DEVELOPER_ERROR" (Android)
- Vérifiez que le SHA-1 est correct
- Vérifiez que le package name correspond
- Attendez quelques minutes après avoir ajouté le SHA-1 (propagation Google)

### Erreur: "SIGN_IN_REQUIRED" (iOS)
- Vérifiez que le Bundle ID correspond
- Vérifiez que le CFBundleURLSchemes est correctement configuré
- Redémarrez l'application

### Le bouton Google ne fait rien
- Vérifiez que le client ID est configuré dans `google_config.dart`
- Vérifiez les logs pour voir l'erreur exacte
- Vérifiez que `google_sign_in` est bien installé: `flutter pub get`

## Notes importantes

- Pour la production, utilisez des Client IDs différents pour debug et release
- Gardez vos Client IDs secrets
- Ne commitez pas les Client IDs dans le code source public (utilisez des variables d'environnement)

