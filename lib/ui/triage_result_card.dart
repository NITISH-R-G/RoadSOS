import 'package:flutter/material.dart';
import '../services/ai_triage_service.dart';
import 'ai_explainability_view.dart';

/// Card showing AI triage results with severity badge, services, and first-aid guidance.
class TriageResultCard extends StatelessWidget {
  final TriageResult result;

  const TriageResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _severityColor(result.severityLevel).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _severityColor(result.severityLevel).withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with severity badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _severityColor(result.severityLevel).withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                _SeverityBadge(level: result.severityLevel),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.isDegradedMode ? 'AI TRIAGE (DEGRADED)' : 'AI TRIAGE RESULT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _severityColor(result.severityLevel),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Severity ${result.severityLevel}/5 — ${_severityLabel(result.severityLevel)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (result.isDegradedMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NO AI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Services needed
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DISPATCHED SERVICES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: result.requiredServices.map((service) {
                    return _ServiceChip(service: service);
                  }).toList(),
                ),
              ],
            ),
          ),

          // First Aid guidance
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.medical_services, size: 14, color: Colors.blue),
                      SizedBox(width: 6),
                      Text(
                        'FIRST AID GUIDANCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.firstAidQuery,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Explainable AI Trace (New V5.0 Feature)
          if (result.thinkingTrace != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AiExplainabilityView(triage: result),
            ),

          // Compressed payload
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'BLE PAYLOAD: ${result.compressedPayload}',
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'RobotoMono',
                color: Colors.white.withOpacity(0.2),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(int level) {
    switch (level) {
      case 5: return Colors.red;
      case 4: return Colors.deepOrange;
      case 3: return Colors.orange;
      case 2: return Colors.amber;
      case 1: return Colors.green;
      default: return Colors.grey;
    }
  }

  String _severityLabel(int level) {
    switch (level) {
      case 5: return 'CRITICAL';
      case 4: return 'SEVERE';
      case 3: return 'MODERATE';
      case 2: return 'MINOR';
      case 1: return 'LOW';
      default: return 'UNKNOWN';
    }
  }
}

class _SeverityBadge extends StatelessWidget {
  final int level;

  const _SeverityBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = level >= 4 ? Colors.red : (level >= 3 ? Colors.orange : Colors.amber);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          '$level',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String service;

  const _ServiceChip({required this.service});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _serviceVisuals(service);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            service.toUpperCase().replaceAll('_', ' '),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _serviceVisuals(String service) {
    switch (service) {
      case 'ambulance': return (Icons.local_hospital, Colors.red);
      case 'police': return (Icons.local_police, Colors.blue);
      case 'fire_department': return (Icons.local_fire_department, Colors.orange);
      case 'rescue': return (Icons.health_and_safety, Colors.teal);
      case 'towing': return (Icons.car_repair, Colors.amber);
      default: return (Icons.help, Colors.grey);
    }
  }
}
