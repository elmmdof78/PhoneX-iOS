import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var webView: WKWebView!
    var bleManager: BleManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let webViewController = UIViewController()
        webView = WKWebView(frame: webViewController.view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // آدرس Ktor روی شیائومی (برای نمایش رابط کاربری)
        // ⚠️ حتماً این IP را به IP گوشی شیائومی خود تغییر دهید
        let androidIP = "192.168.1.100" 
        let url = URL(string: "https://\(androidIP):8443")!
        webView.load(URLRequest(url: url))
        
        webViewController.view.addSubview(webView)
        window?.rootViewController = webViewController
        window?.makeKeyAndVisible()
        
        // ✅ راه‌اندازی بلوتوث
        bleManager = BleManager()
        bleManager.onConnected = {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript("onBleConnected();")
            }
        }
        bleManager.onDisconnected = {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript("onBleDisconnected();")
            }
        }
        bleManager.onDataReceived = { data in
            DispatchQueue.main.async {
                // escape single quotes for javascript
                let escapedData = data.replacingOccurrences(of: "'", with: "\\'")
                self.webView.evaluateJavaScript("onBleDataReceived('\(escapedData)');")
            }
        }
        
        bleManager.startScanning()
        
        return true
    }
}