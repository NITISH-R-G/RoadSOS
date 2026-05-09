import 'package:flutter/material.dart';
<<<<<<< HEAD
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
=======
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/first_aid_store.dart';

class FirstAidScreen extends ConsumerStatefulWidget {
  const FirstAidScreen({super.key});

  @override
  ConsumerState<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends ConsumerState<FirstAidScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String _result = '';
  String? _error;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() async {
    final query = _textController.text;
    if (query.length < 2) {
      if (_suggestions.isNotEmpty) {
        setState(() => _suggestions = []);
      }
      return;
    }

    final suggestions = await FirstAidStore.getSuggestions(query);
    if (mounted) {
      setState(() {
        _suggestions = suggestions;
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
      });
    }
  }

<<<<<<< HEAD
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

=======
  Future<void> _lookupFirstAid(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _result = '';
      _error = null;
      _suggestions = []; // Clear suggestions on submit
    });

    try {
      final res = await FirstAidStore.getVerifiedAdvice(query);
      setState(() {
        _result = res;
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
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
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

=======
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
            // Input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
<<<<<<< HEAD
                      hintText: 'Describe the situation...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1A1A2E),
=======
                      hintText: 'Describe injury...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1A1A2E),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
<<<<<<< HEAD
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
=======
                    onSubmitted: (val) => _lookupFirstAid(val),
                  ),
                ),

                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _lookupFirstAid(_textController.text);
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
                  },
                  icon: const Icon(Icons.send, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(12),
<<<<<<< HEAD
=======
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
                  ),
                ),
              ],
            ),
<<<<<<< HEAD
            const SizedBox(height: 16),
=======

            // Suggestions List
            if (_suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4, left: 4, right: 80),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      dense: true,
                      title: Text(suggestion, style: const TextStyle(color: Colors.white70)),
                      onTap: () {
                        _textController.text = suggestion;
                        _lookupFirstAid(suggestion);
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

            // Loading
            if (_isLoading)
              const Center(
<<<<<<< HEAD
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
=======
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(color: Colors.red),
                ),
              ),

            if (_error != null && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_result.isNotEmpty && !_isLoading)
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medical_services_outlined, color: Colors.redAccent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Verified Medical Solutions',
                              style: TextStyle(
                                color: Colors.redAccent.withValues(alpha: 0.8),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 24),
                        MarkdownBody(
                          data: _result,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: Colors.white, height: 1.6, fontSize: 15),
                            strong: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            listBullet: const TextStyle(color: Colors.redAccent),
                            h1: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            h2: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (_result.isEmpty && _error == null && !_isLoading)
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
<<<<<<< HEAD
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
=======
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.health_and_safety,
                            size: 80, color: Colors.red),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'AI Injury Identification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Type an injury to get\nexact, verified first aid solutions.',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildChip('Severe Bleeding'),
                          _buildChip('Muscle Tear'),
                          _buildChip('Brain Injury'),
                          _buildChip('Sprains'),
                        ],
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
=======

  Widget _buildChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _lookupFirstAid(label),
      backgroundColor: const Color(0xFF1A1A2E),
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
}