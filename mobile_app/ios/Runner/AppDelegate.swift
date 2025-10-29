import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle deep links (URL schemes)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // Log the incoming URL for debugging
    print("Deep link received: \(url.absoluteString)")
    
    // Let Flutter handle the deep link via url_launcher
    return super.application(app, open: url, options: options)
  }
  
  // Handle universal links (iOS 9+)
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    // Log the incoming activity for debugging
    if let url = userActivity.webpageURL {
      print("Universal link received: \(url.absoluteString)")
    }
    
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
