import 'dart:io';

import 'package:telephony/telephony.dart';

import '../logging/app_log.dart';

Future<bool> sendSmsDirectAndroidImpl(String number, String message) async {
  if (!Platform.isAndroid) return false;

  try {
    final telephony = Telephony.instance;
    final granted = await telephony.requestSmsPermissions;
    if (granted != true) {
      appLog.w('SEND_SMS permission denied');
      return false;
    }
    await telephony.sendSms(to: number, message: message);
    return true;
  } catch (e, st) {
    appLog.w('Telephony send failed', e, st);
    return false;
  }
}
