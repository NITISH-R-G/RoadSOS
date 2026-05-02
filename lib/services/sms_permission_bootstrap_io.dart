import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

import '../logging/app_log.dart';

/// Requests RECEIVE_SMS / SEND_SMS at cold start on Android.
///
/// telephony removed — deprecated and rejected by Google Play on Android 12+.
/// Uses permission_handler (already a dependency) instead.
Future<void> requestSmsPermissionEarlyIfAndroidImpl() async {
  if (kIsWeb || !Platform.isAndroid) return;
  try {
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      appLog.w(
        'SEND_SMS not granted at startup — allow SMS in Settings for unattended SOS.',
      );
    }
  } catch (e, st) {
    appLog.w(
      'Startup SMS permission request failed',
      error: e,
      stackTrace: st,
    );
  }
}
