import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
=======
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

class UserProfile {
  final String fullName;
  final String bloodType;
  final String allergies;
  final String medications;
  final String conditions;
  final String emergencyContact;

  UserProfile({
    this.fullName = '',
    this.bloodType = 'Unknown',
    this.allergies = 'None',
    this.medications = 'None',
    this.conditions = 'None',
    this.emergencyContact = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'bloodType': bloodType,
      'allergies': allergies,
      'medications': medications,
      'conditions': conditions,
      'emergencyContact': emergencyContact,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      fullName: map['fullName'] ?? '',
      bloodType: map['bloodType'] ?? 'Unknown',
      allergies: map['allergies'] ?? 'None',
      medications: map['medications'] ?? 'None',
      conditions: map['conditions'] ?? 'None',
      emergencyContact: map['emergencyContact'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
}

class UserProfileService extends StateNotifier<UserProfile> {
  UserProfileService() : super(UserProfile()) {
    _loadProfile();
  }

<<<<<<< HEAD
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_profile');
=======
  static const _storage = FlutterSecureStorage();
  static const _key = 'roadsos.user_profile.v1';

  Future<void> _loadProfile() async {
    final data = await _storage.read(key: _key);
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    if (data != null) {
      state = UserProfile.fromMap(json.decode(data));
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    state = newProfile;
<<<<<<< HEAD
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', newProfile.toJson());
  }

  /// Gemma Risk Analysis: Evaluates the profile for emergency considerations.
=======
    await _storage.write(key: _key, value: newProfile.toJson());
  }

  /// Risk hint for allergies (deterministic — no on-device LLM).
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
  Future<String> getMedicalRiskBrief() async {
    // Prompt: "Analyze this profile for emergency responders: $state"
    if (state.bloodType == 'Unknown' && state.allergies == 'None') {
      return "Low specific medical risk detected.";
    }
<<<<<<< HEAD
    return "Gemma: Prioritizing allergy protocols for ${state.allergies}.";
=======
    return 'Allergy alert: prioritize avoiding exposure to ${state.allergies}.';
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileService, UserProfile>((ref) {
  return UserProfileService();
});
