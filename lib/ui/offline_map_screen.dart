import 'package:flutter/material.dart';

class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  void _startDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() => _downloadProgress = i / 100.0);
    }

    if (!mounted) return;
    setState(() => _isDownloading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Region Cached Successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('OFFLINE MAPS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CACHED REGIONS',
              style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
            ),
            const SizedBox(height: 24),
            _buildRegionItem('San Francisco (Active)', '42 MB', true),
            const Divider(color: Colors.white10),
            _buildRegionItem('Greater Noida', '120 MB', false),
            const Spacer(),
            if (_isDownloading) ...[
              LinearProgressIndicator(value: _downloadProgress, backgroundColor: Colors.white10),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Downloading Current Region... ${( _downloadProgress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: const Icon(Icons.download),
                  label: const Text('DOWNLOAD CURRENT REGION (50KM)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionItem(String name, String size, bool isDownloaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(size, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          Icon(isDownloaded ? Icons.check_circle : Icons.cloud_download, color: isDownloaded ? Colors.green : Colors.white24),
        ],
      ),
    );
  }
}
