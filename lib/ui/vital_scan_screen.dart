<<<<<<< HEAD
import 'dart:math';
import 'package:flutter/material.dart';
=======
import 'package:flutter/material.dart';
import 'package:roadsos/l10n/app_localizations.dart';
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/vital_signs_service.dart';

class VitalScanScreen extends ConsumerStatefulWidget {
  const VitalScanScreen({super.key});

  @override
  ConsumerState<VitalScanScreen> createState() => _VitalScanScreenState();
}

class _VitalScanScreenState extends ConsumerState<VitalScanScreen> with TickerProviderStateMixin {
<<<<<<< HEAD
  late AnimationController _waveController;
=======
  final _bpmCtrl = TextEditingController();
  final _rrCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vitalSignsProvider.notifier).startScan();
    });
=======
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
  }

  @override
  void dispose() {
<<<<<<< HEAD
    _waveController.dispose();
=======
    _bpmCtrl.dispose();
    _rrCtrl.dispose();
    _spo2Ctrl.dispose();
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vitals = ref.watch(vitalSignsProvider);
<<<<<<< HEAD
=======
    final scheme = Theme.of(context).colorScheme;
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('GEMMA PULSE: VITAL SCAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
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
              'Align index finger with rear camera and flash for precise PPG reading.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
            ),
=======
        title: Text(AppLocalizations.of(context)!.vitalScanTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
            ),
            child: Text(
              'Enter vitals manually. RoadSOS does not measure SpO₂/HR from the camera in this build.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.86), height: 1.35),
            ),
          ),
          const SizedBox(height: 18),
          _field(label: 'Pulse (BPM)', controller: _bpmCtrl, hint: 'e.g., 92'),
          const SizedBox(height: 12),
          _field(label: 'Respiratory rate (per min)', controller: _rrCtrl, hint: 'e.g., 18'),
          const SizedBox(height: 12),
          _field(label: 'SpO₂ (%)', controller: _spo2Ctrl, hint: 'e.g., 97'),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _save(),
                    icon: const Icon(Icons.check),
                    label: const Text('SAVE VITALS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => ref.read(vitalSignsProvider.notifier).clear(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('CLEAR'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (vitals != null) ...[
            _buildVitalsGrid(vitals),
            const SizedBox(height: 14),
            _buildInterpretationCard(vitals),
          ],
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.vitalAlignFinger,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blue),
        ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
=======
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
<<<<<<< HEAD
              vitals.gemmaInterpretation,
=======
              vitals.interpretation,
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
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
=======

  void _save() {
    final bpm = int.tryParse(_bpmCtrl.text.trim());
    final rr = int.tryParse(_rrCtrl.text.trim());
    final spo2 = double.tryParse(_spo2Ctrl.text.trim());

    if (bpm == null || rr == null || spo2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid numbers for BPM, RESP, and SpO₂.')),
      );
      return;
    }

    ref.read(vitalSignsProvider.notifier).setManual(
          bpm: bpm.clamp(20, 240),
          respiratoryRate: rr.clamp(4, 60),
          bloodOxygen: spo2.clamp(50.0, 100.0),
        );

    FocusScope.of(context).unfocus();
  }
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
}
