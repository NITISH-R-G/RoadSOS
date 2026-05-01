import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:telephony/telephony.dart';

import '../logging/app_log.dart';

Future<void> requestSmsPermissionEarlyIfAndroidImpl() async {
  if (kIsWeb || !Platform.isAndroid) {
    return;
  }
  try {
    final granted = await Telephony.instance.requestSmsPermissions;
    if (granted != true) {
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
