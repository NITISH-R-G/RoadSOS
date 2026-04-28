import 'dart:async';
import 'dart:convert';

import 'package:country_codes/country_codes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../logging/app_log.dart';
import 'india_emergency_routing.dart';
import 'sms_direct_send.dart';
import 'sms_dispatch_outcome.dart';

/// Routes SOS SMS by platform and region:
/// - **Android**: [SEND_SMS] + Telephony API direct send when no India relay succeeds.
/// - **iOS**: POST to [SMS_DISPATCH_URL] (e.g. Twilio via Supabase Edge Function).
/// - **India**: Prefer [INDIA_SOS_DISPATCH_URL], optional [INDIA_ERSS_API_URL] (MHA/CDAC enrollment).
class EmergencySmsDispatchService {
  EmergencySmsDispatchService._();

  static String emergencyNumberForLocale() {
    final countryCode = CountryCodes.getDeviceLocale()?.countryCode;
    if (countryCode == 'US' || countryCode == 'CA') return '911';
    return '112';
  }

  /// Single entry for mesh / orchestrator SOS path.
  static Future<SmsDispatchOutcome> dispatch({
    required String payload,
    double? lat,
    double? lng,
  }) async {
    if (kIsWeb) {
      return const SmsDispatchOutcome(
        pathConfirmedSent: false,
        detail: 'SMS unavailable on web — install the app on a phone.',
      );
    }

    final cc = CountryCodes.getDeviceLocale()?.countryCode;
    final body = _composeBody(payload, lat, lng);
    final emergencyNum = emergencyNumberForLocale();

    if (lat != null && lng != null && coordinatesRoughlyInIndia(lat, lng)) {
      final erssUrl = dotenv.env['INDIA_ERSS_API_URL']?.trim();
      if (erssUrl != null && erssUrl.isNotEmpty) {
        unawaited(_postIndiaErssIngest(erssUrl, payload, lat, lng));
      }
    }

    // India — server-side relay when enrolled (MoHA / state ERSS integrations).
    if (cc == 'IN') {
      final indiaUrl = dotenv.env['INDIA_SOS_DISPATCH_URL']?.trim();
      final route = lat != null && lng != null && coordinatesRoughlyInIndia(lat, lng)
          ? resolveIndiaEmergencyRoute(lat, lng)
          : null;
      if (indiaUrl != null && indiaUrl.isNotEmpty) {
        final ok = await _postJson(
          indiaUrl,
          <String, dynamic>{
            'channel': 'india_112',
            'country_code': 'IN',
            'destination': '112',
            'payload': payload,
            'latitude': lat,
            'longitude': lng,
            'body': body,
            if (route != null) ...<String, dynamic>{
              'state_code': route.stateCode,
              'state_name': route.stateName,
              'ambulance_number': route.ambulanceNumber,
              'police_number': route.policeNumber,
              'fire_number': route.fireNumber,
            },
          },
        );
        if (ok) {
          appLog.d('SMS India relay accepted');
          return SmsDispatchOutcome(
            pathConfirmedSent: true,
            detail: 'Emergency relay accepted request (112 route) ✓',
          );
        }
        appLog.w('SMS India relay failed; falling back to device SMS where allowed');
      }
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _dispatchIosBackend(cc, payload, lat, lng, body, emergencyNum);
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _dispatchAndroid(body, emergencyNum);
    }

    appLog.w('Unsupported platform for automatic SMS');
    return const SmsDispatchOutcome(
      pathConfirmedSent: false,
      detail: 'Automatic SMS not available on this device.',
    );
  }

  static Future<SmsDispatchOutcome> _dispatchIosBackend(
    String? cc,
    String payload,
    double? lat,
    double? lng,
    String body,
    String emergencyNum,
  ) async {
    final url = dotenv.env['SMS_DISPATCH_URL']?.trim();
    if (url == null || url.isEmpty) {
      appLog.w(
        'iOS: set SMS_DISPATCH_URL for server-side SMS (Twilio/Edge). '
        'Cannot auto-send SMS on iOS.',
      );
      return SmsDispatchOutcome(
        pathConfirmedSent: false,
        detail:
            'SMS did not send automatically on iOS — configure SMS_DISPATCH_URL or dial $emergencyNum manually.',
      );
    }
    final ok = await _postJson(
      url,
      <String, dynamic>{
        'channel': 'twilio_backend',
        'destination': emergencyNum,
        'country_code': cc,
        'payload': payload,
        'latitude': lat,
        'longitude': lng,
        'body': body,
      },
    );
    if (ok) {
      appLog.d('iOS backend SMS dispatch sent');
      return SmsDispatchOutcome(
        pathConfirmedSent: true,
        detail: 'SMS relay reported sent to $emergencyNum ✓',
      );
    }
    appLog.w('iOS backend SMS dispatch failed');
    return const SmsDispatchOutcome(
      pathConfirmedSent: false,
      detail: 'SMS relay request failed — check network and SMS_DISPATCH_URL.',
    );
  }

  static Future<SmsDispatchOutcome> _dispatchAndroid(String body, String number) async {
    final ok = await sendSmsDirectAndroid(number, body);
    if (ok) {
      appLog.d('Android direct SMS send');
      return SmsDispatchOutcome(
        pathConfirmedSent: true,
        detail: 'Sent SMS to $number ✓',
      );
    }
    return SmsDispatchOutcome(
      pathConfirmedSent: false,
      detail: 'SMS not sent — allow SMS permission or open the Messages app.',
    );
  }

  static String _composeBody(String payload, double? lat, double? lng) {
    IndiaEmergencyRoute? route;
    if (lat != null && lng != null && coordinatesRoughlyInIndia(lat, lng)) {
      route = resolveIndiaEmergencyRoute(lat, lng);
    }
    final loc = (lat != null && lng != null)
        ? 'LOC ${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)} '
        : '';
    final st = route != null ? 'STATE ${route.stateCode} ${route.stateName} ' : '';
    const maxPayload = 220;
    final p =
        payload.length > maxPayload ? '${payload.substring(0, maxPayload)}…' : payload;
    return 'RoadSOS $st$loc$p';
  }

  static Future<void> _postIndiaErssIngest(
    String url,
    String payload,
    double lat,
    double lng,
  ) async {
    final route = resolveIndiaEmergencyRoute(lat, lng);
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      final key = dotenv.env['INDIA_ERSS_API_KEY']?.trim();
      if (key != null && key.isNotEmpty) {
        headers['Authorization'] = 'Bearer $key';
      }
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(<String, dynamic>{
              'schema': 'roadsos.india_erss.v1',
              'latitude': lat,
              'longitude': lng,
              'payload': payload,
              if (route != null) ...<String, dynamic>{
                'state_code': route.stateCode,
                'state_name': route.stateName,
                'ambulance_number': route.ambulanceNumber,
              },
            }),
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        appLog.d('India ERSS ingest accepted');
      } else {
        appLog.w('India ERSS ingest HTTP ${response.statusCode}');
      }
    } catch (e, st) {
      appLog.w('India ERSS ingest failed', e, st);
    }
  }

  static Future<bool> _postJson(String url, Map<String, dynamic> body) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      final secret = dotenv.env['SMS_DISPATCH_ANON_KEY']?.trim();
      if (secret != null && secret.isNotEmpty) {
        headers['Authorization'] = 'Bearer $secret';
      }
      final response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, st) {
      appLog.w('SMS HTTP dispatch error', e, st);
      return false;
    }
  }
}
