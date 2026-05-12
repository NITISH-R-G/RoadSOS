import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../database/app_database.dart' show isSupabaseSdkInitialized;
import '../logging/app_log.dart';

class AuthService extends StateNotifier<User?> {
  AuthService()
      : super(
          isSupabaseSdkInitialized
              ? Supabase.instance.client.auth.currentUser
              : null,
        ) {
    if (isSupabaseSdkInitialized) _listenToAuthChanges();
  }

  SupabaseClient? get _client =>
      isSupabaseSdkInitialized ? Supabase.instance.client : null;

  void _listenToAuthChanges() {
    _client?.auth.onAuthStateChange.listen((data) {
      state = data.session?.user;
    });
  }

  Future<void> signUp(String email, String password) async {
    final client = _client;
    if (client == null) throw 'Supabase is not initialized. Check your .env credentials.';
    try {
      await client.auth.signUp(email: email, password: password);
    } catch (e, st) {
      appLog.e('Auth: Sign up failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    final client = _client;
    if (client == null) throw 'Supabase is not initialized. Check your .env credentials.';
    try {
      await client.auth.signInWithPassword(email: email, password: password);
    } catch (e, st) {
      appLog.e('Auth: Sign in failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    final client = _client;
    if (client == null) throw 'Supabase is not initialized. Check your .env credentials.';
    try {
      if (kIsWeb) {
        // Web: Supabase OAuth redirect — browser navigates to Google's consent screen
        // and redirects back to the app. No native SDK needed.
        //
        // ⚠️  ONE-TIME SETUP REQUIRED in Supabase Dashboard:
        //   Authentication → URL Configuration → Redirect URLs
        //   Add: http://localhost:8081
        await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'http://localhost:8081',
        );
        // Browser handles the rest — this line is never reached on web.
        return;
      }

      // Native Android / iOS: token exchange via google_sign_in package.
      // Requires GOOGLE_WEB_CLIENT_ID in assets/.env.
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found. Ensure google-services.json is configured correctly.';
      }

      await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e, st) {
      appLog.e('Auth: Google sign in failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client?.auth.signOut();
    } catch (e, st) {
      appLog.e('Auth: Sign out failed', error: e, stackTrace: st);
    }
  }

  bool get isAuthenticated =>
      state != null && state!.appMetadata['provider'] != 'anonymous';
  bool get isAnonymous =>
      state != null && state!.appMetadata['provider'] == 'anonymous';
}

final authServiceProvider = StateNotifierProvider<AuthService, User?>((ref) {
  return AuthService();
});
