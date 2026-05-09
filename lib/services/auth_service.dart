import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      // In a real mobile app, you'd use a deep link for the callback.
      // Supabase handles the heavy lifting.
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.roadsos.auth://callback', // Match this in your Supabase dashboard
      );
    } catch (e, st) {
      appLog.e('Auth: Google sign in failed', error: e, stackTrace: st);
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
