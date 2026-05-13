import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;

import '../database/app_database.dart';

/// Evidence-based first-aid text bundled in assets and indexed with SQLite FTS5
/// on the **same** PowerSync database as the rest of the app (no separate sqflite DB).
///
/// **Not a substitute for professional training or emergency services.** Always call local EMS.
class _FirstAidEntry {
  final String id;
  final String title;
  final String body;
  final String tags;
  final String source;

  // Pre-computed lowercase fields for fast searching without allocations
  final String titleLower;
  final String tagsLower;
  final String searchHaystackLower;

  _FirstAidEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.source,
  }) : titleLower = title.toLowerCase(),
       tagsLower = tags.toLowerCase(),
       searchHaystackLower = '$title $body $tags'.toLowerCase();
}

class FirstAidRepository {
  FirstAidRepository._();

  static final FirstAidRepository instance = FirstAidRepository._();

  static const String assetPath = 'assets/first_aid/corpus.json';

  List<_FirstAidEntry>? _corpusRows;
  bool _ftsReady = false;

  static const String medicalDisclaimer =
      'This guidance summarizes generic first-aid teaching aligned with international '
      'resuscitation consensus (verify against current WHO/ILCOR/AHA guidance and local protocols). '
      'It is not medical advice. In India dial 108 (or 112 ERSS) for ambulance / coordinated emergency '
      'response where available — follow dispatcher instructions.';

  Future<void> ensureInitialized() async {
    if (_corpusRows == null) {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw) as List<dynamic>;
      _corpusRows = decoded.cast<Map<String, dynamic>>().map((row) {
        return _FirstAidEntry(
          id: row['id'] as String? ?? '',
          title: row['title'] as String? ?? '',
          body: row['body'] as String? ?? '',
          tags: row['tags'] as String? ?? '',
          source: row['source'] as String? ?? '',
        );
      }).toList();
    }
    if (kIsWeb || !isDatabaseInitialized || _ftsReady) {
      return;
    }
    await appDb.execute('''
CREATE VIRTUAL TABLE IF NOT EXISTS first_aid_fts USING fts5(
  title,
  body,
  tags,
  source
);
''');

    final countRows = await appDb.getAll(
      'SELECT COUNT(*) AS c FROM first_aid_fts',
    );
    final count = (countRows.first['c'] as num?)?.toInt() ?? 0;

    if (count == 0 && _corpusRows!.isNotEmpty) {
      for (final row in _corpusRows!) {
        await appDb.execute(
          '''
          INSERT INTO first_aid_fts (title, body, tags, source)
          VALUES (?, ?, ?, ?)
          ''',
          [row.title, row.body, row.tags, row.source],
        );
      }
    }
    _ftsReady = true;
  }

  /// Full-text search; returns formatted guidance with title, body, source, disclaimer.
  Future<String> lookup(String query) async {
    await ensureInitialized();
    final q = query.trim();
    if (q.isEmpty) {
      return _pickGeneralOrFirst();
    }

    if (kIsWeb || !isDatabaseInitialized || !_ftsReady) {
      return _lookupTokenScore(q);
    }
    return _lookupFts(q);
  }

  /// Returns a list of titles for autocomplete suggestions.
  Future<List<String>> getSuggestions(String query) async {
    await ensureInitialized();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    final suggestions = <String>[];
    for (final row in _corpusRows!) {
      // ⚡ Bolt Optimization: Use pre-computed lowercase fields
      if (row.titleLower.contains(q) || row.tagsLower.contains(q)) {
        suggestions.add(row.title);
      }
      if (suggestions.length >= 6) break;
    }
    return suggestions;
  }

  String _lookupTokenScore(String query) {
    final tokens = _tokenize(query);
    if (tokens.isEmpty) {
      return _pickGeneralOrFirst();
    }

    var bestScore = -1;
    _FirstAidEntry? best;
    for (final row in _corpusRows!) {
      // ⚡ Bolt Optimization: Use pre-computed lowercase search haystack
      var score = 0;
      for (final t in tokens) {
        if (row.searchHaystackLower.contains(t)) score += 3;
      }
      if (score > bestScore) {
        bestScore = score;
        best = row;
      }
    }

    if (best == null || bestScore <= 0) {
      return _pickGeneralOrFirst();
    }

    return _formatResult(
      title: best.title,
      body: best.body,
      source: best.source,
    );
  }

  Future<String> _lookupFts(String query) async {
    final ftsQuery = _buildFtsQuery(query);
    List<Map<String, Object?>> rows;

    try {
      rows = await appDb.getAll(
        '''
        SELECT title, body, source
        FROM first_aid_fts
        WHERE first_aid_fts MATCH ?
        LIMIT 4
        ''',
        [ftsQuery],
      );
    } catch (e) {
      rows = [];
    }

    if (rows.isEmpty) {
      try {
        rows = await appDb.getAll(
          '''
          SELECT title, body, source
          FROM first_aid_fts
          WHERE first_aid_fts MATCH ?
          LIMIT 3
          ''',
          ['general OR trauma OR emergency OR india OR 108'],
        );
      } catch (e) {
        rows = [];
      }
    }

    if (rows.isEmpty) {
      return _pickGeneralOrFirst();
    }

    final buf = StringBuffer();
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (i > 0) buf.writeln('\n---\n');
      buf.writeln(
        _formatResult(
          title: r['title'] as String? ?? '',
          body: r['body'] as String? ?? '',
          source: r['source'] as String? ?? '',
          includeDisclaimer: false,
        ),
      );
    }
    buf.writeln('\n---\n$medicalDisclaimer');
    return buf.toString();
  }

  String _pickGeneralOrFirst() {
    _FirstAidEntry? row;
    for (final r in _corpusRows!) {
      if (r.id == 'general-road-emergency-india') {
        row = r;
        break;
      }
    }
    row ??= _corpusRows!.first;
    return _formatResult(title: row.title, body: row.body, source: row.source);
  }

  List<String> _tokenize(String q) {
    return q
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 1)
        .toList();
  }

  /// FTS5 MATCH: OR token groups; strip FTS specials.
  String _buildFtsQuery(String raw) {
    final tokens = _tokenize(raw);
    if (tokens.isEmpty) return 'general OR emergency OR trauma';
    final escaped = tokens.map(_escapeFtsToken).where((t) => t.isNotEmpty);
    return escaped.join(' OR ');
  }

  String _escapeFtsToken(String t) {
    final safe = t.replaceAll('"', '');
    if (safe.isEmpty) return '';
    return '"$safe"';
  }

  String _formatResult({
    required String title,
    required String body,
    required String source,
    bool includeDisclaimer = true,
  }) {
    final buf = StringBuffer()
      ..writeln('**$title**')
      ..writeln()
      ..writeln(body.trim())
      ..writeln()
      ..writeln('Source: $source');
    if (includeDisclaimer) {
      buf.writeln('\n---\n$medicalDisclaimer');
    }
    return buf.toString();
  }
}

/// Call from [main] after [initializeDatabase] so FTS lives on [appDb].
Future<void> initializeFirstAidRepository() async {
  await FirstAidRepository.instance.ensureInitialized();
}
