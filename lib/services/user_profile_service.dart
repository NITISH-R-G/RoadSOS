import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfile {
  final String fullName;
  final String bloodType;
  final String allergies;
  final String medications;
  final String conditions;
  final List<String> emergencyContacts;

  UserProfile({
    this.fullName = '',
    this.bloodType = 'Unknown',
    this.allergies = 'None',
    this.medications = 'None',
    this.conditions = 'None',
    this.emergencyContacts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'bloodType': bloodType,
      'allergies': allergies,
      'medications': medications,
      'conditions': conditions,
      'emergencyContacts': emergencyContacts,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      fullName: map['fullName'] ?? '',
      bloodType: map['bloodType'] ?? 'Unknown',
      allergies: map['allergies'] ?? 'None',
      medications: map['medications'] ?? 'None',
      conditions: map['conditions'] ?? 'None',
      emergencyContacts: (map['emergencyContacts'] as List<dynamic>?)?.cast<String>() ?? 
          (map['emergencyContact'] != null ? [map['emergencyContact']] : []),
    );
  }

  String toJson() => json.encode(toMap());
}

class UserProfileService extends StateNotifier<UserProfile> {
  UserProfileService() : super(UserProfile()) {
    _loadProfile();
  }

  static const _storage = FlutterSecureStorage();
  static const _key = 'roadsos.user_profile.v1';

  Future<void> _loadProfile() async {
    final data = await _storage.read(key: _key);
    if (data != null) {
      try {
        state = UserProfile.fromMap(json.decode(data));
      } catch (e) {
        // Fallback for old format
      }
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    state = newProfile;
    await _storage.write(key: _key, value: newProfile.toJson());
  }

  Future<String> getMedicalRiskBrief() async {
    if (state.bloodType == 'Unknown' && state.allergies == 'None') {
      return "Low specific medical risk detected.";
    }
    return 'Allergy alert: prioritize avoiding exposure to ${state.allergies}.';
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileService, UserProfile>((ref) {
  return UserProfileService();
});
