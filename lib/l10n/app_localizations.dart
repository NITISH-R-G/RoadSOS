import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'RoadSOS'**
  String get appTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'RoadSOS'**
  String get dashboardTitle;

  /// No description provided for @sosButton.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sosButton;

  /// No description provided for @secondsLabel.
  ///
  /// In en, this message translates to:
  /// **'SECONDS'**
  String get secondsLabel;

  /// No description provided for @sosDispatchWarning.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been sent yet. Cancel now if this was a mistake.'**
  String get sosDispatchWarning;

  /// No description provided for @sosIdleTools.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get sosIdleTools;

  /// No description provided for @sosIdleToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency tools & status'**
  String get sosIdleToolsTitle;

  /// No description provided for @sosButtonSub.
  ///
  /// In en, this message translates to:
  /// **'Press to start emergency'**
  String get sosButtonSub;

  /// No description provided for @cancelSos.
  ///
  /// In en, this message translates to:
  /// **'CANCEL SOS'**
  String get cancelSos;

  /// No description provided for @orchestratorBystanderStarted.
  ///
  /// In en, this message translates to:
  /// **'Bystander alert started'**
  String get orchestratorBystanderStarted;

  /// No description provided for @orchestratorSelfSosStarted.
  ///
  /// In en, this message translates to:
  /// **'Self SOS started'**
  String get orchestratorSelfSosStarted;

  /// No description provided for @orchestratorAcquiringLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location…'**
  String get orchestratorAcquiringLocation;

  /// No description provided for @orchestratorLocationSecured.
  ///
  /// In en, this message translates to:
  /// **'Location: {lat}, {lng}'**
  String orchestratorLocationSecured(String lat, String lng);

  /// No description provided for @orchestratorLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable — enable location services or move to open sky.'**
  String get orchestratorLocationUnavailable;

  /// No description provided for @orchestratorManualActionRequired.
  ///
  /// In en, this message translates to:
  /// **'Manual action required — if automated dispatch fails, dial your emergency number now.'**
  String get orchestratorManualActionRequired;

  /// No description provided for @orchestratorSmsNoGpsPayload.
  ///
  /// In en, this message translates to:
  /// **'SOS (no GPS). Please call emergency services now. RoadSOS could not acquire location.'**
  String get orchestratorSmsNoGpsPayload;

  /// No description provided for @orchestratorAiBrief.
  ///
  /// In en, this message translates to:
  /// **'Cloud AI is assessing the situation…'**
  String get orchestratorAiBrief;

  /// No description provided for @orchestratorTriageDone.
  ///
  /// In en, this message translates to:
  /// **'Triage complete — severity {level}'**
  String orchestratorTriageDone(int level);

  /// No description provided for @orchestratorDispatching.
  ///
  /// In en, this message translates to:
  /// **'Trying SMS, mesh beacon, and on-device log…'**
  String get orchestratorDispatching;

  /// No description provided for @orchestratorSosLive.
  ///
  /// In en, this message translates to:
  /// **'SOS live — all channels active'**
  String get orchestratorSosLive;

  /// No description provided for @orchestratorCancelled.
  ///
  /// In en, this message translates to:
  /// **'SOS cancelled'**
  String get orchestratorCancelled;

  /// No description provided for @mapPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapPlaceholder;

  /// No description provided for @actionScene.
  ///
  /// In en, this message translates to:
  /// **'SCENE'**
  String get actionScene;

  /// No description provided for @actionMedicalId.
  ///
  /// In en, this message translates to:
  /// **'MEDICAL ID'**
  String get actionMedicalId;

  /// No description provided for @actionResponder.
  ///
  /// In en, this message translates to:
  /// **'RESPONDER'**
  String get actionResponder;

  /// No description provided for @actionSafeWalk.
  ///
  /// In en, this message translates to:
  /// **'SAFE-WALK'**
  String get actionSafeWalk;

  /// No description provided for @actionFirstAid.
  ///
  /// In en, this message translates to:
  /// **'FIRST AID'**
  String get actionFirstAid;

  /// No description provided for @actionVitalScan.
  ///
  /// In en, this message translates to:
  /// **'VITAL SCAN'**
  String get actionVitalScan;

  /// No description provided for @actionMeshChat.
  ///
  /// In en, this message translates to:
  /// **'MESH CHAT'**
  String get actionMeshChat;

  /// No description provided for @actionSettings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get actionSettings;

  /// No description provided for @triageResultTitle.
  ///
  /// In en, this message translates to:
  /// **'AI TRIAGE RESULT'**
  String get triageResultTitle;

  /// No description provided for @triageDegradedTitle.
  ///
  /// In en, this message translates to:
  /// **'AI TRIAGE (OFFLINE)'**
  String get triageDegradedTitle;

  /// No description provided for @severityLine.
  ///
  /// In en, this message translates to:
  /// **'Severity {level}/5 — {label}'**
  String severityLine(int level, String label);

  /// No description provided for @severityCritical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get severityCritical;

  /// No description provided for @severitySevere.
  ///
  /// In en, this message translates to:
  /// **'SEVERE'**
  String get severitySevere;

  /// No description provided for @severityModerate.
  ///
  /// In en, this message translates to:
  /// **'MODERATE'**
  String get severityModerate;

  /// No description provided for @severityMinor.
  ///
  /// In en, this message translates to:
  /// **'MINOR'**
  String get severityMinor;

  /// No description provided for @severityLow.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get severityLow;

  /// No description provided for @severityUnknown.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get severityUnknown;

  /// No description provided for @dispatchedServices.
  ///
  /// In en, this message translates to:
  /// **'DISPATCHED SERVICES'**
  String get dispatchedServices;

  /// No description provided for @firstAidGuidance.
  ///
  /// In en, this message translates to:
  /// **'FIRST AID GUIDANCE'**
  String get firstAidGuidance;

  /// No description provided for @noAiBadge.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get noAiBadge;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @sectionConnectivity.
  ///
  /// In en, this message translates to:
  /// **'CONNECTIVITY'**
  String get sectionConnectivity;

  /// No description provided for @sectionLegal.
  ///
  /// In en, this message translates to:
  /// **'LEGAL & DATA'**
  String get sectionLegal;

  /// No description provided for @offlineMapsTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline maps'**
  String get offlineMapsTitle;

  /// No description provided for @offlineMapsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download and manage regional tiles'**
  String get offlineMapsSubtitle;

  /// No description provided for @meshConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Mesh configuration'**
  String get meshConfigTitle;

  /// No description provided for @meshConfigSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Broadcast sensitivity and node visibility'**
  String get meshConfigSubtitle;

  /// No description provided for @blackBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Black box report'**
  String get blackBoxTitle;

  /// No description provided for @blackBoxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export signed telemetry and triage logs'**
  String get blackBoxSubtitle;

  /// No description provided for @blackBoxSnack.
  ///
  /// In en, this message translates to:
  /// **'Generating signed black box PDF…'**
  String get blackBoxSnack;

  /// No description provided for @dataPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Data privacy'**
  String get dataPrivacyTitle;

  /// No description provided for @dataPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage local encryption and cloud sync'**
  String get dataPrivacySubtitle;

  /// No description provided for @vitalScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Vital scan'**
  String get vitalScanTitle;

  /// No description provided for @vitalAlignFinger.
  ///
  /// In en, this message translates to:
  /// **'Align index finger with rear camera and flash for PPG reading.'**
  String get vitalAlignFinger;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'UI, triage prompts, and voice output'**
  String get settingsLanguageSubtitle;

  /// No description provided for @incidentAssistantAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Scene note: frontal impact logged. Check for smoke or fire.'**
  String get incidentAssistantAnalyzed;

  /// No description provided for @incidentVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you see…'**
  String get incidentVoiceHint;

  /// No description provided for @profileAiLine.
  ///
  /// In en, this message translates to:
  /// **'Medical profile helps first aid prompts during SOS.'**
  String get profileAiLine;

  /// No description provided for @thinkingOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline rules (no cloud).'**
  String get thinkingOffline;

  /// No description provided for @sttConfirmKeywords.
  ///
  /// In en, this message translates to:
  /// **'You can say yes, confirm, or help.'**
  String get sttConfirmKeywords;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to RoadSOS'**
  String get consentTitle;

  /// No description provided for @consentSummary.
  ///
  /// In en, this message translates to:
  /// **'This app processes location, motion/crash signals, and optional medical profile data to coordinate emergency help. Under India’s Digital Personal Data Protection Act, 2023, we need your informed consent before continuing. Cloud incident summaries are retained for 90 days unless you opt in below.'**
  String get consentSummary;

  /// No description provided for @consentExtendedRetentionLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep anonymised cloud incident copies longer than 90 days for safety research (optional)'**
  String get consentExtendedRetentionLabel;

  /// No description provided for @consentAccept.
  ///
  /// In en, this message translates to:
  /// **'I agree — continue'**
  String get consentAccept;

  /// No description provided for @consentPrivacyButton.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice'**
  String get consentPrivacyButton;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get privacyPolicyLanguageEn;

  /// No description provided for @privacyPolicyLanguageHi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get privacyPolicyLanguageHi;

  /// No description provided for @goodSamaritanTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Samaritan protection'**
  String get goodSamaritanTitle;

  /// No description provided for @goodSamaritanLead.
  ///
  /// In en, this message translates to:
  /// **'You are legally protected when helping in good faith.'**
  String get goodSamaritanLead;

  /// No description provided for @goodSamaritanBody.
  ///
  /// In en, this message translates to:
  /// **'India’s Good Samaritan framework (including the 2016 Supreme Court guidelines) discourages harassment of bystanders who assist road accident victims. Helping promptly can save lives.'**
  String get goodSamaritanBody;

  /// No description provided for @goodSamaritanContinue.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get goodSamaritanContinue;

  /// No description provided for @nearbySosSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby SOS'**
  String get nearbySosSectionTitle;

  /// No description provided for @nearbySosToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby SOS push alerts'**
  String get nearbySosToggleTitle;

  /// No description provided for @nearbySosToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Firebase Cloud Messaging — notify me when someone nearby needs help'**
  String get nearbySosToggleSubtitle;

  /// No description provided for @nearbySosLearnProtection.
  ///
  /// In en, this message translates to:
  /// **'Good Samaritan protection'**
  String get nearbySosLearnProtection;

  /// No description provided for @aiThinkingTraceTitle.
  ///
  /// In en, this message translates to:
  /// **'TRIAGE REASONING'**
  String get aiThinkingTraceTitle;

  /// No description provided for @crisisCompanionTitle.
  ///
  /// In en, this message translates to:
  /// **'CRISIS ASSISTANT'**
  String get crisisCompanionTitle;

  /// No description provided for @crisisCompanionBreathing.
  ///
  /// In en, this message translates to:
  /// **'Breathe steadily. Monitoring your situation.'**
  String get crisisCompanionBreathing;

  /// No description provided for @sceneIntelligenceTitle.
  ///
  /// In en, this message translates to:
  /// **'SCENE INTELLIGENCE'**
  String get sceneIntelligenceTitle;

  /// No description provided for @helpEtaPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No ETA available'**
  String get helpEtaPlaceholder;

  /// No description provided for @talkButton.
  ///
  /// In en, this message translates to:
  /// **'TALK'**
  String get talkButton;

  /// No description provided for @settingsExtendedRetentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Extended cloud retention'**
  String get settingsExtendedRetentionTitle;

  /// No description provided for @settingsExtendedRetentionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep incident summaries beyond 90 days when synced to Supabase (overrides default purge).'**
  String get settingsExtendedRetentionSubtitle;

  /// No description provided for @navSos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get navSos;

  /// No description provided for @navSafetyTools.
  ///
  /// In en, this message translates to:
  /// **'Safety Tools'**
  String get navSafetyTools;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get navProfile;

  /// No description provided for @drivingModeBanner.
  ///
  /// In en, this message translates to:
  /// **'DRIVING MODE — Crash detection armed'**
  String get drivingModeBanner;

  /// No description provided for @safetyToolsHint.
  ///
  /// In en, this message translates to:
  /// **'All safety features are in \"Safety Tools\" below'**
  String get safetyToolsHint;

  /// No description provided for @sectionEmergencyResponse.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY RESPONSE'**
  String get sectionEmergencyResponse;

  /// No description provided for @sectionHealthSafety.
  ///
  /// In en, this message translates to:
  /// **'HEALTH & SAFETY'**
  String get sectionHealthSafety;

  /// No description provided for @sectionRecords.
  ///
  /// In en, this message translates to:
  /// **'RECORDS'**
  String get sectionRecords;

  /// No description provided for @sectionMyInformation.
  ///
  /// In en, this message translates to:
  /// **'MY INFORMATION'**
  String get sectionMyInformation;

  /// No description provided for @sectionSettingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS & PRIVACY'**
  String get sectionSettingsPrivacy;

  /// No description provided for @actionSafeWalkSub.
  ///
  /// In en, this message translates to:
  /// **'Auto-SOS if you don\'t check in at destination'**
  String get actionSafeWalkSub;

  /// No description provided for @actionCaptureScene.
  ///
  /// In en, this message translates to:
  /// **'Capture Scene'**
  String get actionCaptureScene;

  /// No description provided for @actionCaptureSceneSub.
  ///
  /// In en, this message translates to:
  /// **'Document crash with AI-powered photo analysis'**
  String get actionCaptureSceneSub;

  /// No description provided for @actionResponderSub.
  ///
  /// In en, this message translates to:
  /// **'Live map with nearby SOS signals'**
  String get actionResponderSub;

  /// No description provided for @actionFirstAidSub.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step emergency instructions'**
  String get actionFirstAidSub;

  /// No description provided for @actionVitalScanSub.
  ///
  /// In en, this message translates to:
  /// **'Check heart rate & oxygen saturation'**
  String get actionVitalScanSub;

  /// No description provided for @actionMedicalIdSub.
  ///
  /// In en, this message translates to:
  /// **'Show responders your blood type, allergies, contacts'**
  String get actionMedicalIdSub;

  /// No description provided for @actionMeshChatSub.
  ///
  /// In en, this message translates to:
  /// **'Offline Bluetooth messaging — no signal needed'**
  String get actionMeshChatSub;

  /// No description provided for @actionOfflineMaps.
  ///
  /// In en, this message translates to:
  /// **'Offline Maps'**
  String get actionOfflineMaps;

  /// No description provided for @actionOfflineMapsSub.
  ///
  /// In en, this message translates to:
  /// **'Download maps for no-signal areas'**
  String get actionOfflineMapsSub;

  /// No description provided for @actionActivityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity Log'**
  String get actionActivityLog;

  /// No description provided for @actionActivityLogSub.
  ///
  /// In en, this message translates to:
  /// **'GPS, triage, SMS — for police & insurer records'**
  String get actionActivityLogSub;

  /// No description provided for @actionEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get actionEditProfile;

  /// No description provided for @actionEditProfileSub.
  ///
  /// In en, this message translates to:
  /// **'Name, blood type, emergency contacts'**
  String get actionEditProfileSub;

  /// No description provided for @actionMedicalIdCard.
  ///
  /// In en, this message translates to:
  /// **'Medical ID Card'**
  String get actionMedicalIdCard;

  /// No description provided for @actionMedicalIdCardSub.
  ///
  /// In en, this message translates to:
  /// **'Quick-access health info for emergency responders'**
  String get actionMedicalIdCardSub;

  /// No description provided for @actionAllSettings.
  ///
  /// In en, this message translates to:
  /// **'All Settings'**
  String get actionAllSettings;

  /// No description provided for @actionAllSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Language, offline maps, notifications, privacy'**
  String get actionAllSettingsSub;

  /// No description provided for @actionActivityLogFullSub.
  ///
  /// In en, this message translates to:
  /// **'Full SOS history for insurance & police records'**
  String get actionActivityLogFullSub;

  /// No description provided for @rescueGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Rescue Guide'**
  String get rescueGuideTitle;

  /// No description provided for @vehicleRescueTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Rescue'**
  String get vehicleRescueTitle;

  /// No description provided for @rescueOfflineBadge.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get rescueOfflineBadge;

  /// No description provided for @vehicleRescueBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'VEHICLE RESCUE GUIDE'**
  String get vehicleRescueBannerTitle;

  /// No description provided for @vehicleRescueBannerSub.
  ///
  /// In en, this message translates to:
  /// **'Select the type of vehicle involved in the accident to get instant rescue instructions.'**
  String get vehicleRescueBannerSub;

  /// No description provided for @plateNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'PLATE NUMBER (optional)'**
  String get plateNumberLabel;

  /// No description provided for @plateNumberHint.
  ///
  /// In en, this message translates to:
  /// **'TN 11 AB 1234'**
  String get plateNumberHint;

  /// No description provided for @selectVehicleType.
  ///
  /// In en, this message translates to:
  /// **'SELECT VEHICLE TYPE'**
  String get selectVehicleType;

  /// No description provided for @rescueOfflineTip.
  ///
  /// In en, this message translates to:
  /// **'All rescue instructions work offline — no internet needed.'**
  String get rescueOfflineTip;

  /// No description provided for @highVoltageWarning.
  ///
  /// In en, this message translates to:
  /// **'HIGH VOLTAGE'**
  String get highVoltageWarning;

  /// No description provided for @rescueDangersTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️  DANGERS — READ FIRST'**
  String get rescueDangersTitle;

  /// No description provided for @rescueExtractionTitle.
  ///
  /// In en, this message translates to:
  /// **'👐  EXTRACTION STEPS'**
  String get rescueExtractionTitle;

  /// No description provided for @rescueFirstAidTitle.
  ///
  /// In en, this message translates to:
  /// **'🩺  WHILE WAITING FOR AMBULANCE'**
  String get rescueFirstAidTitle;

  /// No description provided for @rescueCriticalBadge.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get rescueCriticalBadge;

  /// No description provided for @dialerError.
  ///
  /// In en, this message translates to:
  /// **'Could not launch dialer. Please call 108 manually.'**
  String get dialerError;

  /// No description provided for @callAmbulanceButton.
  ///
  /// In en, this message translates to:
  /// **'CALL AMBULANCE — 108'**
  String get callAmbulanceButton;

  /// No description provided for @editMedicalIdTitle.
  ///
  /// In en, this message translates to:
  /// **'EDIT MEDICAL ID'**
  String get editMedicalIdTitle;

  /// No description provided for @profileUpdatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Medical Profile Updated'**
  String get profileUpdatedSnack;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fieldFullName;

  /// No description provided for @fieldBloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get fieldBloodType;

  /// No description provided for @fieldAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get fieldAllergies;

  /// No description provided for @fieldMedications.
  ///
  /// In en, this message translates to:
  /// **'Current Medications'**
  String get fieldMedications;

  /// No description provided for @fieldConditions.
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions'**
  String get fieldConditions;

  /// No description provided for @sectionEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY CONTACTS'**
  String get sectionEmergencyContacts;

  /// No description provided for @fieldPrimaryContact.
  ///
  /// In en, this message translates to:
  /// **'Primary Contact'**
  String get fieldPrimaryContact;

  /// No description provided for @fieldAdditionalContact.
  ///
  /// In en, this message translates to:
  /// **'Additional Contact {index}'**
  String fieldAdditionalContact(int index);

  /// No description provided for @addContactButton.
  ///
  /// In en, this message translates to:
  /// **'ADD CONTACT'**
  String get addContactButton;

  /// No description provided for @medicalIdTitle.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY MEDICAL ID'**
  String get medicalIdTitle;

  /// No description provided for @scanForSummary.
  ///
  /// In en, this message translates to:
  /// **'SCAN FOR MEDICAL SUMMARY'**
  String get scanForSummary;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'NOT SET'**
  String get notSet;

  /// No description provided for @medicalCardTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Keep this screen open for responders. For lock-screen wallpaper export, use your device screenshot tools.'**
  String get medicalCardTip;

  /// No description provided for @firstAidGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'🩺 First Aid Guide'**
  String get firstAidGuideTitle;

  /// No description provided for @describeInjuryHint.
  ///
  /// In en, this message translates to:
  /// **'Describe injury...'**
  String get describeInjuryHint;

  /// No description provided for @firstAidError.
  ///
  /// In en, this message translates to:
  /// **'Could not load first-aid guidance on this device.'**
  String get firstAidError;

  /// No description provided for @verifiedSolutionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified Medical Solutions'**
  String get verifiedSolutionsTitle;

  /// No description provided for @aiInjuryIdTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Injury Identification'**
  String get aiInjuryIdTitle;

  /// No description provided for @typeInjuryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type an injury to get\nexact, verified first aid solutions.'**
  String get typeInjuryPrompt;

  /// No description provided for @chipSevereBleeding.
  ///
  /// In en, this message translates to:
  /// **'Severe Bleeding'**
  String get chipSevereBleeding;

  /// No description provided for @chipMuscleTear.
  ///
  /// In en, this message translates to:
  /// **'Muscle Tear'**
  String get chipMuscleTear;

  /// No description provided for @chipBrainInjury.
  ///
  /// In en, this message translates to:
  /// **'Brain Injury'**
  String get chipBrainInjury;

  /// No description provided for @chipSprains.
  ///
  /// In en, this message translates to:
  /// **'Sprains'**
  String get chipSprains;

  /// No description provided for @multimodalDigitalTwin.
  ///
  /// In en, this message translates to:
  /// **'MULTIMODAL: DIGITAL TWIN'**
  String get multimodalDigitalTwin;

  /// No description provided for @aiInterviewNuance.
  ///
  /// In en, this message translates to:
  /// **'AI INTERVIEW: SITUATIONAL NUANCE'**
  String get aiInterviewNuance;

  /// No description provided for @actionGuidanceNextSteps.
  ///
  /// In en, this message translates to:
  /// **'ACTION GUIDANCE: NEXT STEPS'**
  String get actionGuidanceNextSteps;

  /// No description provided for @situationBriefLive.
  ///
  /// In en, this message translates to:
  /// **'SITUATION BRIEF (LIVE)'**
  String get situationBriefLive;

  /// No description provided for @sceneAttached.
  ///
  /// In en, this message translates to:
  /// **'SCENE ATTACHED'**
  String get sceneAttached;

  /// No description provided for @captureAttachPhoto.
  ///
  /// In en, this message translates to:
  /// **'CAPTURE / ATTACH PHOTO'**
  String get captureAttachPhoto;

  /// No description provided for @photoAttachedNote.
  ///
  /// In en, this message translates to:
  /// **'Photo attached to this report (not auto-analyzed in this build).'**
  String get photoAttachedNote;

  /// No description provided for @scenePhotoError.
  ///
  /// In en, this message translates to:
  /// **'Could not capture a scene photo on this device.'**
  String get scenePhotoError;

  /// No description provided for @scenePhotoAttached.
  ///
  /// In en, this message translates to:
  /// **'Scene photo attached.'**
  String get scenePhotoAttached;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question Progress:'**
  String get questionProgress;

  /// No description provided for @describeIncidentPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please describe the incident'**
  String get describeIncidentPrompt;

  /// No description provided for @speakOrTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Speak or type…'**
  String get speakOrTypeHint;

  /// No description provided for @interviewCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'✓ Interview complete. All critical information collected.'**
  String get interviewCompleteMessage;

  /// No description provided for @actionStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'🎯 Action Steps'**
  String get actionStepsTitle;

  /// No description provided for @reportNewIncidentButton.
  ///
  /// In en, this message translates to:
  /// **'Report New Incident'**
  String get reportNewIncidentButton;

  /// No description provided for @sceneCollision.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Collision'**
  String get sceneCollision;

  /// No description provided for @scenePedestrian.
  ///
  /// In en, this message translates to:
  /// **'Pedestrian Hit'**
  String get scenePedestrian;

  /// No description provided for @sceneRollover.
  ///
  /// In en, this message translates to:
  /// **'Rollover'**
  String get sceneRollover;

  /// No description provided for @sceneFire.
  ///
  /// In en, this message translates to:
  /// **'Fire Hazard'**
  String get sceneFire;

  /// No description provided for @sceneUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get sceneUnknown;

  /// No description provided for @activityLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity log'**
  String get activityLogTitle;

  /// No description provided for @activityLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'GPS, triage, SMS/mesh/cloud steps — for insurance or police records'**
  String get activityLogSubtitle;

  /// No description provided for @reviewPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Review permissions'**
  String get reviewPermissionsTitle;

  /// No description provided for @reviewPermissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open the setup walkthrough again'**
  String get reviewPermissionsSubtitle;

  /// No description provided for @backgroundVolumeSosTitle.
  ///
  /// In en, this message translates to:
  /// **'Background volume SOS'**
  String get backgroundVolumeSosTitle;

  /// No description provided for @backgroundVolumeSosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open Accessibility and enable RoadSOS for lock-screen gesture (3× up + 3× down)'**
  String get backgroundVolumeSosSubtitle;

  /// No description provided for @nearbySosFirebaseError.
  ///
  /// In en, this message translates to:
  /// **'Nearby SOS needs Firebase setup (google-services.json / FirebaseOptions). Toggle turned off.'**
  String get nearbySosFirebaseError;

  /// No description provided for @rescue_car_type.
  ///
  /// In en, this message translates to:
  /// **'Car / Sedan / Hatchback'**
  String get rescue_car_type;

  /// No description provided for @rescue_car_desc.
  ///
  /// In en, this message translates to:
  /// **'Standard 4-wheel passenger vehicle'**
  String get rescue_car_desc;

  /// No description provided for @rescue_car_danger_1.
  ///
  /// In en, this message translates to:
  /// **'⛽ Fuel tank is at the REAR — keep flames away from back of car'**
  String get rescue_car_danger_1;

  /// No description provided for @rescue_car_danger_2.
  ///
  /// In en, this message translates to:
  /// **'💥 Airbags may still deploy even after crash — don\'t lean into cabin'**
  String get rescue_car_danger_2;

  /// No description provided for @rescue_car_danger_3.
  ///
  /// In en, this message translates to:
  /// **'🔋 12V battery under hood — avoid touching terminals'**
  String get rescue_car_danger_3;

  /// No description provided for @rescue_car_danger_4.
  ///
  /// In en, this message translates to:
  /// **'🔥 Engine fire risk — if smoke seen, move victim 30m away immediately'**
  String get rescue_car_danger_4;

  /// No description provided for @rescue_car_step_1_title.
  ///
  /// In en, this message translates to:
  /// **'Make the scene safe'**
  String get rescue_car_step_1_title;

  /// No description provided for @rescue_car_step_1_detail.
  ///
  /// In en, this message translates to:
  /// **'Turn off the engine if accessible. Turn on hazard lights. Place objects 50m behind to warn traffic.'**
  String get rescue_car_step_1_detail;

  /// No description provided for @rescue_car_step_2_title.
  ///
  /// In en, this message translates to:
  /// **'Check if victim is conscious'**
  String get rescue_car_step_2_title;

  /// No description provided for @rescue_car_step_2_detail.
  ///
  /// In en, this message translates to:
  /// **'Tap shoulder and shout \"Can you hear me?\". If no response, call 108 immediately. Do NOT shake them.'**
  String get rescue_car_step_2_detail;

  /// No description provided for @rescue_car_step_3_title.
  ///
  /// In en, this message translates to:
  /// **'Do NOT move the victim yet'**
  String get rescue_car_step_3_title;

  /// No description provided for @rescue_car_step_3_detail.
  ///
  /// In en, this message translates to:
  /// **'If victim is breathing and not in immediate danger (no fire/flood), keep them still. Moving can worsen spinal injuries.'**
  String get rescue_car_step_3_detail;

  /// No description provided for @rescue_car_step_4_title.
  ///
  /// In en, this message translates to:
  /// **'Open the door safely'**
  String get rescue_car_step_4_title;

  /// No description provided for @rescue_car_step_4_detail.
  ///
  /// In en, this message translates to:
  /// **'Pull door handle and simultaneously push door outward with shoulder. For jammed doors, try rear doors first.'**
  String get rescue_car_step_4_detail;

  /// No description provided for @rescue_car_step_5_title.
  ///
  /// In en, this message translates to:
  /// **'Support the neck and head'**
  String get rescue_car_step_5_title;

  /// No description provided for @rescue_car_step_5_detail.
  ///
  /// In en, this message translates to:
  /// **'Place both hands on either side of victim\'s head. Keep head aligned with spine at ALL times. Ask someone else to help.'**
  String get rescue_car_step_5_detail;

  /// No description provided for @rescue_car_step_6_title.
  ///
  /// In en, this message translates to:
  /// **'Slide victim out horizontally'**
  String get rescue_car_step_6_title;

  /// No description provided for @rescue_car_step_6_detail.
  ///
  /// In en, this message translates to:
  /// **'One person holds head, another grips under armpits. Move in one smooth motion. Never twist the spine.'**
  String get rescue_car_step_6_detail;

  /// No description provided for @rescue_car_step_7_title.
  ///
  /// In en, this message translates to:
  /// **'Place in recovery position'**
  String get rescue_car_step_7_title;

  /// No description provided for @rescue_car_step_7_detail.
  ///
  /// In en, this message translates to:
  /// **'If breathing, place on their side (recovery position) to prevent choking. Keep monitoring until ambulance arrives.'**
  String get rescue_car_step_7_detail;

  /// No description provided for @rescue_car_firstaid_1.
  ///
  /// In en, this message translates to:
  /// **'🩸 For bleeding: apply firm pressure with cloth. Don\'t remove it.'**
  String get rescue_car_firstaid_1;

  /// No description provided for @rescue_car_firstaid_2.
  ///
  /// In en, this message translates to:
  /// **'🫁 If not breathing: begin CPR — 30 chest compressions + 2 breaths.'**
  String get rescue_car_firstaid_2;

  /// No description provided for @rescue_car_firstaid_3.
  ///
  /// In en, this message translates to:
  /// **'🦴 If you suspect broken bones: do NOT straighten them.'**
  String get rescue_car_firstaid_3;

  /// No description provided for @rescue_car_firstaid_4.
  ///
  /// In en, this message translates to:
  /// **'🚨 Keep talking to the victim — keep them conscious and calm.'**
  String get rescue_car_firstaid_4;

  /// No description provided for @fuel_petrol_diesel.
  ///
  /// In en, this message translates to:
  /// **'Petrol / Diesel'**
  String get fuel_petrol_diesel;

  /// No description provided for @fuel_diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get fuel_diesel;

  /// No description provided for @fuel_petrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get fuel_petrol;

  /// No description provided for @fuel_electric.
  ///
  /// In en, this message translates to:
  /// **'Electric / Battery'**
  String get fuel_electric;

  /// No description provided for @fuel_diesel_cng.
  ///
  /// In en, this message translates to:
  /// **'Diesel / CNG'**
  String get fuel_diesel_cng;

  /// No description provided for @fuel_multi.
  ///
  /// In en, this message translates to:
  /// **'CNG / Petrol / Electric'**
  String get fuel_multi;

  /// No description provided for @rescue_truck_type.
  ///
  /// In en, this message translates to:
  /// **'Truck / Lorry / Heavy Vehicle'**
  String get rescue_truck_type;

  /// No description provided for @rescue_truck_desc.
  ///
  /// In en, this message translates to:
  /// **'Heavy goods vehicle, high cab, large fuel tanks'**
  String get rescue_truck_desc;

  /// No description provided for @rescue_truck_danger_1.
  ///
  /// In en, this message translates to:
  /// **'⛽ LARGE diesel tanks on both sides — fire risk is HIGH'**
  String get rescue_truck_danger_1;

  /// No description provided for @rescue_truck_danger_2.
  ///
  /// In en, this message translates to:
  /// **'⚡ 24V electrical system — more dangerous than regular cars'**
  String get rescue_truck_danger_2;

  /// No description provided for @rescue_truck_danger_3.
  ///
  /// In en, this message translates to:
  /// **'🏋️ Cab is very high — falling risk when extracting driver'**
  String get rescue_truck_danger_3;

  /// No description provided for @rescue_truck_danger_4.
  ///
  /// In en, this message translates to:
  /// **'📦 Cargo may shift and fall — approach from the side carefully'**
  String get rescue_truck_danger_4;

  /// No description provided for @rescue_truck_danger_5.
  ///
  /// In en, this message translates to:
  /// **'🔧 Air brakes may release suddenly — stay clear of wheels'**
  String get rescue_truck_danger_5;

  /// No description provided for @rescue_truck_step_1_title.
  ///
  /// In en, this message translates to:
  /// **'Approach from the SIDE only'**
  String get rescue_truck_step_1_title;

  /// No description provided for @rescue_truck_step_1_detail.
  ///
  /// In en, this message translates to:
  /// **'Never approach from front (engine fire) or rear (cargo). Come from driver\'s side door angle.'**
  String get rescue_truck_step_1_detail;

  /// No description provided for @rescue_truck_step_2_title.
  ///
  /// In en, this message translates to:
  /// **'Secure the truck'**
  String get rescue_truck_step_2_title;

  /// No description provided for @rescue_truck_step_2_detail.
  ///
  /// In en, this message translates to:
  /// **'If safe, apply handbrake and place wheel chocks (stones/wood) under tires to prevent rolling.'**
  String get rescue_truck_step_2_detail;

  /// No description provided for @rescue_truck_step_3_title.
  ///
  /// In en, this message translates to:
  /// **'Climb up carefully'**
  String get rescue_truck_step_3_title;

  /// No description provided for @rescue_truck_step_3_detail.
  ///
  /// In en, this message translates to:
  /// **'Use the built-in steps/handles on the cab. Don\'t pull on door handles to climb — they may break.'**
  String get rescue_truck_step_3_detail;

  /// No description provided for @rescue_truck_step_4_title.
  ///
  /// In en, this message translates to:
  /// **'Check driver consciousness'**
  String get rescue_truck_step_4_title;

  /// No description provided for @rescue_truck_step_4_detail.
  ///
  /// In en, this message translates to:
  /// **'Tap and call out. Driver may be trapped by steering wheel. Do NOT force them out.'**
  String get rescue_truck_step_4_detail;

  /// No description provided for @rescue_truck_step_5_title.
  ///
  /// In en, this message translates to:
  /// **'Extraction needs 3+ people'**
  String get rescue_truck_step_5_title;

  /// No description provided for @rescue_truck_step_5_detail.
  ///
  /// In en, this message translates to:
  /// **'One holds head/neck, two support body. Lower driver down cab steps slowly. Never drop.'**
  String get rescue_truck_step_5_detail;

  /// No description provided for @rescue_truck_step_6_title.
  ///
  /// In en, this message translates to:
  /// **'Move victim 50m away'**
  String get rescue_truck_step_6_title;

  /// No description provided for @rescue_truck_step_6_detail.
  ///
  /// In en, this message translates to:
  /// **'Trucks carry large fuel loads. Move victim far from vehicle in case of fire.'**
  String get rescue_truck_step_6_detail;

  /// No description provided for @rescue_truck_firstaid_1.
  ///
  /// In en, this message translates to:
  /// **'🚨 Call 108 AND fire brigade (101) — truck fires spread fast.'**
  String get rescue_truck_firstaid_1;

  /// No description provided for @rescue_truck_firstaid_2.
  ///
  /// In en, this message translates to:
  /// **'🩸 Truck drivers often hit steering wheel — check chest for injury.'**
  String get rescue_truck_firstaid_2;

  /// No description provided for @rescue_truck_firstaid_3.
  ///
  /// In en, this message translates to:
  /// **'👁️ Check for head injuries — helmet-less impact with windshield is common.'**
  String get rescue_truck_firstaid_3;

  /// No description provided for @rescue_truck_firstaid_4.
  ///
  /// In en, this message translates to:
  /// **'🦺 If cargo has hazmat symbols, stay back and call 112.'**
  String get rescue_truck_firstaid_4;

  /// No description provided for @rescue_bike_type.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle / Bike / Scooter'**
  String get rescue_bike_type;

  /// No description provided for @rescue_bike_desc.
  ///
  /// In en, this message translates to:
  /// **'Two-wheeler, rider likely thrown from vehicle'**
  String get rescue_bike_desc;

  /// No description provided for @rescue_bike_danger_1.
  ///
  /// In en, this message translates to:
  /// **'⛽ Small fuel tank near engine — can ignite easily'**
  String get rescue_bike_danger_1;

  /// No description provided for @rescue_bike_danger_2.
  ///
  /// In en, this message translates to:
  /// **'🪖 DO NOT remove helmet — may cause spinal damage'**
  String get rescue_bike_danger_2;

  /// No description provided for @rescue_bike_danger_3.
  ///
  /// In en, this message translates to:
  /// **'🛣️ Rider likely skidded — check for road rash injuries'**
  String get rescue_bike_danger_3;

  /// No description provided for @rescue_bike_danger_4.
  ///
  /// In en, this message translates to:
  /// **'🔥 Hot exhaust pipe — avoid touching, can cause burns'**
  String get rescue_bike_danger_4;

  /// No description provided for @rescue_bike_step_1_title.
  ///
  /// In en, this message translates to:
  /// **'Move the bike away first'**
  String get rescue_bike_step_1_title;

  /// No description provided for @rescue_bike_step_1_detail.
  ///
  /// In en, this message translates to:
  /// **'The bike is the fire risk. Push it at least 10m away from the victim before helping.'**
  String get rescue_bike_step_1_detail;

  /// No description provided for @rescue_bike_step_2_title.
  ///
  /// In en, this message translates to:
  /// **'NEVER remove the helmet'**
  String get rescue_bike_step_2_title;

  /// No description provided for @rescue_bike_step_2_detail.
  ///
  /// In en, this message translates to:
  /// **'Even if victim asks. Helmet removal can cause fatal spinal damage. Only doctors should remove it.'**
  String get rescue_bike_step_2_detail;

  /// No description provided for @rescue_bike_step_3_title.
  ///
  /// In en, this message translates to:
  /// **'Check breathing through visor'**
  String get rescue_bike_step_3_title;

  /// No description provided for @rescue_bike_step_3_detail.
  ///
  /// In en, this message translates to:
  /// **'Open the visor to check breathing. If vomiting, hold helmet steady and gently tilt to side.'**
  String get rescue_bike_step_3_detail;

  /// No description provided for @rescue_bike_step_4_title.
  ///
  /// In en, this message translates to:
  /// **'Check for road rash'**
  String get rescue_bike_step_4_title;

  /// No description provided for @rescue_bike_step_4_detail.
  ///
  /// In en, this message translates to:
  /// **'Large skin abrasions from skidding. Cover with clean cloth — don\'t clean with water yet.'**
  String get rescue_bike_step_4_detail;

  /// No description provided for @rescue_bike_step_5_title.
  ///
  /// In en, this message translates to:
  /// **'Keep rider still and flat'**
  String get rescue_bike_step_5_title;

  /// No description provided for @rescue_bike_step_5_detail.
  ///
  /// In en, this message translates to:
  /// **'Riders are often thrown and land awkwardly. Assume spinal injury. Keep them flat until help arrives.'**
  String get rescue_bike_step_5_detail;

  /// No description provided for @rescue_bike_step_6_title.
  ///
  /// In en, this message translates to:
  /// **'Keep them warm'**
  String get rescue_bike_step_6_title;

  /// No description provided for @rescue_bike_step_6_detail.
  ///
  /// In en, this message translates to:
  /// **'Shock causes rapid body cooling. Cover with jacket/blanket. Keep talking to them.'**
  String get rescue_bike_step_6_detail;

  /// No description provided for @rescue_bike_firstaid_1.
  ///
  /// In en, this message translates to:
  /// **'🪖 NEVER remove helmet — this is the most important rule for bike accidents.'**
  String get rescue_bike_firstaid_1;

  /// No description provided for @rescue_bike_firstaid_2.
  ///
  /// In en, this message translates to:
  /// **'🦴 Assume broken limbs — don\'t try to straighten or move them.'**
  String get rescue_bike_firstaid_2;

  /// No description provided for @rescue_bike_firstaid_3.
  ///
  /// In en, this message translates to:
  /// **'😮 Shock is common — keep victim lying down, legs slightly elevated.'**
  String get rescue_bike_firstaid_3;

  /// No description provided for @rescue_bike_firstaid_4.
  ///
  /// In en, this message translates to:
  /// **'🩸 Road rash bleeds a lot but is rarely life-threatening — focus on head/spine.'**
  String get rescue_bike_firstaid_4;

  /// No description provided for @rescue_ev_car_type.
  ///
  /// In en, this message translates to:
  /// **'Electric Vehicle (EV Car)'**
  String get rescue_ev_car_type;

  /// No description provided for @rescue_ev_car_desc.
  ///
  /// In en, this message translates to:
  /// **'Battery-powered car — special electrical hazards'**
  String get rescue_ev_car_desc;

  /// No description provided for @rescue_ev_car_danger_1.
  ///
  /// In en, this message translates to:
  /// **'⚡ HIGH VOLTAGE battery (400-800V) — can be LETHAL if touched'**
  String get rescue_ev_car_danger_1;

  /// No description provided for @rescue_ev_car_danger_2.
  ///
  /// In en, this message translates to:
  /// **'🔥 Lithium battery fires burn at 1000°C and CANNOT be extinguished easily'**
  String get rescue_ev_car_danger_2;

  /// No description provided for @rescue_ev_car_danger_3.
  ///
  /// In en, this message translates to:
  /// **'🌊 If EV is in water — stay away, electric shock risk is EXTREME'**
  String get rescue_ev_car_danger_3;

  /// No description provided for @rescue_ev_car_danger_4.
  ///
  /// In en, this message translates to:
  /// **'💨 Battery fires release toxic gases — stay upwind'**
  String get rescue_ev_car_danger_4;

  /// No description provided for @rescue_ev_car_danger_5.
  ///
  /// In en, this message translates to:
  /// **'🔄 Car may still be \"on\" even if silent — EVs make no engine noise'**
  String get rescue_ev_car_danger_5;

  /// No description provided for @rescue_ev_car_step_1_title.
  ///
  /// In en, this message translates to:
  /// **'DO NOT touch orange cables'**
  String get rescue_ev_car_step_1_title;

  /// No description provided for @rescue_ev_car_step_1_detail.
  ///
  /// In en, this message translates to:
  /// **'Orange cables carry high voltage. If you see orange wires exposed — do NOT touch the car at all.'**
  String get rescue_ev_car_step_1_detail;

  /// No description provided for @rescue_ev_car_step_2_title.
  ///
  /// In en, this message translates to:
  /// **'Turn off the car'**
  String get rescue_ev_car_step_2_title;

  /// No description provided for @rescue_ev_car_step_2_detail.
  ///
  /// In en, this message translates to:
  /// **'If safe, reach in and press power button. Look for emergency cut-off switch (usually near door sill — bright red/orange).'**
  String get rescue_ev_car_step_2_detail;

  /// No description provided for @rescue_ev_car_step_3_title.
  ///
  /// In en, this message translates to:
  /// **'Check for battery damage'**
  String get rescue_ev_car_step_3_title;

  /// No description provided for @rescue_ev_car_step_3_detail.
  ///
  /// In en, this message translates to:
  /// **'If battery area (under floor) is visibly damaged or smoking — treat as fire emergency. Move victim 30m away.'**
  String get rescue_ev_car_step_3_detail;

  /// No description provided for @rescue_ev_car_step_4_title.
  ///
  /// In en, this message translates to:
  /// **'Extraction same as regular car'**
  String get rescue_ev_car_step_4_title;

  /// No description provided for @rescue_ev_car_step_4_detail.
  ///
  /// In en, this message translates to:
  /// **'Once confirmed safe (no exposed cables, no smoke), extraction steps are same as regular car. Support neck, slide out.'**
  String get rescue_ev_car_step_4_detail;

  /// No description provided for @rescue_ev_car_step_5_title.
  ///
  /// In en, this message translates to:
  /// **'If battery catches fire — RUN'**
  String get rescue_ev_car_step_5_title;

  /// No description provided for @rescue_ev_car_step_5_detail.
  ///
  /// In en, this message translates to:
  /// **'EV battery fires cannot be put out with normal extinguishers. Move everyone 50m away and call fire brigade 101.'**
  String get rescue_ev_car_step_5_detail;

  /// No description provided for @rescue_ev_car_firstaid_1.
  ///
  /// In en, this message translates to:
  /// **'⚡ If victim received electric shock: do not touch them until power is confirmed off.'**
  String get rescue_ev_car_firstaid_1;

  /// No description provided for @rescue_ev_car_firstaid_2.
  ///
  /// In en, this message translates to:
  /// **'👁️ Electric shock victims may have internal burns not visible outside.'**
  String get rescue_ev_car_firstaid_2;

  /// No description provided for @rescue_ev_car_firstaid_3.
  ///
  /// In en, this message translates to:
  /// **'🫁 Toxic battery fumes — move victim upwind, fresh air is critical.'**
  String get rescue_ev_car_firstaid_3;

  /// No description provided for @rescue_ev_car_firstaid_4.
  ///
  /// In en, this message translates to:
  /// **'🚒 Always call fire brigade for EV accidents — even if no visible fire yet.'**
  String get rescue_ev_car_firstaid_4;

  /// No description provided for @rescue_bus_type.
  ///
  /// In en, this message translates to:
  /// **'Bus / Minibus'**
  String get rescue_bus_type;

  /// No description provided for @rescue_bus_desc.
  ///
  /// In en, this message translates to:
  /// **'Large passenger vehicle, multiple victims likely'**
  String get rescue_bus_desc;

  /// No description provided for @rescue_bus_danger_1.
  ///
  /// In en, this message translates to:
  /// **'👥 Multiple casualties — prioritize who needs help most (triage)'**
  String get rescue_bus_danger_1;

  /// No description provided for @rescue_bus_danger_2.
  ///
  /// In en, this message translates to:
  /// **'⛽ Large fuel tank — fire risk is HIGH'**
  String get rescue_bus_danger_2;

  /// No description provided for @rescue_bus_danger_3.
  ///
  /// In en, this message translates to:
  /// **'💨 CNG buses have gas cylinders — EXPLOSION RISK if ruptured'**
  String get rescue_bus_danger_3;

  /// No description provided for @rescue_bus_danger_4.
  ///
  /// In en, this message translates to:
  /// **'🚪 Emergency exits at rear and roof — know how to use them'**
  String get rescue_bus_danger_4;

  /// No description provided for @rescue_bus_step_1_title.
  ///
  /// In en, this message translates to:
  /// **'Assess from outside first'**
  String get rescue_bus_step_1_title;

  /// No description provided for @rescue_bus_step_1_detail.
  ///
  /// In en, this message translates to:
  /// **'Count visible victims. Check for fire/smoke. Don\'t rush in — a second casualty helps no one.'**
  String get rescue_bus_step_1_detail;

  /// No description provided for @rescue_bus_step_2_title.
  ///
  /// In en, this message translates to:
  /// **'Check for CNG cylinders'**
  String get rescue_bus_step_2_title;

  /// No description provided for @rescue_bus_step_2_detail.
  ///
  /// In en, this message translates to:
  /// **'CNG buses have cylindrical tanks on roof or rear. If hissing sound heard — evacuate everyone 100m away immediately.'**
  String get rescue_bus_step_2_detail;

  /// No description provided for @rescue_bus_step_3_title.
  ///
  /// In en, this message translates to:
  /// **'Use emergency exits'**
  String get rescue_bus_step_3_title;

  /// No description provided for @rescue_bus_step_3_detail.
  ///
  /// In en, this message translates to:
  /// **'Red handles at rear door and roof hatch. Push/pull to open. Don\'t wait for front door if jammed.'**
  String get rescue_bus_step_3_detail;

  /// No description provided for @rescue_bus_step_4_title.
  ///
  /// In en, this message translates to:
  /// **'Triage victims — most critical first'**
  String get rescue_bus_step_4_title;

  /// No description provided for @rescue_bus_step_4_detail.
  ///
  /// In en, this message translates to:
  /// **'Walking wounded can help themselves. Focus on unconscious or heavily bleeding victims first.'**
  String get rescue_bus_step_4_detail;

  /// No description provided for @rescue_bus_step_5_title.
  ///
  /// In en, this message translates to:
  /// **'Form human chain for extraction'**
  String get rescue_bus_step_5_title;

  /// No description provided for @rescue_bus_step_5_detail.
  ///
  /// In en, this message translates to:
  /// **'Line up bystanders to pass victims out of windows/exits. One person stabilizes head, others support body.'**
  String get rescue_bus_step_5_detail;

  /// No description provided for @rescue_bus_firstaid_1.
  ///
  /// In en, this message translates to:
  /// **'📞 Call 108 AND 100 — multiple casualties need multiple ambulances.'**
  String get rescue_bus_firstaid_1;

  /// No description provided for @rescue_bus_firstaid_2.
  ///
  /// In en, this message translates to:
  /// **'🏃 Get able-bodied passengers out first — they can then help others.'**
  String get rescue_bus_firstaid_2;

  /// No description provided for @rescue_bus_firstaid_3.
  ///
  /// In en, this message translates to:
  /// **'🔴 Triage: Red = critical (help first), Yellow = serious, Green = walking.'**
  String get rescue_bus_firstaid_3;

  /// No description provided for @rescue_bus_firstaid_4.
  ///
  /// In en, this message translates to:
  /// **'💨 If CNG leak suspected — NO flames, NO phones near the vehicle.'**
  String get rescue_bus_firstaid_4;

  /// No description provided for @rescue_auto_type.
  ///
  /// In en, this message translates to:
  /// **'Auto Rickshaw / Tuk-Tuk'**
  String get rescue_auto_type;

  /// No description provided for @rescue_auto_desc.
  ///
  /// In en, this message translates to:
  /// **'3-wheeler, open sides, common in Indian roads'**
  String get rescue_auto_desc;

  /// No description provided for @rescue_auto_danger_1.
  ///
  /// In en, this message translates to:
  /// **'💨 CNG autos — check for hissing gas leak sounds'**
  String get rescue_auto_danger_1;

  /// No description provided for @rescue_auto_danger_2.
  ///
  /// In en, this message translates to:
  /// **'🔓 Open sides mean passengers are often thrown out'**
  String get rescue_auto_danger_2;

  /// No description provided for @rescue_auto_danger_3.
  ///
  /// In en, this message translates to:
  /// **'⚖️ Autos tip over easily — approach carefully, may be unstable'**
  String get rescue_auto_danger_3;

  /// No description provided for @rescue_auto_danger_4.
  ///
  /// In en, this message translates to:
  /// **'🔧 Small vehicle = less protection = more severe injuries'**
  String get rescue_auto_danger_4;

  /// No description provided for @rescue_auto_step_1_title.
  ///
  /// In en, this message translates to:
  /// **'Stabilize the auto first'**
  String get rescue_auto_step_1_title;

  /// No description provided for @rescue_auto_step_1_detail.
  ///
  /// In en, this message translates to:
  /// **'Autos tip over easily. Push gently to check stability before leaning in. Ask bystanders to hold it steady.'**
  String get rescue_auto_step_1_detail;

  /// No description provided for @rescue_auto_step_2_title.
  ///
  /// In en, this message translates to:
  /// **'Check all three sides'**
  String get rescue_auto_step_2_title;

  /// No description provided for @rescue_auto_step_2_detail.
  ///
  /// In en, this message translates to:
  /// **'Passengers in autos are often thrown sideways. Check all around the vehicle, not just inside.'**
  String get rescue_auto_step_2_detail;

  /// No description provided for @rescue_auto_step_3_title.
  ///
  /// In en, this message translates to:
  /// **'Driver extraction'**
  String get rescue_auto_step_3_title;

  /// No description provided for @rescue_auto_step_3_detail.
  ///
  /// In en, this message translates to:
  /// **'Driver seat is exposed. Support driver\'s head from behind while helper pulls from front.'**
  String get rescue_auto_step_3_detail;

  /// No description provided for @rescue_auto_step_4_title.
  ///
  /// In en, this message translates to:
  /// **'Passenger extraction'**
  String get rescue_auto_step_4_title;

  /// No description provided for @rescue_auto_step_4_detail.
  ///
  /// In en, this message translates to:
  /// **'Open side means easy access. Support neck, slide passenger out sideways onto flat ground.'**
  String get rescue_auto_step_4_detail;

  /// No description provided for @rescue_auto_firstaid_1.
  ///
  /// In en, this message translates to:
  /// **'🛺 Auto passengers have no seatbelts — expect to find them thrown from vehicle.'**
  String get rescue_auto_firstaid_1;

  /// No description provided for @rescue_auto_firstaid_2.
  ///
  /// In en, this message translates to:
  /// **'🔍 Search radius of 5m around auto for thrown passengers.'**
  String get rescue_auto_firstaid_2;

  /// No description provided for @rescue_auto_firstaid_3.
  ///
  /// In en, this message translates to:
  /// **'🩹 Road rash from open sides is common — cover wounds with clean cloth.'**
  String get rescue_auto_firstaid_3;

  /// No description provided for @rescue_auto_firstaid_4.
  ///
  /// In en, this message translates to:
  /// **'😮 Shock sets in fast in small vehicle accidents — keep victims warm and calm.'**
  String get rescue_auto_firstaid_4;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bn',
    'en',
    'hi',
    'mr',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
