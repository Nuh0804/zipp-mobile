import Flutter
import UIKit
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Google Maps API Key
    GMSServices.provideAPIKey("AIzaSyDqOt-pE0JObnX_UaZXO6-3Pih953Kc5Ho")
    
    // Set the default Map ID for advanced features
    GMSMapID.init(identifier: "a11b0e9d62ccce5e")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
