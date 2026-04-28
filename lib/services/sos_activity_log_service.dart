import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../logging/app_log.dart';
import '../models/sos_activity_record.dart';

const _prefsKey = 'sos_activity_history_v1';
const _maxRecords = 30;

/// Persists SOS dispatch summaries for trust UI and post-incident documentation (e.g. insurance).
class SosActivityLogService {
  SosActivityLogService._();
  static final SosActivityLogService instance = SosActivityLogService._();

  Future<List<SosActivityRecord>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SosActivityRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      appLog.w('Activity log parse failed', error: e, stackTrace: st);
      return [];
    }
  }

  Future<void> append(SosActivityRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await loadHistory();
      final next = [record, ...existing];
      final trimmed =
          next.length > _maxRecords ? next.sublist(0, _maxRecords) : next;
      await prefs.setString(
        _prefsKey,
        jsonEncode(trimmed.map((e) => e.toJson()).toList()),
      );
    } catch (e, st) {
      appLog.w('Activity log append failed', error: e, stackTrace: st);
    }
  }
}
