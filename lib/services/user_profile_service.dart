import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Column;
import '../database/app_database.dart';
import 'auth_service.dart';

class UserProfile {
  final String id;
  final String fullName;
  final String bloodType;
  final String allergies;
  final String medications;
  final String conditions;
  final String emergencyContact;
  final String? userId;

  UserProfile({
    this.id = '',
    this.fullName = '',
    this.bloodType = 'Unknown',
    this.allergies = 'None',
    this.medications = 'None',
    this.conditions = 'None',
    this.emergencyContact = '',
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'full_name': fullName,
      'blood_type': bloodType,
      'allergies': allergies,
      'medications': medications,
      'conditions': conditions,
      'emergency_contact': emergencyContact,
      if (userId != null) 'user_id': userId,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name'] ?? '',
      bloodType: map['blood_type'] ?? 'Unknown',
      allergies: map['allergies'] ?? 'None',
      medications: map['medications'] ?? 'None',
      conditions: map['conditions'] ?? 'None',
      emergencyContact: map['emergency_contact'] ?? '',
      userId: map['user_id'],
    );
  }
}

class UserProfileService extends StateNotifier<UserProfile> {
  UserProfileService(this.ref) : super(UserProfile()) {
    _init();
  }

  final Ref ref;
  StreamSubscription? _profileSubscription;

  void _init() {
    // Listen to auth changes to reload profile
    ref.listen<User?>(authServiceProvider, (previous, next) {
      _loadProfile();
    });
    
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _profileSubscription?.cancel();
    
    // Watch for profile changes in the local DB
    _profileSubscription = appDb.watch('SELECT * FROM profiles WHERE user_id = ?', [user.id]).listen((results) {
      if (results.isNotEmpty) {
        state = UserProfile.fromMap(results.first);
      } else {
        // If no profile exists yet, create a default one for this user
        state = UserProfile(userId: user.id);
      }
    });
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profileWithUser = UserProfile(
      id: state.id,
      fullName: newProfile.fullName,
      bloodType: newProfile.bloodType,
      allergies: newProfile.allergies,
      medications: newProfile.medications,
      conditions: newProfile.conditions,
      emergencyContact: newProfile.emergencyContact,
      userId: user.id,
    );

    // PowerSync will automatically sync this to Supabase
    await appDb.execute(
      '''
      INSERT OR REPLACE INTO profiles (id, full_name, blood_type, allergies, medications, conditions, emergency_contact, user_id)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        profileWithUser.id.isEmpty ? null : profileWithUser.id,
        profileWithUser.fullName,
        profileWithUser.bloodType,
        profileWithUser.allergies,
        profileWithUser.medications,
        profileWithUser.conditions,
        profileWithUser.emergencyContact,
        profileWithUser.userId,
      ],
    );
  }

  Future<String> getMedicalRiskBrief() async {
    if (state.bloodType == 'Unknown' && state.allergies == 'None') {
      return "Low specific medical risk detected.";
    }
    return 'Allergy alert: prioritize avoiding exposure to ${state.allergies}.';
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileService, UserProfile>((ref) {
  return UserProfileService(ref);
});
