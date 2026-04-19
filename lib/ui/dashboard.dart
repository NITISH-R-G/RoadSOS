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
import 'mesh_radar.dart';
import 'incident_reporting_screen.dart';
import 'medical_card_screen.dart';
import 'ai_explainability_view.dart';
import 'crisis_companion_overlay.dart';
import 'responder_dashboard.dart';
import 'safe_walk_overlay.dart';
import 'sos_side_effect_observer.dart';
import 'mesh_chat_screen.dart';
import 'vital_scan_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

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

  Future<void> _checkInitialPermissions() async {
    print('[System] 🔋 Checking safety permissions...');
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(emergencyOrchestratorProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emergency_share, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('RoadSOS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          ],
        ),
        actions: const [
          StatusIndicatorBar(),
          SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildBody(sosState),
          ),
          const CrisisCompanionOverlay(),
          const SafeWalkOverlay(),
          const SOSSideEffectObserver(),
        ],
      ),
    );
  }

  Widget _buildBody(SOSState sosState) {
    switch (sosState.phase) {
      case SOSPhase.idle:
        return _buildIdleView();
      case SOSPhase.countdown:
        return _buildCountdownView(sosState);
      default:
        return _buildActiveView(sosState);
    }
  }

  Widget _buildIdleView() {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: MeshRadar(),
          ),
          const SizedBox(height: 32),
          
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
          const SizedBox(height: 32),

          // Action Items Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionItem(
                  icon: Icons.camera_enhance, 
                  label: 'SCENE', 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncidentReportingScreen()))
                ),
                _buildActionItem(
                  icon: Icons.qr_code, 
                  label: 'MEDICAL ID', 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalCardScreen()))
                ),
                _buildActionItem(
                  icon: Icons.health_and_safety, 
                  label: 'RESPONDER', 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResponderDashboard()))
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
                  icon: Icons.settings, 
                  label: 'SETTINGS', 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

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

          const SizedBox(height: 24),

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
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCountdownView(SOSState state) {
    return Center(
      child: SOSCountdownWidget(
        secondsRemaining: state.countdownSeconds,
        onCancel: () => ref.read(emergencyOrchestratorProvider.notifier).cancelSos(),
      ),
    );
  }

  Widget _buildActiveView(SOSState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (state.triageResult != null) TriageResultCard(result: state.triageResult!),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Center(child: Text("Map Placeholder")),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38)),
        ],
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
