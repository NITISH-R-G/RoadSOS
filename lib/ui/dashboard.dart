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
          const SizedBox(height: 48),
          Center(
            child: GestureDetector(
              onTap: () => ref.read(emergencyOrchestratorProvider.notifier).triggerSos(),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(scale: _pulseAnimation.value, child: child);
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
                    ],
                    gradient: const RadialGradient(colors: [Colors.redAccent, Color(0xFF8B0000)]),
                  ),
                  child: const Center(
                    child: Text('SOS', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 64),
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
                  icon: Icons.directions_walk, 
                  label: 'SAFE-WALK', 
                  onTap: () {
                    print("Safe Walk feature coming soon");
                  }
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
          const Spacer(flex: 2),
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
