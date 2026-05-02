import 'package:flutter/material.dart';
import '../models/dispatch_channel_status.dart';

/// Honest per-channel dispatch states (SMS, mesh, cloud) — no fake “help is coming” timer.
class DispatchStatusPanel extends StatelessWidget {
  final List<DispatchChannelRow> channels;

  const DispatchStatusPanel({super.key, required this.channels});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (channels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      label: 'Dispatch status list',
      child: Card(
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outline.withOpacity(0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'DISPATCH STATUS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.2,
                        color: scheme.onSurface.withOpacity(0.88),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              for (final row in channels) _DispatchRow(row: row, scheme: scheme),
            ],
          ),
        ),
      ),
    );
  }
}

class _DispatchRow extends StatelessWidget {
  final DispatchChannelRow row;
  final ColorScheme scheme;

  const _DispatchRow({required this.row, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = _iconFor(row.lifecycle, scheme);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  row.detail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withOpacity(0.87),
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _iconFor(DispatchChannelLifecycle life, ColorScheme scheme) {
    switch (life) {
      case DispatchChannelLifecycle.pending:
        return (Icons.radio_button_unchecked, scheme.outline);
      case DispatchChannelLifecycle.inProgress:
        return (Icons.pending_outlined, scheme.primary);
      case DispatchChannelLifecycle.success:
        return (Icons.check_circle_rounded, scheme.secondary);
      case DispatchChannelLifecycle.failed:
        return (Icons.error_outline_rounded, scheme.error);
      case DispatchChannelLifecycle.skipped:
        return (Icons.do_not_disturb_on_outlined, scheme.outline);
    }
  }
}
