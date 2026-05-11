import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/user_profile_service.dart';
import 'profile_editor_screen.dart';
import 'package:roadsos/l10n/app_localizations.dart';

class MedicalCardScreen extends ConsumerWidget {
  const MedicalCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final l10n = AppLocalizations.of(context)!;
    
    // QR contains a short, offline-safe summary (no network dependency).
    final qrData =
        'ROADSOS_MEDICAL_V1|NAME:${profile.fullName}|BLOOD:${profile.bloodType}|ALLERGIES:${profile.allergies}|MEDS:${profile.medications}|CONTACT:${profile.emergencyContact}';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.medicalIdTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditorScreen())),
            icon: const Icon(Icons.edit, size: 20),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Dynamic QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
                gapless: false,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.scanForSummary,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white54),
            ),
            
            const SizedBox(height: 48),
            _buildInfoRow(Icons.person, l10n.fieldFullName, profile.fullName.isEmpty ? l10n.notSet : profile.fullName),
            _buildDivider(),
            _buildInfoRow(Icons.bloodtype, l10n.fieldBloodType, profile.bloodType),
            _buildDivider(),
            _buildInfoRow(Icons.warning, l10n.fieldAllergies, profile.allergies),
            _buildDivider(),
            _buildInfoRow(Icons.contact_phone, l10n.fieldPrimaryContact, profile.emergencyContact.isEmpty ? l10n.notSet : profile.emergencyContact),
            
            const Spacer(),
            Text(
              l10n.medicalCardTip,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 28),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withValues(alpha: 0.1), height: 1);
  }
}
