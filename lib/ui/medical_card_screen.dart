import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_profile_service.dart';
import 'profile_editor_screen.dart';

class MedicalCardScreen extends ConsumerWidget {
  const MedicalCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    
    // Create a QR data string that responders can scan
    final qrData = Uri.encodeComponent(
      'ROADSOS_ID: ${profile.fullName} | Blood: ${profile.bloodType} | Allergies: ${profile.allergies} | Meds: ${profile.medications}'
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('EMERGENCY MEDICAL ID', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
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
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$qrData',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'SCAN FOR FULL MEDICAL HISTORY',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white54),
            ),
            
            const SizedBox(height: 48),
            _buildInfoRow(Icons.person, 'FULL NAME', profile.fullName.isEmpty ? 'NOT SET' : profile.fullName),
            _buildDivider(),
            _buildInfoRow(Icons.bloodtype, 'BLOOD TYPE', profile.bloodType),
            _buildDivider(),
            _buildInfoRow(Icons.warning, 'ALLERGIES', profile.allergies),
            _buildDivider(),
            _buildInfoRow(Icons.contact_phone, 'EMERGENCY CONTACT', profile.emergencyContact.isEmpty ? 'NOT SET' : profile.emergencyContact),
            
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generating High-Res QR Wallpaper...')),
                );
              },
              icon: const Icon(Icons.wallpaper),
              label: const Text('SAVE AS WALLPAPER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'TIP: Setting this as your lock screen can save minutes during rescue.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
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
