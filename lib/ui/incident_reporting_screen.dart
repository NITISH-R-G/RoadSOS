import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_locale_controller.dart';
import '../services/roadsos_assistant_service.dart';
class IncidentReportingScreen extends ConsumerStatefulWidget {
  const IncidentReportingScreen({super.key});

  @override
  ConsumerState<IncidentReportingScreen> createState() =>
      _IncidentReportingScreenState();
}

class _IncidentReportingScreenState
    extends ConsumerState<IncidentReportingScreen> {
  final TextEditingController _voiceInputController = TextEditingController();
  bool _isCapturingImage = false;

  @override
  Widget build(BuildContext context) {
    final assistantState = ref.watch(roadsosAssistantProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.sceneIntelligenceTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
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
            _buildSceneCaptureCard(l10n),
            const SizedBox(height: 32),
            _buildSectionHeader('AI INTERVIEW: SITUATIONAL NUANCE'),
            const SizedBox(height: 12),
            _buildVoiceInterviewCard(assistantState, l10n),
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

  Widget _buildSceneCaptureCard(AppLocalizations l10n) {
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
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  l10n.incidentAssistantAnalyzed,
                  style: const TextStyle(
                      color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceInterviewCard(AssistantState assistant, AppLocalizations l10n) {
    final lang = ref.read(appLocaleProvider).languageCode;

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
            assistant.lastResponse.isEmpty ? l10n.incidentVoiceHint : assistant.lastResponse,
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
                    hintText: 'Speak or type…',
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
                  ref.read(roadsosAssistantProvider.notifier).getNextWitnessQuestion(
                        _voiceInputController.text,
                        languageCode: lang,
                      );
                  _voiceInputController.clear();
                },
                icon: assistant.isThinking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        assistant.history.join('\n'),
        style: const TextStyle(color: Colors.white70, height: 1.5),
      ),
    );
  }
}
