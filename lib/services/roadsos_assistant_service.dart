import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../logging/app_log.dart';

<<<<<<< HEAD
/// Cloud-first assistant (Gemini Flash). **No on-device LLM** — safe for low-RAM phones.
=======
/// Cloud-first assistant powered by Gemma 4 27B via Supabase Edge Function.
/// Falls back to structured question scripts when cloud is unavailable.
>>>>>>> origin/main
class AssistantState {
  final String lastResponse;
  final bool isThinking;
  final List<String> history;
<<<<<<< HEAD
  final String sceneContext; // e.g., "vehicle_collision", "pedestrian_hit", "rollover"
  final Set<String> askedQuestions; // Track questions to avoid repetition
  final int questionIndex; // Current position in interview flow
  final bool interviewComplete; // Flag to indicate if interview is finished
  final List<GuidanceStep> guidanceSteps; // Action steps to take after interview
  final bool showingGuidance; // Show guidance phase instead of questions
=======
  final String sceneContext;
  final Set<String> askedQuestions;
  final int questionIndex;
  final bool interviewComplete;
  final List<GuidanceStep> guidanceSteps;
  final bool showingGuidance;
>>>>>>> origin/main

  AssistantState({
    this.lastResponse = '',
    this.isThinking = false,
    this.history = const [],
    this.sceneContext = 'unknown',
    this.askedQuestions = const {},
    this.questionIndex = 0,
    this.interviewComplete = false,
    this.guidanceSteps = const [],
    this.showingGuidance = false,
  });

  AssistantState copyWith({
    String? lastResponse,
    bool? isThinking,
    List<String>? history,
    String? sceneContext,
    Set<String>? askedQuestions,
    int? questionIndex,
    bool? interviewComplete,
    List<GuidanceStep>? guidanceSteps,
    bool? showingGuidance,
  }) {
    return AssistantState(
      lastResponse: lastResponse ?? this.lastResponse,
      isThinking: isThinking ?? this.isThinking,
      history: history ?? this.history,
      sceneContext: sceneContext ?? this.sceneContext,
      askedQuestions: askedQuestions ?? this.askedQuestions,
      questionIndex: questionIndex ?? this.questionIndex,
      interviewComplete: interviewComplete ?? this.interviewComplete,
      guidanceSteps: guidanceSteps ?? this.guidanceSteps,
      showingGuidance: showingGuidance ?? this.showingGuidance,
    );
  }
}

<<<<<<< HEAD
/// Represents a single action step in the guidance
=======
>>>>>>> origin/main
class GuidanceStep {
  final int stepNumber;
  final String title;
  final String description;
<<<<<<< HEAD
  final String icon; // emoji or icon name
=======
  final String icon;
>>>>>>> origin/main
  final bool completed;

  GuidanceStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    this.completed = false,
  });

  GuidanceStep copyWith({bool? completed}) {
    return GuidanceStep(
      stepNumber: stepNumber,
      title: title,
      description: description,
      icon: icon,
      completed: completed ?? this.completed,
    );
  }
}

class RoadSosAssistantService extends StateNotifier<AssistantState> {
  RoadSosAssistantService() : super(AssistantState());

<<<<<<< HEAD
  /// Scene-specific question sequences (English)
=======
>>>>>>> origin/main
  static const Map<String, List<String>> _sceneQuestionsEn = {
    'vehicle_collision': [
      'How many vehicles are involved in this collision?',
      'Are there any trapped or injured occupants in the vehicles?',
      'Are there any leaked fluids or smoke visible near the vehicles?',
      'Is the scene safe for responders? Are traffic/pedestrians at risk?',
      'Can you describe the impact damage and vehicle positions?',
    ],
    'pedestrian_hit': [
      'Is the pedestrian conscious and responsive?',
      'Are there any visible injuries or bleeding?',
      'Was the pedestrian hit by a vehicle? Describe the incident.',
      'Is the pedestrian able to move or complaining of pain?',
      'What is the pedestrian\'s approximate age and current location?',
    ],
    'rollover': [
      'How many occupants are in the vehicle?',
      'Are any occupants trapped inside the vehicle?',
      'Is the fuel leaking or is there smoke/fire risk?',
      'Are occupants conscious and can they move?',
      'What is the vehicle\'s current stable position?',
    ],
    'fire_hazard': [
      'Is there active fire or heavy smoke from the vehicle?',
      'Are occupants still inside the vehicle?',
      'Is the fire spreading to nearby vehicles or structures?',
      'Have you alerted nearby people to evacuate?',
      'What is the estimated size and intensity of the fire?',
    ],
    'unknown': [
      'What type of incident is this? (collision, medical, fire, etc.)',
      'How many people are affected?',
      'Are there any visible injuries or emergencies?',
      'Is the scene safe for responders to approach?',
      'What is the current status and any immediate dangers?',
    ],
  };

<<<<<<< HEAD
  /// Scene-specific question sequences (Hindi)
=======
>>>>>>> origin/main
  static const Map<String, List<String>> _sceneQuestionsHi = {
    'vehicle_collision': [
      'इस टक्कर में कितने वाहन शामिल हैं?',
      'क्या कोई फंसे हुए या घायल लोग हैं?',
      'क्या वाहनों के पास तरल रिसाव या धुआँ दिखाई दे रहा है?',
      'क्या दृश्य प्रथमदर्शकों के लिए सुरक्षित है?',
      'टक्कर के नुकसान और वाहन की स्थिति बताइए।',
    ],
    'pedestrian_hit': [
      'क्या पैदल यात्री होश में है?',
      'कोई दिखाई देने वाली चोट या खून तो नहीं?',
      'पैदल यात्री को वाहन ने मारा? घटना बताइए।',
      'क्या पैदल यात्री हिल-डुल सकता है?',
      'पीड़ित की उम्र और स्थिति क्या है?',
    ],
    'rollover': [
      'वाहन में कितने लोग हैं?',
      'क्या कोई फंसा हुआ है?',
      'क्या ईंधन रिस रहा है या आग का खतरा है?',
      'क्या लोग होश में हैं?',
      'वाहन की स्थिति कैसी है?',
    ],
    'fire_hazard': [
      'क्या आग या भारी धुआँ दिखाई दे रहा है?',
      'क्या कोई वाहन में है?',
      'क्या आग फैल रही है?',
      'क्या लोगों को खाली करने की चेतावनी दी?',
      'आग कितनी बड़ी और तीव्र है?',
    ],
    'unknown': [
      'यह किस प्रकार की घटना है?',
      'कितने लोग प्रभावित हैं?',
      'कोई दिखाई देने वाली चोट तो नहीं?',
      'क्या दृश्य सुरक्षित है?',
      'वर्तमान स्थिति और खतरे क्या हैं?',
    ],
  };

<<<<<<< HEAD
  Future<String?> _edgeGenerate(String prompt) async {
    try {
      final client = Supabase.instance.client;
=======
  /// Call Gemma 4 27B via Supabase Edge Function for dynamic question generation.
  Future<String?> _gemma4Generate(String prompt) async {
    if (kIsWeb) return null;
    try {
      final client = Supabase.instance.client;
      // Edge function slug: 'gemini-generate' (legacy name kept for Supabase deploy compatibility).
      // Internally uses Gemma 4 27B (gemma-4-27b-it). See supabase/functions/gemini-generate/index.ts.
>>>>>>> origin/main
      final res = await client.functions.invoke(
        'gemini-generate',
        body: <String, dynamic>{
          'prompt': prompt,
<<<<<<< HEAD
          'model': 'gemini-2.0-flash',
          'temperature': 0.3,
          'max_output_tokens': 256,
        },
      );
      final data = res.data;
      if (data is Map && data['text'] is String) return (data['text'] as String).trim();
      return null;
    } catch (e, st) {
      appLog.d('Assistant edge generate failed', error: e, stackTrace: st);
=======
          'model': 'gemma-4-27b-it',
          'temperature': 0.4,
          'max_output_tokens': 150,
        },
      );
      final data = res.data;
      if (data is Map && data['text'] is String) {
        return (data['text'] as String).trim();
      }
      return null;
    } catch (e, st) {
      appLog.d('[Assistant] Gemma 4 cloud generate failed', error: e, stackTrace: st);
>>>>>>> origin/main
      return null;
    }
  }

<<<<<<< HEAD
  /// Detect scene context from user input
=======
>>>>>>> origin/main
  String _detectSceneContext(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('pedestrian') || lower.contains('पैदल')) return 'pedestrian_hit';
    if (lower.contains('rollover') || lower.contains('पलटा') || lower.contains('overturned')) return 'rollover';
    if (lower.contains('fire') || lower.contains('आग') || lower.contains('smoke') || lower.contains('धुआँ')) return 'fire_hazard';
    if (lower.contains('collision') || lower.contains('टक्कर') || lower.contains('crash')) return 'vehicle_collision';
    return 'unknown';
  }

<<<<<<< HEAD
  /// Initialize scene context based on user's first input
=======
>>>>>>> origin/main
  void setSceneContext(String context) {
    state = state.copyWith(sceneContext: context);
  }

<<<<<<< HEAD
  /// Get the next guided question based on scene and history
=======
  void completeGuidanceStep(int stepNumber) {
    final updated = state.guidanceSteps.map((s) {
      return s.stepNumber == stepNumber ? s.copyWith(completed: true) : s;
    }).toList();
    state = state.copyWith(guidanceSteps: updated);
  }

  void resetInterview() {
    state = AssistantState();
  }

>>>>>>> origin/main
  Future<String> getNextWitnessQuestion(
    String previousAnswer, {
    String languageCode = 'en',
  }) async {
<<<<<<< HEAD
    // If this is the first input, detect scene and ask appropriate first question
=======
>>>>>>> origin/main
    if (state.history.isEmpty) {
      final detectedContext = _detectSceneContext(previousAnswer);
      final questions = languageCode == 'hi' ? _sceneQuestionsHi : _sceneQuestionsEn;
      final sceneQuestions = questions[detectedContext] ?? questions['unknown']!;
<<<<<<< HEAD
      
      final firstQuestion = sceneQuestions.first;
=======
      final firstQuestion = sceneQuestions.first;

>>>>>>> origin/main
      state = state.copyWith(
        isThinking: false,
        lastResponse: firstQuestion,
        history: [...state.history, previousAnswer, firstQuestion],
        sceneContext: detectedContext,
        askedQuestions: {firstQuestion},
        questionIndex: 1,
        interviewComplete: false,
      );
      return firstQuestion;
    }

<<<<<<< HEAD
    // Check if interview is complete
=======
>>>>>>> origin/main
    if (state.interviewComplete) {
      final endMessage = languageCode == 'hi'
          ? 'साक्षात्कार पूर्ण। सभी महत्वपूर्ण जानकारी एकत्र की जा चुकी है। धन्यवाद।'
          : 'Interview complete. All critical information has been gathered. Thank you.';
      return endMessage;
    }

    state = state.copyWith(isThinking: true);

<<<<<<< HEAD
    final questions = languageCode == 'hi' ? _sceneQuestionsHi : _sceneQuestionsEn;
    final sceneQuestions = questions[state.sceneContext] ?? questions['unknown']!;

    // Determine next question index (avoiding already asked questions)
    final nextIndex = (state.questionIndex) % sceneQuestions.length;
    final nextQuestion = sceneQuestions[nextIndex];

    // Skip if already asked, find next unasked question
    var questionToAsk = nextQuestion;
    var searchIndex = nextIndex;
    var attempts = 0;
    while (state.askedQuestions.contains(questionToAsk) && attempts < sceneQuestions.length) {
      searchIndex = (searchIndex + 1) % sceneQuestions.length;
      questionToAsk = sceneQuestions[searchIndex];
      attempts++;
    }

    // If all questions have been asked, mark interview as complete
    bool newInterviewComplete = state.askedQuestions.length >= sceneQuestions.length;

    final response = newInterviewComplete
        ? (languageCode == 'hi'
            ? 'साक्षात्कार पूर्ण। सभी महत्वपूर्ण जानकारी एकत्र की जा चुकी है। धन्यवाद।'
            : 'Interview complete. All critical information has been gathered. Thank you.')
        : questionToAsk;

    // Generate guidance steps when interview completes
=======
    // Try Gemma 4 for adaptive follow-up questions based on conversation so far.
    final conversationContext = state.history.take(6).join('\n');
    final gemmaPrompt =
        'Emergency scene type: ${state.sceneContext}. Conversation so far:\n$conversationContext\n'
        'Responder answer: "$previousAnswer"\n'
        'Ask ONE short follow-up question in ${languageCode == "hi" ? "Hindi" : "English"} '
        'to gather the most critical missing information for emergency dispatch. '
        'Just the question, no prefix.';

    String? gemmaQuestion = await _gemma4Generate(gemmaPrompt);

    final questions = languageCode == 'hi' ? _sceneQuestionsHi : _sceneQuestionsEn;
    final sceneQuestions = questions[state.sceneContext] ?? questions['unknown']!;
    final nextIndex = state.questionIndex % sceneQuestions.length;

    var fallbackQuestion = sceneQuestions[nextIndex];
    var searchIndex = nextIndex;
    var attempts = 0;
    while (state.askedQuestions.contains(fallbackQuestion) &&
        attempts < sceneQuestions.length) {
      searchIndex = (searchIndex + 1) % sceneQuestions.length;
      fallbackQuestion = sceneQuestions[searchIndex];
      attempts++;
    }

    final bool newInterviewComplete =
        state.askedQuestions.length >= sceneQuestions.length && gemmaQuestion == null;

    final response = newInterviewComplete
        ? (languageCode == 'hi'
            ? 'साक्षात्कार पूर्ण। धन्यवाद।'
            : 'Interview complete. Thank you.')
        : (gemmaQuestion ?? fallbackQuestion);

>>>>>>> origin/main
    final newGuidanceSteps = newInterviewComplete
        ? _generateGuidanceSteps(state.sceneContext, languageCode)
        : <GuidanceStep>[];

    state = state.copyWith(
      isThinking: false,
      lastResponse: response,
      history: [...state.history, previousAnswer, response],
<<<<<<< HEAD
      askedQuestions: {...state.askedQuestions, questionToAsk},
=======
      askedQuestions: {...state.askedQuestions, response},
>>>>>>> origin/main
      questionIndex: nextIndex + 1,
      interviewComplete: newInterviewComplete,
      guidanceSteps: newGuidanceSteps,
      showingGuidance: newInterviewComplete,
    );

    return response;
  }

<<<<<<< HEAD
  /// Generate actionable guidance steps based on scene type
=======
>>>>>>> origin/main
  List<GuidanceStep> _generateGuidanceSteps(String sceneContext, String lang) {
    if (lang == 'hi') {
      switch (sceneContext) {
        case 'vehicle_collision':
          return [
<<<<<<< HEAD
            GuidanceStep(
              stepNumber: 1,
              title: 'सुरक्षा सुनिश्चित करें',
              description:
                  'यदि सुरक्षित हो तो घायलों को सड़क से हटाएं। ट्रैफिक की चेतावनी दें।',
              icon: '🚨',
            ),
            GuidanceStep(
              stepNumber: 2,
              title: 'आपातकालीन सेवाएं बुलाएं',
              description: '102 (एम्बुलेंस) या 112 (इमरजेंसी) डायल करें।',
              icon: '📞',
            ),
            GuidanceStep(
              stepNumber: 3,
              title: 'प्राथमिक चिकित्सा करें',
              description:
                  'घायलों को स्थिर करें। रक्तस्राव को नियंत्रित करें। एयरवे खुला रखें।',
              icon: '🏥',
            ),
            GuidanceStep(
              stepNumber: 4,
              title: 'साक्ष्य संरक्षित करें',
              description:
                  'दृश्य की तस्वीरें लें। चश्मदीद खोजें। नंबर नोट करें।',
              icon: '📸',
            ),
            GuidanceStep(
              stepNumber: 5,
              title: 'पुलिस को सूचित करें',
              description: 'FIR दर्ज करें। दस्तावेज़ संभालकर रखें।',
              icon: '👮',
            ),
          ];
        case 'pedestrian_hit':
          return [
            GuidanceStep(
              stepNumber: 1,
              title: 'मेडिकल सहायता प्राथमिकता दें',
              description: 'तुरंत 102 कॉल करें। पीड़ित को हिलाएं नहीं।',
              icon: '🚑',
            ),
            GuidanceStep(
              stepNumber: 2,
              title: 'मस्तिष्क की चोट बचाव',
              description:
                  'सिर के नीचे तकिया न रखें। गर्दन को स्थिर रखें।',
              icon: '🧠',
            ),
            GuidanceStep(
              stepNumber: 3,
              title: 'दर्शकों को सूचित करें',
              description: 'चश्मदीद खोजें। फोन नंबर लिखें।',
              icon: '👥',
            ),
            GuidanceStep(
              stepNumber: 4,
              title: 'घटना रिपोर्ट करें',
              description: '100 को कॉल करें। FIR दर्ज करें।',
              icon: '📋',
            ),
            GuidanceStep(
              stepNumber: 5,
              title: 'अस्पताल में पालन करें',
              description: 'पीड़ित के साथ रहें। मेडिकल रिकॉर्ड सहेजें।',
              icon: '🏨',
            ),
          ];
        case 'rollover':
          return [
            GuidanceStep(
              stepNumber: 1,
              title: 'अग्नि संभावना जांचें',
              description: 'ईंधन रिसाव के लिए देखें। सिगरेट/माचिस रखें दूर।',
              icon: '🔥',
            ),
            GuidanceStep(
              stepNumber: 2,
              title: 'फंसे हुए लोगों की पहचान करें',
              description: 'अगर संभव हो तो सुरक्षित निकासी करें।',
              icon: '⚠️',
            ),
            GuidanceStep(
              stepNumber: 3,
              title: 'तुरंत आपातकालीन सेवा बुलाएं',
              description: '102 (एम्बुलेंस) + 101 (फायर ब्रिगेड) कॉल करें।',
              icon: '📞',
            ),
            GuidanceStep(
              stepNumber: 4,
              title: 'CPR तैयार रहें',
              description: 'जरूरत पड़ने पर CPR देने के लिए तैयार रहें।',
              icon: '💓',
            ),
            GuidanceStep(
              stepNumber: 5,
              title: 'पुलिस को सूचित करें',
              description: '100 कॉल करें। सभी विवरण बताएं।',
              icon: '👮',
            ),
          ];
        case 'fire_hazard':
          return [
            GuidanceStep(
              stepNumber: 1,
              title: 'तुरंत खाली करें',
              description: 'सभी को सुरक्षित जगह ले जाएं। आग से दूर रहें।',
              icon: '🏃',
            ),
            GuidanceStep(
              stepNumber: 2,
              title: 'फायर ब्रिगेड बुलाएं',
              description: '101 तुरंत कॉल करें। सटीक स्थिति बताएं।',
              icon: '🚒',
            ),
            GuidanceStep(
              stepNumber: 3,
              title: 'एम्बुलेंस तैयार रखें',
              description: '102 कॉल करें। जलने की चोटों के लिए तैयार रहें।',
              icon: '🚑',
            ),
            GuidanceStep(
              stepNumber: 4,
              title: 'आग से दूर रहें',
              description:
                  'पेशेवरों को काम करने दें। धुएं से सांस न लें।',
              icon: '💨',
            ),
            GuidanceStep(
              stepNumber: 5,
              title: 'मेडिकल सहायता दें',
              description:
                  'घायलों को ठंडे पानी से धोएं। त्वचा को न छुएं।',
              icon: '🏥',
            ),
          ];
        default:
          return [
            GuidanceStep(
              stepNumber: 1,
              title: 'आपातकालीन नंबर डायल करें',
              description: '112 कॉल करें। स्थिति समझाएं।',
              icon: '📞',
            ),
            GuidanceStep(
              stepNumber: 2,
              title: 'घायलों को स्थिर करें',
              description: 'घायलों को हिलाएं नहीं। उन्हें सहारा दें।',
              icon: '🤝',
            ),
            GuidanceStep(
              stepNumber: 3,
              title: 'क्षेत्र को सुरक्षित करें',
              description: 'ट्रैफिक को चेतावनी दें। भीड़ को दूर रखें।',
              icon: '🚧',
            ),
            GuidanceStep(
              stepNumber: 4,
              title: 'चश्मदीद ढूंढें',
              description: 'संपर्क जानकारी एकत्र करें।',
              icon: '👁️',
            ),
            GuidanceStep(
              stepNumber: 5,
              title: 'सहायता सेवाओं की प्रतीक्षा करें',
              description: 'पेशेवरों को काम करने दें।',
              icon: '⏳',
            ),
          ];
      }
    } else {
      // English guidance
      switch (sceneContext) {
        case 'vehicle_collision':
          return [
            GuidanceStep(
              stepNumber: 1,
              title: 'Ensure Scene Safety',
              description: 'Move injured to safety if possible. Warn oncoming traffic.',
              icon: '🚨',
            ),
            GuidanceStep(
              stepNumber: 2,
              title: 'Call Emergency Services',
              description: 'Dial 102 (Ambulance) or 112 (Emergency).',
              icon: '📞',
            ),
            GuidanceStep(
              stepNumber: 3,
              title: 'Provide First Aid',
              description:
                  'Stabilize victims. Control bleeding. Keep airway open.',
              icon: '🏥',
            ),
            GuidanceStep(
              stepNumber: 4,
              title: 'Preserve Evidence',
              description:
                  'Take photos. Find witnesses. Note vehicle numbers.',
              icon: '📸',
            ),
            GuidanceStep(
              stepNumber: 5,
              title: 'Notify Police',
              description: 'File FIR. Keep documents safe.',
              icon: '👮',
            ),
          ];
        case 'pedestrian_hit':
          return [
            GuidanceStep(
              stepNumber: 1,
              title: 'Prioritize Medical Aid',
              description: 'Call 102 immediately. Do NOT move the victim.',
              icon: '🚑',
            ),
            GuidanceStep(
              stepNumber: 2,
              title: 'Head Injury Protection',
              description:
                  'Do not place pillow under head. Stabilize neck.',
              icon: '🧠',
            ),
            GuidanceStep(
              stepNumber: 3,
              title: 'Identify Witnesses',
              description: 'Find bystanders. Take contact information.',
              icon: '👥',
            ),
            GuidanceStep(
              stepNumber: 4,
              title: 'Report Incident',
              description: 'Call 100 for police. File FIR.',
              icon: '📋',
            ),
            GuidanceStep(
              stepNumber: 5,
              title: 'Follow-up Hospital Care',
              description: 'Stay with victim. Preserve medical records.',
              icon: '🏨',
            ),
          ];
        case 'rollover':
          return [
            GuidanceStep(
              stepNumber: 1,
              title: 'Check Fire Risk',
              description: 'Look for fuel leaks. Keep away from ignition.',
              icon: '🔥',
            ),
            GuidanceStep(
              stepNumber: 2,
              title: 'Identify Trapped Occupants',
              description: 'Attempt safe evacuation if possible.',
              icon: '⚠️',
            ),
            GuidanceStep(
              stepNumber: 3,
              title: 'Call Emergency Services',
              description: 'Call 102 (Ambulance) + 101 (Fire Brigade).',
              icon: '📞',
            ),
            GuidanceStep(
              stepNumber: 4,
              title: 'Be Ready for CPR',
              description: 'Prepare to perform CPR if needed.',
              icon: '💓',
            ),
            GuidanceStep(
              stepNumber: 5,
              title: 'Notify Police',
              description: 'Call 100. Provide all details.',
              icon: '👮',
            ),
          ];
        case 'fire_hazard':
          return [
            GuidanceStep(
              stepNumber: 1,
              title: 'Evacuate Immediately',
              description: 'Move everyone to safety. Stay away from fire.',
              icon: '🏃',
            ),
            GuidanceStep(
              stepNumber: 2,
              title: 'Call Fire Brigade',
              description: 'Dial 101 immediately. Provide exact location.',
              icon: '🚒',
            ),
            GuidanceStep(
              stepNumber: 3,
              title: 'Have Ambulance Ready',
              description: 'Call 102. Be ready for burn injuries.',
              icon: '🚑',
            ),
            GuidanceStep(
              stepNumber: 4,
              title: 'Stay Clear of Fire',
              description:
                  'Let professionals work. Avoid smoke inhalation.',
              icon: '💨',
            ),
            GuidanceStep(
              stepNumber: 5,
              title: 'Provide Medical Support',
              description:
                  'Cool burn wounds with water. Do not touch skin.',
              icon: '🏥',
            ),
          ];
        default:
          return [
            GuidanceStep(
              stepNumber: 1,
              title: 'Call Emergency Services',
              description: 'Dial 112. Explain the situation.',
              icon: '📞',
            ),
            GuidanceStep(
              stepNumber: 2,
              title: 'Stabilize Victims',
              description: 'Do not move injured persons. Provide support.',
              icon: '🤝',
            ),
            GuidanceStep(
              stepNumber: 3,
              title: 'Secure the Scene',
              description: 'Warn traffic. Keep crowd away.',
              icon: '🚧',
            ),
            GuidanceStep(
              stepNumber: 4,
              title: 'Find Witnesses',
              description: 'Collect contact information.',
              icon: '👁️',
            ),
            GuidanceStep(
              stepNumber: 5,
              title: 'Wait for Help',
              description: 'Let professionals take over.',
              icon: '⏳',
            ),
=======
            GuidanceStep(stepNumber: 1, title: 'सुरक्षा सुनिश्चित करें', description: 'घायलों को सड़क से हटाएं। ट्रैफिक की चेतावनी दें।', icon: '🚨'),
            GuidanceStep(stepNumber: 2, title: 'आपातकालीन सेवाएं बुलाएं', description: '112 डायल करें।', icon: '📞'),
            GuidanceStep(stepNumber: 3, title: 'प्राथमिक चिकित्सा करें', description: 'रक्तस्राव नियंत्रित करें। एयरवे खुला रखें।', icon: '🏥'),
            GuidanceStep(stepNumber: 4, title: 'साक्ष्य संरक्षित करें', description: 'तस्वीरें लें। चश्मदीद खोजें।', icon: '📸'),
            GuidanceStep(stepNumber: 5, title: 'पुलिस को सूचित करें', description: 'FIR दर्ज करें।', icon: '👮'),
          ];
        default:
          return [
            GuidanceStep(stepNumber: 1, title: '112 डायल करें', description: 'तुरंत आपातकालीन सेवा बुलाएं।', icon: '📞'),
            GuidanceStep(stepNumber: 2, title: 'घायलों को स्थिर करें', description: 'हिलाएं नहीं। सहारा दें।', icon: '🤝'),
            GuidanceStep(stepNumber: 3, title: 'क्षेत्र सुरक्षित करें', description: 'ट्रैफिक को चेतावनी दें।', icon: '🚧'),
          ];
      }
    } else {
      switch (sceneContext) {
        case 'vehicle_collision':
          return [
            GuidanceStep(stepNumber: 1, title: 'Ensure Scene Safety', description: 'Move injured to safety if possible. Warn traffic.', icon: '🚨'),
            GuidanceStep(stepNumber: 2, title: 'Call Emergency Services', description: 'Dial 112 or 911.', icon: '📞'),
            GuidanceStep(stepNumber: 3, title: 'Provide First Aid', description: 'Control bleeding. Keep airway open.', icon: '🏥'),
            GuidanceStep(stepNumber: 4, title: 'Preserve Evidence', description: 'Take photos. Note vehicle numbers.', icon: '📸'),
            GuidanceStep(stepNumber: 5, title: 'Notify Police', description: 'File incident report.', icon: '👮'),
          ];
        case 'fire_hazard':
          return [
            GuidanceStep(stepNumber: 1, title: 'Evacuate Immediately', description: 'Move everyone away from fire.', icon: '🏃'),
            GuidanceStep(stepNumber: 2, title: 'Call Fire Brigade', description: 'Dial 101 (India) or 112.', icon: '🚒'),
            GuidanceStep(stepNumber: 3, title: 'Call Ambulance', description: 'Dial 102 (India) for burn injuries.', icon: '🚑'),
          ];
        default:
          return [
            GuidanceStep(stepNumber: 1, title: 'Call Emergency Services', description: 'Dial 112. Describe situation clearly.', icon: '📞'),
            GuidanceStep(stepNumber: 2, title: 'Stabilize Victims', description: 'Do not move injured unless in danger.', icon: '🤝'),
            GuidanceStep(stepNumber: 3, title: 'Secure the Scene', description: 'Warn traffic. Keep crowd back.', icon: '🚧'),
>>>>>>> origin/main
          ];
      }
    }
  }
<<<<<<< HEAD

  /// Mark a guidance step as completed
  void completeGuidanceStep(int stepNumber) {
    final updatedSteps = state.guidanceSteps.map((step) {
      if (step.stepNumber == stepNumber) {
        return step.copyWith(completed: true);
      }
      return step;
    }).toList();

    state = state.copyWith(guidanceSteps: updatedSteps);
  }

  /// Reset to start a new incident report
  void resetInterview() {
    state = AssistantState();
  }

  Future<String> synthesizeTelemetry({
    required double maxG,
    required double speedDelta,
    required String impactVector,
    String languageCode = 'en',
  }) async {
    state = state.copyWith(isThinking: true);

    final fallback =
        _offlineTelemetryBrief(maxG, speedDelta, impactVector, languageCode);

    if (kIsWeb) {
      state = state.copyWith(isThinking: false, lastResponse: fallback);
      return fallback;
    }

    try {
      final text = await _edgeGenerate(
        '''Emergency telemetry brief for paramedics (max 20 words). Language: $languageCode (match if not English).
Max G=$maxG, Delta speed=$speedDelta km/h, Impact=$impactVector.
Output one line starting with "Brief:"''',
      );
      final result = (text == null || text.trim().isEmpty) ? fallback : text.trim();
      state = state.copyWith(isThinking: false, lastResponse: result);
      return result;
    } catch (e, st) {
      appLog.d(
        'RoadSosAssistant synthesizeTelemetry fallback',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(isThinking: false, lastResponse: fallback);
      return fallback;
    }
  }

  String _offlineTelemetryBrief(
    double maxG,
    double speedDelta,
    String impactVector,
    String languageCode,
  ) {
    if (languageCode == 'hi') {
      return 'संक्षेप: $impactVector प्रभाव, तेज मंदी — आंतरिक चोट संभव।';
    }
    return 'Brief: High-G $impactVector impact with severe deceleration. Possible internal trauma.';
  }
}

final roadsosAssistantProvider =
    StateNotifierProvider<RoadSosAssistantService, AssistantState>((ref) {
  return RoadSosAssistantService();
});
=======
}

final roadSosAssistantServiceProvider =
    StateNotifierProvider<RoadSosAssistantService, AssistantState>((ref) {
  return RoadSosAssistantService();
});

/// Alias used by UI files.
final roadsosAssistantProvider = roadSosAssistantServiceProvider;
>>>>>>> origin/main
