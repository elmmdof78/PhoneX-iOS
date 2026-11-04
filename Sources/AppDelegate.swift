import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let webViewController = UIViewController()
        let webView = WKWebView(frame: webViewController.view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // در اینجا IP گوشی اندروید خود را قرار دهید
        let androidIP = "192.168.1.100" // ⚠️ این آی‌پی را بعدا باید تغییر دهید
        let url = URL(string: "https://\(androidIP):8443")!
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        webViewController.view.addSubview(webView)
        window?.rootViewController = webViewController
        window?.makeKeyAndVisible()
        
        return true
    }
}
