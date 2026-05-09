<<<<<<< HEAD
import 'dart:math' show min;

import 'package:flutter/material.dart';
=======
import 'dart:convert';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
>>>>>>> origin/main
import 'package:roadsos/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_log.dart';
import '../services/ai_triage_service.dart';
<<<<<<< HEAD
=======
import '../services/driving_mode_service.dart';
>>>>>>> origin/main
import '../services/emergency_orchestrator.dart';
import '../services/proactive_monitor_service.dart';
import 'crisis_companion_overlay.dart';
import 'dispatch_status_panel.dart';
import 'first_aid_screen.dart';
import 'incident_reporting_screen.dart';
import 'map_widget.dart';
import 'medical_card_screen.dart';
import 'mesh_chat_screen.dart';
import 'mesh_radar.dart';
<<<<<<< HEAD
import 'responder_dashboard.dart';
import 'safe_walk_overlay.dart';
import 'settings_screen.dart';
import 'vehicle_rescue_screen.dart';
=======
import 'offline_map_screen.dart';
import 'profile_editor_screen.dart';
import 'responder_dashboard.dart';
import 'safe_walk_overlay.dart';
import 'settings_screen.dart';
>>>>>>> origin/main
import 'sos_activity_log_screen.dart';
import 'sos_countdown_widget.dart';
import 'sos_side_effect_observer.dart';
import 'status_indicator.dart';
import 'triage_result_card.dart';
import 'vital_scan_screen.dart';

<<<<<<< HEAD
/// Main shell: idle = single giant SOS (panic-first); other phases show honest dispatch status.
=======
/// Main shell — panic-first design with a discoverable bottom navigation bar.
///
/// Idle:     3-tab NavigationBar — SOS | Safety Tools | My Profile
/// Active:   Full-screen emergency UI (countdown → GPS lock → dispatch → live)
>>>>>>> origin/main
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
<<<<<<< HEAD
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
=======
  int _tab = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const _kRed = Color(0xFFE8281A);
  static const _kSurface = Color(0xFF111418);
  static const _kNavBg = Color(0xFF0D1014);

  @override
  void initState() {
    super.initState();
    appLog.d('DashboardScreen init');
>>>>>>> origin/main

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiTriageServiceProvider).initializeModel();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _checkInitialPermissions() async {
    appLog.d('Checking safety permissions');
  }

  void _openEmergencyToolsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: scheme.surfaceContainerHighest,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.paddingOf(ctx).bottom + 16,
              top: 8,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sosIdleToolsTitle,
                    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 180, child: MeshRadar()),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StatusIndicatorBar(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.start,
                    children: [
                      _sheetAction(
                        ctx,
                        Icons.camera_enhance,
                        l10n.actionScene,
                        () => Navigator.push(
                          ctx,
                          MaterialPageRoute(builder: (_) => const IncidentReportingScreen()),
                        ),
                      ),
                      _sheetAction(
                        ctx,
                        Icons.qr_code,
                        l10n.actionMedicalId,
                        () => Navigator.push(
                          ctx,
                          MaterialPageRoute(builder: (_) => const MedicalCardScreen()),
                        ),
                      ),
                      _sheetAction(
                        ctx,
                        Icons.health_and_safety,
                        l10n.actionResponder,
                        () => Navigator.push(
                          ctx,
                          MaterialPageRoute(builder: (_) => const ResponderDashboard()),
                        ),
                      ),
                      _sheetAction(
                        ctx,
                        Icons.directions_walk,
                        l10n.actionSafeWalk,
                        () => _showSafeWalkDialog(ctx),
                      ),
                      _sheetAction(
                        ctx,
                        Icons.health_and_safety_outlined,
                        l10n.actionFirstAid,
                        () => Navigator.push(
                          ctx,
                          MaterialPageRoute(builder: (_) => const FirstAidScreen()),
                        ),
                      ),
                      _sheetAction(
                        ctx,
                        Icons.monitor_heart,
                        l10n.actionVitalScan,
                        () => Navigator.push(
                          ctx,
                          MaterialPageRoute(builder: (_) => const VitalScanScreen()),
                        ),
                      ),
                      _sheetAction(
                        ctx,
                        Icons.forum,
                        l10n.actionMeshChat,
                        () => Navigator.push(
                          ctx,
                          MaterialPageRoute(builder: (_) => const MeshChatScreen()),
                        ),
                      ),
                      _sheetAction(
                        ctx,
                        Icons.fact_check_outlined,
                        'Activity log',
                        () => Navigator.push(
                          ctx,
                          MaterialPageRoute<void>(builder: (_) => const SosActivityLogScreen()),
                        ),
                      ),
                      _sheetAction(
                      ctx,
                      Icons.car_crash,
                      'Vehicle Rescue',
                      () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                      builder: (_) => const VehicleRescueScreen(),
                    ),
                  ),
                ),
                      _sheetAction(
                        ctx,
                        Icons.settings,
                        l10n.actionSettings,
                        () => Navigator.push(
                          ctx,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sheetAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: scheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
=======
  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
>>>>>>> origin/main

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(emergencyOrchestratorProvider);
    final scheme = Theme.of(context).colorScheme;
    final idle = sosState.phase == SOSPhase.idle;
<<<<<<< HEAD

    return Scaffold(
      backgroundColor: idle ? Colors.black : scheme.surface,
      appBar: idle ? null : _buildEmergencyAppBar(context),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: KeyedSubtree(
              key: ValueKey<SOSPhase>(sosState.phase),
              child: _buildBody(context, sosState),
            ),
=======
    final drivingMode = ref.watch(drivingModeProvider);

    // Emergency active → full-screen (no nav bar, no distractions).
    if (!idle) {
      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: _emergencyAppBar(context),
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: KeyedSubtree(
                key: ValueKey<SOSPhase>(sosState.phase),
                child: _emergencyBody(context, sosState),
              ),
            ),
            const CrisisCompanionOverlay(),
            const SafeWalkOverlay(),
            const SOSSideEffectObserver(),
          ],
        ),
      );
    }

    // Idle → 3-tab layout.
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _idleAppBar(context),
      body: Stack(
        children: [
          IndexedStack(
            index: _tab,
            children: [
              _sosTab(context, drivingMode),
              _toolsTab(context),
              _profileTab(context),
            ],
>>>>>>> origin/main
          ),
          const CrisisCompanionOverlay(),
          const SafeWalkOverlay(),
          const SOSSideEffectObserver(),
        ],
      ),
<<<<<<< HEAD
    );
  }

  PreferredSizeWidget _buildEmergencyAppBar(BuildContext context) {
=======
      bottomNavigationBar: _navBar(context),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // App bars
  // ─────────────────────────────────────────────────────────────────────────

  PreferredSizeWidget _idleAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _kRed,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.emergency_share,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'RoadSOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: const [StatusIndicatorBar(), SizedBox(width: 12)],
    );
  }

  PreferredSizeWidget _emergencyAppBar(BuildContext context) {
>>>>>>> origin/main
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
<<<<<<< HEAD
      backgroundColor: scheme.surface.withValues(alpha: 0.94),
=======
      backgroundColor: scheme.surface.withAlpha(240),
>>>>>>> origin/main
      elevation: 0,
      scrolledUnderElevation: 2,
      title: Row(
        children: [
          Icon(Icons.emergency_share, color: scheme.error, size: 26),
          const SizedBox(width: 10),
          Text(
            l10n.dashboardTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
<<<<<<< HEAD
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
=======
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
>>>>>>> origin/main
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Activity log',
          icon: const Icon(Icons.fact_check_outlined),
          onPressed: () => Navigator.push(
            context,
<<<<<<< HEAD
            MaterialPageRoute<void>(builder: (_) => const SosActivityLogScreen()),
          ),
        ),
        const StatusIndicatorBar(),
        const SizedBox(width: 16),
=======
            MaterialPageRoute<void>(
              builder: (_) => const SosActivityLogScreen(),
            ),
          ),
        ),
        const StatusIndicatorBar(),
        const SizedBox(width: 12),
>>>>>>> origin/main
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildBody(BuildContext context, SOSState sosState) {
    switch (sosState.phase) {
      case SOSPhase.idle:
        return _buildPanicIdleView(context);
      case SOSPhase.countdown:
        return _buildCountdownView(context, sosState);
      case SOSPhase.gpsLocking:
      case SOSPhase.triaging:
        return _buildPipelineProgressView(context, sosState);
      case SOSPhase.dispatching:
        return _buildDispatchingView(context, sosState);
      case SOSPhase.active:
        return _buildActiveSessionView(context, sosState);
      default:
        return _buildActiveSessionView(context, sosState);
    }
  }

  Widget _buildPanicIdleView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
=======
  // ─────────────────────────────────────────────────────────────────────────
  // Bottom navigation bar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _navBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
      backgroundColor: _kNavBg,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black,
      elevation: 8,
      indicatorColor: _kRed.withAlpha(38),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.emergency_outlined, color: Colors.white54),
          selectedIcon: Icon(Icons.emergency, color: _kRed),
          label: 'SOS',
        ),
        NavigationDestination(
          icon: Icon(Icons.apps_outlined, color: Colors.white54),
          selectedIcon: Icon(Icons.apps, color: _kRed),
          label: 'Safety Tools',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: Colors.white54),
          selectedIcon: Icon(Icons.person, color: _kRed),
          label: 'My Profile',
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 0 — SOS (panic button)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _sosTab(BuildContext context, DrivingMode drivingMode) {
    final l10n = AppLocalizations.of(context)!;
    final isDriving = drivingMode == DrivingMode.driving;
>>>>>>> origin/main

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalH = constraints.maxHeight;
<<<<<<< HEAD
        final btnH = totalH * 0.8;
=======
        final bannerH = isDriving ? 36.0 : 0.0;
        final btnH = (totalH - bannerH) * 0.78;
>>>>>>> origin/main
        final titleSize = min(96.0, btnH * 0.14);

        return Column(
          children: [
<<<<<<< HEAD
=======
            // Driving mode banner
            if (isDriving)
              Container(
                height: 36,
                color: const Color(0xFFFF9500),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car, color: Colors.black, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'DRIVING MODE — Crash detection armed',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

            // SOS button — takes up most of the screen
>>>>>>> origin/main
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
<<<<<<< HEAD
                    onTap: () =>
                        ref.read(emergencyOrchestratorProvider.notifier).triggerSOS(),
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
=======
                    onTap: () => ref
                        .read(emergencyOrchestratorProvider.notifier)
                        .triggerSOS(),
                    // ⚡ Bolt Optimization: Use ScaleTransition instead of AnimatedBuilder + Transform.scale.
                    // This delegates the transformation to the rendering engine and prevents costly widget rebuilds on every frame.
                    child: ScaleTransition(
                      scale: _pulseAnimation,
>>>>>>> origin/main
                      child: SizedBox(
                        height: btnH,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(52),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
<<<<<<< HEAD
                                colors: [
                                  Color(0xFFFF453A),
                                  Color(0xFFB00020),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF453A).withValues(alpha: 0.42),
=======
                                colors: [Color(0xFFFF453A), Color(0xFFB00020)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF453A).withAlpha(107),
>>>>>>> origin/main
                                  blurRadius: 40,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.sosButton,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
<<<<<<< HEAD
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    l10n.sosButtonSub,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.94),
=======
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    l10n.sosButtonSub,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xF0FFFFFF),
>>>>>>> origin/main
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
<<<<<<< HEAD
            SafeArea(
              minimum: const EdgeInsets.only(bottom: 12),
              child: TextButton(
                onPressed: () => _openEmergencyToolsSheet(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.88),
                  minimumSize: const Size(120, 52),
                ),
                child: Text(
                  l10n.sosIdleTools,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
                _buildActionItem(
                  icon: Icons.health_and_safety, 
                  label: 'RESPONDER', 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResponderDashboard()))
                ),
                _buildActionItem(
                  icon: Icons.directions_walk, 
                  label: 'SAFE-WALK', 
                  onTap: () => ref.read(proactiveMonitorProvider.notifier).startSafeWalk('Home', const Duration(minutes: 15))
                ),
                _buildActionItem(
                  icon: Icons.monitor_heart, 
                  label: 'VITAL SCAN', 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VitalScanScreen()))
                ),
                _buildActionItem(
                  icon: Icons.forum, 
                  label: 'MESH CHAT', 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MeshChatScreen()))
                ),
                _buildActionItem(
                  icon: Icons.car_crash,
                  label: 'RESCUE',
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const VehicleRescueScreen()))
                ),
                _buildActionItem(
                  icon: Icons.settings, 
                  label: 'SETTINGS', 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))
                ),
              ],
=======

            // Discovery hint
            SafeArea(
              minimum: const EdgeInsets.only(bottom: 8),
              child: Text(
                'All safety features are in "Safety Tools" below',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 13,
                ),
              ),
>>>>>>> origin/main
            ),
          ],
        );
      },
    );
  }

<<<<<<< HEAD
  Future<void> _showSafeWalkDialog(BuildContext context) async {
    final destCtrl = TextEditingController();
    var minutes = 30;
    final monitor = ref.read(proactiveMonitorProvider);

    if (monitor.isMonitoring) {
      // Quick stop
      ref.read(proactiveMonitorProvider.notifier).endSafeWalk();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Safe Walk ended.')),
        );
      }
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.paddingOf(ctx).bottom + 16,
              top: 8,
            ),
            child: StatefulBuilder(
              builder: (ctx, setModal) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Safe Walk',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: destCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Destination (optional)',
                        hintText: 'e.g., Home, Hostel, Station',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('ETA minutes:'),
                        const SizedBox(width: 12),
                        DropdownButton<int>(
                          value: minutes,
                          items: const [10, 15, 20, 30, 45, 60]
                              .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
                              .toList(),
                          onChanged: (v) => setModal(() => minutes = v ?? 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'If you miss check-in after ETA, RoadSOS will escalate to SOS after a 60s grace window.',
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(proactiveMonitorProvider.notifier).startSafeWalk(
                                destCtrl.text.trim().isEmpty ? 'your destination' : destCtrl.text.trim(),
                                Duration(minutes: minutes),
                              );
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.directions_walk),
                        label: const Text('START SAFE WALK'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdownView(BuildContext context, SOSState state) {
    final l10n = AppLocalizations.of(context)!;

=======
  // ─────────────────────────────────────────────────────────────────────────
  // Tab 1 — Safety Tools (all features, always visible)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _toolsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // Radar + status at the top
        const SizedBox(height: 160, child: MeshRadar()),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 4, bottom: 4),
            child: StatusIndicatorBar(),
          ),
        ),
        const SizedBox(height: 16),

        // ── Emergency Response ──────────────────────────────────────────
        _sectionLabel('EMERGENCY RESPONSE'),
        const SizedBox(height: 8),
        _toolCard(
          context,
          icon: Icons.directions_walk,
          color: const Color(0xFF00B8A0),
          title: 'Safe Walk',
          subtitle: 'Auto-SOS if you don\'t check in at destination',
          onTap: () => _showSafeWalkDialog(context),
        ),
        _toolCard(
          context,
          icon: Icons.camera_enhance,
          color: const Color(0xFFF59220),
          title: 'Capture Scene',
          subtitle: 'Document crash with AI-powered photo analysis',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const IncidentReportingScreen(),
            ),
          ),
        ),
        _toolCard(
          context,
          icon: Icons.health_and_safety,
          color: const Color(0xFF4CAF50),
          title: 'Responder View',
          subtitle: 'Live map with nearby SOS signals',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const ResponderDashboard()),
          ),
        ),

        const SizedBox(height: 20),

        // ── Health & Safety ─────────────────────────────────────────────
        _sectionLabel('HEALTH & SAFETY'),
        const SizedBox(height: 8),
        _toolCard(
          context,
          icon: Icons.health_and_safety_outlined,
          color: const Color(0xFF4CAF50),
          title: 'First Aid Guide',
          subtitle: 'Step-by-step emergency instructions',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const FirstAidScreen()),
          ),
        ),
        _toolCard(
          context,
          icon: Icons.monitor_heart,
          color: const Color(0xFFE8281A),
          title: 'Vital Scan',
          subtitle: 'Check heart rate & oxygen saturation',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const VitalScanScreen()),
          ),
        ),
        _toolCard(
          context,
          icon: Icons.qr_code,
          color: const Color(0xFF2196F3),
          title: 'Medical ID',
          subtitle: 'Show responders your blood type, allergies, contacts',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const MedicalCardScreen()),
          ),
        ),

        const SizedBox(height: 20),

        // ── Connectivity ────────────────────────────────────────────────
        _sectionLabel('CONNECTIVITY'),
        const SizedBox(height: 8),
        _toolCard(
          context,
          icon: Icons.forum,
          color: const Color(0xFF9C27B0),
          title: 'Mesh Chat',
          subtitle: 'Offline Bluetooth messaging — no signal needed',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const MeshChatScreen()),
          ),
        ),
        _toolCard(
          context,
          icon: Icons.map_outlined,
          color: const Color(0xFF00B8A0),
          title: 'Offline Maps',
          subtitle: 'Download maps for no-signal areas',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const OfflineMapScreen()),
          ),
        ),

        const SizedBox(height: 20),

        // ── Records ─────────────────────────────────────────────────────
        _sectionLabel('RECORDS'),
        const SizedBox(height: 8),
        _toolCard(
          context,
          icon: Icons.fact_check_outlined,
          color: Colors.white70,
          title: 'Activity Log',
          subtitle: 'GPS, triage, SMS — for police & insurer records',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const SosActivityLogScreen(),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 2 — My Profile
  // ─────────────────────────────────────────────────────────────────────────

  Widget _profileTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _sectionLabel('MY INFORMATION'),
        const SizedBox(height: 8),
        _toolCard(
          context,
          icon: Icons.person,
          color: const Color(0xFF2196F3),
          title: 'Edit Profile',
          subtitle: 'Name, blood type, emergency contacts',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const ProfileEditorScreen(),
            ),
          ),
        ),
        _toolCard(
          context,
          icon: Icons.qr_code,
          color: const Color(0xFF00B8A0),
          title: 'Medical ID Card',
          subtitle: 'Quick-access health info for emergency responders',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const MedicalCardScreen()),
          ),
        ),

        const SizedBox(height: 20),
        _sectionLabel('SETTINGS & PRIVACY'),
        const SizedBox(height: 8),
        _toolCard(
          context,
          icon: Icons.settings,
          color: Colors.white70,
          title: 'All Settings',
          subtitle: 'Language, offline maps, notifications, privacy',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          ),
        ),
        _toolCard(
          context,
          icon: Icons.history,
          color: Colors.white54,
          title: 'Activity Log',
          subtitle: 'Full SOS history for insurance & police records',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const SosActivityLogScreen(),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared widgets
  // ─────────────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withAlpha(100),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _toolCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: color.withAlpha(20),
          highlightColor: color.withAlpha(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withAlpha(28),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withAlpha(120),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withAlpha(60),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Emergency phase views (shown when !idle)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _emergencyBody(BuildContext context, SOSState sosState) {
    switch (sosState.phase) {
      case SOSPhase.countdown:
        return _countdownView(context, sosState);
      case SOSPhase.gpsLocking:
      case SOSPhase.triaging:
        return _pipelineProgressView(context, sosState);
      case SOSPhase.dispatching:
        return _dispatchingView(context, sosState);
      case SOSPhase.active:
      default:
        return _activeSessionView(context, sosState);
    }
  }

  Widget _countdownView(BuildContext context, SOSState state) {
    final l10n = AppLocalizations.of(context)!;
>>>>>>> origin/main
    return Center(
      child: SOSCountdownWidget(
        secondsRemaining: state.countdownSeconds,
        warningText: l10n.sosDispatchWarning,
        cancelLabel: l10n.cancelSos,
        secondsLabel: l10n.secondsLabel,
<<<<<<< HEAD
        onCancel: () => ref.read(emergencyOrchestratorProvider.notifier).cancelSos(),
=======
        onCancel: () =>
            ref.read(emergencyOrchestratorProvider.notifier).cancelSos(),
>>>>>>> origin/main
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildPipelineProgressView(BuildContext context, SOSState state) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

=======
  Widget _pipelineProgressView(BuildContext context, SOSState state) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
>>>>>>> origin/main
    final headline = state.phase == SOSPhase.gpsLocking
        ? l10n.orchestratorAcquiringLocation
        : l10n.orchestratorAiBrief;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
<<<<<<< HEAD
            CircularProgressIndicator(
              strokeWidth: 5,
              color: scheme.primary,
            ),
=======
            CircularProgressIndicator(strokeWidth: 5, color: scheme.primary),
>>>>>>> origin/main
            const SizedBox(height: 28),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
<<<<<<< HEAD
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    height: 1.35,
                  ),
=======
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
                height: 1.35,
              ),
>>>>>>> origin/main
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildDispatchingView(BuildContext context, SOSState state) {
=======
  Widget _dispatchingView(BuildContext context, SOSState state) {
>>>>>>> origin/main
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.orchestratorDispatching,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
<<<<<<< HEAD
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
=======
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
>>>>>>> origin/main
            ),
            const SizedBox(height: 16),
            DispatchStatusPanel(channels: state.dispatchChannels),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: scheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildActiveSessionView(BuildContext context, SOSState state) {
=======
  Widget _activeSessionView(BuildContext context, SOSState state) {
>>>>>>> origin/main
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.dispatchChannels.isNotEmpty) ...[
              DispatchStatusPanel(channels: state.dispatchChannels),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
<<<<<<< HEAD
                  MaterialPageRoute<void>(builder: (_) => const SosActivityLogScreen()),
=======
                  MaterialPageRoute<void>(
                    builder: (_) => const SosActivityLogScreen(),
                  ),
>>>>>>> origin/main
                ),
                icon: const Icon(Icons.history_edu_outlined),
                label: const Text('Full activity log & insurer note'),
              ),
              const SizedBox(height: 16),
            ],
            if (state.triageResult != null)
              TriageResultCard(result: state.triageResult!),
            const SizedBox(height: 16),
<<<<<<< HEAD
            SizedBox(
              height: 300,
              child: RoadSosMap(state: state),
            ),
=======
            SizedBox(height: 300, child: RoadSosMap(state: state)),
>>>>>>> origin/main
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  // ─────────────────────────────────────────────────────────────────────────
  // Safe Walk dialog
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _showSafeWalkDialog(BuildContext context) async {
    final monitor = ref.read(proactiveMonitorProvider);

    if (monitor.isMonitoring) {
      ref.read(proactiveMonitorProvider.notifier).endSafeWalk();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Safe Walk ended.')));
      }
      return;
    }

    String selectedDestination = '';

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Safe Walk',
                style: Theme.of(
                  ctx,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  try {
                    final uri = Uri.parse(
                      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(textEditingValue.text)}&format=json&addressdetails=1&limit=5',
                    );
                    final response = await http.get(
                      uri,
                      headers: {'User-Agent': 'RoadSOS/1.0'},
                    );
                    if (response.statusCode == 200) {
                      final List<dynamic> data = json.decode(response.body);
                      return data
                          .map((e) => e['display_name'] as String)
                          .toList();
                    }
                  } catch (e) {
                    appLog.w('Error fetching location suggestions: $e');
                  }
                  return const Iterable<String>.empty();
                },
                onSelected: (String selection) {
                  selectedDestination = selection;
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        onChanged: (val) {
                          selectedDestination = val;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Destination (optional)',
                          hintText: 'e.g., Home, Hostel, Station',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      );
                    },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surface,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 200,
                          maxWidth: 300,
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final option = options.elementAt(index);
                            return InkWell(
                              onTap: () {
                                onSelected(option);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  option,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'A 30-minute safety check timer will start now.\nIf you miss the check-in, RoadSOS will escalate to SOS after a 60s grace window.',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(proactiveMonitorProvider.notifier)
                        .startSafeWalk(
                          selectedDestination.trim().isEmpty
                              ? 'your destination'
                              : selectedDestination.trim(),
                          const Duration(minutes: 30),
                        );
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.directions_walk),
                  label: const Text('START SAFE WALK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
>>>>>>> origin/main
}
