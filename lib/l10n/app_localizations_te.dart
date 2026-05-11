// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'RoadSOS';

  @override
  String get dashboardTitle => 'RoadSOS';

  @override
  String get sosButton => 'అత్యవసరం';

  @override
  String get secondsLabel => 'సెకన్లు';

  @override
  String get sosDispatchWarning =>
      'ఇంకా ఏమీ పంపలేదు — తప్పు అయితే కింద రద్దు చేయండి.';

  @override
  String get sosIdleTools => 'మరిన్ని';

  @override
  String get sosIdleToolsTitle => 'అత్యవసర సాధనాలు & స్థితి';

  @override
  String get sosButtonSub => 'అత్యవసరాన్ని ప్రారంభించడానికి నొక్కండి';

  @override
  String get cancelSos => 'రద్దు';

  @override
  String get orchestratorBystanderStarted => 'Bystander Alert Started';

  @override
  String get orchestratorSelfSosStarted => 'Self SOS Started';

  @override
  String get orchestratorAcquiringLocation => 'స్థానం పొందుతున్నాం…';

  @override
  String orchestratorLocationSecured(String lat, String lng) {
    return 'Location: $lat, $lng';
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
  String get orchestratorAiBrief => 'క్లౌడ్ AI పరిస్థితి అంచనా…';

  @override
  String orchestratorTriageDone(int level) {
    return 'Triage Done — Severity $level';
  }

  @override
  String get orchestratorDispatching => 'అన్ని చానల్‌లకు పంపుతున్నాం…';

  @override
  String get orchestratorSosLive => 'SOS సక్రియం';

  @override
  String get orchestratorCancelled => 'SOS Cancelled';

  @override
  String get mapPlaceholder => 'Map';

  @override
  String get actionScene => 'Scene';

  @override
  String get actionMedicalId => 'Medical ID';

  @override
  String get actionResponder => 'Responder';

  @override
  String get actionSafeWalk => 'Safe Walk';

  @override
  String get actionFirstAid => 'First Aid';

  @override
  String get actionVitalScan => 'Vital Scan';

  @override
  String get actionMeshChat => 'Mesh Chat';

  @override
  String get actionSettings => 'Settings';

  @override
  String get triageResultTitle => 'AI ట్రయేజ్ ఫలితం';

  @override
  String get triageDegradedTitle => 'AI (ఆఫ్‌లైన్)';

  @override
  String severityLine(int level, String label) {
    return 'Severity $level/5 — $label';
  }

  @override
  String get severityCritical => 'Critical';

  @override
  String get severitySevere => 'Severe';

  @override
  String get severityModerate => 'Moderate';

  @override
  String get severityMinor => 'Minor';

  @override
  String get severityLow => 'Low';

  @override
  String get severityUnknown => 'Unknown';

  @override
  String get dispatchedServices => 'Dispatched Services';

  @override
  String get firstAidGuidance => 'మొదటి చికిత్స';

  @override
  String get noAiBadge => 'OFFLINE';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionConnectivity => 'Connectivity';

  @override
  String get sectionLegal => 'Legal & Data';

  @override
  String get offlineMapsTitle => 'Offline Maps';

  @override
  String get offlineMapsSubtitle => 'Download regional tiles';

  @override
  String get meshConfigTitle => 'Mesh Config';

  @override
  String get meshConfigSubtitle => 'Sensitivity & Visibility';

  @override
  String get blackBoxTitle => 'Black Box Report';

  @override
  String get blackBoxSubtitle => 'Telemetry & Triage Export';

  @override
  String get blackBoxSnack => 'Generating signed PDF…';

  @override
  String get dataPrivacyTitle => 'Data Privacy';

  @override
  String get dataPrivacySubtitle => 'Encryption & Sync';

  @override
  String get vitalScanTitle => 'Vital Scan';

  @override
  String get vitalAlignFinger => 'Place finger on camera & flash for PPG.';

  @override
  String get settingsLanguage => 'భాష';

  @override
  String get settingsLanguageSubtitle => 'UI మరియు వాయిస్';

  @override
  String get incidentAssistantAnalyzed =>
      'Scene: Next of kin logged. Check smoke/fire.';

  @override
  String get incidentVoiceHint => 'మీరు చూసేది చెప్పండి…';

  @override
  String get profileAiLine => 'Profile helps with first-aid cues during SOS.';

  @override
  String get thinkingOffline => 'ఆఫ్‌లైన్ నియమాలు.';

  @override
  String get sttConfirmKeywords => 'You can say Yes, Confirm, or Help.';

  @override
  String get consentTitle => 'Welcome to RoadSOS';

  @override
  String get consentSummary =>
      'This app processes your location, crash/motion signals, and optional medical profile for emergency response. In accordance with India\'s Digital Personal Data Protection Act, 2023, consent is required to proceed. 90-day retention on cloud (unless opted below).';

  @override
  String get consentExtendedRetentionLabel =>
      'Keep cloud data beyond 90 days for safety research (Optional)';

  @override
  String get consentAccept => 'I CONSENT — PROCEED';

  @override
  String get consentPrivacyButton => 'Privacy Notice';

  @override
  String get privacyPolicyTitle => 'Privacy Notice';

  @override
  String get privacyPolicyLanguageEn => 'English';

  @override
  String get privacyPolicyLanguageHi => 'Hindi';

  @override
  String get goodSamaritanTitle => 'Good Samaritan Protection';

  @override
  String get goodSamaritanLead =>
      'You are legally protected for helping in good faith.';

  @override
  String get goodSamaritanBody =>
      'India\'s Good Samaritan Framework (including 2016 SC guidelines) prevents harassment of those helping road accident victims. Timely help saves lives.';

  @override
  String get goodSamaritanContinue => 'UNDERSTOOD';

  @override
  String get nearbySosSectionTitle => 'Nearby SOS';

  @override
  String get nearbySosToggleTitle => 'Nearby SOS Push Alerts';

  @override
  String get nearbySosToggleSubtitle =>
      'Firebase — Notification when someone nearby needs help';

  @override
  String get nearbySosLearnProtection => 'Good Samaritan Protection';

  @override
  String get aiThinkingTraceTitle => 'TRIAGE REASONING';

  @override
  String get crisisCompanionTitle => 'CRISIS ASSISTANT';

  @override
  String get crisisCompanionBreathing =>
      'Breathe steadily. Monitoring your situation.';

  @override
  String get sceneIntelligenceTitle => 'Scene Intelligence';

  @override
  String get helpEtaPlaceholder => 'No ETA available';

  @override
  String get talkButton => 'TALK';

  @override
  String get settingsExtendedRetentionTitle => 'Extended Cloud Retention';

  @override
  String get settingsExtendedRetentionSubtitle =>
      'Keep incident summaries beyond 90 days on Supabase sync (overrides default purge).';

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
  String get actionOfflineMapsSub => 'Download maps for no-signal areas';

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
  String get vehicleRescueBannerTitle => 'Vehicle Rescue';

  @override
  String get vehicleRescueBannerSub =>
      'Select for specific hazards & instructions';

  @override
  String get plateNumberLabel => 'PLATE NUMBER (optional)';

  @override
  String get plateNumberHint => 'e.g. MH 01 AA 1111';

  @override
  String get selectVehicleType => 'SELECT VEHICLE TYPE';

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
  String get fieldFullName => 'Full Name';

  @override
  String get fieldBloodType => 'Blood Type';

  @override
  String get fieldAllergies => 'Allergies';

  @override
  String get fieldMedications => 'Medications';

  @override
  String get fieldConditions => 'Chronic Conditions';

  @override
  String get sectionEmergencyContacts => 'EMERGENCY CONTACTS';

  @override
  String get fieldPrimaryContact => 'Primary Contact';

  @override
  String fieldAdditionalContact(int index) {
    return 'Additional Contact $index';
  }

  @override
  String get addContactButton => 'ADD CONTACT';

  @override
  String get medicalIdTitle => 'EMERGENCY MEDICAL ID';

  @override
  String get scanForSummary => 'SCAN FOR MEDICAL SUMMARY';

  @override
  String get notSet => 'NOT SET';

  @override
  String get medicalCardTip =>
      'Tip: Keep this screen open for responders. For lock-screen wallpaper export, use your device screenshot tools.';

  @override
  String get firstAidGuideTitle => '🩺 First Aid Guide';

  @override
  String get describeInjuryHint => 'Describe injury...';

  @override
  String get firstAidError =>
      'Could not load first-aid guidance on this device.';

  @override
  String get verifiedSolutionsTitle => 'Verified Medical Solutions';

  @override
  String get aiInjuryIdTitle => 'AI Injury Identification';

  @override
  String get typeInjuryPrompt =>
      'Type an injury to get\nexact, verified first aid solutions.';

  @override
  String get chipSevereBleeding => 'Severe Bleeding';

  @override
  String get chipMuscleTear => 'Muscle Tear';

  @override
  String get chipBrainInjury => 'Brain Injury';

  @override
  String get chipSprains => 'Sprains';

  @override
  String get multimodalDigitalTwin => 'MULTIMODAL: DIGITAL TWIN';

  @override
  String get aiInterviewNuance => 'AI INTERVIEW: SITUATIONAL NUANCE';

  @override
  String get actionGuidanceNextSteps => 'ACTION GUIDANCE: NEXT STEPS';

  @override
  String get situationBriefLive => 'SITUATION BRIEF (LIVE)';

  @override
  String get sceneAttached => 'SCENE ATTACHED';

  @override
  String get captureAttachPhoto => 'CAPTURE / ATTACH PHOTO';

  @override
  String get photoAttachedNote =>
      'Photo attached to this report (not auto-analyzed in this build).';

  @override
  String get scenePhotoError =>
      'Could not capture a scene photo on this device.';

  @override
  String get scenePhotoAttached => 'Scene photo attached.';

  @override
  String get questionProgress => 'Question Progress:';

  @override
  String get describeIncidentPrompt => 'Please describe the incident';

  @override
  String get speakOrTypeHint => 'Speak or type…';

  @override
  String get interviewCompleteMessage =>
      '✓ Interview complete. All critical information collected.';

  @override
  String get actionStepsTitle => '🎯 Action Steps';

  @override
  String get reportNewIncidentButton => 'Report New Incident';

  @override
  String get sceneCollision => 'Vehicle Collision';

  @override
  String get scenePedestrian => 'Pedestrian Hit';

  @override
  String get sceneRollover => 'Rollover';

  @override
  String get sceneFire => 'Fire Hazard';

  @override
  String get sceneUnknown => 'Unknown';

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
  String get rescue_car_type => 'Car / Sedan / Hatchback';

  @override
  String get rescue_car_desc => 'Standard 4-wheel passenger vehicle';

  @override
  String get rescue_car_danger_1 =>
      '⛽ Fuel tank is at the REAR — keep flames away from back of car';

  @override
  String get rescue_car_danger_2 =>
      '🔋 12V battery is usually under the hood (avoid short circuits)';

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
  String get rescue_truck_type => 'Heavy Vehicle / Truck / Bus';

  @override
  String get rescue_truck_desc => 'Large logistics or passenger buses';

  @override
  String get rescue_truck_danger_1 =>
      '🛑 Massive blind spots — ensure driver sees you';

  @override
  String get rescue_truck_danger_2 =>
      '💨 Air brake pressure loss can cause wheels to lock suddenly';

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
  String get rescue_bike_type => 'Two-Wheeler / Motorcycle';

  @override
  String get rescue_bike_desc => 'Motorbikes and scooters';

  @override
  String get rescue_bike_danger_1 =>
      '🔥 Risk of burns from hot engine/exhaust pipe';

  @override
  String get rescue_bike_danger_2 =>
      '⛽ Fuel leaks are common if bike is down; avoid ignition sources';

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
