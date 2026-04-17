import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let channelName = "com.codestreak.roadsos/hardware_buttons"
  private var methodChannel: FlutterMethodChannel?
  private var volumePressCount = 0
  private var lastPressTime = Date()
  private var audioSessionContext = 0

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    
    setupVolumeObserver()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
  
  private func setupVolumeObserver() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setActive(true)
      audioSession.addObserver(self, forKeyPath: "outputVolume", options: .new, context: &audioSessionContext)
    } catch {
      print("Failed to activate audio session")
    }
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if context == &audioSessionContext {
        let now = Date()
        if now.timeIntervalSince(lastPressTime) > 2.0 {
            volumePressCount = 0
        }
        lastPressTime = now
        volumePressCount += 1
        
        if volumePressCount >= 6 {
            methodChannel?.invokeMethod("triggerSOS", arguments: nil)
            volumePressCount = 0
        }
    } else {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
}
