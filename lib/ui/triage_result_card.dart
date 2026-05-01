import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:roadsos/l10n/app_localizations.dart';

import '../services/ai_triage_service.dart';
import 'ai_explainability_view.dart';

/// Card showing AI triage results with severity badge, services, and first-aid guidance.
class TriageResultCard extends StatelessWidget {
  final TriageResult result;

  const TriageResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final severe = _severityColor(result.severityLevel);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: severe.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: severe.withValues(alpha: 0.18),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: severe.withValues(alpha: 0.18),
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
                        result.isDegradedMode ? l10n.triageDegradedTitle : l10n.triageResultTitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: severe,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.severityLine(
                          result.severityLevel,
                          _severityLabel(context, result.severityLevel),
                        ),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
                if (result.isDegradedMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.tertiary.withValues(alpha: 0.22),
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
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dispatchedServices,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: scheme.onSurface.withValues(alpha: 0.76),
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

          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: scheme.primary.withValues(alpha: 0.42)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  MarkdownBody(
                    data: result.firstAidQuery,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.92),
                            height: 1.4,
                          ),
                      strong: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                      em: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: scheme.onSurface.withValues(alpha: 0.92),
                          ),
                      blockquoteDecoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (result.thinkingTrace != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AiExplainabilityView(triage: result),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              result.compressedPayload,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontFamily: 'RobotoMono',
                    color: scheme.onSurface.withValues(alpha: 0.58),
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _severityLabel(BuildContext context, int level) {
    final l10n = AppLocalizations.of(context)!;
    switch (level) {
      case 5:
        return l10n.severityCritical;
      case 4:
        return l10n.severitySevere;
      case 3:
        return l10n.severityModerate;
      case 2:
        return l10n.severityMinor;
      case 1:
        return l10n.severityLow;
      default:
        return l10n.severityUnknown;
    }
  }

  Color _severityColor(int level) {
    switch (level) {
      case 5:
        return Colors.red;
      case 4:
        return Colors.deepOrange;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.amber.shade700;
      case 1:
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }
}

class _SeverityBadge extends StatelessWidget {
  final int level;

  const _SeverityBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = level >= 4 ? Colors.red : (level >= 3 ? Colors.orange : Colors.amber.shade800);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.22),
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
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.42)),
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
      case 'ambulance':
        return (Icons.local_hospital, Colors.red);
      case 'police':
        return (Icons.local_police, Colors.blue);
      case 'fire_department':
        return (Icons.local_fire_department, Colors.orange);
      case 'rescue':
        return (Icons.health_and_safety, Colors.teal);
      case 'towing':
        return (Icons.car_repair, Colors.amber.shade800);
      default:
        return (Icons.help, Colors.grey);
    }
  }
}
