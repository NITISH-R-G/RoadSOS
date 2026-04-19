import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isCriticalMode = false;
  bool _isLoading = false;
  String _aiResponse = '';
  File? _selectedImage;
  int _currentStep = 0;
  List<String> _steps = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _getFirstAidGuidance(String situation) async {
    setState(() {
      _isLoading = true;
      _aiResponse = '';
      _steps = [];
    });

    // Simulate AI response (replace with actual Gemma API call)
    await Future.delayed(const Duration(seconds: 2));

    List<String> mockSteps = [];
    bool isCritical = false;

    if (situation.toLowerCase().contains('cpr') ||
        situation.toLowerCase().contains('not breathing') ||
        situation.toLowerCase().contains('cardiac')) {
      isCritical = true;
      mockSteps = [
        'Call emergency services (108) immediately',
        'Place the person on their back on a firm surface',
        'Kneel beside the person and place heel of hand on center of chest',
        'Place other hand on top, interlace fingers',
        'Push hard and fast — 100-120 compressions per minute',
        'After 30 compressions, give 2 rescue breaths',
        'Continue until help arrives',
      ];
    } else if (situation.toLowerCase().contains('bleed') ||
        situation.toLowerCase().contains('cut') ||
        situation.toLowerCase().contains('wound')) {
      mockSteps = [
        'Stay calm and keep the person still',
        'Apply firm pressure with a clean cloth or bandage',
        'Do not remove the cloth — add more on top if needed',
        'Elevate the injured area above heart level if possible',
        'If bleeding does not stop in 10 minutes, call 108',
      ];
    } else if (situation.toLowerCase().contains('fracture') ||
        situation.toLowerCase().contains('broken') ||
        situation.toLowerCase().contains('bone')) {
      mockSteps = [
        'Do not try to straighten the injured area',
        'Immobilize the area using a splint or firm object',
        'Apply ice pack wrapped in cloth to reduce swelling',
        'Keep the person calm and still',
        'Call 108 or take to nearest hospital',
      ];
    } else {
      mockSteps = [
        'Keep the person calm and comfortable',
        'Check for any visible injuries',
        'Monitor breathing and pulse',
        'Do not give food or water',
        'Call 108 if condition worsens',
      ];
    }

    setState(() {
      _isLoading = false;
      _steps = mockSteps;
      _isCriticalMode = isCritical;
      _currentStep = 0;
    });
  }

  Widget _buildCriticalMode() {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🚨 CPR MODE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => setState(() => _isCriticalMode = false),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Step indicator
                    Text(
                      'Step ${_currentStep + 1} of ${_steps.length}',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    // 3D visual placeholder
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red.shade800,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30, width: 2),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.accessibility_new,
                              size: 100, color: Colors.white),
                          SizedBox(height: 10),
                          Text('3D Demonstration',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Current step text
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _steps[_currentStep],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (_currentStep > 0)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                            ),
                            onPressed: () =>
                                setState(() => _currentStep--),
                            child: const Text('← Previous'),
                          ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          onPressed: _currentStep < _steps.length - 1
                              ? () => setState(() => _currentStep++)
                              : null,
                          child: Text(
                              _currentStep < _steps.length - 1
                                  ? 'Next →'
                                  : 'Done ✓'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCriticalMode) return _buildCriticalMode();

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
            // Image preview
            if (_selectedImage != null)
              Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

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
                // Camera button
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),
                // Submit button
                IconButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _getFirstAidGuidance(_textController.text);
                    }
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

            // Steps list
            if (_steps.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'First Aid Steps:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isCriticalMode)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () =>
                                setState(() => _isCriticalMode = true),
                            child: const Text('Full Screen Mode',
                                style: TextStyle(color: Colors.white)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _steps.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _steps[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Empty state
            if (_steps.isEmpty && !_isLoading)
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
                        'e.g. "CPR", "bleeding wound", "broken bone"',
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