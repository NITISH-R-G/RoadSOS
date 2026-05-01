import 'package:flutter/material.dart';

import '../services/first_aid_store.dart';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String _result = '';
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _normalize(String raw) {
    // Corpus results are plain text with simple markdown-like markers.
    return raw.replaceAll('**', '').trim();
  }

  Future<void> _lookupFirstAid(String query) async {
    setState(() {
      _isLoading = true;
      _result = '';
      _error = null;
    });

    try {
      final res = await FirstAidStore.getVerifiedAdvice(query);
      setState(() {
        _result = _normalize(res);
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load first-aid guidance on this device.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: const Text(
          '🩺 First Aid Guide',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Describe the situation...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1A1A2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Submit button
                IconButton(
                  onPressed: () {
                    _lookupFirstAid(_textController.text);
                  },
                  icon: const Icon(Icons.send, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Loading
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),

            if (_error != null && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),

            if (_result.isNotEmpty && !_isLoading)
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _result,
                      style: const TextStyle(color: Colors.white70, height: 1.35),
                    ),
                  ),
                ),
              ),

            // Empty state
            if (_result.isEmpty && _error == null && !_isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.health_and_safety,
                          size: 80, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Describe the emergency situation\nto get instant first aid guidance',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'e.g. "CPR", "bleeding wound", "broken bone", "burns"',
                        style: TextStyle(color: Colors.white30, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}