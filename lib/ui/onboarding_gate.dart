import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'permission_onboarding_screen.dart';

const _kOnboardingDone = 'permissions_onboarding_v1_done';

/// Shows [PermissionOnboardingScreen] once, then the main app.
class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool? _loaded;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final done = p.getBool(_kOnboardingDone) ?? false;
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _showOnboarding = !done;
    });
  }

  Future<void> _completeOnboarding() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOnboardingDone, true);
    if (!mounted) return;
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded != true) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_showOnboarding) {
      return PermissionOnboardingScreen(onComplete: _completeOnboarding);
    }
    return widget.child;
  }
}
