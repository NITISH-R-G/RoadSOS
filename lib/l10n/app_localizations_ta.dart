// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'RoadSOS';

  @override
  String get dashboardTitle => 'RoadSOS';

  @override
  String get sosButton => 'SOS';

  @override
  String get secondsLabel => 'விநாடிகள்';

  @override
  String get sosDispatchWarning =>
      'இன்னும் எதுவும் அனுப்பப்படவில்லை. தவறு என்றால் உடனே ரத்து செய்யவும்.';

  @override
  String get sosIdleTools => 'கூடுதல்';

  @override
  String get sosIdleToolsTitle => 'அவசர கருவிகள் & நிலை';

  @override
  String get sosButtonSub => 'அவசரத்தைத் தொடங்க அழுத்தவும்';

  @override
  String get cancelSos => 'ரத்து செய்';

  @override
  String get orchestratorBystanderStarted =>
      'சுற்றியுள்ளவர்களுக்கு அறிவிப்பு தொடங்கப்பட்டது';

  @override
  String get orchestratorSelfSosStarted => 'சுய SOS தொடங்கப்பட்டது';

  @override
  String get orchestratorAcquiringLocation =>
      'உங்கள் இருப்பிடத்தைப் பெறுகிறது…';

  @override
  String orchestratorLocationSecured(String lat, String lng) {
    return 'இருப்பிடம்: $lat, $lng';
  }

  @override
  String get orchestratorLocationUnavailable =>
      'இருப்பிடம் கிடைக்கவில்லை — இருப்பிட சேவைகளை இயக்கவும் அல்லது திறந்தவெளிக்குச் செல்லவும்.';

  @override
  String get orchestratorManualActionRequired =>
      'கைமுறை நடவடிக்கை தேவை — தானியங்கி உதவி தோல்வியுற்றால், உடனே 108 ஐ அழைக்கவும்.';

  @override
  String get orchestratorSmsNoGpsPayload =>
      'SOS (GPS இல்லை). தயவுசெய்து உடனே அவசர சேவையை அழைக்கவும். RoadSOS இருப்பிடத்தைப் பெற முடியவில்லை.';

  @override
  String get orchestratorAiBrief => 'கிளவுட் AI நிலையை ஆய்வு செய்கிறது…';

  @override
  String orchestratorTriageDone(int level) {
    return 'ஆய்வு முடிந்தது — தீவிரம் $level';
  }

  @override
  String get orchestratorDispatching =>
      'SMS, மெஷ் சிக்னல் மற்றும் பதிவு மூலம் உதவி கோருகிறது…';

  @override
  String get orchestratorSosLive =>
      'SOS நேரலையில் உள்ளது — அனைத்து வழிகளும் செயலில் உள்ளன';

  @override
  String get orchestratorCancelled => 'SOS ரத்து செய்யப்பட்டது';

  @override
  String get mapPlaceholder => 'வரைபடம்';

  @override
  String get actionScene => 'சம்பவம்';

  @override
  String get actionMedicalId => 'மருத்துவ ID';

  @override
  String get actionResponder => 'உதவியாளர்';

  @override
  String get actionSafeWalk => 'பாதுகாப்பான நடை';

  @override
  String get actionFirstAid => 'முதலுதவி';

  @override
  String get actionVitalScan => 'உடல்நிலை ஆய்வு';

  @override
  String get actionMeshChat => 'மெஷ் சாட்';

  @override
  String get actionSettings => 'அமைப்புகள்';

  @override
  String get triageResultTitle => 'AI ஆய்வு முடிவு';

  @override
  String get triageDegradedTitle => 'AI ஆய்வு (ஆஃப்லைன்)';

  @override
  String severityLine(int level, String label) {
    return 'தீவிரம் $level/5 — $label';
  }

  @override
  String get severityCritical => 'மிகவும் ஆபத்தானது';

  @override
  String get severitySevere => 'கடுமையானது';

  @override
  String get severityModerate => 'மிதமானது';

  @override
  String get severityMinor => 'சிறியது';

  @override
  String get severityLow => 'குறைவானது';

  @override
  String get severityUnknown => 'தெரியவில்லை';

  @override
  String get dispatchedServices => 'அனுப்பப்பட்ட சேவைகள்';

  @override
  String get firstAidGuidance => 'முதலுதவி வழிகாட்டுதல்';

  @override
  String get noAiBadge => 'ஆஃப்லைன்';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get sectionConnectivity => 'இணைப்பு';

  @override
  String get sectionLegal => 'சட்டம் & தரவு';

  @override
  String get offlineMapsTitle => 'ஆஃப்லைன் வரைபடங்கள்';

  @override
  String get offlineMapsSubtitle =>
      'வரைபடங்களைப் பதிவிறக்கவும் மற்றும் நிர்வகிக்கவும்';

  @override
  String get meshConfigTitle => 'மெஷ் அமைப்பு';

  @override
  String get meshConfigSubtitle => 'சிக்னல் உணர்திறன் மற்றும் தெரிவுநிலை';

  @override
  String get blackBoxTitle => 'பிளாக் பாக்ஸ் அறிக்கை';

  @override
  String get blackBoxSubtitle =>
      'தரவு மற்றும் ஆய்வுப் பதிவுகளை ஏற்றுமதி செய்யவும்';

  @override
  String get blackBoxSnack => 'பிளாக் பாக்ஸ் PDF உருவாக்கப்படுகிறது…';

  @override
  String get dataPrivacyTitle => 'தரவு தனியுரிமை';

  @override
  String get dataPrivacySubtitle =>
      'உள்ளூர் குறியாக்கம் மற்றும் கிளவுட் ஒத்திசைவை நிர்வகிக்கவும்';

  @override
  String get vitalScanTitle => 'உடல்நிலை ஆய்வு';

  @override
  String get vitalAlignFinger =>
      'ஆய்வு செய்ய உங்கள் ஆள்காட்டி விரலை கேமரா மற்றும் பிளாஷ் மீது வைக்கவும்.';

  @override
  String get settingsLanguage => 'மொழி';

  @override
  String get settingsLanguageSubtitle => 'இடைமுகம் மற்றும் குரல் வெளியீடு';

  @override
  String get incidentAssistantAnalyzed =>
      'சம்பவக் குறிப்பு: முன்பக்க விபத்து பதிவானது. புகை அல்லது நெருப்பு உள்ளதா எனச் சரிபார்க்கவும்.';

  @override
  String get incidentVoiceHint => 'நீங்கள் காண்பதை விவரிக்கவும்…';

  @override
  String get profileAiLine =>
      'மருத்துவ விவரம் SOS இன் போது முதலுதவிக்கு உதவும்.';

  @override
  String get thinkingOffline => 'ஆஃப்லைன் விதிகள் (கிளவுட் இல்லை).';

  @override
  String get sttConfirmKeywords =>
      'நீங்கள் ஆம், உறுதிப்படுத்து, அல்லது உதவி என்று சொல்லலாம்.';

  @override
  String get consentTitle => 'RoadSOS-க்கு வரவேற்கிறோம்';

  @override
  String get consentSummary =>
      'இந்த ஆப் அவசர உதவியை ஒருங்கிணைக்க இருப்பிடம், இயக்கம் மற்றும் மருத்துவ விவரங்களைப் பயன்படுத்துகிறது. இந்தியத் தரவு பாதுகாப்புச் சட்டத்தின்படி உங்கள் அனுமதி தேவை.';

  @override
  String get consentExtendedRetentionLabel =>
      'ஆராய்ச்சி நோக்கத்திற்காகத் தரவை 90 நாட்களுக்கு மேல் வைத்திருக்க அனுமதி (விருப்பத்தேர்வு)';

  @override
  String get consentAccept => 'ஏற்கிறேன் — தொடரவும்';

  @override
  String get consentPrivacyButton => 'தனியுரிமை அறிவிப்பு';

  @override
  String get privacyPolicyTitle => 'தனியுரிமை அறிவிப்பு';

  @override
  String get privacyPolicyLanguageEn => 'English';

  @override
  String get privacyPolicyLanguageHi => 'हिंदी';

  @override
  String get goodSamaritanTitle => 'நல்ல சமாரியன் பாதுகாப்பு';

  @override
  String get goodSamaritanLead =>
      'உதவி செய்யும்போது நீங்கள் சட்டப்பூர்வமாகப் பாதுகாக்கப்படுகிறீர்கள்.';

  @override
  String get goodSamaritanBody =>
      'இந்தியச் சட்டப்படி, விபத்தில் சிக்கியவர்களுக்கு உதவும் நபர்களை போலீஸாரோ அல்லது அதிகாரிகளோ தொந்தரவு செய்யக்கூடாது. உங்கள் உதவி ஒரு உயிரைக் காக்கலாம்.';

  @override
  String get goodSamaritanContinue => 'புரிந்தது';

  @override
  String get nearbySosSectionTitle => 'அருகிலுள்ள SOS';

  @override
  String get nearbySosToggleTitle => 'அருகிலுள்ள SOS அறிவிப்புகள்';

  @override
  String get nearbySosToggleSubtitle =>
      'அருகில் யாருக்காவது உதவி தேவைப்பட்டால் எனக்குத் தெரிவிக்கவும்';

  @override
  String get nearbySosLearnProtection =>
      'பாதுகாப்பு விதிகளைப் பற்றி தெரிந்து கொள்ளுங்கள்';

  @override
  String get aiThinkingTraceTitle => 'ஆய்வு விளக்கம்';

  @override
  String get crisisCompanionTitle => 'நெருக்கடி உதவியாளர்';

  @override
  String get crisisCompanionBreathing =>
      'சீராக மூச்சு விடுங்கள். நிலைமையைக் கண்காணித்து வருகிறோம்.';

  @override
  String get sceneIntelligenceTitle => 'சம்பவ நுண்ணறிவு';

  @override
  String get helpEtaPlaceholder => 'நேரம் கிடைக்கவில்லை';

  @override
  String get talkButton => 'பேசவும்';

  @override
  String get settingsExtendedRetentionTitle => 'கூடுதல் தரவு சேமிப்பு';

  @override
  String get settingsExtendedRetentionSubtitle =>
      '90 நாட்களுக்குப் பிறகும் சம்பவ விவரங்களைச் சேமித்து வைக்கவும்.';

  @override
  String get navSos => 'SOS';

  @override
  String get navSafetyTools => 'பாதுகாப்பு கருவிகள்';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String get drivingModeBanner =>
      'டிரைவிங் மோடு — விபத்து கண்டறிதல் செயலில் உள்ளது';

  @override
  String get safetyToolsHint =>
      'அனைத்து பாதுகாப்பு அம்சங்களும் கீழே உள்ள \"பாதுகாப்பு கருவிகள்\" பகுதியில் உள்ளன';

  @override
  String get sectionEmergencyResponse => 'அவசரக்கால பதிலளிப்பு';

  @override
  String get sectionHealthSafety => 'உடல்நலம் & பாதுகாப்பு';

  @override
  String get sectionRecords => 'பதிவுகள்';

  @override
  String get sectionMyInformation => 'எனது தகவல்';

  @override
  String get sectionSettingsPrivacy => 'அமைப்புகள் & தனியுரிமை';

  @override
  String get actionSafeWalkSub =>
      'இலக்கை அடையாவிட்டால் தானாகவே SOS அனுப்பப்படும்';

  @override
  String get actionCaptureScene => 'சம்பவத்தைப் பதிவு செய்';

  @override
  String get actionCaptureSceneSub =>
      'AI உதவியுடன் விபத்துப் புகைப்படங்களை ஆய்வு செய்யவும்';

  @override
  String get actionResponderSub =>
      'அருகிலுள்ள SOS சிக்னல்களை வரைபடத்தில் காணவும்';

  @override
  String get actionFirstAidSub => 'படிப்படியான அவசர கால வழிகாட்டுதல்கள்';

  @override
  String get actionVitalScanSub =>
      'இதயத் துடிப்பு மற்றும் ஆக்ஸிஜன் அளவைச் சரிபார்க்கவும்';

  @override
  String get actionMedicalIdSub =>
      'இரத்த வகை, ஒவ்வாமை மற்றும் தொடர்புகளைக் காட்டவும்';

  @override
  String get actionMeshChatSub =>
      'இணையம் இல்லாத போது புளூடூத் மூலம் செய்தி அனுப்பவும்';

  @override
  String get actionOfflineMaps => 'Offline Maps';

  @override
  String get actionOfflineMapsSub =>
      'சிக்னல் இல்லாத இடங்களுக்கான வரைபடங்களைப் பதிவிறக்கவும்';

  @override
  String get actionActivityLog => 'Activity Log';

  @override
  String get actionActivityLogSub =>
      'போலீஸ் மற்றும் காப்பீட்டுக்கான GPS மற்றும் ஆய்வுக் குறிப்புகள்';

  @override
  String get actionEditProfile => 'விவரங்களைத் திருத்து';

  @override
  String get actionEditProfileSub => 'பெயர், இரத்த வகை, அவசர தொடர்புகள்';

  @override
  String get actionMedicalIdCard => 'மருத்துவ ID அட்டை';

  @override
  String get actionMedicalIdCardSub =>
      'அவசர உதவியாளர்களுக்கான மருத்துவத் தகவல்கள்';

  @override
  String get actionAllSettings => 'அனைத்து அமைப்புகள்';

  @override
  String get actionAllSettingsSub =>
      'மொழி, வரைபடங்கள், அறிவிப்புகள், தனியுரிமை';

  @override
  String get actionActivityLogFullSub =>
      'காப்பீடு மற்றும் போலீஸ் பதிவுகளுக்கான முழு வரலாறு';

  @override
  String get rescueGuideTitle => 'மீட்பு வழிகாட்டி';

  @override
  String get vehicleRescueTitle => 'வாகன மீட்பு';

  @override
  String get rescueOfflineBadge => 'ஆஃப்லைன்';

  @override
  String get vehicleRescueBannerTitle => 'வாகன மீட்பு வழிகாட்டி';

  @override
  String get vehicleRescueBannerSub =>
      'மீட்பு வழிமுறைகளைப் பெற விபத்தில் சிக்கிய வாகன வகையைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get plateNumberLabel => 'வண்டி எண் (விருப்பத்தேர்வு)';

  @override
  String get plateNumberHint => 'TN 11 AB 1234';

  @override
  String get selectVehicleType => 'வாகன வகையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get rescueOfflineTip =>
      'அனைத்து மீட்பு வழிமுறைகளும் இணையம் இல்லாமலேயே வேலை செய்யும்.';

  @override
  String get highVoltageWarning => 'அதிவேக மின்சாரம்';

  @override
  String get rescueDangersTitle => '⚠️  ஆபத்துகள் — முதலில் படிக்கவும்';

  @override
  String get rescueExtractionTitle => '👐  மீட்புப் படிகள்';

  @override
  String get rescueFirstAidTitle => '🩺  ஆம்புலன்ஸ் வரும் வரை செய்ய வேண்டியவை';

  @override
  String get rescueCriticalBadge => 'முக்கியமானது';

  @override
  String get dialerError =>
      'அழைப்பைத் தொடங்க முடியவில்லை. தயவுசெய்து 108-ஐ நேரடியாக அழைக்கவும்.';

  @override
  String get callAmbulanceButton => 'ஆம்புலன்ஸை அழைக்கவும் — 108';

  @override
  String get editMedicalIdTitle => 'மருத்துவ விவரங்களைத் திருத்து';

  @override
  String get profileUpdatedSnack => 'மருத்துவ விவரங்கள் புதுப்பிக்கப்பட்டன';

  @override
  String get fieldFullName => 'முழு பெயர்';

  @override
  String get fieldBloodType => 'இரத்த வகை';

  @override
  String get fieldAllergies => 'ஒவ்வாமைகள்';

  @override
  String get fieldMedications => 'தற்போது உட்கொள்ளும் மருந்துகள்';

  @override
  String get fieldConditions => 'நீண்ட கால நோய்கள்';

  @override
  String get sectionEmergencyContacts => 'அவசர தொடர்புகள்';

  @override
  String get fieldPrimaryContact => 'முதன்மை தொடர்பு';

  @override
  String fieldAdditionalContact(int index) {
    return 'கூடுதல் தொடர்பு $index';
  }

  @override
  String get addContactButton => 'தொடர்பைச் சேர்க்கவும்';

  @override
  String get medicalIdTitle => 'அவசர மருத்துவ ID';

  @override
  String get scanForSummary => 'மருத்துவச் சுருக்கத்தைப் பெற ஸ்கேன் செய்யவும்';

  @override
  String get notSet => 'பதிவு செய்யப்படவில்லை';

  @override
  String get medicalCardTip =>
      'குறிப்பு: அவசர உதவியாளர்களுக்காக இந்தத் திரையைத் திறந்து வைக்கவும். லாக்-ஸ்கிரீன் வால்பேப்பராக மாற்ற உங்கள் போனின் ஸ்கிரீன்ஷாட் வசதியைப் பயன்படுத்தவும்.';

  @override
  String get firstAidGuideTitle => '🩺 முதலுதவி வழிகாட்டி';

  @override
  String get describeInjuryHint => 'காயத்தை விவரிக்கவும்...';

  @override
  String get firstAidError =>
      'இந்த சாதனத்தில் முதலுதவி வழிகாட்டலை ஏற்ற முடியவில்லை.';

  @override
  String get verifiedSolutionsTitle => 'சரிபார்க்கப்பட்ட மருத்துவத் தீர்வுகள்';

  @override
  String get aiInjuryIdTitle => 'AI காயம் அடையாளம் காணுதல்';

  @override
  String get typeInjuryPrompt =>
      'சரியான, சரிபார்க்கப்பட்ட முதலுதவி தீர்வுகளைப் பெற காயத்தின் பெயரை உள்ளிடவும்.';

  @override
  String get chipSevereBleeding => 'கடுமையான இரத்தப்போக்கு';

  @override
  String get chipMuscleTear => 'தசை கிழிவு';

  @override
  String get chipBrainInjury => 'மூளைக் காயம்';

  @override
  String get chipSprains => 'சுளுக்கு';

  @override
  String get multimodalDigitalTwin => 'மல்டிமோடல்: டிஜிட்டல் ட்வின்';

  @override
  String get aiInterviewNuance => 'AI நேர்காணல்: சூழ்நிலை நுணுக்கம்';

  @override
  String get actionGuidanceNextSteps => 'செயல் வழிகாட்டல்: அடுத்த படிகள்';

  @override
  String get situationBriefLive => 'சூழ்நிலைச் சுருக்கம் (நேரடி)';

  @override
  String get sceneAttached => 'காட்சி இணைக்கப்பட்டது';

  @override
  String get captureAttachPhoto => 'புகைப்படத்தை எடுக்கவும் / இணைக்கவும்';

  @override
  String get photoAttachedNote =>
      'இந்த அறிக்கையுடன் புகைப்படம் இணைக்கப்பட்டுள்ளது (இந்த பதிப்பில் தானாகவே பகுப்பாய்வு செய்யப்படவில்லை).';

  @override
  String get scenePhotoError =>
      'இந்தச் சாதனத்தில் காட்சிப் புகைப்படத்தை எடுக்க முடியவில்லை.';

  @override
  String get scenePhotoAttached => 'காட்சி புகைப்படம் இணைக்கப்பட்டது.';

  @override
  String get questionProgress => 'கேள்வி முன்னேற்றம்:';

  @override
  String get describeIncidentPrompt => 'தயவுசெய்து சம்பவத்தை விவரிக்கவும்';

  @override
  String get speakOrTypeHint => 'பேசவும் அல்லது தட்டச்சு செய்யவும்…';

  @override
  String get interviewCompleteMessage =>
      '✓ நேர்காணல் முடிந்தது. அனைத்து முக்கியமான தகவல்களும் சேகரிக்கப்பட்டன.';

  @override
  String get actionStepsTitle => '🎯 செயல் படிகள்';

  @override
  String get reportNewIncidentButton => 'புதிய சம்பவத்தைப் புகாரளிக்கவும்';

  @override
  String get sceneCollision => 'வாகன மோதல்';

  @override
  String get scenePedestrian => 'பாதசாரி விபத்து';

  @override
  String get sceneRollover => 'வாகனம் கவிழ்ந்தது';

  @override
  String get sceneFire => 'தீ விபத்து';

  @override
  String get sceneUnknown => 'தெரியவில்லை';

  @override
  String get activityLogTitle => 'செயல்பாட்டுப் பதிவு';

  @override
  String get activityLogSubtitle =>
      'GPS, ட்ரயேஜ், SMS/மெஷ்/கிளவுட் படிகள் — காப்பீடு அல்லது போலீஸ் பதிவுகளுக்காக';

  @override
  String get reviewPermissionsTitle => 'அனுமதிகளை மதிப்பாய்வு செய்யவும்';

  @override
  String get reviewPermissionsSubtitle =>
      'அமைவு வழிகாட்டியை மீண்டும் திறக்கவும்';

  @override
  String get backgroundVolumeSosTitle => 'பின்னணி வால்யூம் SOS';

  @override
  String get backgroundVolumeSosSubtitle =>
      'அணுகல்தன்மையை (Accessibility) திறந்து, லாக்-ஸ்கிரீன் சைகைக்காக (3× மேலே + 3× கீழே) RoadSOS-ஐ இயக்கவும்';

  @override
  String get nearbySosFirebaseError =>
      'அருகிலுள்ள SOS-க்கு Firebase அமைப்பு தேவை. நிலைமாற்றி அணைக்கப்பட்டது.';

  @override
  String get rescue_car_type => 'கார் / செடான் / ஹேட்ச்பேக்';

  @override
  String get rescue_car_desc => 'சாதாரண 4-சக்கர பயணிகள் வாகனம்';

  @override
  String get rescue_car_danger_1 =>
      '⛽ எரிபொருள் தொட்டி பின்புறம் உள்ளது — வாகனத்தின் பின்புறம் நெருப்பு வராமல் பார்த்துக் கொள்ளவும்';

  @override
  String get rescue_car_danger_2 =>
      '💥 விபத்துக்குப் பிறகும் ஏர்பேக்குகள் விரியக்கூடும் — வாகனத்தின் உட்பகுதியல் அதிகம் குனிய வேண்டாம்';

  @override
  String get rescue_car_danger_3 =>
      '🔋 12V பேட்டரி முன்பக்கம் உள்ளது — அதன் முனைகளைத் தொட வேண்டாம்';

  @override
  String get rescue_car_danger_4 =>
      '🔥 என்ஜின் தீப்பிடிக்க வாய்ப்புள்ளது — புகை தெரிந்தால், பாதிக்கப்பட்டவரை உடனே 30மீ தூரத்திற்கு அப்பால் கொண்டு செல்லவும்';

  @override
  String get rescue_car_step_1_title => 'சம்பவ இடத்தை பாதுகாப்பானதாக்கவும்';

  @override
  String get rescue_car_step_1_detail =>
      'முடிந்தால் என்ஜினை அணைக்கவும். ஹசார்ட் விளக்குகளை ஒளிரவிடவும். போக்குவரத்தை எச்சரிக்க 50மீ பின்னால் ஏதாவது பொருட்களை வைக்கவும்.';

  @override
  String get rescue_car_step_2_title =>
      'பாதிக்கப்பட்டவர் உணர்வுடன் இருக்கிறாரா எனச் சரிபார்க்கவும்';

  @override
  String get rescue_car_step_2_detail =>
      'தோளைத் தட்டி \"உங்களுக்கு நான் பேசுவது கேட்கிறதா?\" என்று சத்தமாகக் கேட்கவும். பதில் இல்லை என்றால், உடனே 108 ஐ அழைக்கவும். அவர்களை உலுக்க வேண்டாம்.';

  @override
  String get rescue_car_step_3_title =>
      'பாதிக்கப்பட்டவரை இப்போதே நகர்த்த வேண்டாம்';

  @override
  String get rescue_car_step_3_detail =>
      'அவர் மூச்சு விடுகிறார் மற்றும் உடனடி ஆபத்து (நெருப்பு/வெள்ளம்) இல்லை என்றால், அவரை அசையாமல் இருக்க விடவும். நகர்த்துவது முதுகுத்தண்டு காயத்தை அதிகமாக்கும்.';

  @override
  String get rescue_car_step_4_title => 'கதவை கவனமாகத் திறக்கவும்';

  @override
  String get rescue_car_step_4_detail =>
      'கதவு பிடியை இழுத்து, அதே சமயம் தோளால் கதவை வெளிப்புறமாகத் தள்ளவும். கதவு சிக்கியிருந்தால், முதலில் பின் கதவுகளை முயற்சிக்கவும்.';

  @override
  String get rescue_car_step_5_title => 'கழுத்து மற்றும் தலையைத் தாங்கவும்';

  @override
  String get rescue_car_step_5_detail =>
      'பாதிக்கப்பட்டவரின் தலையின் இருபுறமும் கைகளை வைக்கவும். தலையை முதுகுத்தண்டுடன் நேராக வைத்திருக்கவும். வேறு யாரையாவது உதவிக்கு அழைக்கவும்.';

  @override
  String get rescue_car_step_6_title =>
      'பாதிக்கப்பட்டவரை கிடைமட்டமாக வெளியே நகர்த்தவும்';

  @override
  String get rescue_car_step_6_detail =>
      'ஒருவர் தலையைப் பிடிக்க, மற்றொருவர் அக்குள்களுக்கு அடியில் பிடித்து மெதுவாக வெளியே எடுக்கவும். முதுகுத்தண்டை ஒருபோதும் திருக வேண்டாம்.';

  @override
  String get rescue_car_step_7_title =>
      'மீட்பு நிலையில் (Recovery position) வைக்கவும்';

  @override
  String get rescue_car_step_7_detail =>
      'மூச்சு விடுகிறார் என்றால், அவர் விக்கிப் போவதைத் தடுக்க ஒருபுறமாகச் சாய்த்து வைக்கவும். ஆம்புலன்ஸ் வரும் வரை கண்காணித்து வரவும்.';

  @override
  String get rescue_car_firstaid_1 =>
      '🩸 ரத்தப்போக்கு இருந்தால்: சுத்தமான துணியால் அழுத்திப் பிடிக்கவும். அதை அகற்ற வேண்டாம்.';

  @override
  String get rescue_car_firstaid_2 =>
      '🫁 மூச்சு விடவில்லை என்றால்: CPR தொடங்கவும் — 30 முறை நெஞ்சை அழுத்தி 2 முறை செயற்கை சுவாசம் அளிக்கவும்.';

  @override
  String get rescue_car_firstaid_3 =>
      '🦴 எலும்பு முறிவு இருப்பதாகத் தெரிந்தால்: அதை நேராக்க முயற்சிக்க வேண்டாம்.';

  @override
  String get rescue_car_firstaid_4 =>
      '🚨 பாதிக்கப்பட்டவரிடம் தொடர்ந்து பேசிக் கொண்டே இருங்கள் — அவர்களை அமைதியாகவும் உணர்வுடனும் வைத்திருக்கவும்.';

  @override
  String get fuel_petrol_diesel => 'பெட்ரோல் / டீசல்';

  @override
  String get fuel_diesel => 'டீசல்';

  @override
  String get fuel_petrol => 'பெட்ரோல்';

  @override
  String get fuel_electric => 'மின்சாரம் / பேட்டரி';

  @override
  String get fuel_diesel_cng => 'டீசல் / CNG';

  @override
  String get fuel_multi => 'CNG / பெட்ரோல் / மின்சாரம்';

  @override
  String get rescue_truck_type => 'லாரி / கனரக வாகனம்';

  @override
  String get rescue_truck_desc =>
      'கனரக சரக்கு வாகனம், பெரிய எரிபொருள் தொட்டிகள்';

  @override
  String get rescue_truck_danger_1 =>
      '⛽ இருபுறமும் பெரிய டீசல் தொட்டிகள் — தீ விபத்து ஏற்பட அதிக வாய்ப்பு உள்ளது';

  @override
  String get rescue_truck_danger_2 =>
      '⚡ 24V மின் அமைப்பு — சாதாரண கார்களை விட ஆபத்தானது';

  @override
  String get rescue_truck_danger_3 =>
      '🏋️ ஓட்டுநர் இருக்கை மிகவும் உயரத்தில் இருக்கும் — அவரை இறக்கும் போது கீழே விழும் ஆபத்து உள்ளது';

  @override
  String get rescue_truck_danger_4 =>
      '📦 சரக்குகள் சரிந்து விழக்கூடும் — பக்கவாட்டில் இருந்து கவனமாக அணுகவும்';

  @override
  String get rescue_truck_danger_5 =>
      '🔧 ஏர் பிரேக்குகள் திடீரென நகரலாம் — சக்கரங்களுக்கு அருகில் செல்ல வேண்டாம்';

  @override
  String get rescue_truck_step_1_title =>
      'பக்கவாட்டில் இருந்து மட்டும் அணுகவும்';

  @override
  String get rescue_truck_step_1_detail =>
      'முன்பக்கமோ (என்ஜின் தீ) அல்லது பின்பக்கமோ (சரக்கு) செல்ல வேண்டாம். ஓட்டுநர் பக்கக் கதவு வழியாக அணுகவும்.';

  @override
  String get rescue_truck_step_2_title => 'லாரியை அசையாமல் நிறுத்தவும்';

  @override
  String get rescue_truck_step_2_detail =>
      'பாதுகாப்பாக இருந்தால் ஹேண்ட்பிரேக் போடவும். சக்கரங்களுக்கு அடியில் கல் அல்லது கட்டையை வைத்து லாரி உருளாமல் தடுக்கவும்.';

  @override
  String get rescue_truck_step_3_title => 'கவனமாக மேலே ஏறவும்';

  @override
  String get rescue_truck_step_3_detail =>
      'லாரியில் உள்ள படிகள்/பிடிகளைப் பயன்படுத்தவும். கதவு பிடியைப் பிடித்து ஏற வேண்டாம் — அது உடைந்து விழ வாய்ப்புள்ளது.';

  @override
  String get rescue_truck_step_4_title => 'ஓட்டுநரின் நிலையைச் சரிபார்க்கவும்';

  @override
  String get rescue_truck_step_4_detail =>
      'தட்டிப் பார்க்கவும். ஸ்டீயரிங் வீலில் ஓட்டுநர் சிக்கியிருக்கலாம். அவரை வலுக்கட்டாயமாக வெளியே இழுக்க வேண்டாம்.';

  @override
  String get rescue_truck_step_5_title => 'வெளியே எடுக்க 3+ நபர்கள் தேவை';

  @override
  String get rescue_truck_step_5_detail =>
      'ஒருவர் தலை/கழுத்தைப் பிடிக்க, மற்ற இருவர் உடலைத் தாங்க வேண்டும். மெதுவாக கீழே இறக்கவும். கீழே போட்டுவிட வேண்டாம்.';

  @override
  String get rescue_truck_step_6_title =>
      'பாதிக்கப்பட்டவரை 50மீ தூரம் தள்ளி வைக்கவும்';

  @override
  String get rescue_truck_step_6_detail =>
      'லாரிகளில் அதிக எரிபொருள் இருக்கும். தீப்பிடிக்க வாய்ப்புள்ளதால் வெகுதூரம் தள்ளி வைக்கவும்.';

  @override
  String get rescue_truck_firstaid_1 =>
      '🚨 108 மற்றும் தீயணைப்புத் துறைக்கு (101) உடனே அழைக்கவும் — லாரி தீ வேகமாகப் பரவும்.';

  @override
  String get rescue_truck_firstaid_2 =>
      '🩸 ஓட்டுநர் ஸ்டீயரிங்கில் மோதியிருக்கலாம் — நெஞ்சுப் பகுதியில் காயம் உள்ளதா எனப் பார்க்கவும்.';

  @override
  String get rescue_truck_firstaid_3 =>
      '👁️ தலைக் காயங்களைச் சரிபார்க்கவும் — ஹெல்மெட் இல்லாத மோதல் உயிருக்கு ஆபத்தானது.';

  @override
  String get rescue_truck_firstaid_4 =>
      '🦺 அபாயகரமான பொருட்கள் (Hazmat) இருந்தால், தள்ளி நின்று 112 ஐ அழைக்கவும்.';

  @override
  String get rescue_bike_type => 'மோட்டார் சைக்கிள் / ஸ்கூட்டர் / பைக்';

  @override
  String get rescue_bike_desc =>
      'இருசக்கர வாகனம், ஓட்டுநர் வாகனத்திலிருந்து தூக்கி எறியப்பட வாய்ப்புள்ளது';

  @override
  String get rescue_bike_danger_1 =>
      '⛽ என்ஜின் அருகில் சிறிய எரிபொருள் தொட்டி — எளிதில் தீப்பிடிக்கும்';

  @override
  String get rescue_bike_danger_2 =>
      '🪖 ஹெல்மெட்டை கழற்ற வேண்டாம் — இது முதுகுத்தண்டைப் பாதிக்கலாம்';

  @override
  String get rescue_bike_danger_3 =>
      '🛣️ சாலையில் உரசிச் சென்றதால் தோலில் காயங்கள் (Road rash) இருக்கலாம்';

  @override
  String get rescue_bike_danger_4 =>
      '🔥 சூடான சைலன்சர் குழாய் — தொடுவதைத் தவிர்க்கவும், சுடக்கூடும்';

  @override
  String get rescue_bike_step_1_title => 'பைக்கை முதலில் தள்ளி வைக்கவும்';

  @override
  String get rescue_bike_step_1_detail =>
      'பைக் தான் தீ விபத்துக்குக் காரணம். உதவியைத் தொடங்கும் முன் பைக்கை 10மீ தூரத்திற்கு அப்பால் தள்ளி வைக்கவும்.';

  @override
  String get rescue_bike_step_2_title => 'ஹெல்மெட்டை ஒருபோதும் கழற்ற வேண்டாம்';

  @override
  String get rescue_bike_step_2_detail =>
      'பாதிக்கப்பட்டவர் கேட்டாலும் கழற்ற வேண்டாம். இது உயிருக்கே ஆபத்தாக முடியும். மருத்துவர்கள் மட்டுமே கழற்ற வேண்டும்.';

  @override
  String get rescue_bike_step_3_title => 'மூச்சு விடுவதைச் சரிபார்க்கவும்';

  @override
  String get rescue_bike_step_3_detail =>
      'ஹெல்மெட்டின் முகப்பு கண்ணாடியைத் திறந்து மூச்சு விடுவதை உணரவும். வாந்தி எடுத்தால், தலையை அசையாமல் ஒருபுறம் சாய்க்கவும்.';

  @override
  String get rescue_bike_step_4_title => 'தோல் காயங்களைச் சரிபார்க்கவும்';

  @override
  String get rescue_bike_step_4_detail =>
      'சறுக்கிச் சென்றதால் ஏற்பட்ட காயங்கள். சுத்தமான துணியால் மூடவும் — இப்போதே தண்ணீரால் கழுவ வேண்டாம்.';

  @override
  String get rescue_bike_step_5_title =>
      'ஓட்டுநரை அசையாமல் சமதளத்தில் வைக்கவும்';

  @override
  String get rescue_bike_step_5_detail =>
      'தூக்கி எறியப்பட்டதால் தண்டுவட பாதிப்பு இருக்கலாம். உதவி வரும் வரை அவரைத் தட்டையாகப் படுக்க வைக்கவும்.';

  @override
  String get rescue_bike_step_6_title => 'உடலை வெதுவெதுப்பாக வைத்திருக்கவும்';

  @override
  String get rescue_bike_step_6_detail =>
      'அதிர்ச்சியால் உடல் குளிர்ச்சியடையலாம். ஜாக்கெட் அல்லது போர்வையால் மூடவும். தொடர்ந்து பேசிக் கொண்டே இருக்கவும்.';

  @override
  String get rescue_bike_firstaid_1 =>
      '🪖 ஹெல்மெட்டை கழற்றக் கூடாது — இதுவே பைக் விபத்துகளின் மிக முக்கியமான விதி.';

  @override
  String get rescue_bike_firstaid_2 =>
      '🦴 எலும்பு முறிவு இருப்பதாகக் கருதவும் — அதை நேராக்க முயல வேண்டாம்.';

  @override
  String get rescue_bike_firstaid_3 =>
      '😮 அதிர்ச்சி ஏற்படலாம் — கால்களை சற்று உயர்த்திப் படுக்க வைக்கவும்.';

  @override
  String get rescue_bike_firstaid_4 =>
      '🩸 தோல் காயங்களில் ரத்தம் அதிகம் வரலாம், ஆனால் அது உயிருக்கு ஆபத்தல்ல — தலை மற்றும் தண்டுவடத்தைக் கவனிக்கவும்.';

  @override
  String get rescue_ev_car_type => 'மின்சார வாகனம் (EV கார்)';

  @override
  String get rescue_ev_car_desc =>
      'பேட்டரி மூலம் இயங்கும் கார் — மின்சார ஆபத்துகள் இருக்கலாம்';

  @override
  String get rescue_ev_car_danger_1 =>
      '⚡ உயர் அழுத்த பேட்டரி (400-800V) — தொட்டால் உயிருக்கு ஆபத்து';

  @override
  String get rescue_ev_car_danger_2 =>
      '🔥 லித்தியம் பேட்டரி தீ 1000°C வரை எரியும் — இதை அணைப்பது மிகவும் கடினம்';

  @override
  String get rescue_ev_car_danger_3 =>
      '🌊 கார் தண்ணீருக்குள் இருந்தால் — தள்ளி நிற்கவும், மின்சாரம் பாய வாய்ப்புள்ளது';

  @override
  String get rescue_ev_car_danger_4 =>
      '💨 பேட்டரி தீயால் நச்சு வாயுக்கள் வெளியேறும் — காற்றின் திசையை கவனித்து நிற்கவும்';

  @override
  String get rescue_ev_car_danger_5 =>
      '🔄 என்ஜின் சத்தம் இல்லாததால் கார் \'ஆன்\' நிலையில் இருப்பது தெரியாது';

  @override
  String get rescue_ev_car_step_1_title =>
      'ஆரஞ்சு நிற கேபிள்களைத் தொட வேண்டாம்';

  @override
  String get rescue_ev_car_step_1_detail =>
      'ஆரஞ்சு நிற கம்பிகள் அதிக மின்சாரத்தைக் கொண்டு செல்லும். அவை வெளியே தெரிந்தால் காரைத் தொடவே வேண்டாம்.';

  @override
  String get rescue_ev_car_step_2_title => 'காரை அணைக்கவும்';

  @override
  String get rescue_ev_car_step_2_detail =>
      'பாதுகாப்பாக இருந்தால் பவர் பட்டனை அழுத்தவும். அவசர மின் துண்டிப்பு ஸ்விட்ச் (ஆரஞ்சு நிறம்) இருக்கிறதா எனப் பார்க்கவும்.';

  @override
  String get rescue_ev_car_step_3_title =>
      'பேட்டரி சேதமடைந்துள்ளதா எனப் பார்க்கவும்';

  @override
  String get rescue_ev_car_step_3_detail =>
      'தரைக்கு அடியில் உள்ள பேட்டரி சேதமடைந்தாலோ அல்லது புகை வந்தாலோ, பாதிக்கப்பட்டவரை 30மீ தூரம் தள்ளி வைக்கவும்.';

  @override
  String get rescue_ev_car_step_4_title => 'மீட்பு முறை சாதாரண காரைப் போன்றதே';

  @override
  String get rescue_ev_car_step_4_detail =>
      'மின்சாரக் கசிவோ புகையோ இல்லை என உறுதி செய்த பின், சாதாரண காரைப் போலவே மீட்புப் பணிகளைச் செய்யவும்.';

  @override
  String get rescue_ev_car_step_5_title =>
      'பேட்டரி தீப்பிடித்தால் — ஓடிவிடவும்';

  @override
  String get rescue_ev_car_step_5_detail =>
      'சாதாரண தீயணைப்பான்களால் இதை அணைக்க முடியாது. அனைவரையும் 50மீ தூரம் தள்ளி வைத்துவிட்டு தீயணைப்புத் துறைக்கு (101) அழைக்கவும்.';

  @override
  String get rescue_ev_car_firstaid_1 =>
      '⚡ மின்சாரம் பாய்ந்திருந்தால்: மின்சாரம் முற்றிலும் நிறுத்தப்பட்டதை உறுதி செய்யாமல் அவர்களைத் தொட வேண்டாம்.';

  @override
  String get rescue_ev_car_firstaid_2 =>
      '👁️ மின்சாரத் தாக்கத்தால் உட்புறக் காயங்கள் ஏற்படலாம், அவை வெளியே தெரியாது.';

  @override
  String get rescue_ev_car_firstaid_3 =>
      '🫁 நச்சுப் புகையிலிருந்து காக்க பாதிக்கப்பட்டவரை நல்ல காற்று வரும் இடத்திற்கு மாற்றவும்.';

  @override
  String get rescue_ev_car_firstaid_4 =>
      '🚒 EV விபத்துகளுக்கு எப்போதும் தீயணைப்புத் துறையை அழைக்கவும் — தீ வெளியே தெரியாவிட்டாலும்.';

  @override
  String get rescue_bus_type => 'பேருந்து / மினிபஸ்';

  @override
  String get rescue_bus_desc =>
      'பெரிய பயணிகள் வாகனம், பலர் காயமடைய வாய்ப்புள்ளது';

  @override
  String get rescue_bus_danger_1 =>
      '👥 பலர் காயமடைந்திருக்கலாம் — யாருக்கு முதலில் உதவி தேவை எனத் தீர்மானிக்கவும்';

  @override
  String get rescue_bus_danger_2 =>
      '⛽ பெரிய எரிபொருள் தொட்டி — தீ விபத்து ஏற்பட அதிக வாய்ப்பு உள்ளது';

  @override
  String get rescue_bus_danger_3 =>
      '💨 CNG பேருந்துகளில் கேஸ் சிலிண்டர்கள் இருக்கும் — வெடிக்க வாய்ப்புள்ளது';

  @override
  String get rescue_bus_danger_4 =>
      '🚪 அவசர வழிகள் (பின்புறம் மற்றும் கூரை) எங்குள்ளது எனத் தெரிந்து கொள்ளவும்';

  @override
  String get rescue_bus_step_1_title =>
      'முதலில் வெளியில் இருந்து ஆய்வு செய்யவும்';

  @override
  String get rescue_bus_step_1_detail =>
      'எத்தனை பேர் காயமடைந்துள்ளனர் எனப் பார்க்கவும். புகை வருகிறதா எனச் சரிபார்க்கவும். அவசரப்பட்டு உள்ளே நுழைய வேண்டாம்.';

  @override
  String get rescue_bus_step_2_title => 'CNG சிலிண்டர்களைச் சரிபார்க்கவும்';

  @override
  String get rescue_bus_step_2_detail =>
      'கேஸ் கசியும் சத்தம் கேட்டால், அனைவரையும் உடனே 100மீ தூரத்திற்கு அப்பால் கொண்டு செல்லவும்.';

  @override
  String get rescue_bus_step_3_title => 'அவசர வழிகளைப் பயன்படுத்தவும்';

  @override
  String get rescue_bus_step_3_detail =>
      'முன்கதவு சிக்கியிருந்தால், பின்பக்க அவசர கதவு அல்லது கூரை வழியைப் பயன்படுத்தவும்.';

  @override
  String get rescue_bus_step_4_title => 'முக்கியமானவர்களுக்கு முதலில் உதவவும்';

  @override
  String get rescue_bus_step_4_detail =>
      'நடக்க முடிந்தவர்கள் தாங்களாகவே வெளியே வரலாம். சுயநினைவற்ற அல்லது அதிக ரத்தப்போக்கு உள்ளவர்களுக்கு முதலில் உதவவும்.';

  @override
  String get rescue_bus_step_5_title => 'அனைவரும் இணைந்து மீட்கவும்';

  @override
  String get rescue_bus_step_5_detail =>
      'மக்களை வரிசையாக நிற்க வைத்து பாதிக்கப்பட்டவர்களை ஜன்னல் வழியாக வெளியே எடுக்கவும். தலை மற்றும் கழுத்தைத் தாங்கவும்.';

  @override
  String get rescue_bus_firstaid_1 =>
      '📞 108 மற்றும் 100-க்கு அழைக்கவும் — பல ஆம்புலன்ஸ்கள் தேவைப்படலாம்.';

  @override
  String get rescue_bus_firstaid_2 =>
      '🏃 ஆரோக்கியமான பயணிகளை முதலில் வெளியேற்றவும் — அவர்கள் மற்றவர்களுக்கு உதவலாம்.';

  @override
  String get rescue_bus_firstaid_3 =>
      '🔴 முக்கியத்துவம்: சிவப்பு = அவசரம் (முதலில் உதவவும்), மஞ்சள் = தீவிரம், பச்சை = லேசான காயம்.';

  @override
  String get rescue_bus_firstaid_4 =>
      '💨 CNG கசிவு இருந்தால் — வாகனத்தின் அருகில் நெருப்போ அல்லது செல்போனோ பயன்படுத்த வேண்டாம்.';

  @override
  String get rescue_auto_type => 'ஆட்டோ ரிக்ஷா / துக்க்-துக்க்';

  @override
  String get rescue_auto_desc =>
      '3-சக்கர வாகனம், இந்தியச் சாலைகளில் அதிகம் காணப்படுவது';

  @override
  String get rescue_auto_danger_1 =>
      '💨 CNG ஆட்டோக்கள் — கேஸ் கசியும் சத்தம் உள்ளதா எனப் பார்க்கவும்';

  @override
  String get rescue_auto_danger_2 =>
      '🔓 திறந்த பக்கவாட்டுகள் இருப்பதால் பயணிகள் வெளியே தூக்கி எறியப்படலாம்';

  @override
  String get rescue_auto_danger_3 =>
      '⚖️ ஆட்டோக்கள் எளிதில் கவிழ்ந்துவிடும் — கவனமாக அணுகவும்';

  @override
  String get rescue_auto_danger_4 =>
      '🔧 சிறிய வாகனம் என்பதால் காயங்கள் அதிகமாக இருக்க வாய்ப்புள்ளது';

  @override
  String get rescue_auto_step_1_title => 'ஆட்டோவை நிலைப்படுத்தவும்';

  @override
  String get rescue_auto_step_1_detail =>
      'ஆட்டோ கவிழாமல் இருக்கப் பிடித்துக் கொள்ளவும். மற்றவர்களின் உதவியுடன் அதை அசையாமல் வைக்கவும்.';

  @override
  String get rescue_auto_step_2_title => 'மூன்று பக்கங்களையும் சரிபார்க்கவும்';

  @override
  String get rescue_auto_step_2_detail =>
      'பயணிகள் வெளியே விழுந்திருக்கலாம். வாகனத்தைச் சுற்றியுள்ள இடங்களையும் சரிபார்க்கவும்.';

  @override
  String get rescue_auto_step_3_title => 'ஓட்டுநரை மீட்டெடுத்தல்';

  @override
  String get rescue_auto_step_3_detail =>
      'ஓட்டுநரின் தலையைப் பின்புறமிருந்து தாங்கிப் பிடிக்கவும். மற்றொருவர் முன்னாலிருந்து அவருக்கு உதவலாம்.';

  @override
  String get rescue_auto_step_4_title => 'பயணிகளை மீட்டெடுத்தல்';

  @override
  String get rescue_auto_step_4_detail =>
      'பக்கவாட்டு வழியாக எளிதாக அணுகலாம். கழுத்தைத் தாங்கி மெதுவாக வெளியே தரையில் படுக்க வைக்கவும்.';

  @override
  String get rescue_auto_firstaid_1 =>
      '🛺 ஆட்டோ பயணிகளுக்கு சீட் பெல்ட் இருக்காது — அவர்கள் வெளியே விழுந்திருக்க வாய்ப்பு அதிகம்.';

  @override
  String get rescue_auto_firstaid_2 =>
      '🔍 ஆட்டோவைச் சுற்றி 5மீ தூரம் வரை யாராவது விழுந்துள்ளார்களா எனத் தேடவும்.';

  @override
  String get rescue_auto_firstaid_3 =>
      '🩹 தோல் சிராய்ப்புகள் அதிகம் இருக்கும் — சுத்தமான துணியால் காயங்களை மூடவும்.';

  @override
  String get rescue_auto_firstaid_4 =>
      '😮 அதிர்ச்சி வேகமாக ஏற்படலாம் — பாதிக்கப்பட்டவர்களை வெதுவெதுப்பாகவும் அமைதியாகவும் வைத்திருக்கவும்.';
}
