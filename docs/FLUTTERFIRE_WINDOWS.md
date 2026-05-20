# FlutterFire on Windows (PowerShell)

## 1. `flutterfire` is not recognized

`dart pub global activate flutterfire_cli` installs the executable here:

`C:\Users\THINKPAD\AppData\Local\Pub\Cache\bin`

**Option A — add to PATH (recommended)**  
1. Windows → *Environment variables* → *Path* → *Edit* → *New*  
2. Add: `C:\Users\THINKPAD\AppData\Local\Pub\Cache\bin`  
3. Close and reopen PowerShell (and Cursor).

**Option B — run without PATH** (always works):

```powershell
cd D:\MRM-Rental-Manager-Mobile-
dart pub global run flutterfire_cli:flutterfire configure
```

Use the same `dart pub global run flutterfire_cli:flutterfire ...` prefix for any `flutterfire` subcommand.

## 2. Do not paste Dart into PowerShell

Lines like:

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
runApp(...);
```

belong in **`lib/main.dart`** (after `flutterfire configure` generates `lib/firebase_options.dart` and you add `firebase_core` to `pubspec.yaml`). PowerShell will error on them — that is expected.

## 3. Typical order after PATH (or Option B)

```powershell
cd D:\MRM-Rental-Manager-Mobile-
dart pub global run flutterfire_cli:flutterfire configure
```

- Log in to Google when prompted.  
- Pick your Firebase project and platforms (include **Web** if you use `flutter run -d chrome`).

Then:

```powershell
flutter pub add firebase_core firebase_auth google_sign_in
```

Merge `main.dart` changes from FlutterFire’s output (initialize Firebase before `runApp`).

## 4. Google Sign-In on **Chrome (web)**

The `google_sign_in` plugin needs your **OAuth Web client ID** (not the same string as `apiKey` in `firebase_options.dart`).

1. [Firebase Console](https://console.firebase.google.com/) → your project → **Authentication** → **Sign-in method** → **Google** → copy **Web client ID** (or use Google Cloud Console → **APIs & Credentials** → OAuth 2.0 Client IDs → **Web client**).

2. Either:

   - Uncomment and fill in `web/index.html`:

     ```html
     <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
     ```

   - Or run with a define:

     ```powershell
     flutter run -d chrome --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
     ```

3. In Firebase, enable **Google** as a sign-in provider and add **localhost** (and your dev port if needed) under **Authentication → Settings → Authorized domains**.

## 5. `flutter run -d chrome` again

```powershell
flutter run -d chrome
```

If Chrome debug connection fails, use:

```powershell
flutter run -d web-server --web-hostname localhost --web-port 8080
```

and open the printed URL in Chrome.

## 5. Lifecycle / `flutter/lifecycle` messages on web

Those “message was discarded” lines often appear when a plugin sends lifecycle events before the engine is ready. They are usually **safe to ignore** unless something actually breaks in the UI.
