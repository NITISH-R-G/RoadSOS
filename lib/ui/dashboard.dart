import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_log.dart';
import '../services/ai_triage_service.dart';
import '../services/emergency_orchestrator.dart';
import 'crisis_companion_overlay.dart';
import 'dispatch_status_panel.dart';
import 'first_aid_screen.dart';
import 'incident_reporting_screen.dart';
import 'map_widget.dart';
import 'medical_card_screen.dart';
import 'mesh_chat_screen.dart';
import 'mesh_radar.dart';
import 'responder_dashboard.dart';
import 'safe_walk_overlay.dart';
import 'settings_screen.dart';
import 'sos_activity_log_screen.dart';
import 'sos_countdown_widget.dart';
import 'sos_side_effect_observer.dart';
import 'status_indicator.dart';
import 'triage_result_card.dart';
import 'vital_scan_screen.dart';

/// Main shell: idle = single giant SOS (panic-first); other phases show honest dispatch status.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();

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
                        () => appLog.d('Safe Walk feature coming soon'),
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

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(emergencyOrchestratorProvider);
    final scheme = Theme.of(context).colorScheme;
    final idle = sosState.phase == SOSPhase.idle;

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
          ),
          const CrisisCompanionOverlay(),
          const SafeWalkOverlay(),
          const SOSSideEffectObserver(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildEmergencyAppBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: scheme.surface.withValues(alpha: 0.94),
      elevation: 0,
      scrolledUnderElevation: 2,
      title: Row(
        children: [
          Icon(Icons.emergency_share, color: scheme.error, size: 26),
          const SizedBox(width: 10),
          Text(
            l10n.dashboardTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Activity log',
          icon: const Icon(Icons.fact_check_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const SosActivityLogScreen()),
          ),
        ),
        const StatusIndicatorBar(),
        const SizedBox(width: 16),
      ],
    );
  }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalH = constraints.maxHeight;
        final btnH = totalH * 0.8;
        final titleSize = min(96.0, btnH * 0.14);

        return Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
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
                                colors: [
                                  Color(0xFFFF453A),
                                  Color(0xFFB00020),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF453A).withValues(alpha: 0.42),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    l10n.sosButtonSub,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.94),
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
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCountdownView(BuildContext context, SOSState state) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SOSCountdownWidget(
        secondsRemaining: state.countdownSeconds,
        warningText: l10n.sosDispatchWarning,
        cancelLabel: l10n.cancelSos,
        secondsLabel: l10n.secondsLabel,
        onCancel: () => ref.read(emergencyOrchestratorProvider.notifier).cancelSos(),
      ),
    );
  }

  Widget _buildPipelineProgressView(BuildContext context, SOSState state) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final headline = state.phase == SOSPhase.gpsLocking
        ? l10n.orchestratorAcquiringLocation
        : l10n.orchestratorAiBrief;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 5,
              color: scheme.primary,
            ),
            const SizedBox(height: 28),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchingView(BuildContext context, SOSState state) {
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
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
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

  Widget _buildActiveSessionView(BuildContext context, SOSState state) {
    final scheme = Theme.of(context).colorScheme;

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
                  MaterialPageRoute<void>(builder: (_) => const SosActivityLogScreen()),
                ),
                icon: const Icon(Icons.history_edu_outlined),
                label: const Text('Full activity log & insurer note'),
              ),
              const SizedBox(height: 16),
            ],
            if (state.triageResult != null)
              TriageResultCard(result: state.triageResult!),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: RoadSosMap(state: state),
            ),
          ],
        ),
      ),
    );
  }
}
