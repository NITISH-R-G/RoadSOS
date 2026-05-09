import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../services/first_aid_store.dart';
import '../services/gemma_assistant_service.dart';

// ── Design tokens ────────────────────────────────────────────────────────────
const _kBg = Color(0xFF060612);
const _kSurface = Color(0xFF0F0F24);
const _kCard = Color(0xFF141428);
const _kRed = Color(0xFFFF2D55);
const _kRedDim = Color(0x33FF2D55);
const _kCyan = Color(0xFF00E5FF);
const _kCyanDim = Color(0x2200E5FF);
const _kText = Color(0xFFEEEEF5);
const _kMuted = Color(0xFF6B6B8A);

// ── Mode enum ────────────────────────────────────────────────────────────────
enum _Mode { firstAid, witness }

class FirstAidScreen extends ConsumerStatefulWidget {
  const FirstAidScreen({super.key});

  @override
  ConsumerState<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends ConsumerState<FirstAidScreen>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  // State
  _Mode _mode = _Mode.firstAid;
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechAvailable = false;
  String _result = '';
  String _displayedResult = '';
  String? _error;
  List<String> _suggestions = [];

  // Witness mode
  final List<Map<String, String>> _witnessHistory = [];
  String _witnessQuestion = '';
  bool _witnessComplete = false;

  // Animations
  late AnimationController _pulseCtrl;
  late AnimationController _entryCtrl;
  late AnimationController _shimmerCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _entryAnim;
  late Animation<double> _shimmerAnim;

  // Typewriter
  Timer? _typewriterTimer;
  int _typewriterIndex = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _initSpeech();
    _initTts();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear));

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    _shimmerCtrl.dispose();
    _typewriterTimer?.cancel();
    if (_isListening) _speech.stop();
    _tts.stop();
    super.dispose();
  }

  // ── TTS ───────────────────────────────────────────────────────────────────

  Future<void> _initTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() => setState(() => _isSpeaking = true));
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _tts.setCancelHandler(() => setState(() => _isSpeaking = false));
  }

  Future<void> _toggleSpeak() async {
    if (_isSpeaking) {
      await _tts.stop();
    } else {
      final plain = _result
          .replaceAll(RegExp(r'\*+'), '')
          .replaceAll(RegExp(r'#+\s'), '')
          .replaceAll('---', '');
      await _tts.speak(plain);
    }
  }

  // ── Speech ────────────────────────────────────────────────────────────────

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onError: (_) => _stopListening(),
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') _stopListening();
      },
    );
    if (mounted) setState(() => _speechAvailable = ok);
  }

  Future<void> _toggleListening() async {
    _isListening ? await _stopListening() : await _startListening();
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;
    setState(() {
      _isListening = true;
      _textController.clear();
      _suggestions = [];
    });
    await _speech.listen(
      localeId: 'en_IN',
      listenMode: stt.ListenMode.dictation,
      onResult: (r) {
        if (!mounted) return;
        setState(() {
          _textController.text = r.recognizedWords;
          _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length));
        });
        if (r.finalResult && r.recognizedWords.trim().isNotEmpty) {
          _stopListening();
          _submit(r.recognizedWords);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  // ── Typewriter ────────────────────────────────────────────────────────────

  void _startTypewriter(String text) {
    _typewriterTimer?.cancel();
    _typewriterIndex = 0;
    setState(() => _displayedResult = '');
    _typewriterTimer =
        Timer.periodic(const Duration(milliseconds: 12), (t) {
      if (_typewriterIndex >= text.length) {
        t.cancel();
        return;
      }
      setState(() {
        _displayedResult = text.substring(0, ++_typewriterIndex);
      });
    });
  }

  // ── Text changed ──────────────────────────────────────────────────────────

  void _onTextChanged() async {
    final q = _textController.text;
    if (q.length < 2) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
      return;
    }
    final s = await FirstAidStore.getSuggestions(q);
    if (mounted) setState(() => _suggestions = s);
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit(String query) async {
    if (query.trim().isEmpty) return;
    _mode == _Mode.witness
        ? await _submitWitness(query)
        : await _lookupFirstAid(query);
  }

  Future<void> _lookupFirstAid(String query) async {
    setState(() {
      _isLoading = true;
      _result = '';
      _displayedResult = '';
      _error = null;
      _suggestions = [];
    });
    _entryCtrl.reset();

    try {
      final gemma = ref.read(gemmaAssistantProvider.notifier);
      String res;

      if (query.split(' ').length > 2) {
        final synthesis = await gemma.synthesizeTelemetry(
          maxG: 0,
          speedDelta: 0,
          impactVector: query,
        );
        final corpusRes = await FirstAidStore.getVerifiedAdvice(query);
        res =
            '**AI Assessment:** ${synthesis.replaceAll("Brief: ", "")}\n\n---\n\n$corpusRes';
      } else {
        res = await FirstAidStore.getVerifiedAdvice(query);
      }

      setState(() => _result = res);
      _startTypewriter(res);
      _entryCtrl.forward();
    } catch (e) {
      setState(
          () => _error = 'Could not load first-aid guidance on this device.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Witness mode ──────────────────────────────────────────────────────────

  void _startWitnessMode() {
    setState(() {
      _mode = _Mode.witness;
      _witnessHistory.clear();
      _witnessComplete = false;
      _result = '';
      _displayedResult = '';
      _error = null;
      _witnessQuestion =
          'What did you see happen? Describe the accident briefly.';
    });
  }

  Future<void> _submitWitness(String answer) async {
    if (answer.trim().isEmpty) return;
    setState(() {
      _witnessHistory.add({'q': _witnessQuestion, 'a': answer});
      _isLoading = true;
      _textController.clear();
      _suggestions = [];
    });

    try {
      final gemma = ref.read(gemmaAssistantProvider.notifier);
      if (_witnessHistory.length >= 3) {
        final summary = _witnessHistory
            .map((e) => 'Q: ${e['q']}\nA: ${e['a']}')
            .join('\n\n');
        setState(() {
          _result =
              '**Witness Report Summary**\n\n$summary\n\n---\n\n⚠️ Share this with emergency responders. Call **108** now.';
          _witnessComplete = true;
        });
        _startTypewriter(_result);
        _entryCtrl
          ..reset()
          ..forward();
      } else {
        final nextQ = await gemma.getNextWitnessQuestion(answer);
        setState(() => _witnessQuestion = nextQ);
      }
    } catch (_) {
      setState(
          () => _error = 'Could not reach AI. Please call 108 directly.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _exitWitnessMode() {
    setState(() {
      _mode = _Mode.firstAid;
      _witnessHistory.clear();
      _witnessComplete = false;
      _result = '';
      _displayedResult = '';
      _witnessQuestion = '';
      _error = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entryAnim,
          child: Column(
            children: [
              _buildHeader(),
              _buildModeToggle(),
              Expanded(
                child: _mode == _Mode.witness
                    ? _buildWitnessBody()
                    : _buildFirstAidBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: _kText, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FIRST AID',
                  style: GoogleFonts.syne(
                    color: _kRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                Text(
                  'AI Emergency Guide',
                  style: GoogleFonts.syne(
                    color: _kText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kCyanDim,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: _kCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: _kCyan, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  'Gemma 4',
                  style: GoogleFonts.dmSans(
                    color: _kCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mode toggle ───────────────────────────────────────────────────────────

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            _modeTab('First Aid', Icons.medical_services_outlined,
                _Mode.firstAid),
            _modeTab('Witness Guide',
                Icons.record_voice_over_outlined, _Mode.witness),
          ],
        ),
      ),
    );
  }

  Widget _modeTab(String label, IconData icon, _Mode mode) {
    final active = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            mode == _Mode.witness ? _startWitnessMode() : _exitWitnessMode(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active ? _kRed : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14, color: active ? Colors.white : _kMuted),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  color: active ? Colors.white : _kMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── First Aid body ────────────────────────────────────────────────────────

  Widget _buildFirstAidBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          _buildInputRow(),
          if (_suggestions.isNotEmpty) _buildSuggestions(),
          const SizedBox(height: 12),
          if (_isLoading) _buildLoadingState(),
          if (_error != null && !_isLoading) _buildError(),
          if (_result.isNotEmpty && !_isLoading)
            Expanded(child: _buildResult()),
          if (_result.isEmpty && _error == null && !_isLoading)
            Expanded(child: _buildEmptyState()),
        ],
      ),
    );
  }

  // ── Input row ─────────────────────────────────────────────────────────────

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isListening
                    ? _kRed.withValues(alpha: 0.6)
                    : Colors.white10,
              ),
              boxShadow: _isListening
                  ? [
                      BoxShadow(
                          color: _kRedDim,
                          blurRadius: 12,
                          spreadRadius: 2)
                    ]
                  : [],
            ),
            child: TextField(
              controller: _textController,
              style: GoogleFonts.dmSans(color: _kText, fontSize: 15),
              decoration: InputDecoration(
                hintText: _isListening
                    ? 'Listening...'
                    : 'Describe the injury or emergency...',
                hintStyle: GoogleFonts.dmSans(
                  color: _isListening
                      ? _kRed.withValues(alpha: 0.7)
                      : _kMuted,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                suffixIcon: _isListening
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                              4, (i) => _WaveBar(delay: i * 120)),
                        ),
                      )
                    : null,
              ),
              onSubmitted: _submit,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (_speechAvailable)
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: _isListening ? _pulseAnim.value : 1.0,
              child: child,
            ),
            child: _iconBtn(
              icon: _isListening ? Icons.mic : Icons.mic_none_outlined,
              bg: _isListening ? _kRed : _kSurface,
              border: _isListening ? _kRed : Colors.white12,
              onTap: _toggleListening,
            ),
          ),
        const SizedBox(width: 8),
        _iconBtn(
          icon: Icons.send_rounded,
          bg: _kRed,
          border: _kRed,
          onTap: () => _submit(_textController.text),
        ),
      ],
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color bg,
    required Color border,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Suggestions ───────────────────────────────────────────────────────────

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) =>
            const Divider(color: Colors.white10, height: 1),
        itemBuilder: (_, i) {
          final s = _suggestions[i];
          return ListTile(
            dense: true,
            leading:
                const Icon(Icons.search, color: _kMuted, size: 16),
            title: Text(s,
                style:
                    GoogleFonts.dmSans(color: _kText, fontSize: 13)),
            onTap: () {
              _textController.text = s;
              _submit(s);
            },
          );
        },
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _shimmerAnim,
              builder: (_, __) => ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [_kMuted, _kRed, _kCyan, _kMuted],
                  stops: [
                    (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
                    _shimmerAnim.value.clamp(0.0, 1.0),
                    (_shimmerAnim.value + 0.1).clamp(0.0, 1.0),
                    (_shimmerAnim.value + 0.4).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds),
                child: Text(
                  'ANALYZING...',
                  style: GoogleFonts.syne(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: _kRed,
                strokeWidth: 2,
                backgroundColor: _kRedDim,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kRedDim,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: _kRed.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: _kRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_error!,
                style:
                    GoogleFonts.dmSans(color: _kRed, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ── Result ────────────────────────────────────────────────────────────────

  Widget _buildResult() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.verified_outlined, color: _kCyan, size: 14),
            const SizedBox(width: 6),
            Text(
              'AI-VERIFIED GUIDANCE',
              style: GoogleFonts.syne(
                color: _kCyan,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _toggleSpeak,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isSpeaking ? _kRedDim : _kSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _isSpeaking
                          ? _kRed.withValues(alpha: 0.5)
                          : Colors.white10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isSpeaking
                          ? Icons.stop_rounded
                          : Icons.volume_up_outlined,
                      color: _isSpeaking ? _kRed : _kMuted,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isSpeaking ? 'Stop' : 'Read Aloud',
                      style: GoogleFonts.dmSans(
                        color: _isSpeaking ? _kRed : _kMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: _kRed.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: _kRed.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: MarkdownBody(
                data: _displayedResult,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.dmSans(
                      color: _kText, height: 1.7, fontSize: 14),
                  strong: GoogleFonts.dmSans(
                      color: _kRed,
                      fontWeight: FontWeight.w700),
                  listBullet: GoogleFonts.dmSans(
                      color: _kRed, fontSize: 14),
                  h1: GoogleFonts.syne(
                      color: _kText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                  h2: GoogleFonts.syne(
                      color: _kText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                  blockquoteDecoration: BoxDecoration(
                    color: _kCyanDim,
                    border: Border(
                        left:
                            BorderSide(color: _kCyan, width: 3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  blockquote: GoogleFonts.dmSans(
                      color: _kCyan, fontSize: 13),
                  horizontalRuleDecoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: Colors.white10, width: 1)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final chips = [
      ('Severe Bleeding', Icons.water_drop_outlined),
      ('Unconscious Person', Icons.person_off_outlined),
      ('Fracture', Icons.accessibility_new_outlined),
      ('Burns', Icons.local_fire_department_outlined),
      ('Choking', Icons.air_outlined),
      ('Heart Attack', Icons.favorite_border_outlined),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kRed.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                child!,
              ],
            ),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kRedDim,
                border: Border.all(
                    color: _kRed.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                  Icons.health_and_safety_outlined,
                  size: 36,
                  color: _kRed),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'What\'s the emergency?',
            style: GoogleFonts.syne(
              color: _kText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _speechAvailable
                ? 'Type or speak — Gemma 4 gives you\nstep-by-step verified guidance.'
                : 'Describe the injury — Gemma 4 gives you\nstep-by-step verified guidance.',
            style: GoogleFonts.dmSans(
                color: _kMuted, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _kRedDim,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: _kRed.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.call_outlined,
                    color: _kRed, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Call 108 for ambulance',
                  style: GoogleFonts.syne(
                    color: _kRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'COMMON SCENARIOS',
                style: GoogleFonts.syne(
                  color: _kMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map((c) => _buildScenarioChip(c.$1, c.$2))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildScenarioChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () => _submit(label),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _kMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: _kText.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Witness body ──────────────────────────────────────────────────────────

  Widget _buildWitnessBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          if (_witnessHistory.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _witnessHistory.length,
                itemBuilder: (_, i) {
                  final item = _witnessHistory[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _witnessChip(item['q']!, isQ: true),
                      const SizedBox(height: 6),
                      _witnessChip(item['a']!, isQ: false),
                      const SizedBox(height: 14),
                    ],
                  );
                },
              ),
            ),
          if (_witnessComplete && _result.isNotEmpty)
            Expanded(child: _buildResult()),
          if (!_witnessComplete) ...[
            if (_witnessHistory.isEmpty) const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kCyanDim,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _kCyan.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_outlined,
                          color: _kCyan, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'GEMMA 4 ASKS',
                        style: GoogleFonts.syne(
                          color: _kCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _witnessQuestion,
                    style: GoogleFonts.dmSans(
                        color: _kText, fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
            if (_witnessHistory.isEmpty) const Spacer(),
            const SizedBox(height: 12),
            // Step progress
            Row(
              children: List.generate(3, (i) {
                final done = i < _witnessHistory.length;
                return Expanded(
                  child: Container(
                    height: 3,
                    margin:
                        EdgeInsets.only(right: i < 2 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: done ? _kRed : _kSurface,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            _buildInputRow(),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(
                    color: _kRed, strokeWidth: 2),
              ),
          ],
        ],
      ),
    );
  }

  Widget _witnessChip(String text, {required bool isQ}) {
    return Align(
      alignment:
          isQ ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isQ ? _kCyanDim : _kRedDim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isQ
                ? _kCyan.withValues(alpha: 0.25)
                : _kRed.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.dmSans(
            color: isQ ? _kCyan : _kText,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

// ── Animated voice waveform bar ───────────────────────────────────────────────

class _WaveBar extends StatefulWidget {
  final int delay;
  const _WaveBar({required this.delay});

  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450 + widget.delay),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 3, end: 18).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 3,
        height: _anim.value,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(
          color: _kRed,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}