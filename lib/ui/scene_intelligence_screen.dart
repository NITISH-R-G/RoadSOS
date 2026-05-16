import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

/// SceneIntelligenceScreen
///
/// Allows responder to:
///   1. Capture or pick a photo of the crash scene
///   2. AI analyzes the image and returns structured assessment
///   3. Works with cloud AI — graceful offline fallback message

class SceneIntelligenceScreen extends StatefulWidget {
  const SceneIntelligenceScreen({super.key});

  @override
  State<SceneIntelligenceScreen> createState() =>
      _SceneIntelligenceScreenState();
}

class _SceneIntelligenceScreenState extends State<SceneIntelligenceScreen> {
  File? _capturedImage;
  bool _isAnalyzing = false;
  SceneAnalysisResult? _result;
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();

  // ── Capture from camera ──
  Future<void> _captureFromCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() {
        _capturedImage = File(photo.path);
        _result = null;
        _errorMessage = null;
      });
      await _analyzeScene();
    }
  }

  // ── Pick from gallery ──
  Future<void> _pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() {
        _capturedImage = File(photo.path);
        _result = null;
        _errorMessage = null;
      });
      await _analyzeScene();
    }
  }

  // ── Analyze scene with AI ──
  Future<void> _analyzeScene() async {
    if (_capturedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final bytes = await _capturedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Gemini Vision API call
      const apiKey = String.fromEnvironment('GEMINI_API_KEY');
      const url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

      final response = await http
          .post(
            Uri.parse('$url?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {
                      'text':
                          '''You are an emergency road accident AI assistant. Analyze this crash scene image and respond ONLY in this exact JSON format:
{
  "severity": "CRITICAL | HIGH | MODERATE | LOW",
  "vehiclesInvolved": ["list of vehicle types seen"],
  "visibleInjuries": "description of visible injuries or NONE VISIBLE",
  "immediateRisks": ["list of immediate dangers like fire, fuel leak, unstable vehicle"],
  "recommendedActions": ["list of 3-5 immediate actions for responder"],
  "callServices": ["108 - Ambulance", "101 - Fire Brigade", "100 - Police"] 
}
Only include services that are actually needed based on the scene.''',
                    },
                    {
                      'inline_data': {
                        'mime_type': 'image/jpeg',
                        'data': base64Image,
                      },
                    },
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        // Clean JSON from response
        final jsonStr = text
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        final parsed = jsonDecode(jsonStr);
        setState(() {
          _result = SceneAnalysisResult.fromJson(parsed);
          _isAnalyzing = false;
        });
      } else {
        throw Exception('API error ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage =
            'AI analysis unavailable offline. Follow standard rescue procedures:\n\n'
            '1. Ensure scene safety\n'
            '2. Call 108 for ambulance\n'
            '3. Check victim consciousness\n'
            '4. Apply first aid while waiting';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scene Intelligence',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue, size: 14),
                SizedBox(width: 4),
                Text(
                  'AI ANALYSIS',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 20),

            // Image preview or capture buttons
            _capturedImage == null
                ? _buildCaptureButtons()
                : _buildImagePreview(),

            const SizedBox(height: 20),

            // Analysis result or loading
            if (_isAnalyzing) _buildLoadingCard(),
            if (_errorMessage != null) _buildOfflineFallback(),
            if (_result != null) _buildAnalysisResult(),
          ],
        ),
      ),
    );
  }

  // ── Header banner ──
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900.withOpacity(0.6), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.document_scanner, color: Colors.blue, size: 22),
              SizedBox(width: 10),
              Text(
                'CRASH SCENE ANALYZER',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Capture the crash scene. AI will assess severity, risks, and recommend immediate actions.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Capture buttons ──
  Widget _buildCaptureButtons() {
    return Column(
      children: [
        // Camera button
        GestureDetector(
          onTap: _captureFromCamera,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, color: Colors.blue, size: 52),
                SizedBox(height: 12),
                Text(
                  'TAP TO CAPTURE SCENE',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Point camera at the crash scene',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Gallery option
        TextButton.icon(
          onPressed: _pickFromGallery,
          icon: const Icon(
            Icons.photo_library,
            color: Colors.white38,
            size: 18,
          ),
          label: const Text(
            'Choose from gallery instead',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ── Image preview ──
  Widget _buildImagePreview() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _capturedImage!,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _captureFromCamera,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retake'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white54,
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _analyzeScene,
                icon: const Icon(Icons.psychology, size: 16),
                label: const Text('Re-analyze'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Loading card ──
  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'AI ANALYZING SCENE...',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Assessing severity, risks, and required services',
            style: TextStyle(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Offline fallback ──
  Widget _buildOfflineFallback() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'OFFLINE — STANDARD PROCEDURE',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Full analysis result ──
  Widget _buildAnalysisResult() {
    final r = _result!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Severity badge
        _buildSeverityCard(r.severity),
        const SizedBox(height: 12),

        // Vehicles involved
        if (r.vehiclesInvolved.isNotEmpty) ...[
          _buildInfoCard(
            title: '🚗  VEHICLES INVOLVED',
            color: Colors.white,
            content: r.vehiclesInvolved.join(', '),
          ),
          const SizedBox(height: 12),
        ],

        // Visible injuries
        _buildInfoCard(
          title: '🩺  VISIBLE INJURIES',
          color: Colors.red,
          content: r.visibleInjuries,
        ),
        const SizedBox(height: 12),

        // Immediate risks
        if (r.immediateRisks.isNotEmpty) ...[
          _buildListCard(
            title: '⚠️  IMMEDIATE RISKS',
            color: Colors.red,
            items: r.immediateRisks,
          ),
          const SizedBox(height: 12),
        ],

        // Recommended actions
        _buildListCard(
          title: '👐  RECOMMENDED ACTIONS',
          color: Colors.orange,
          items: r.recommendedActions,
          numbered: true,
        ),
        const SizedBox(height: 12),

        // Call services
        _buildCallServicesCard(r.callServices),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSeverityCard(String severity) {
    final color = switch (severity) {
      'CRITICAL' => Colors.red,
      'HIGH' => Colors.orange,
      'MODERATE' => Colors.yellow,
      _ => Colors.green,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.emergency, color: color, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SCENE SEVERITY',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              Text(
                severity,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Color color,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required Color color,
    required List<String> items,
    bool numbered = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          ...items.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    numbered ? '${e.key + 1}. ' : '• ',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallServicesCard(List<String> services) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📞  CALL NOW',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          ...services.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 16),
                  label: Text(
                    s,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class SceneAnalysisResult {
  final String severity;
  final List<String> vehiclesInvolved;
  final String visibleInjuries;
  final List<String> immediateRisks;
  final List<String> recommendedActions;
  final List<String> callServices;

  SceneAnalysisResult({
    required this.severity,
    required this.vehiclesInvolved,
    required this.visibleInjuries,
    required this.immediateRisks,
    required this.recommendedActions,
    required this.callServices,
  });

  factory SceneAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SceneAnalysisResult(
      severity: json['severity'] ?? 'UNKNOWN',
      vehiclesInvolved: List<String>.from(json['vehiclesInvolved'] ?? []),
      visibleInjuries: json['visibleInjuries'] ?? 'Unable to assess',
      immediateRisks: List<String>.from(json['immediateRisks'] ?? []),
      recommendedActions: List<String>.from(json['recommendedActions'] ?? []),
      callServices: List<String>.from(json['callServices'] ?? []),
    );
  }
}
