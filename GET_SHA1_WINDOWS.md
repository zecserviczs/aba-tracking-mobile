# Obtenir le SHA-1 Fingerprint sur Windows

## ⚠️ Si vous obtenez l'erreur "SDK location not found"

Consultez d'abord `INSTALL_ANDROID_SDK.md` pour installer/configurer le SDK Android.

---

# Obtenir le SHA-1 Fingerprint sur Windows

## Problème : SDK Android non trouvé

Si vous obtenez l'erreur "SDK location not found", suivez ces étapes :

## Solution 1 : Trouver le chemin du SDK Android

### Méthode 1 : Via Android Studio
1. Ouvrez Android Studio
2. Allez dans **File** > **Settings** (ou **Android Studio** > **Preferences** sur Mac)
3. **Appearance & Behavior** > **System Settings** > **Android SDK**
4. Copiez le chemin indiqué dans **"Android SDK Location"**
5. Exemple : `C:\Users\VotreNom\AppData\Local\Android\Sdk`

### Méthode 2 : Recherche Windows
1. Appuyez sur **Windows + R**
2. Tapez : `%LOCALAPPDATA%\Android\Sdk`
3. Si le dossier existe, copiez le chemin complet

### Méthode 3 : Via PowerShell
```powershell
# Vérifier si le SDK existe dans l'emplacement par défaut
Test-Path "$env:LOCALAPPDATA\Android\Sdk"

# Si True, le chemin est :
$env:LOCALAPPDATA\Android\Sdk
```

## Solution 2 : Configurer local.properties

1. Ouvrez le fichier `android/local.properties`
2. Ajoutez ou modifiez la ligne `sdk.dir` avec le chemin de votre SDK :

```properties
flutter.sdk=C:\tools\flutter
sdk.dir=C:\Users\VotreNom\AppData\Local\Android\Sdk
```

**Important** : Remplacez `VotreNom` par votre nom d'utilisateur Windows, ou utilisez le chemin exact que vous avez trouvé.

## Solution 3 : Variable d'environnement (Alternative)

Si vous préférez utiliser une variable d'environnement :

1. Ouvrez **Paramètres système** > **Variables d'environnement**
2. Créez une nouvelle variable système :
   - Nom : `ANDROID_HOME`
   - Valeur : `C:\Users\VotreNom\AppData\Local\Android\Sdk`
3. Redémarrez le terminal/PowerShell

## Après configuration : Obtenir le SHA-1

Une fois le SDK configuré, exécutez :

```powershell
cd android
.\gradlew signingReport
```

Cherchez dans la sortie la section :
```
Variant: debug
Config: debug
Store: C:\Users\...\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: A1:B2:C3:D4:E5:...
```

Copiez la valeur du **SHA1** (sans les deux-points si nécessaire, selon ce que demande Google Cloud Console).

## Vérification

Vérifiez que le fichier `local.properties` contient bien :

```properties
flutter.sdk=C:\tools\flutter
sdk.dir=C:\Users\VotreNom\AppData\Local\Android\Sdk
```

Remplacez `VotreNom` par votre nom d'utilisateur Windows réel.

---

## 🚀 Alternative Rapide : Obtenir le SHA-1 sans configurer Gradle

**Si vous avez juste besoin du SHA-1 rapidement**, vous pouvez utiliser `keytool` directement (inclus avec Java/JDK) :

### Méthode 1 : PowerShell
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Cherchez la ligne avec `SHA1:` dans la sortie.

### Méthode 2 : CMD
```cmd
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Avantages
- ✅ Fonctionne même sans configurer le SDK dans `local.properties`
- ✅ Plus rapide si vous avez juste besoin du SHA-1
- ✅ Le keystore de debug est automatiquement créé par Flutter/Android

### Note importante
Le keystore de debug est créé automatiquement lors de la première compilation Flutter Android. Si vous n'avez jamais compilé l'app Android, il se peut que le fichier n'existe pas encore.

Pour le créer, lancez une compilation :
```powershell
flutter build apk --debug
```
