import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/app_database.dart' show isSupabaseSdkInitialized;
import '../services/family_circle_service.dart';
import '../services/family_tracking_service.dart';
import '../services/sms_direct_send.dart';
import '../services/webrtc_voice_call_service.dart';
import 'widgets/roadsos_glass.dart';

/// Family Circle: trusted peers, live map, invite + redeem.
class FamilyCircleScreen extends ConsumerStatefulWidget {
  const FamilyCircleScreen({super.key});

  @override
  ConsumerState<FamilyCircleScreen> createState() => _FamilyCircleScreenState();
}

class _FamilyCircleScreenState extends ConsumerState<FamilyCircleScreen> {
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(familyCircleServiceProvider.notifier).ensureCircleReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyCircleServiceProvider);
    final notifier = ref.read(familyCircleServiceProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Family Circle',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.busy ? null : () => notifier.ensureCircleReady(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Redeem invite',
            onPressed: () => _showRedeemDialog(context, notifier),
            icon: const Icon(Icons.qr_code_rounded),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0C10), Color(0xFF121820)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (state.lastError != null) _errorBanner(state.lastError!),
              SizedBox(height: 220, child: _liveMap(state)),
              _publishingControls(state, notifier),
              const Divider(height: 1, color: Color(0xFF1F2933)),
              Expanded(child: _membersList(state, notifier)),
            ],
          ),
        ),
      ),
      floatingActionButton: state.circles.isEmpty
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF5C7CFA),
              onPressed: state.busy
                  ? null
                  : () => notifier.ensureCircleReady(),
              icon: const Icon(Icons.group_add),
              label: const Text('Set up circle'),
            )
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFF5C7CFA),
              onPressed: state.busy
                  ? null
                  : () => _showInviteDialog(context, notifier, state.circles.first.id),
              icon: const Icon(Icons.person_add),
              label: const Text('Invite by SMS'),
            ),
    );
  }

  Widget _liveMap(FamilyCircleState state) {
    final markers = <Marker>[];
    LatLng? first;
    for (final loc in state.livePositions.values) {
      final point = LatLng(loc.latitude, loc.longitude);
      first ??= point;
      markers.add(
        Marker(
          point: point,
          width: 70,
          height: 70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                loc.isSos
                    ? Icons.warning
                    : loc.isSafeWalk
                        ? Icons.directions_walk
                        : Icons.person_pin_circle,
                size: 32,
                color: loc.isSos
                    ? const Color(0xFFE8281A)
                    : loc.isSafeWalk
                        ? const Color(0xFF00B8A0)
                        : const Color(0xFF5C7CFA),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loc.displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final center = first ?? const LatLng(12.9716, 77.5946);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: center, initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.roadsos.app',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _publishingControls(FamilyCircleState state, FamilyCircleService notifier) {
    final mode = state.publishingMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: RoadSosGlassPanel(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.publishing
                    ? mode == FamilyPublishMode.sos
                        ? 'Sharing SOS location with circle'
                        : 'Sharing Safe Walk with circle'
                    : 'Location sharing is off',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            if (state.publishing)
              TextButton(
                onPressed: notifier.stopPublishing,
                child: const Text('Stop'),
              )
            else ...[
              TextButton(
                onPressed: state.usesLocalPreview
                    ? null
                    : () => notifier.startPublishing(
                          mode: FamilyPublishMode.safeWalk,
                          destination: 'Out',
                        ),
                child: const Text('Safe Walk'),
              ),
              TextButton(
                onPressed: state.usesLocalPreview
                    ? null
                    : () => notifier.startPublishing(mode: FamilyPublishMode.sos),
                child: const Text('SOS share'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: RoadSosGlassPanel(
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(12),
        tint: const Color(0x22E8281A),
        child: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    );
  }

  String? _currentUserId() {
    if (!isSupabaseSdkInitialized) return 'local-self';
    try {
      return Supabase.instance.client.auth.currentUser?.id ?? 'local-self';
    } catch (_) {
      return 'local-self';
    }
  }

  Widget _membersList(FamilyCircleState state, FamilyCircleService notifier) {
    if (state.members.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Setting up your circle…',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: state.members.length,
      itemBuilder: (context, i) {
        final m = state.members[i];
        final live = state.livePositions[m.userId];
        final isSelf = m.userId == _currentUserId();
        return RoadSosGlassPanel(
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(12),
          tint: isSelf
              ? const Color(0x18FFFFFF)
              : const Color(0x105C7CFA),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF5C7CFA),
                child: Text(
                  (m.displayName.isNotEmpty ? m.displayName[0] : '?').toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (m.phoneE164 != null)
                      Text(
                        m.phoneE164!,
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      live == null
                          ? 'Not sharing right now'
                          : live.isSos
                              ? 'SOS · ${_age(live.updatedAt)} ago'
                              : live.isSafeWalk
                                  ? 'Safe Walk · ${_age(live.updatedAt)} ago'
                                  : 'Live · ${_age(live.updatedAt)} ago',
                      style: TextStyle(
                        color: live == null
                            ? Colors.white38
                            : live.isSos
                                ? const Color(0xFFE8281A)
                                : const Color(0xFF00B8A0),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSelf) ...[
                if (!state.usesLocalPreview)
                  IconButton(
                    tooltip: 'Voice call in app',
                    onPressed: () async {
                      final res = await ref
                          .read(webRtcVoiceCallServiceProvider.notifier)
                          .startCall(
                            calleeId: m.userId,
                            peerName: m.displayName,
                          );
                      if (!context.mounted) return;
                      if (res.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res.error!)),
                        );
                      }
                    },
                    icon: const Icon(Icons.headset_mic, color: Color(0xFF5C7CFA)),
                  ),
                if (m.phoneE164 != null)
                  IconButton(
                    tooltip: 'Phone call',
                    onPressed: () {
                      final digits = m.phoneE164!.replaceAll(RegExp(r'[^\d+]'), '');
                      launchUrl(Uri.parse('tel:$digits'));
                    },
                    icon: const Icon(Icons.call, color: Color(0xFF00B8A0)),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _age(DateTime t) {
    final d = DateTime.now().toUtc().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    return '${d.inHours}h';
  }

  Future<void> _showInviteDialog(
    BuildContext context,
    FamilyCircleService notifier,
    String circleId,
  ) async {
    final phoneController = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite to Family Circle'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone number',
            hintText: '9876543210',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, phoneController.text),
            child: const Text('Send invite'),
          ),
        ],
      ),
    );
    if (raw == null || raw.trim().isEmpty) return;

    await notifier.ensureCircleReady();
    if (!context.mounted) return;

    final state = ref.read(familyCircleServiceProvider);
    if (state.usesLocalPreview) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Still connecting — try again in a moment.')),
      );
      return;
    }

    final phone = FamilyTrackingService.normalizePhoneDigits(raw);
    if (phone == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number.')),
      );
      return;
    }

    final res = await notifier.createInvite(
      circleId: circleId,
      phoneE164: '+91$phone',
    );
    if (!context.mounted) return;
    if (res.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.error!)));
      return;
    }

    final body =
        'RoadSOS: Join my Family Circle. Tap to accept: ${res.shareUrl} (code ${res.code}). Expires in 7 days.';
    if (!kIsWeb && Platform.isAndroid) {
      final sent = await sendSmsDirectAndroid(phone, body);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sent ? 'Invite SMS sent' : 'Invite code: ${res.code}'),
        ),
      );
    } else {
      await Clipboard.setData(ClipboardData(text: body));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite link copied to clipboard')),
      );
    }
  }

  Future<void> _showRedeemDialog(
    BuildContext context,
    FamilyCircleService notifier,
  ) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join a circle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Invite code'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim().toUpperCase()),
            child: const Text('Join'),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty) return;
    final err = await notifier.redeemInvite(code);
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }
}
