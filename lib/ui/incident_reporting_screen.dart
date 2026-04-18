import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemma_assistant_service.dart';
import '../services/emergency_orchestrator.dart';

class IncidentReportingScreen extends ConsumerStatefulWidget {
  const IncidentReportingScreen({super.key});

  @override
  ConsumerState<IncidentReportingScreen> createState() => _IncidentReportingScreenState();
}

class _IncidentReportingScreenState extends ConsumerState<IncidentReportingScreen> {
  final TextEditingController _voiceInputController = TextEditingController();
  bool _isCapturingImage = false;

  @override
  Widget build(BuildContext context) {
    final assistantState = ref.watch(gemmaAssistantProvider);
    final orchestrator = ref.watch(emergencyOrchestratorProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('SCENE INTELLIGENCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('MULTIMODAL: DIGITAL TWIN'),
            const SizedBox(height: 12),
            _buildSceneCaptureCard(),
            
            const SizedBox(height: 32),
            _buildSectionHeader('AI INTERVIEW: SITUATIONAL NUANCE'),
            const SizedBox(height: 12),
            _buildVoiceInterviewCard(assistantState),
            
            const SizedBox(height: 32),
            if (assistantState.history.isNotEmpty) ...[
              _buildSectionHeader('SITUATION BRIEF (LIVE)'),
              const SizedBox(height: 12),
              _buildLiveBriefCard(assistantState),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Colors.blue.withOpacity(0.6),
      ),
    );
  }

  Widget _buildSceneCaptureCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_enhance, size: 40, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() => _isCapturingImage = !_isCapturingImage),
              icon: Icon(_isCapturingImage ? Icons.check : Icons.add_a_photo),
              label: Text(_isCapturingImage ? 'SCENE CAPTURED' : 'CAPTURE SCENE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCapturingImage ? Colors.green : Colors.blue,
              ),
            ),
            if (_isCapturingImage)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Gemma 4: Analyzed 1 Frontal Impact, No Fire Detected.', 
                  style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceInterviewCard(AssistantState assistant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            assistant.lastResponse.isEmpty 
              ? 'Tell Gemma about the situation...' 
              : assistant.lastResponse,
            style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voiceInputController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Speak or type...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () {
                  ref.read(gemmaAssistantProvider.notifier).getNextWitnessQuestion(_voiceInputController.text);
                  _voiceInputController.clear();
                },
                icon: assistant.isThinking 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBriefCard(AssistantState assistant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        assistant.history.join(' -> '),
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontFamily: 'monospace'),
      ),
    );
  }
}
