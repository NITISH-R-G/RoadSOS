import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../logging/app_log.dart';

class AuthService extends StateNotifier<User?> {
  AuthService() : super(Supabase.instance.client.auth.currentUser) {
    _listenToAuthChanges();
  }

  final _client = Supabase.instance.client;

  void _listenToAuthChanges() {
    _client.auth.onAuthStateChange.listen((data) {
      state = data.user;
    });
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _client.auth.signUp(email: email, password: password);
    } catch (e, st) {
      appLog.e('Auth: Sign up failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (e, st) {
      appLog.e('Auth: Sign in failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      // 1. Initialize Google Sign In
      // In production, you'll need to set up the SHA-1 fingerprint in Firebase/Google Console
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );
      
      // 2. Trigger the native picker
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled

      // 3. Obtain auth details from the request
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // 4. Authenticate with Supabase using the ID Token
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
    } catch (e, st) {
      appLog.e('Auth: Native Google sign in failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e, st) {
      appLog.e('Auth: Sign out failed', error: e, stackTrace: st);
    }
  }

  bool get isAuthenticated => state != null && state!.appMetadata['provider'] != 'anonymous';
  bool get isAnonymous => state != null && state!.appMetadata['provider'] == 'anonymous';
}

final authServiceProvider = StateNotifierProvider<AuthService, User?>((ref) {
  return AuthService();
});
