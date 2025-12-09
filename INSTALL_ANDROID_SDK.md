# Installation et Configuration Android SDK

## Problème : SDK Android non trouvé

Gradle ne trouve pas le SDK Android. Voici comment le résoudre.

## Solution 1 : Installer Android Studio (Recommandé)

1. **Télécharger Android Studio**
   - Allez sur https://developer.android.com/studio
   - Téléchargez et installez Android Studio

2. **Premier lancement d'Android Studio**
   - Android Studio va installer automatiquement le SDK Android
   - Le SDK sera installé dans : `C:\Users\VotreNom\AppData\Local\Android\Sdk`

3. **Configurer Flutter**
   ```powershell
   flutter doctor --android-licenses
   ```
   Acceptez toutes les licences.

4. **Configurer local.properties**
   - Ouvrez `android/local.properties`
   - Ajoutez la ligne :
   ```properties
   sdk.dir=C:\\Users\\VotreNom\\AppData\\Local\\Android\\Sdk
   ```
   Remplacez `VotreNom` par votre nom d'utilisateur Windows.

## Solution 2 : SDK déjà installé mais non détecté

Si vous avez déjà Android Studio ou le SDK installé :

### Trouver le chemin du SDK

**Méthode 1 : Via Android Studio**
1. Ouvrez Android Studio
2. **File** > **Settings** (ou `Ctrl + Alt + S`)
3. **Appearance & Behavior** > **System Settings** > **Android SDK**
4. Copiez le chemin dans **"Android SDK Location"**

**Méthode 2 : Recherche manuelle**
1. Ouvrez l'Explorateur de fichiers
2. Appuyez sur `Windows + R`
3. Tapez : `%LOCALAPPDATA%\Android\Sdk`
4. Si le dossier s'ouvre, c'est votre SDK. Copiez le chemin complet.

**Méthode 3 : Via PowerShell**
```powershell
# Vérifier les emplacements courants
$locations = @(
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:USERPROFILE\AppData\Local\Android\Sdk",
    "C:\Android\Sdk",
    "D:\Android\Sdk"
)

foreach ($loc in $locations) {
    if (Test-Path $loc) {
        Write-Host "SDK trouvé: $loc" -ForegroundColor Green
    }
}
```

### Configurer local.properties

Une fois que vous avez le chemin :

1. Ouvrez `android/local.properties`
2. Ajoutez/modifiez la ligne :
```properties
flutter.sdk=C:\tools\flutter
sdk.dir=C:\CHEMIN\VERS\VOTRE\SDK
```

**Exemple :**
```properties
flutter.sdk=C:\tools\flutter
sdk.dir=C:\Users\eddyz\AppData\Local\Android\Sdk
```

## Solution 3 : Installer uniquement le SDK (Sans Android Studio)

1. **Télécharger le SDK Command Line Tools**
   - https://developer.android.com/studio#command-tools
   - Téléchargez "Command line tools only"

2. **Extraire dans un dossier**
   - Créez un dossier : `C:\Android\Sdk`
   - Extrayez les outils dans : `C:\Android\Sdk\cmdline-tools`

3. **Installer les composants**
   ```powershell
   cd C:\Android\Sdk\cmdline-tools\bin
   .\sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
   ```

4. **Configurer local.properties**
   ```properties
   sdk.dir=C:\\Android\\Sdk
   ```

## Vérification

Après configuration, vérifiez :

```powershell
cd android
.\gradlew signingReport
```

Si ça fonctionne, vous verrez le SHA-1 dans la sortie.

## Obtenir le SHA-1

Une fois que `gradlew signingReport` fonctionne, cherchez dans la sortie :

```
Variant: debug
Config: debug
Store: C:\Users\...\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: A1:B2:C3:D4:E5:F6:...
```

**Copiez le SHA1** (vous en aurez besoin pour configurer Google Sign-In dans Google Cloud Console).

## Notes importantes

- Le fichier `local.properties` ne doit **PAS** être commité dans Git (il est déjà dans `.gitignore`)
- Si vous changez d'ordinateur, vous devrez reconfigurer `local.properties`
- Le SDK Android nécessite au moins 3-4 GB d'espace disque

## Alternative : Utiliser Flutter directement

Si vous avez juste besoin du SHA-1 et que Flutter fonctionne, vous pouvez aussi utiliser :

```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Cela affichera directement le SHA-1 sans avoir besoin de configurer Gradle.

