import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;

import '../database/app_database.dart';

/// Evidence-based first-aid text bundled in assets and indexed with SQLite FTS5.
///
/// Improvements over v1:
/// - In-memory LRU result cache (last 20 queries — instant repeat lookups)
/// - Synonym expansion: "heart attack" → also searches "cardiac arrest", etc.
/// - Weighted token scoring: title match = 10pts, tags = 6pts, body = 2pts
/// - Severity extraction from corpus `severity` field (1–5)
/// - `getTopScenarios()` pulls real entries from corpus for the UI chips
/// - Better FTS fallback chain with AND → OR → general
///
/// **Not a substitute for professional training or emergency services.**
class FirstAidRepository {
  FirstAidRepository._();
  static final FirstAidRepository instance = FirstAidRepository._();

  static const String _assetPath = 'assets/first_aid/corpus.json';
  static const int _cacheMax = 20;

  List<Map<String, dynamic>>? _corpusRows;
  bool _ftsReady = false;

  // LRU cache: query → formatted result
  final _cache = <String, String>{};
  final _cacheOrder = <String>[];

  // ── Synonym map ───────────────────────────────────────────────────────────
  static const Map<String, List<String>> _synonyms = {
    'heart attack': ['cardiac arrest', 'myocardial infarction', 'chest pain'],
    'cardiac arrest': ['heart attack', 'chest pain', 'heart failure'],
    'stroke': ['brain attack', 'paralysis', 'facial droop'],
    'choking': ['airway obstruction', 'heimlich', 'foreign body'],
    'bleeding': ['hemorrhage', 'laceration', 'wound', 'cut'],
    'fracture': ['broken bone', 'break', 'crack'],
    'burn': ['scald', 'thermal injury', 'fire injury'],
    'unconscious': ['unresponsive', 'fainted', 'collapse', 'passed out'],
    'seizure': ['epilepsy', 'fit', 'convulsion'],
    'shock': ['hypovolemic', 'pale cold clammy', 'low blood pressure'],
    'sprain': ['twisted ankle', 'ligament', 'joint injury'],
    'head injury': ['traumatic brain injury', 'tbi', 'concussion'],
    'drowning': ['near drowning', 'water rescue', 'submersion'],
    'snake bite': ['envenomation', 'venom', 'snakebite'],
    'allergic': ['anaphylaxis', 'anaphylactic', 'allergy reaction'],
  };

  static const String medicalDisclaimer =
      'This guidance summarizes generic first-aid teaching aligned with '
      'international resuscitation consensus (verify against current '
      'WHO/ILCOR/AHA guidance and local protocols). It is not medical advice. '
      'In India dial **108** (or 112 ERSS) for ambulance — follow dispatcher '
      'instructions.';

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> ensureInitialized() async {
    await _loadCorpus();
    await _initFts();
  }

  Future<void> _loadCorpus() async {
    if (_corpusRows != null) return;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    _corpusRows = decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _initFts() async {
    if (kIsWeb || !isDatabaseInitialized || _ftsReady) return;

    await appDb.execute('''
CREATE VIRTUAL TABLE IF NOT EXISTS first_aid_fts USING fts5(
  title, body, tags, source
);
''');

    final countRows =
        await appDb.getAll('SELECT COUNT(*) AS c FROM first_aid_fts');
    final count = (countRows.first['c'] as num?)?.toInt() ?? 0;

    if (count == 0 && _corpusRows!.isNotEmpty) {
      for (final row in _corpusRows!) {
        await appDb.execute(
          'INSERT INTO first_aid_fts (title, body, tags, source) VALUES (?, ?, ?, ?)',
          [
            row['title'] as String? ?? '',
            row['body'] as String? ?? '',
            row['tags'] as String? ?? '',
            row['source'] as String? ?? '',
          ],
        );
      }
    }
    _ftsReady = true;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Full-text search with caching, synonym expansion, and severity.
  Future<String> lookup(String query) async {
    await ensureInitialized();
    final q = query.trim();
    if (q.isEmpty) return _pickGeneralOrFirst();

    // Cache hit
    final cacheKey = q.toLowerCase();
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    String result;
    if (kIsWeb || !isDatabaseInitialized || !_ftsReady) {
      result = _lookupWeightedScore(q);
    } else {
      result = await _lookupFts(q);
    }

    _cacheWrite(cacheKey, result);
    return result;
  }

  /// Returns cached result immediately (null if not cached).
  String? getCachedResult(String query) => _cache[query.toLowerCase().trim()];

  /// Autocomplete suggestions — title + tag matches, ranked by title-first.
  Future<List<String>> getSuggestions(String query) async {
    await ensureInitialized();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    final titleMatches = <String>[];
    final tagMatches = <String>[];

    for (final row in _corpusRows!) {
      final title = (row['title'] as String? ?? '').toLowerCase();
      final tags = (row['tags'] as String? ?? '').toLowerCase();
      final display = row['title'] as String? ?? '';

      if (title.contains(q)) {
        titleMatches.add(display);
      } else if (tags.contains(q)) {
        tagMatches.add(display);
      }
      if (titleMatches.length + tagMatches.length >= 8) break;
    }

    return [...titleMatches, ...tagMatches].take(6).toList();
  }

  /// Returns severity level 1–5 for a query (1=minor, 5=critical).
  /// Extracted from corpus `severity` field; defaults to 3.
  Future<int> getSeverity(String query) async {
    await ensureInitialized();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return 3;

    final tokens = _tokenize(q);
    var bestScore = -1;
    var bestSeverity = 3;

    for (final row in _corpusRows!) {
      final haystack =
          '${row['title']} ${row['tags']}'.toLowerCase();
      var score = 0;
      for (final t in tokens) {
        if (haystack.contains(t)) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        bestSeverity = (row['severity'] as num?)?.toInt() ?? 3;
      }
    }
    return bestSeverity;
  }

  /// Returns top N corpus entries suitable for UI quick-pick chips.
  /// Prefers entries with high severity or tagged as 'common'.
  Future<List<Map<String, String>>> getTopScenarios({int limit = 6}) async {
    await ensureInitialized();
    final results = <Map<String, String>>[];

    // Priority 1: tagged 'common' or 'road'
    for (final row in _corpusRows!) {
      final tags = (row['tags'] as String? ?? '').toLowerCase();
      if (tags.contains('common') || tags.contains('road')) {
        results.add({
          'title': row['title'] as String? ?? '',
          'id': row['id'] as String? ?? '',
          'severity': '${(row['severity'] as num?)?.toInt() ?? 3}',
        });
      }
      if (results.length >= limit) break;
    }

    // Fill remaining with high-severity entries
    if (results.length < limit) {
      for (final row in _corpusRows!) {
        final severity = (row['severity'] as num?)?.toInt() ?? 3;
        final title = row['title'] as String? ?? '';
        if (severity >= 4 && !results.any((r) => r['title'] == title)) {
          results.add({
            'title': title,
            'id': row['id'] as String? ?? '',
            'severity': '$severity',
          });
        }
        if (results.length >= limit) break;
      }
    }

    // Fallback: just take first N
    if (results.isEmpty) {
      for (final row in _corpusRows!.take(limit)) {
        results.add({
          'title': row['title'] as String? ?? '',
          'id': row['id'] as String? ?? '',
          'severity': '${(row['severity'] as num?)?.toInt() ?? 3}',
        });
      }
    }

    return results.take(limit).toList();
  }

  // ── Weighted token scoring (web / no FTS) ─────────────────────────────────

  String _lookupWeightedScore(String query) {
    final tokens = _expandWithSynonyms(_tokenize(query));
    if (tokens.isEmpty) return _pickGeneralOrFirst();

    var bestScore = -1;
    Map<String, dynamic>? best;

    for (final row in _corpusRows!) {
      final title = (row['title'] as String? ?? '').toLowerCase();
      final body = (row['body'] as String? ?? '').toLowerCase();
      final tags = (row['tags'] as String? ?? '').toLowerCase();

      var score = 0;
      for (final t in tokens) {
        if (title.contains(t)) score += 10; // title match is strongest
        if (tags.contains(t)) score += 6;   // tags second
        if (body.contains(t)) score += 2;   // body weakest
      }

      if (score > bestScore) {
        bestScore = score;
        best = row;
      }
    }

    if (best == null || bestScore <= 0) return _pickGeneralOrFirst();

    return _formatResult(
      title: best['title'] as String? ?? 'Topic',
      body: best['body'] as String? ?? '',
      source: best['source'] as String? ?? '',
      severity: (best['severity'] as num?)?.toInt(),
    );
  }

  // ── FTS5 lookup ───────────────────────────────────────────────────────────

  Future<String> _lookupFts(String query) async {
    final tokens = _expandWithSynonyms(_tokenize(query));

    List<Map<String, Object?>> rows = [];

    // Pass 1: AND query (precise)
    if (tokens.length > 1) {
      final andQuery = tokens.map(_escapeFtsToken).join(' AND ');
      try {
        rows = await appDb.getAll(
          'SELECT title, body, source FROM first_aid_fts WHERE first_aid_fts MATCH ? LIMIT 2',
          [andQuery],
        );
      } catch (_) {}
    }

    // Pass 2: OR query (broader)
    if (rows.isEmpty) {
      final orQuery = tokens.map(_escapeFtsToken).join(' OR ');
      try {
        rows = await appDb.getAll(
          'SELECT title, body, source FROM first_aid_fts WHERE first_aid_fts MATCH ? LIMIT 4',
          [orQuery],
        );
      } catch (_) {}
    }

    // Pass 3: general fallback
    if (rows.isEmpty) {
      try {
        rows = await appDb.getAll(
          'SELECT title, body, source FROM first_aid_fts WHERE first_aid_fts MATCH ? LIMIT 3',
          ['"general" OR "trauma" OR "emergency" OR "india" OR "108"'],
        );
      } catch (_) {}
    }

    if (rows.isEmpty) return _pickGeneralOrFirst();

    final buf = StringBuffer();
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (i > 0) buf.writeln('\n---\n');
      buf.writeln(_formatResult(
        title: r['title'] as String? ?? '',
        body: r['body'] as String? ?? '',
        source: r['source'] as String? ?? '',
        includeDisclaimer: false,
      ));
    }
    buf.writeln('\n---\n$medicalDisclaimer');
    return buf.toString();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _pickGeneralOrFirst() {
    Map<String, dynamic>? row;
    for (final r in _corpusRows!) {
      if ((r['id'] as String?) == 'general-road-emergency-india') {
        row = r;
        break;
      }
    }
    row ??= _corpusRows!.first;
    return _formatResult(
      title: row['title'] as String? ?? '',
      body: row['body'] as String? ?? '',
      source: row['source'] as String? ?? '',
      severity: (row['severity'] as num?)?.toInt(),
    );
  }

  List<String> _tokenize(String q) {
    return q
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 1)
        .toList();
  }

  /// Expand tokens with synonyms to improve recall.
  List<String> _expandWithSynonyms(List<String> tokens) {
    final expanded = <String>{...tokens};
    final queryLower = tokens.join(' ');

    for (final entry in _synonyms.entries) {
      if (queryLower.contains(entry.key)) {
        for (final syn in entry.value) {
          expanded.addAll(_tokenize(syn));
        }
      }
    }
    return expanded.toList();
  }

  String _escapeFtsToken(String t) {
    final safe = t.replaceAll('"', '');
    return safe.isEmpty ? '' : '"$safe"';
  }

  String _buildFtsQuery(String raw) {
    final tokens = _expandWithSynonyms(_tokenize(raw));
    if (tokens.isEmpty) return '"general" OR "emergency" OR "trauma"';
    return tokens.map(_escapeFtsToken).where((t) => t.isNotEmpty).join(' OR ');
  }

  String _formatResult({
    required String title,
    required String body,
    required String source,
    int? severity,
    bool includeDisclaimer = true,
  }) {
    final severityLabel = severity != null ? _severityLabel(severity) : null;

    final buf = StringBuffer();
    if (severityLabel != null) buf.writeln('$severityLabel\n');
    buf
      ..writeln('**$title**')
      ..writeln()
      ..writeln(body.trim())
      ..writeln()
      ..writeln('*Source: $source*');
    if (includeDisclaimer) {
      buf.writeln('\n---\n$medicalDisclaimer');
    }
    return buf.toString();
  }

  String _severityLabel(int level) {
    switch (level) {
      case 5:
        return '🔴 **CRITICAL — Call 108 immediately**';
      case 4:
        return '🟠 **SEVERE — Seek emergency care now**';
      case 3:
        return '🟡 **MODERATE — Monitor and treat promptly**';
      case 2:
        return '🟢 **MINOR — First aid typically sufficient**';
      default:
        return '⚪ **Severity: Unknown**';
    }
  }

  // ── LRU cache ─────────────────────────────────────────────────────────────

  void _cacheWrite(String key, String value) {
    if (_cache.containsKey(key)) {
      _cacheOrder.remove(key);
    } else if (_cache.length >= _cacheMax) {
      final oldest = _cacheOrder.removeAt(0);
      _cache.remove(oldest);
    }
    _cache[key] = value;
    _cacheOrder.add(key);
  }

  /// Clear the result cache (e.g. after corpus update).
  void clearCache() {
    _cache.clear();
    _cacheOrder.clear();
  }
}

/// Call from [main] after [initializeDatabase] so FTS lives on [appDb].
Future<void> initializeFirstAidRepository() async {
  await FirstAidRepository.instance.ensureInitialized();
}