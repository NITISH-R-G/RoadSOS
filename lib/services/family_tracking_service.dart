import 'dart:io';
import 'dart:math' as dart_math;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import 'ai_triage_service.dart';
import 'location_service.dart';
import 'sms_direct_send.dart';
import 'user_profile_service.dart';
import '../logging/app_log.dart';

final familyTrackingServiceProvider = Provider<FamilyTrackingService>((ref) {
  return FamilyTrackingService(ref);
});

/// Registers an ephemeral tracking token in Supabase and optionally SMSes the profile contact.
///
/// Browser opens `GET /functions/v1/family-track?t=<token>` (deploy Edge Function + migration).
class FamilyTrackingService {
  FamilyTrackingService(this._ref);

  final Ref _ref;

  /// Best-effort digit sequence for SMS (India-friendly).
  static String? normalizePhoneDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return null;
    if (digits.length == 10) return digits;
    if (digits.length == 11 && digits.startsWith('0')) {
      return digits.substring(1);
    }
    if (digits.length >= 12 && digits.startsWith('91')) {
      return digits.substring(digits.length - 10);
    }
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  Future<({bool ok, String detail, String? token})> registerAndNotifyContact({
    required String incidentId,
    required LocationFix location,
    required TriageResult triage,
  }) async {
    final profile = _ref.read(userProfileProvider);
    final contacts = profile.emergencyContacts
        .map((e) => normalizePhoneDigits(e))
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();

    Future<({bool ok, String detail, String? token})> fallbackOffline() async {
      final name = profile.fullName.trim().isEmpty
          ? 'RoadSOS user'
          : profile.fullName.trim();
      final body =
          'RoadSOS: $name needs help. LOC: (${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}). '
          'Services: ${triage.requiredServices.join(", ")}. Emergency mode active.';

      if (contacts.isEmpty) {
        return (
          ok: false,
          detail: 'Offline fallback ready but no contacts configured.',
          token: null,
        );
      }

      if (!kIsWeb && Platform.isAndroid) {
        final results = await Future.wait(
          contacts.map((p) => sendSmsDirectAndroid(p, body)),
        );
        final ok = results.any((e) => e);
        return (
          ok: ok,
          detail: ok
              ? 'Offline SOS SMS sent to family ✓'
              : 'Offline SOS SMS failed (permission?).',
          token: null,
        );
      }
      return (
        ok: false,
        detail: 'Offline: share coordinates manually: $body',
        token: null,
      );
    }

    if (kIsWeb || !isSupabaseSdkInitialized) {
      appLog.w(
        'Family link needs Supabase on mobile — falling back to offline SMS.',
      );
      return fallbackOffline();
    }

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      appLog.w('No auth session — falling back to offline SMS.');
      return fallbackOffline();
    }

    final baseUrl = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    if (baseUrl.isEmpty) {
      appLog.w('SUPABASE_URL not configured — falling back to offline SMS.');
      return fallbackOffline();
    }

    final r = dart_math.Random.secure();
    String hex(int bytes) => List.generate(bytes, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    final token = '${hex(4)}-${hex(2)}-4${hex(2).substring(1)}-${['8','9','a','b'][r.nextInt(4)]}${hex(2).substring(1)}-${hex(6)}';
    final rawSummary =
        '${triage.functionCall} · sev ${triage.severityLevel} · ${triage.compressedPayload}';
    final triageSummary = rawSummary.length > 1200
        ? '${rawSummary.substring(0, 1197)}…'
        : rawSummary;

    final expiresAt = DateTime.now().toUtc().add(const Duration(hours: 24));

    try {
      await client.from('incident_live_links').insert({
        'user_id': user.id,
        'incident_id': incidentId,
        'token': token,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy_m': location.accuracy,
        'triage_summary': triageSummary,
        'severity': triage.severityLevel,
        'expires_at': expiresAt.toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e, st) {
      appLog.w(
        'incident_live_links insert failed — falling back to offline SMS.',
        error: e,
        stackTrace: st,
      );
      return fallbackOffline();
    }

    if (contacts.isEmpty) {
      return (
        ok: true,
        detail:
            'Family link active — add phone numbers in Medical profile to auto-SMS.',
        token: token,
      );
    }

    final root = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final trackingUrl =
        '$root/functions/v1/family-track?t=${Uri.encodeComponent(token)}';

    final trimmedName = profile.fullName.trim();
    final name = trimmedName.isEmpty ? 'RoadSOS user' : trimmedName;
    final body =
        'RoadSOS: $name needs help. Live location & triage: $trackingUrl '
        '(updates if app online; expires 24h).';

    if (!kIsWeb && Platform.isAndroid) {
      final results = await Future.wait(
        contacts.map((phone) => sendSmsDirectAndroid(phone, body)),
      );
      final successCount = results.where((e) => e).length;

      if (successCount > 0) {
        return (
          ok: true,
          detail: 'Family link sent SMS to $successCount contact(s) ✓',
          token: token,
        );
      }
      return (
        ok: true,
        detail:
            'Link ready — SMS failed for all ${contacts.length} contacts (permission?).',
        token: token,
      );
    }

    return (
      ok: true,
      detail:
          'Family link ready — iOS cannot auto-SMS contact; share: $trackingUrl',
      token: token,
    );
  }

  /// Updates an existing tracking link with a new location fix.
  Future<void> updateLiveLocation({
    required String token,
    required LocationFix location,
  }) async {
    if (kIsWeb || !isSupabaseSdkInitialized) return;

    try {
      final client = Supabase.instance.client;
      await client
          .from('incident_live_links')
          .update({
            'latitude': location.latitude,
            'longitude': location.longitude,
            'accuracy_m': location.accuracy,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('token', token);
    } catch (e) {
      appLog.w('Failed to update live tracking location', error: e);
    }
  }
}
