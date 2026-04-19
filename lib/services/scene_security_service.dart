import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SceneSecurityService {
  /// Generates a 128-bit key based on rounded coordinates and hourly timestamp.
  /// This ensures 'Spatial Privacy' - only people in the same region at the same time can decrypt.
  static String generateSceneKey(double lat, double lng) {
    // Round to ~1.1km precision (2 decimal places)
    final String spatialHash = "${lat.toStringAsFixed(2)}:${lng.toStringAsFixed(2)}";
    final int hourStamp = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60 * 60);
    
    final bytes = utf8.encode("$spatialHash:$hourStamp");
    final digest = sha256.convert(bytes);
    
    return digest.toString().substring(0, 32); // Use first 32 chars for AES-256
  }

  static String encryptPayload(String data, String keyString) {
    final key = encrypt.Key.fromUtf8(keyString.substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  static String decryptPayload(String base64Data, String keyString) {
    try {
      final key = encrypt.Key.fromUtf8(keyString.substring(0, 32));
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      return encrypter.decrypt64(base64Data, iv: iv);
    } catch (e) {
      return "ENCRYPTED_DATA"; // Fallback if key mismatch
    }
  }
}
