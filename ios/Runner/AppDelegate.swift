import Flutter
import UIKit
// import FirebaseCore  // Temporarily disabled to test if Firebase is causing the crash

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    // FirebaseApp.configure()  // Temporarily disabled - Firebase not used in Dart code
  }
}
