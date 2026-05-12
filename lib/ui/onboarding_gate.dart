import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart' show isSupabaseSdkInitialized;
import '../services/gemma_model_manager.dart';
import 'gemma_model_download_screen.dart';
import 'permission_onboarding_screen.dart';
import 'auth/auth_screen.dart';

const _kPermsDone = 'permissions_onboarding_v1_done';
const _kModelPromptDone = 'model_download_prompt_v1_done';

/// Two-phase onboarding gate:
///
/// Phase 1 — Permissions (location, bluetooth, camera, microphone, SMS, notifications)
/// Phase 2 — Gemma 4 E4B model download (~2.4 GB, skippable)
///   • Skipped automatically if the model is already downloaded
///   • Skipped if the user chooses "Skip — use cloud AI only"
///
/// After both phases (or skip), shows the main app.
class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  _GatePhase _phase = _GatePhase.loading;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final permsDone = prefs.getBool(_kPermsDone) ?? false;
    final modelPromptDone = prefs.getBool(_kModelPromptDone) ?? false;
    // On Web the model is never downloadable — skip that prompt.
    final modelReady = kIsWeb ? true : await GemmaModelManager.isModelReady();

    // Safely check Supabase auth — only if the SDK was actually initialized.
    bool isAuth = false;
    if (isSupabaseSdkInitialized) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        isAuth = user != null && user.appMetadata['provider'] != 'anonymous';
      } catch (_) {
        isAuth = false;
      }
    }

    if (!mounted) return;

    if (!isAuth && !permsDone && !kIsWeb) {
      // On mobile: permissions first, then auth.
      setState(() => _phase = _GatePhase.permissions);
    } else if (!isAuth) {
      // On Web: skip straight to auth (no native permission pages).
      setState(() => _phase = _GatePhase.auth);
    } else if (!modelPromptDone && !modelReady) {
      setState(() => _phase = _GatePhase.modelDownload);
    } else {
      setState(() => _phase = _GatePhase.app);
    }
  }

  Future<void> _onPermsDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPermsDone, true);
    if (!mounted) return;

    bool isAuth = false;
    if (isSupabaseSdkInitialized) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        isAuth = user != null && user.appMetadata['provider'] != 'anonymous';
      } catch (_) {}
    }

    if (!isAuth) {
      setState(() => _phase = _GatePhase.auth);
    } else {
      _checkModelPhase(prefs);
    }
  }

  Future<void> _onAuthDone() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _checkModelPhase(prefs);
  }

  Future<void> _checkModelPhase(SharedPreferences prefs) async {
    final modelReady = kIsWeb ? true : await GemmaModelManager.isModelReady();
    final modelPromptDone = prefs.getBool(_kModelPromptDone) ?? false;

    if (!mounted) return;
    if (!modelPromptDone && !modelReady) {
      setState(() => _phase = _GatePhase.modelDownload);
    } else {
      setState(() => _phase = _GatePhase.app);
    }
  }

  Future<void> _onModelPhaseDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kModelPromptDone, true);
    if (!mounted) return;
    setState(() => _phase = _GatePhase.app);
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _GatePhase.loading:
        return const Scaffold(
          backgroundColor: Color(0xFF080b12),
          body: Center(child: CircularProgressIndicator(color: Color(0xFF4a90d9))),
        );
      case _GatePhase.permissions:
        return PermissionOnboardingScreen(onComplete: _onPermsDone);
      case _GatePhase.auth:
        return AuthScreen(onComplete: _onAuthDone);
      case _GatePhase.modelDownload:
        return GemmaModelDownloadScreen(onComplete: _onModelPhaseDone);
      case _GatePhase.app:
        return widget.child;
    }
  }
}

enum _GatePhase { loading, permissions, auth, modelDownload, app }
