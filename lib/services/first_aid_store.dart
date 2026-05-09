import 'first_aid_repository.dart';

/// Public façade over [FirstAidRepository].
///
/// All UI code should go through this store — never call the repository directly.
/// This keeps the API stable even if the repository internals change.
class FirstAidStore {
  FirstAidStore._();

  // ── Core lookup ───────────────────────────────────────────────────────────

  /// Returns full formatted first-aid guidance for [query].
  /// Results are cached in-memory — repeated calls are instant.
  static Future<String> getVerifiedAdvice(String query) =>
      FirstAidRepository.instance.lookup(query);

  /// Returns cached result synchronously if available, null otherwise.
  /// Use this to pre-populate the UI before an async call completes.
  static String? getCachedAdvice(String query) =>
      FirstAidRepository.instance.getCachedResult(query);

  // ── Autocomplete ──────────────────────────────────────────────────────────

  /// Returns up to 6 autocomplete suggestions for [query].
  /// Title matches are ranked above tag matches.
  static Future<List<String>> getSuggestions(String query) =>
      FirstAidRepository.instance.getSuggestions(query);

  // ── Severity ──────────────────────────────────────────────────────────────

  /// Returns severity level 1–5 for [query].
  /// 1 = minor, 5 = critical. Defaults to 3 (moderate) if unknown.
  /// Use to drive UI colour coding or urgency banners.
  static Future<int> getSeverity(String query) =>
      FirstAidRepository.instance.getSeverity(query);

  // ── Scenario chips ────────────────────────────────────────────────────────

  /// Returns top scenario entries from the corpus for quick-pick UI chips.
  /// Each entry has 'title', 'id', and 'severity' keys.
  /// Falls back to hardcoded defaults if corpus isn't loaded yet.
  static Future<List<Map<String, String>>> getTopScenarios({int limit = 6}) =>
      FirstAidRepository.instance.getTopScenarios(limit: limit);

  // ── Cache control ─────────────────────────────────────────────────────────

  /// Clears the in-memory result cache.
  /// Call if corpus data is refreshed at runtime.
  static void clearCache() => FirstAidRepository.instance.clearCache();

  // ── Init ──────────────────────────────────────────────────────────────────

  /// Warms up the repository (loads corpus + FTS index).
  /// Safe to call multiple times — no-op after first call.
  static Future<void> initialize() =>
      FirstAidRepository.instance.ensureInitialized();
}