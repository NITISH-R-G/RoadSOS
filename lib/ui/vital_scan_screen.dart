import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/vital_signs_service.dart';

class VitalScanScreen extends ConsumerStatefulWidget {
  const VitalScanScreen({super.key});

  @override
  ConsumerState<VitalScanScreen> createState() => _VitalScanScreenState();
}

class _VitalScanScreenState extends ConsumerState<VitalScanScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vitalSignsProvider.notifier).startScan();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vitals = ref.watch(vitalSignsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.vitalScanTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildLiveWave(),
          const SizedBox(height: 32),
          if (vitals != null) ...[
            _buildVitalsGrid(vitals),
            const SizedBox(height: 48),
            _buildInterpretationCard(vitals),
          ] else
            const Center(child: CircularProgressIndicator()),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              AppLocalizations.of(context)!.vitalAlignFinger,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveWave() {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(painter: _WavePainter(animationValue: _waveController.value));
        },
      ),
    );
  }

  Widget _buildVitalsGrid(VitalSigns vitals) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildVitalItem('BPM', '${vitals.bpm}', Icons.favorite, Colors.red),
          _buildVitalItem('RESP', '${vitals.respiratoryRate}', Icons.air, Colors.blue),
          _buildVitalItem('SPO2', '${vitals.bloodOxygen.toStringAsFixed(1)}%', Icons.bloodtype, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildVitalItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInterpretationCard(VitalSigns vitals) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              vitals.aiInterpretation,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;

  _WavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(0, size.height / 2);

    for (double i = 0; i < size.width; i++) {
      final x = i;
      final y = size.height / 2 + sin((i / size.width * 2 * pi) + (animationValue * 2 * pi)) * 30;
      
      // Add "spikes" to simulate ECG
      double spike = 0;
      if ((i + animationValue * size.width) % (size.width / 2) < 20) {
        spike = -60;
      }

      path.lineTo(x, y + spike);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => true;
}
