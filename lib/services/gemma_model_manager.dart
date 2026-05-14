import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../logging/app_log.dart';

/// Manages the Gemma 4 E4B on-device model lifecycle:
///   • Check if model is present and valid
///   • Download from HuggingFace with resumable streaming progress
///   • Cancel in-progress download
///   • Delete to reclaim space
///
/// Model: gemma-4-e4b-it-Q4_K_M.gguf (~2.4 GB)
/// Source: https://huggingface.co/google/gemma-4-e4b-it-GGUF
///
/// IMPORTANT — gated model:
/// The user must accept Gemma terms on HuggingFace and provide a read token.
/// See [GemmaModelDownloadScreen] for the onboarding UI.
class GemmaModelManager {
  static const _modelFileName = 'gemma-4-e4b-it-Q4_K_M.gguf';

  /// Minimum sane file size: anything under 800 MB is definitely truncated.
  static const int expectedMinBytes = 800 * 1024 * 1024;

  /// Approximate full model size — used for progress UI when Content-Length is missing.
  static const int approximateFullBytes = 2_400_000_000;

  /// HuggingFace download URL.
  static const String modelDownloadUrl =
      'https://huggingface.co/google/gemma-4-e4b-it-GGUF/resolve/main/$_modelFileName';

  /// HuggingFace terms acceptance page (user must visit before downloading).
  static const String hfTermsUrl = 'https://huggingface.co/google/gemma-4-e4b-it-GGUF';

  /// HuggingFace token creation page.
  static const String hfTokenUrl = 'https://huggingface.co/settings/tokens';

  // ── Path ──────────────────────────────────────────────────────────────────

  /// Full path to the model file (may or may not exist).
  static Future<String> localModelPath() async {
    if (kIsWeb) return '';
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_modelFileName';
  }

  // ── Status queries ────────────────────────────────────────────────────────

  /// Returns true if model file exists and passes size sanity check.
  static Future<bool> isModelReady() async {
    if (kIsWeb) return false;
    try {
      final file = File(await localModelPath());
      if (!file.existsSync()) return false;
      return file.lengthSync() >= expectedMinBytes;
    } on Object catch (_) {
      return false;
    }
  }

  /// Returns bytes of local model file (0 if not present).
  static Future<int> localModelBytes() async {
    try {
      final file = File(await localModelPath());
      return file.existsSync() ? file.lengthSync() : 0;
    } on Object catch (_) {
      return 0;
    }
  }

  /// Returns bytes of in-progress download temp file (for resume display).
  static Future<int> downloadedSoFar() async {
    try {
      final tmp = File('${await localModelPath()}.download');
      return tmp.existsSync() ? tmp.lengthSync() : 0;
    } on Object catch (_) {
      return 0;
    }
  }

  // ── Download ──────────────────────────────────────────────────────────────

  /// Downloads the Gemma 4 E4B model from HuggingFace.
  ///
  /// [hfToken] — HuggingFace read token (required — model is gated)
  /// [onProgress] — called with (bytesReceived, totalBytes) — totalBytes may be
  ///   [approximateFullBytes] if the server omits Content-Length.
  /// [cancelToken] — call [CancelToken.cancel] to abort; partial file is kept
  ///   so the next call resumes from where it left off.
  ///
  /// Throws [GemmaDownloadException] on auth failure or unexpected HTTP error.
  static Future<void> downloadModel({
    required String hfToken,
    required void Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    final path = await localModelPath();
    final tmpPath = '$path.download';
    final tmpFile = File(tmpPath);

    // Resume: check how much is already on disk.
    int alreadyHave = 0;
    if (tmpFile.existsSync()) {
      alreadyHave = tmpFile.lengthSync();
      appLog.i('[GemmaModel] Resuming download from ${(alreadyHave / 1e6).round()} MB');
    }

    final headers = <String, String>{
      'Authorization': 'Bearer ${hfToken.trim()}',
      'User-Agent': 'RoadSOS/1.0 (Gemma 4 Good Hackathon)',
      if (alreadyHave > 0) 'Range': 'bytes=$alreadyHave-',
    };

    final client = http.Client();

    try {
      final request = http.Request('GET', Uri.parse(modelDownloadUrl));
      request.headers.addAll(headers);
      final response = await client.send(request);

      final ok = response.statusCode == 200 || response.statusCode == 206;
      if (!ok) {
        final body = await response.stream.bytesToString();
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw GemmaDownloadException(
            'Access denied (HTTP ${response.statusCode}).\n\n'
            '1. Accept Gemma 4 terms at: $hfTermsUrl\n'
            '2. Generate a read token at: $hfTokenUrl\n'
            '3. Paste the token here and try again.',
            statusCode: response.statusCode,
          );
        }
        throw GemmaDownloadException(
          'Server returned HTTP ${response.statusCode}: ${body.substring(0, body.length.clamp(0, 200))}',
          statusCode: response.statusCode,
        );
      }

      // Content-Length is relative to range start; add already-downloaded bytes.
      final contentLength = response.contentLength ?? -1;
      final totalBytes = contentLength > 0
          ? alreadyHave + contentLength
          : approximateFullBytes; // fallback for progress UI

      final sink = tmpFile.openWrite(
        mode: alreadyHave > 0 ? FileMode.append : FileMode.write,
      );
      int received = alreadyHave;

      try {
        await for (final chunk in response.stream) {
          if (cancelToken?.isCancelled ?? false) {
            appLog.i('[GemmaModel] Download cancelled — partial file kept for resume');
            await sink.flush();
            await sink.close();
            return;
          }
          sink.add(chunk);
          received += chunk.length;
          onProgress(received, totalBytes);
        }
      } finally {
        await sink.flush();
        await sink.close();
      }

      if (cancelToken?.isCancelled ?? false) return;

      // Sanity check before promoting.
      final finalSize = tmpFile.lengthSync();
      if (finalSize < expectedMinBytes) {
        throw GemmaDownloadException(
          'Downloaded file too small (${(finalSize / 1e6).round()} MB — expected ≥ '
          '${(expectedMinBytes / 1e6).round()} MB). The download may be incomplete.',
        );
      }

      // Atomic rename: .download → final path.
      await tmpFile.rename(path);
      appLog.i('[GemmaModel] ✓ Download complete — ${(finalSize / 1e6).round()} MB at $path');
    } finally {
      client.close();
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  /// Deletes model and any partial download to reclaim storage.
  static Future<void> deleteModel() async {
    final path = await localModelPath();
    for (final p in [path, '$path.download']) {
      final f = File(p);
      if (f.existsSync()) {
        await f.delete();
        appLog.i('[GemmaModel] Deleted $p');
      }
    }
  }
}

/// Pass to [GemmaModelManager.downloadModel] to cancel an in-progress download.
/// The partial file is preserved for resuming on the next attempt.
class CancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

/// Thrown when [GemmaModelManager.downloadModel] encounters a fatal error.
class GemmaDownloadException implements Exception {
  final String message;
  final int? statusCode;

  const GemmaDownloadException(this.message, {this.statusCode});

  @override
  String toString() => 'GemmaDownloadException: $message';
}
