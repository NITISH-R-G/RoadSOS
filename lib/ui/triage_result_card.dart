import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../services/ai_triage_service.dart';
import 'ai_explainability_view.dart';

/// Card showing AI triage results with severity badge, services, and first-aid guidance.
=======
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:roadsos/l10n/app_localizations.dart';

import '../services/ai_triage_service.dart';
import 'ai_explainability_view.dart';

/// Card showing AI triage results with severity badge, services, first-aid guidance,
/// confidence score, and validation agent notes.
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
class TriageResultCard extends StatelessWidget {
  final TriageResult result;

  const TriageResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _severityColor(result.severityLevel).withOpacity(0.4),
=======
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final severe = _severityColor(result.severityLevel);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: severe.withAlpha(115),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
<<<<<<< HEAD
            color: _severityColor(result.severityLevel).withOpacity(0.1),
=======
            color: severe.withAlpha(46),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          // Header with severity badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _severityColor(result.severityLevel).withOpacity(0.15),
=======
          // ── Header: severity + confidence ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: severe.withAlpha(46),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
                        result.isDegradedMode ? 'AI TRIAGE (DEGRADED)' : 'AI TRIAGE RESULT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _severityColor(result.severityLevel),
=======
                        result.isDegradedMode ? l10n.triageDegradedTitle : l10n.triageResultTitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: severe,
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
<<<<<<< HEAD
                        'Severity ${result.severityLevel}/5 — ${_severityLabel(result.severityLevel)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
=======
                        l10n.severityLine(
                          result.severityLevel,
                          _severityLabel(context, result.severityLevel),
                        ),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
                      ),
                    ],
                  ),
                ),
<<<<<<< HEAD
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
=======
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (result.isDegradedMode)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.tertiary.withAlpha(56),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.noAiBadge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: scheme.tertiary,
                          ),
                        ),
                      ),
                    if (result.wasOverridden) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(40),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber.withAlpha(100)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 10, color: Colors.amber),
                            SizedBox(width: 3),
                            Text(
                              'VALIDATED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
              ],
            ),
          ),

<<<<<<< HEAD
          // Services needed
=======
          // ── Services ─────────────────────────────────────────────────────
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< HEAD
                const Text(
                  'DISPATCHED SERVICES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1.5,
                  ),
=======
                Text(
                  l10n.dispatchedServices,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: scheme.onSurface.withAlpha(194),
                      ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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

<<<<<<< HEAD
          // First Aid guidance
=======
          // ── First-aid guidance (RAG) ──────────────────────────────────────
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
=======
                color: scheme.primaryContainer.withAlpha(166),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: scheme.primary.withAlpha(107)),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
<<<<<<< HEAD
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
=======
                  Row(
                    children: [
                      Icon(Icons.medical_services, size: 14, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        l10n.firstAidGuidance,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                              letterSpacing: 1,
                            ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
<<<<<<< HEAD
                  Text(
                    result.firstAidQuery,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
=======
                  MarkdownBody(
                    data: result.firstAidQuery,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withAlpha(235),
                            height: 1.4,
                          ),
                      strong: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                      em: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: scheme.onSurface.withAlpha(235),
                          ),
                      blockquoteDecoration: BoxDecoration(
                        color: scheme.surface.withAlpha(140),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: scheme.outline.withAlpha(64)),
                      ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
                    ),
                  ),
                ],
              ),
            ),
          ),

<<<<<<< HEAD
          // Explainable AI Trace (New V5.0 Feature)
          if (result.thinkingTrace != null)
=======
          // ── AI explainability (thinking trace + validation + actions) ─────
          if (result.thinkingTrace != null || result.wasOverridden)
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AiExplainabilityView(triage: result),
            ),

<<<<<<< HEAD
          // Compressed payload
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              result.compressedPayload,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'RobotoMono',
                color: Colors.white.withOpacity(0.3),
                letterSpacing: 0.5,
              ),
=======
          // ── Compressed payload (BLE mesh / SMS interop) ───────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              result.compressedPayload,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontFamily: 'RobotoMono',
                    color: scheme.onSurface.withAlpha(148),
                    letterSpacing: 0.5,
                  ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
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
=======
  String _severityLabel(BuildContext context, int level) {
    final l10n = AppLocalizations.of(context)!;
    switch (level) {
      case 5:  return l10n.severityCritical;
      case 4:  return l10n.severitySevere;
      case 3:  return l10n.severityModerate;
      case 2:  return l10n.severityMinor;
      case 1:  return l10n.severityLow;
      default: return l10n.severityUnknown;
    }
  }

  Color _severityColor(int level) {
    switch (level) {
      case 5:  return Colors.red;
      case 4:  return Colors.deepOrange;
      case 3:  return Colors.orange;
      case 2:  return Colors.amber.shade700;
      case 1:  return Colors.green.shade700;
      default: return Colors.grey;
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    }
  }
}

class _SeverityBadge extends StatelessWidget {
  final int level;

  const _SeverityBadge({required this.level});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final color = level >= 4 ? Colors.red : (level >= 3 ? Colors.orange : Colors.amber);
=======
    final color = level >= 4
        ? Colors.red
        : (level >= 3 ? Colors.orange : Colors.amber.shade800);
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
<<<<<<< HEAD
        color: color.withOpacity(0.2),
=======
        color: color.withAlpha(56),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
=======
        color: color.withAlpha(36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(107)),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
      case 'ambulance': return (Icons.local_hospital, Colors.red);
      case 'police': return (Icons.local_police, Colors.blue);
      case 'fire_department': return (Icons.local_fire_department, Colors.orange);
      case 'rescue': return (Icons.health_and_safety, Colors.teal);
      case 'towing': return (Icons.car_repair, Colors.amber);
      default: return (Icons.help, Colors.grey);
=======
      case 'ambulance':       return (Icons.local_hospital, Colors.red);
      case 'police':          return (Icons.local_police, Colors.blue);
      case 'fire_department': return (Icons.local_fire_department, Colors.orange);
      case 'rescue':          return (Icons.health_and_safety, Colors.teal);
      case 'towing':          return (Icons.car_repair, Colors.amber.shade800);
      default:                return (Icons.help, Colors.grey);
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    }
  }
}
