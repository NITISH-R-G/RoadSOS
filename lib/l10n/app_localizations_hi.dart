// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'RoadSOS';

  @override
  String get dashboardTitle => 'RoadSOS';

  @override
  String get sosButton => 'एसओएस';

  @override
  String get secondsLabel => 'सेकंड';

  @override
  String get sosDispatchWarning =>
      'अभी कुछ नहीं भेजा गया। गलती हो तो नीचे रद्द करें।';

  @override
  String get sosIdleTools => 'और';

  @override
  String get sosIdleToolsTitle => 'आपातकालीन उपकरण और स्थिति';

  @override
  String get sosButtonSub => 'आपातकाल के लिए दबाएँ';

  @override
  String get cancelSos => 'रद्द करें';

  @override
  String get orchestratorBystanderStarted => 'बाइस्टैंडर अलर्ट शुरू';

  @override
  String get orchestratorSelfSosStarted => 'सेल्फ SOS शुरू';

  @override
  String get orchestratorAcquiringLocation => 'स्थान प्राप्त कर रहे हैं…';

  @override
  String orchestratorLocationSecured(String lat, String lng) {
    return 'स्थान: $lat, $lng';
  }

  @override
  String get orchestratorLocationUnavailable =>
      'Location unavailable — enable location services or move to open sky.';

  @override
  String get orchestratorManualActionRequired =>
      'Manual action required — if automated dispatch fails, dial your emergency number now.';

  @override
  String get orchestratorSmsNoGpsPayload =>
      'SOS (no GPS). Please call emergency services now. RoadSOS could not acquire location.';

  @override
  String get orchestratorAiBrief => 'क्लाउड AI स्थिति जांच रहा है…';

  @override
  String orchestratorTriageDone(int level) {
    return 'ट्राइएज पूर्ण — गंभीरता $level';
  }

  @override
  String get orchestratorDispatching => 'सभी चैनलों पर अलर्ट भेज रहे हैं…';

  @override
  String get orchestratorSosLive => 'SOS सक्रिय — सभी चैनल चालू';

  @override
  String get orchestratorCancelled => 'SOS रद्द';

  @override
  String get mapPlaceholder => 'मानचित्र';

  @override
  String get actionScene => 'दृश्य';

  @override
  String get actionMedicalId => 'मेडिकल आईडी';

  @override
  String get actionResponder => 'रिस्पॉन्डर';

  @override
  String get actionSafeWalk => 'सुरक्षित चलना';

  @override
  String get actionFirstAid => 'प्राथमिक उपचार';

  @override
  String get actionVitalScan => 'वाइटल स्कैन';

  @override
  String get actionMeshChat => 'मेश चैट';

  @override
  String get actionSettings => 'सेटिंग्स';

  @override
  String get triageResultTitle => 'AI ट्राइएज परिणाम';

  @override
  String get triageDegradedTitle => 'AI ट्राइएज (ऑफ़लाइन)';

  @override
  String severityLine(int level, String label) {
    return 'गंभीरता $level/5 — $label';
  }

  @override
  String get severityCritical => 'अत्यंत गंभीर';

  @override
  String get severitySevere => 'गंभीर';

  @override
  String get severityModerate => 'मध्यम';

  @override
  String get severityMinor => 'हल्का';

  @override
  String get severityLow => 'कम';

  @override
  String get severityUnknown => 'अज्ञात';

  @override
  String get dispatchedServices => 'भेजी गई सेवाएँ';

  @override
  String get firstAidGuidance => 'प्राथमिक उपचार मार्गदर्शन';

  @override
  String get noAiBadge => 'ऑफ़लाइन';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get sectionConnectivity => 'कनेक्टिविटी';

  @override
  String get sectionLegal => 'कानूनी और डेटा';

  @override
  String get offlineMapsTitle => 'ऑफ़लाइन मानचित्र';

  @override
  String get offlineMapsSubtitle => 'क्षेत्रीय टाइल डाउनलोड करें';

  @override
  String get meshConfigTitle => 'मेश सेटिंग';

  @override
  String get meshConfigSubtitle => 'संवेदनशीलता और दृश्यता';

  @override
  String get blackBoxTitle => 'ब्लैक बॉक्स रिपोर्ट';

  @override
  String get blackBoxSubtitle => 'टेलीमेट्री और ट्राइएज निर्यात';

  @override
  String get blackBoxSnack => 'हस्ताक्षरित PDF बन रहा है…';

  @override
  String get dataPrivacyTitle => 'डेटा गोपनीयता';

  @override
  String get dataPrivacySubtitle => 'एन्क्रिप्शन और सिंक';

  @override
  String get vitalScanTitle => 'वाइटल स्कैन';

  @override
  String get vitalAlignFinger => 'PPG के लिए उंगली कैमरे और फ्लैश पर रखें।';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageSubtitle => 'इंटरफ़ेस, ट्राइएज और आवाज़';

  @override
  String get incidentAssistantAnalyzed =>
      'दृश्य: अगला प्रहार दर्ज। धुआँ या आग जाँचें।';

  @override
  String get incidentVoiceHint => 'जो देखें वह बताएँ…';

  @override
  String get profileAiLine =>
      'प्रोफ़ाइल SOS के दौरान पहला उपचार संकेतों में मदद करती है।';

  @override
  String get thinkingOffline => 'ऑफ़लाइन नियम (क्लाउड नहीं)।';

  @override
  String get sttConfirmKeywords => 'आप हाँ, पुष्टि, या मदद कह सकते हैं।';

  @override
  String get consentTitle => 'RoadSOS में आपका स्वागत';

  @override
  String get consentSummary =>
      'यह ऐप आपकी लोकेशन, क्रैश/मोशन संकेतों और वैकल्पिक मेडिकल प्रोफ़ाइल को आपातकालीन सहायता के लिए प्रोसेस करता है। भारत के डिजिटल व्यक्तिगत डेटा संरक्षण अधिनियम, 2023 के अनुसार, जारी रखने से पहले सहमति ज़रूरी है। क्लाउड पर 90 दिन तक रिटेंशन (जब तक नीचे विकल्प न चुने)।';

  @override
  String get consentExtendedRetentionLabel =>
      'सुरक्षा शोध के लिए क्लाउड डेटा 90 दिन से अधिक रखें (वैकल्पिक)';

  @override
  String get consentAccept => 'मैं सहमत हूँ — आगे बढ़ें';

  @override
  String get consentPrivacyButton => 'गोपनीयता नोटिस';

  @override
  String get privacyPolicyTitle => 'गोपनीयता नोटिस';

  @override
  String get privacyPolicyLanguageEn => 'English';

  @override
  String get privacyPolicyLanguageHi => 'हिंदी';

  @override
  String get goodSamaritanTitle => 'गुड सेमेरिटन सुरक्षा';

  @override
  String get goodSamaritanLead =>
      'ईमानदारी से मदद करने पर आप कानूनी रूप से सुरक्षित हैं।';

  @override
  String get goodSamaritanBody =>
      'भारत में गुड सेमेरिटन फ्रेमवर्क (2016 सर्वोच्च न्यायालय दिशानिर्देश सहित) सड़क दुर्घटना पीड़ितों की मदद करने वालों के उत्पीड़न को रोकता है। समय पर मदद जान बचा सकती है।';

  @override
  String get goodSamaritanContinue => 'समझ गया';

  @override
  String get nearbySosSectionTitle => 'आसपास SOS';

  @override
  String get nearbySosToggleTitle => 'आसपास SOS पुश अलर्ट';

  @override
  String get nearbySosToggleSubtitle =>
      'फायरबेस — जब पास में किसी को मदद चाहिए तो सूचना';

  @override
  String get nearbySosLearnProtection => 'गुड सेमेरिटन सुरक्षा';

  @override
  String get aiThinkingTraceTitle => 'TRIAGE REASONING';

  @override
  String get crisisCompanionTitle => 'CRISIS ASSISTANT';

  @override
  String get crisisCompanionBreathing =>
      'Breathe steadily. Monitoring your situation.';

  @override
  String get sceneIntelligenceTitle => 'दृश्य बुद्धिमत्ता';

  @override
  String get helpEtaPlaceholder => 'No ETA available';

  @override
  String get talkButton => 'TALK';

  @override
  String get settingsExtendedRetentionTitle => 'विस्तारित क्लाउड रिटेंशन';

  @override
  String get settingsExtendedRetentionSubtitle =>
      'Supabase सिंक पर 90 दिन से अधिक घटना सारांश रखें (डिफ़ॉल्ट purge ओवरराइड)।';

  @override
  String get navSos => 'SOS';

  @override
  String get navSafetyTools => 'Safety Tools';

  @override
  String get navProfile => 'My Profile';

  @override
  String get drivingModeBanner => 'DRIVING MODE — Crash detection armed';

  @override
  String get safetyToolsHint =>
      'All safety features are in \"Safety Tools\" below';

  @override
  String get sectionEmergencyResponse => 'EMERGENCY RESPONSE';

  @override
  String get sectionHealthSafety => 'HEALTH & SAFETY';

  @override
  String get sectionRecords => 'RECORDS';

  @override
  String get sectionMyInformation => 'MY INFORMATION';

  @override
  String get sectionSettingsPrivacy => 'SETTINGS & PRIVACY';

  @override
  String get actionSafeWalkSub =>
      'Auto-SOS if you don\'t check in at destination';

  @override
  String get actionCaptureScene => 'Capture Scene';

  @override
  String get actionCaptureSceneSub =>
      'Document crash with AI-powered photo analysis';

  @override
  String get actionResponderSub => 'Live map with nearby SOS signals';

  @override
  String get actionFirstAidSub => 'Step-by-step emergency instructions';

  @override
  String get actionVitalScanSub => 'Check heart rate & oxygen saturation';

  @override
  String get actionMedicalIdSub =>
      'Show responders your blood type, allergies, contacts';

  @override
  String get actionMeshChatSub =>
      'Offline Bluetooth messaging — no signal needed';

  @override
  String get actionOfflineMaps => 'Offline Maps';

  @override
  String get actionOfflineMapsSub => 'Download maps for no-signal areas';

  @override
  String get actionActivityLog => 'Activity Log';

  @override
  String get actionActivityLogSub =>
      'GPS, triage, SMS — for police & insurer records';

  @override
  String get actionEditProfile => 'Edit Profile';

  @override
  String get actionEditProfileSub => 'Name, blood type, emergency contacts';

  @override
  String get actionMedicalIdCard => 'Medical ID Card';

  @override
  String get actionMedicalIdCardSub =>
      'Quick-access health info for emergency responders';

  @override
  String get actionAllSettings => 'All Settings';

  @override
  String get actionAllSettingsSub =>
      'Language, offline maps, notifications, privacy';

  @override
  String get actionActivityLogFullSub =>
      'Full SOS history for insurance & police records';

  @override
  String get rescueGuideTitle => 'Rescue Guide';

  @override
  String get vehicleRescueTitle => 'Vehicle Rescue';

  @override
  String get rescueOfflineBadge => 'OFFLINE';

  @override
  String get vehicleRescueBannerTitle => 'वाहन बचाव';

  @override
  String get vehicleRescueBannerSub =>
      'विशिष्ट खतरों और निर्देशों के लिए चयन करें';

  @override
  String get plateNumberLabel => 'प्लेट नंबर (वैकल्पिक)';

  @override
  String get plateNumberHint => 'जैसे MH 01 AA 1111';

  @override
  String get selectVehicleType => 'वाहन प्रकार चुनें';

  @override
  String get rescueOfflineTip =>
      'All rescue instructions work offline — no internet needed.';

  @override
  String get highVoltageWarning => 'HIGH VOLTAGE';

  @override
  String get rescueDangersTitle => '⚠️  DANGERS — READ FIRST';

  @override
  String get rescueExtractionTitle => '👐  EXTRACTION STEPS';

  @override
  String get rescueFirstAidTitle => '🩺  WHILE WAITING FOR AMBULANCE';

  @override
  String get rescueCriticalBadge => 'CRITICAL';

  @override
  String get dialerError =>
      'Could not launch dialer. Please call 108 manually.';

  @override
  String get callAmbulanceButton => 'CALL AMBULANCE — 108';

  @override
  String get editMedicalIdTitle => 'EDIT MEDICAL ID';

  @override
  String get profileUpdatedSnack => 'Medical Profile Updated';

  @override
  String get fieldFullName => 'पूरा नाम';

  @override
  String get fieldBloodType => 'रक्त समूह';

  @override
  String get fieldAllergies => 'एलर्जी';

  @override
  String get fieldMedications => 'दवाइयाँ';

  @override
  String get fieldConditions => 'Chronic Conditions';

  @override
  String get sectionEmergencyContacts => 'EMERGENCY CONTACTS';

  @override
  String get fieldPrimaryContact => 'प्राथमिक संपर्क';

  @override
  String fieldAdditionalContact(int index) {
    return 'अतिरिक्त संपर्क $index';
  }

  @override
  String get addContactButton => 'संपर्क जोड़ें';

  @override
  String get medicalIdTitle => 'आपातकालीन मेडिकल आईडी';

  @override
  String get scanForSummary => 'मेडिकल सारांश के लिए स्कैन करें';

  @override
  String get notSet => 'निर्धारित नहीं';

  @override
  String get medicalCardTip =>
      'टिप: इस स्क्रीन को उत्तरदाताओं के लिए खुला रखें। लॉक-स्क्रीन वॉलपेपर निर्यात के लिए, अपने डिवाइस स्क्रीनशॉट टूल का उपयोग करें।';

  @override
  String get firstAidGuideTitle => '🩺 प्राथमिक चिकित्सा गाइड';

  @override
  String get describeInjuryHint => 'चोट का वर्णन करें...';

  @override
  String get firstAidError =>
      'इस डिवाइस पर प्राथमिक चिकित्सा मार्गदर्शन लोड नहीं किया जा सका।';

  @override
  String get verifiedSolutionsTitle => 'सत्यापित चिकित्सा समाधान';

  @override
  String get aiInjuryIdTitle => 'AI चोट पहचान';

  @override
  String get typeInjuryPrompt =>
      'सटीक, सत्यापित प्राथमिक चिकित्सा समाधान प्राप्त करने के के लिए चोट का नाम टाइप करें।';

  @override
  String get chipSevereBleeding => 'गंभीर रक्तस्राव';

  @override
  String get chipMuscleTear => 'मांसपेशियों का फटना';

  @override
  String get chipBrainInjury => 'मस्तिष्क की चोट';

  @override
  String get chipSprains => 'मोच';

  @override
  String get multimodalDigitalTwin => 'मल्टीमॉडल: डिजिटल ट्विन';

  @override
  String get aiInterviewNuance => 'AI साक्षात्कार: स्थिति संबंधी सूक्ष्मता';

  @override
  String get actionGuidanceNextSteps => 'कार्रवाई मार्गदर्शन: अगले चरण';

  @override
  String get situationBriefLive => 'स्थिति विवरण (लाइव)';

  @override
  String get sceneAttached => 'दृश्य संलग्न';

  @override
  String get captureAttachPhoto => 'फोटो कैप्चर / संलग्न करें';

  @override
  String get photoAttachedNote =>
      'इस रिपोर्ट में फोटो संलग्न है (इस निर्माण में ऑटो-विश्लेषण नहीं किया गया है)।';

  @override
  String get scenePhotoError =>
      'इस डिवाइस पर दृश्य फोटो कैप्चर नहीं किया जा सका।';

  @override
  String get scenePhotoAttached => 'दृश्य फोटो संलग्न।';

  @override
  String get questionProgress => 'प्रश्न प्रगति:';

  @override
  String get describeIncidentPrompt => 'कृपया घटना का वर्णन करें';

  @override
  String get speakOrTypeHint => 'बोलें या टाइप करें…';

  @override
  String get interviewCompleteMessage =>
      '✓ साक्षात्कार पूर्ण। सभी महत्वपूर्ण जानकारी एकत्र की गई।';

  @override
  String get actionStepsTitle => '🎯 कार्रवाई चरण';

  @override
  String get reportNewIncidentButton => 'नई घटना की रिपोर्ट करें';

  @override
  String get sceneCollision => 'वाहन टक्कर';

  @override
  String get scenePedestrian => 'पैदल यात्री की टक्कर';

  @override
  String get sceneRollover => 'पलटना';

  @override
  String get sceneFire => 'आग का खतरा';

  @override
  String get sceneUnknown => 'अज्ञात';

  @override
  String get activityLogTitle => 'Activity log';

  @override
  String get activityLogSubtitle =>
      'GPS, triage, SMS/mesh/cloud steps — for insurance or police records';

  @override
  String get reviewPermissionsTitle => 'Review permissions';

  @override
  String get reviewPermissionsSubtitle => 'Open the setup walkthrough again';

  @override
  String get backgroundVolumeSosTitle => 'Background volume SOS';

  @override
  String get backgroundVolumeSosSubtitle =>
      'Open Accessibility and enable RoadSOS for lock-screen gesture (3× up + 3× down)';

  @override
  String get nearbySosFirebaseError =>
      'Nearby SOS needs Firebase setup (google-services.json / FirebaseOptions). Toggle turned off.';

  @override
  String get rescue_car_type => 'कार / सेडान / हैचबैक';

  @override
  String get rescue_car_desc => 'मानक 4-पहिया यात्री वाहन';

  @override
  String get rescue_car_danger_1 =>
      '⛽ ईंधन टैंक पीछे है — कार के पीछे से आग दूर रखें';

  @override
  String get rescue_car_danger_2 =>
      '🔋 12V बैटरी आमतौर पर हुड के नीचे होती है (शॉर्ट सर्किट से बचें)';

  @override
  String get rescue_car_danger_3 =>
      '🔋 12V battery under hood — avoid touching terminals';

  @override
  String get rescue_car_danger_4 =>
      '🔥 Engine fire risk — if smoke seen, move victim 30m away immediately';

  @override
  String get rescue_car_step_1_title => 'Make the scene safe';

  @override
  String get rescue_car_step_1_detail =>
      'Turn off the engine if accessible. Turn on hazard lights. Place objects 50m behind to warn traffic.';

  @override
  String get rescue_car_step_2_title => 'Check if victim is conscious';

  @override
  String get rescue_car_step_2_detail =>
      'Tap shoulder and shout \"Can you hear me?\". If no response, call 108 immediately. Do NOT shake them.';

  @override
  String get rescue_car_step_3_title => 'Do NOT move the victim yet';

  @override
  String get rescue_car_step_3_detail =>
      'If victim is breathing and not in immediate danger (no fire/flood), keep them still. Moving can worsen spinal injuries.';

  @override
  String get rescue_car_step_4_title => 'Open the door safely';

  @override
  String get rescue_car_step_4_detail =>
      'Pull door handle and simultaneously push door outward with shoulder. For jammed doors, try rear doors first.';

  @override
  String get rescue_car_step_5_title => 'Support the neck and head';

  @override
  String get rescue_car_step_5_detail =>
      'Place both hands on either side of victim\'s head. Keep head aligned with spine at ALL times. Ask someone else to help.';

  @override
  String get rescue_car_step_6_title => 'Slide victim out horizontally';

  @override
  String get rescue_car_step_6_detail =>
      'One person holds head, another grips under armpits. Move in one smooth motion. Never twist the spine.';

  @override
  String get rescue_car_step_7_title => 'Place in recovery position';

  @override
  String get rescue_car_step_7_detail =>
      'If breathing, place on their side (recovery position) to prevent choking. Keep monitoring until ambulance arrives.';

  @override
  String get rescue_car_firstaid_1 =>
      '🩸 For bleeding: apply firm pressure with cloth. Don\'t remove it.';

  @override
  String get rescue_car_firstaid_2 =>
      '🫁 If not breathing: begin CPR — 30 chest compressions + 2 breaths.';

  @override
  String get rescue_car_firstaid_3 =>
      '🦴 If you suspect broken bones: do NOT straighten them.';

  @override
  String get rescue_car_firstaid_4 =>
      '🚨 Keep talking to the victim — keep them conscious and calm.';

  @override
  String get fuel_petrol_diesel => 'Petrol / Diesel';

  @override
  String get fuel_diesel => 'Diesel';

  @override
  String get fuel_petrol => 'Petrol';

  @override
  String get fuel_electric => 'Electric / Battery';

  @override
  String get fuel_diesel_cng => 'Diesel / CNG';

  @override
  String get fuel_multi => 'CNG / Petrol / Electric';

  @override
  String get rescue_truck_type => 'भारी वाहन / ट्रक / बस';

  @override
  String get rescue_truck_desc => 'बड़ी रसद या यात्री बसें';

  @override
  String get rescue_truck_danger_1 =>
      '🛑 भारी ब्लाइंड स्पॉट — सुनिश्चित करें कि ड्राइवर आपको देख रहा है';

  @override
  String get rescue_truck_danger_2 =>
      '💨 एयर ब्रेक का दबाव कम होने से पहिए अचानक जाम हो सकते हैं';

  @override
  String get rescue_truck_danger_3 =>
      '🏋️ Cab is very high — falling risk when extracting driver';

  @override
  String get rescue_truck_danger_4 =>
      '📦 Cargo may shift and fall — approach from the side carefully';

  @override
  String get rescue_truck_danger_5 =>
      '🔧 Air brakes may release suddenly — stay clear of wheels';

  @override
  String get rescue_truck_step_1_title => 'Approach from the SIDE only';

  @override
  String get rescue_truck_step_1_detail =>
      'Never approach from front (engine fire) or rear (cargo). Come from driver\'s side door angle.';

  @override
  String get rescue_truck_step_2_title => 'Secure the truck';

  @override
  String get rescue_truck_step_2_detail =>
      'If safe, apply handbrake and place wheel chocks (stones/wood) under tires to prevent rolling.';

  @override
  String get rescue_truck_step_3_title => 'Climb up carefully';

  @override
  String get rescue_truck_step_3_detail =>
      'Use the built-in steps/handles on the cab. Don\'t pull on door handles to climb — they may break.';

  @override
  String get rescue_truck_step_4_title => 'Check driver consciousness';

  @override
  String get rescue_truck_step_4_detail =>
      'Tap and call out. Driver may be trapped by steering wheel. Do NOT force them out.';

  @override
  String get rescue_truck_step_5_title => 'Extraction needs 3+ people';

  @override
  String get rescue_truck_step_5_detail =>
      'One holds head/neck, two support body. Lower driver down cab steps slowly. Never drop.';

  @override
  String get rescue_truck_step_6_title => 'Move victim 50m away';

  @override
  String get rescue_truck_step_6_detail =>
      'Trucks carry large fuel loads. Move victim far from vehicle in case of fire.';

  @override
  String get rescue_truck_firstaid_1 =>
      '🚨 Call 108 AND fire brigade (101) — truck fires spread fast.';

  @override
  String get rescue_truck_firstaid_2 =>
      '🩸 Truck drivers often hit steering wheel — check chest for injury.';

  @override
  String get rescue_truck_firstaid_3 =>
      '👁️ Check for head injuries — helmet-less impact with windshield is common.';

  @override
  String get rescue_truck_firstaid_4 =>
      '🦺 If cargo has hazmat symbols, stay back and call 112.';

  @override
  String get rescue_bike_type => 'दोपहिया / मोटरसाइकिल';

  @override
  String get rescue_bike_desc => 'मोटरबाइक और स्कूटर';

  @override
  String get rescue_bike_danger_1 => '🔥 गर्म इंजन/निकास पाइप से जलने का जोखिम';

  @override
  String get rescue_bike_danger_2 =>
      '⛽ ईंधन रिसाव सामान्य है यदि बाइक गिरी हो; आग के स्रोतों से बचें';

  @override
  String get rescue_bike_danger_3 =>
      '🛣️ Rider likely skidded — check for road rash injuries';

  @override
  String get rescue_bike_danger_4 =>
      '🔥 Hot exhaust pipe — avoid touching, can cause burns';

  @override
  String get rescue_bike_step_1_title => 'Move the bike away first';

  @override
  String get rescue_bike_step_1_detail =>
      'The bike is the fire risk. Push it at least 10m away from the victim before helping.';

  @override
  String get rescue_bike_step_2_title => 'NEVER remove the helmet';

  @override
  String get rescue_bike_step_2_detail =>
      'Even if victim asks. Helmet removal can cause fatal spinal damage. Only doctors should remove it.';

  @override
  String get rescue_bike_step_3_title => 'Check breathing through visor';

  @override
  String get rescue_bike_step_3_detail =>
      'Open the visor to check breathing. If vomiting, hold helmet steady and gently tilt to side.';

  @override
  String get rescue_bike_step_4_title => 'Check for road rash';

  @override
  String get rescue_bike_step_4_detail =>
      'Large skin abrasions from skidding. Cover with clean cloth — don\'t clean with water yet.';

  @override
  String get rescue_bike_step_5_title => 'Keep rider still and flat';

  @override
  String get rescue_bike_step_5_detail =>
      'Riders are often thrown and land awkwardly. Assume spinal injury. Keep them flat until help arrives.';

  @override
  String get rescue_bike_step_6_title => 'Keep them warm';

  @override
  String get rescue_bike_step_6_detail =>
      'Shock causes rapid body cooling. Cover with jacket/blanket. Keep talking to them.';

  @override
  String get rescue_bike_firstaid_1 =>
      '🪖 NEVER remove helmet — this is the most important rule for bike accidents.';

  @override
  String get rescue_bike_firstaid_2 =>
      '🦴 Assume broken limbs — don\'t try to straighten or move them.';

  @override
  String get rescue_bike_firstaid_3 =>
      '😮 Shock is common — keep victim lying down, legs slightly elevated.';

  @override
  String get rescue_bike_firstaid_4 =>
      '🩸 Road rash bleeds a lot but is rarely life-threatening — focus on head/spine.';

  @override
  String get rescue_ev_car_type => 'Electric Vehicle (EV Car)';

  @override
  String get rescue_ev_car_desc =>
      'Battery-powered car — special electrical hazards';

  @override
  String get rescue_ev_car_danger_1 =>
      '⚡ HIGH VOLTAGE battery (400-800V) — can be LETHAL if touched';

  @override
  String get rescue_ev_car_danger_2 =>
      '🔥 Lithium battery fires burn at 1000°C and CANNOT be extinguished easily';

  @override
  String get rescue_ev_car_danger_3 =>
      '🌊 If EV is in water — stay away, electric shock risk is EXTREME';

  @override
  String get rescue_ev_car_danger_4 =>
      '💨 Battery fires release toxic gases — stay upwind';

  @override
  String get rescue_ev_car_danger_5 =>
      '🔄 Car may still be \"on\" even if silent — EVs make no engine noise';

  @override
  String get rescue_ev_car_step_1_title => 'DO NOT touch orange cables';

  @override
  String get rescue_ev_car_step_1_detail =>
      'Orange cables carry high voltage. If you see orange wires exposed — do NOT touch the car at all.';

  @override
  String get rescue_ev_car_step_2_title => 'Turn off the car';

  @override
  String get rescue_ev_car_step_2_detail =>
      'If safe, reach in and press power button. Look for emergency cut-off switch (usually near door sill — bright red/orange).';

  @override
  String get rescue_ev_car_step_3_title => 'Check for battery damage';

  @override
  String get rescue_ev_car_step_3_detail =>
      'If battery area (under floor) is visibly damaged or smoking — treat as fire emergency. Move victim 30m away.';

  @override
  String get rescue_ev_car_step_4_title => 'Extraction same as regular car';

  @override
  String get rescue_ev_car_step_4_detail =>
      'Once confirmed safe (no exposed cables, no smoke), extraction steps are same as regular car. Support neck, slide out.';

  @override
  String get rescue_ev_car_step_5_title => 'If battery catches fire — RUN';

  @override
  String get rescue_ev_car_step_5_detail =>
      'EV battery fires cannot be put out with normal extinguishers. Move everyone 50m away and call fire brigade 101.';

  @override
  String get rescue_ev_car_firstaid_1 =>
      '⚡ If victim received electric shock: do not touch them until power is confirmed off.';

  @override
  String get rescue_ev_car_firstaid_2 =>
      '👁️ Electric shock victims may have internal burns not visible outside.';

  @override
  String get rescue_ev_car_firstaid_3 =>
      '🫁 Toxic battery fumes — move victim upwind, fresh air is critical.';

  @override
  String get rescue_ev_car_firstaid_4 =>
      '🚒 Always call fire brigade for EV accidents — even if no visible fire yet.';

  @override
  String get rescue_bus_type => 'Bus / Minibus';

  @override
  String get rescue_bus_desc =>
      'Large passenger vehicle, multiple victims likely';

  @override
  String get rescue_bus_danger_1 =>
      '👥 Multiple casualties — prioritize who needs help most (triage)';

  @override
  String get rescue_bus_danger_2 => '⛽ Large fuel tank — fire risk is HIGH';

  @override
  String get rescue_bus_danger_3 =>
      '💨 CNG buses have gas cylinders — EXPLOSION RISK if ruptured';

  @override
  String get rescue_bus_danger_4 =>
      '🚪 Emergency exits at rear and roof — know how to use them';

  @override
  String get rescue_bus_step_1_title => 'Assess from outside first';

  @override
  String get rescue_bus_step_1_detail =>
      'Count visible victims. Check for fire/smoke. Don\'t rush in — a second casualty helps no one.';

  @override
  String get rescue_bus_step_2_title => 'Check for CNG cylinders';

  @override
  String get rescue_bus_step_2_detail =>
      'CNG buses have cylindrical tanks on roof or rear. If hissing sound heard — evacuate everyone 100m away immediately.';

  @override
  String get rescue_bus_step_3_title => 'Use emergency exits';

  @override
  String get rescue_bus_step_3_detail =>
      'Red handles at rear door and roof hatch. Push/pull to open. Don\'t wait for front door if jammed.';

  @override
  String get rescue_bus_step_4_title => 'Triage victims — most critical first';

  @override
  String get rescue_bus_step_4_detail =>
      'Walking wounded can help themselves. Focus on unconscious or heavily bleeding victims first.';

  @override
  String get rescue_bus_step_5_title => 'Form human chain for extraction';

  @override
  String get rescue_bus_step_5_detail =>
      'Line up bystanders to pass victims out of windows/exits. One person stabilizes head, others support body.';

  @override
  String get rescue_bus_firstaid_1 =>
      '📞 Call 108 AND 100 — multiple casualties need multiple ambulances.';

  @override
  String get rescue_bus_firstaid_2 =>
      '🏃 Get able-bodied passengers out first — they can then help others.';

  @override
  String get rescue_bus_firstaid_3 =>
      '🔴 Triage: Red = critical (help first), Yellow = serious, Green = walking.';

  @override
  String get rescue_bus_firstaid_4 =>
      '💨 If CNG leak suspected — NO flames, NO phones near the vehicle.';

  @override
  String get rescue_auto_type => 'Auto Rickshaw / Tuk-Tuk';

  @override
  String get rescue_auto_desc =>
      '3-wheeler, open sides, common in Indian roads';

  @override
  String get rescue_auto_danger_1 =>
      '💨 CNG autos — check for hissing gas leak sounds';

  @override
  String get rescue_auto_danger_2 =>
      '🔓 Open sides mean passengers are often thrown out';

  @override
  String get rescue_auto_danger_3 =>
      '⚖️ Autos tip over easily — approach carefully, may be unstable';

  @override
  String get rescue_auto_danger_4 =>
      '🔧 Small vehicle = less protection = more severe injuries';

  @override
  String get rescue_auto_step_1_title => 'Stabilize the auto first';

  @override
  String get rescue_auto_step_1_detail =>
      'Autos tip over easily. Push gently to check stability before leaning in. Ask bystanders to hold it steady.';

  @override
  String get rescue_auto_step_2_title => 'Check all three sides';

  @override
  String get rescue_auto_step_2_detail =>
      'Passengers in autos are often thrown sideways. Check all around the vehicle, not just inside.';

  @override
  String get rescue_auto_step_3_title => 'Driver extraction';

  @override
  String get rescue_auto_step_3_detail =>
      'Driver seat is exposed. Support driver\'s head from behind while helper pulls from front.';

  @override
  String get rescue_auto_step_4_title => 'Passenger extraction';

  @override
  String get rescue_auto_step_4_detail =>
      'Open side means easy access. Support neck, slide passenger out sideways onto flat ground.';

  @override
  String get rescue_auto_firstaid_1 =>
      '🛺 Auto passengers have no seatbelts — expect to find them thrown from vehicle.';

  @override
  String get rescue_auto_firstaid_2 =>
      '🔍 Search radius of 5m around auto for thrown passengers.';

  @override
  String get rescue_auto_firstaid_3 =>
      '🩹 Road rash from open sides is common — cover wounds with clean cloth.';

  @override
  String get rescue_auto_firstaid_4 =>
      '😮 Shock sets in fast in small vehicle accidents — keep victims warm and calm.';
}
