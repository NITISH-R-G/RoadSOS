import 'package:flutter/material.dart';
import 'offline_map_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('GLOBAL SETTINGS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('CONNECTIVITY'),
          _buildSettingItem(
            context,
            Icons.map,
            'Offline Maps',
            'Download and manage regional tiles',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineMapScreen())),
          ),
          _buildSettingItem(
            context,
            Icons.bluetooth,
            'Mesh Configuration',
            'Broadcast sensitivity and node visibility',
            () {},
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('LEGAL & DATA'),
          _buildSettingItem(
            context,
            Icons.description,
            'Black Box Report',
            'Export signed telemetry and triage logs',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating Signed Black Box PDF...')),
              );
            },
          ),
          _buildSettingItem(
            context,
            Icons.privacy_tip,
            'Data Privacy',
            'Manage local encryption and cloud sync',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: TextStyle(color: Colors.blue.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    );
  }
}
