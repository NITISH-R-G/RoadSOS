import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String fullName;
  final String bloodGroup;
  final String allergies;
  final String emergencyContact;

  UserProfile({
    this.fullName = 'Unknown',
    this.bloodGroup = 'UNK',
    this.allergies = 'None',
    this.emergencyContact = '',
  });

  Map<String, dynamic> toJson() => {
    'name': fullName,
    'blood': bloodGroup,
    'allergies': allergies,
    'ice': emergencyContact,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    fullName: json['name'] ?? 'Unknown',
    bloodGroup: json['blood'] ?? 'UNK',
    allergies: json['allergies'] ?? 'None',
    emergencyContact: json['ice'] ?? '',
  );

  /// Compact string for SOS payload (≤ 20 bytes)
  String toCompactString() {
    return 'BG:$bloodGroup|ICE:${emergencyContact.substring(emergencyContact.length.clamp(0, 5))}';
  }
}

class UserProfileService {
  static const String _key = 'user_profile';

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(profile.toJson()));
  }

  Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return UserProfile();
    return UserProfile.fromJson(json.decode(data));
  }
}
