import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rental_mgr_mobile/core/api/api_error.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/auth/onboarding_navigation.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';

/// Web OAuth client ID (ends with `.apps.googleusercontent.com`).
/// Firebase Console → Authentication → Sign-in method → Google → *Web client ID*,
/// or Google Cloud Console → APIs & Credentials → OAuth 2.0 Client IDs → Web client.
///
/// Run Chrome with:
/// `flutter run -d chrome --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com`
/// Or add `<meta name="google-signin-client_id" content="...">` in `web/index.html`.
const String _kWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

GoogleSignIn _googleSignIn() {
  if (kIsWeb && _kWebClientId.isNotEmpty) {
    return GoogleSignIn(scopes: const ['email', 'profile'], clientId: _kWebClientId);
  }
  return GoogleSignIn(scopes: const ['email', 'profile']);
}

/// Google account → Firebase session → RentDirect `POST /auth/firebase` (via [AuthNotifier.loginWithFirebaseIdToken]).
Future<void> signInWithGoogleAndRentDirectApi(
  WidgetRef ref,
  BuildContext context, {
  required bool onboarding,
}) async {
  try {
    final google = _googleSignIn();
    await google.signOut();
    final account = await google.signIn();
    if (account == null) return;

    final ga = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: ga.accessToken,
      idToken: ga.idToken,
    );
    final cred = await FirebaseAuth.instance.signInWithCredential(credential);
    final idToken = await cred.user?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Firebase ID token. Enable Google in Firebase Authentication.')),
        );
      }
      return;
    }

    final user = await ref.read(authProvider.notifier).loginWithFirebaseIdToken(idToken);
    if (!context.mounted) return;
    if (onboarding) {
      context.go(RouteNames.selectRole);
    } else {
      context.go(postLoginDestination(user));
    }
  } catch (e) {
    if (!context.mounted) return;
    final msg = apiErrorMessage(e, 'Google sign-in failed. Use email/password or ensure this Google email is registered.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg.length > 280 ? '${msg.substring(0, 280)}…' : msg)),
    );
  }
}
