import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emergency_orchestrator.dart';
import '../services/ai_triage_service.dart';
import 'status_indicator.dart';
import 'sos_countdown_widget.dart';
import 'triage_result_card.dart';
import 'map_widget.dart';

/// Production-quality emergency dashboard.
///
/// Displays different UI states based on the SOS lifecycle:
/// - IDLE: Animated pulsing SOS button + system status
/// - COUNTDOWN: 10-second cancel window
/// - ACTIVE: Live status feed, triage results, dispatched services
/// - RESOLVED: Incident summary
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();

    // Pulsing animation for SOS button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Initialize AI model on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiTriageServiceProvider).initializeModel();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(emergencyOrchestratorProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: sosState.phase == SOSPhase.active ||
              sosState.phase == SOSPhase.countdown
          ? Colors.black
          : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.emergency, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              'RoadSOS',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: const [
          StatusIndicatorBar(),
          SizedBox(width: 12),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _buildBody(sosState),
      ),
    );
  }

  Widget _buildBody(SOSState sosState) {
    switch (sosState.phase) {
      case SOSPhase.idle:
        return _buildIdleView();
      case SOSPhase.countdown:
        return _buildCountdownView(sosState);
      case SOSPhase.bystanderMode:
      case SOSPhase.gpsLocking:
      case SOSPhase.triaging:
      case SOSPhase.dispatching:
        return _buildProcessingView(sosState);
      case SOSPhase.active:
        return _buildActiveView(sosState);
      case SOSPhase.resolved:
        return _buildResolvedView(sosState);
    }
  }

  /// IDLE — The main SOS button view.
  Widget _buildIdleView() {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Animated SOS Button
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.03);
              final glowRadius = 20.0 + (_glowController.value * 30);

              return Transform.scale(
                scale: scale,
                child: GestureDetector(
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                    ref
                        .read(emergencyOrchestratorProvider.notifier)
                        .triggerSOS();
                  },
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFFFF1744),
                          Color(0xFFD50000),
                          Color(0xFFB71C1C),
                        ],
                        stops: [0.0, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF1744).withOpacity(0.3),
                          blurRadius: glowRadius,
                          spreadRadius: glowRadius / 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emergency_share, size: 40, color: Colors.white),
                          SizedBox(height: 4),
                          Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          Text(
            'LONG PRESS TO ACTIVATE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 2,
            ),
          ),

          // Nearby Facilities Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'NEARBY EMERGENCY HELP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white38,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.radar, size: 10, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            '800m',
                            style: TextStyle(fontSize: 9, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FacilityListItem(
                  name: 'IITM Apollo Hospital',
                  type: 'Trauma Center',
                  distance: '0.4 km',
                  icon: Icons.local_hospital,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 8),
                _FacilityListItem(
                  name: 'Emergency Response Hub',
                  type: 'Quick Response Team',
                  distance: '1.2 km',
                  icon: Icons.health_and_safety,
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          // Info cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.volume_up,
                    title: 'Hardware SOS',
                    subtitle: 'Vol ↑↓ x3 in 2s',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.bluetooth,
                    title: 'Mesh Network',
                    subtitle: 'BLE relay ready',
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.psychology,
                    title: 'Edge AI',
                    subtitle: 'Gemma 4 on-device',
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.visibility,
                    title: 'Witness SOS',
                    subtitle: 'Report for others',
                    color: Colors.amber,
                    onTap: () {
                       ref.read(emergencyOrchestratorProvider.notifier).triggerBystanderSOS();
                    },
                  ),
                ),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.cloud_off,
                    title: 'Offline-First',
                    subtitle: 'PowerSync active',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Attribution
          Text(
            'Gemma is a trademark of Google LLC',
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// COUNTDOWN — Cancel window.
  Widget _buildCountdownView(SOSState state) {
    return SafeArea(
      child: Center(
        child: SOSCountdownWidget(
          secondsRemaining: state.countdownSeconds,
          onCancel: () {
            ref.read(emergencyOrchestratorProvider.notifier).cancelSOS();
          },
        ),
      ),
    );
  }

  /// PROCESSING — GPS / AI / Dispatching in progress.
  Widget _buildProcessingView(SOSState state) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const CircularProgressIndicator(color: Colors.red, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            _phaseLabel(state.phase),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RoadSosMap(state: state),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildStatusLog(state)),
        ],
      ),
    );
  }

  /// ACTIVE — SOS is live.
  Widget _buildActiveView(SOSState state) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Active SOS banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD50000), Color(0xFFFF1744)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.emergency, size: 36, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text(
                    'SOS ACTIVE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Incident ${state.incidentId ?? "---"}',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'RobotoMono',
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Map View
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: RoadSosMap(state: state),
            ),

            // Triage result card
            if (state.triageResult != null)
              TriageResultCard(result: state.triageResult!),

            // Location info
            if (state.location != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.location!.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'RobotoMono',
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Status log
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(14, 14, 14, 8),
                    child: Text(
                      'EVENT LOG',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white38,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  ...state.statusLog.map((entry) => _StatusLogEntry(entry: entry)),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Resolve button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(emergencyOrchestratorProvider.notifier)
                        .resolveSOS();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  label: const Text(
                    'MARK AS RESOLVED',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// RESOLVED — Summary view.
  Widget _buildResolvedView(SOSState state) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'SOS RESOLVED',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.green,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Incident ${state.incidentId ?? "---"} closed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(emergencyOrchestratorProvider.notifier).reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'RETURN HOME',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLog(SOSState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.statusLog.length,
      itemBuilder: (context, index) {
        return _StatusLogEntry(entry: state.statusLog[index]);
      },
    );
  }

  String _phaseLabel(SOSPhase phase) {
    switch (phase) {
      case SOSPhase.gpsLocking: return 'ACQUIRING GPS...';
      case SOSPhase.triaging: return 'AI TRIAGE IN PROGRESS...';
      case SOSPhase.dispatching: return 'DISPATCHING SERVICES...';
      default: return '';
    }
  }
}

/// Single entry in the event status log.
class _StatusLogEntry extends StatelessWidget {
  final SOSStatusMessage entry;

  const _StatusLogEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'RobotoMono',
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.message,
              style: TextStyle(
                fontSize: 12,
                color: entry.isError ? Colors.orange : Colors.white70,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small info card for the idle view.
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List item for nearby emergency facilities.
class _FacilityListItem extends StatelessWidget {
  final String name;
  final String type;
  final String distance;
  final IconData icon;
  final Color color;

  const _FacilityListItem({
    required this.name,
    required this.type,
    required this.distance,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Text(
            distance,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
