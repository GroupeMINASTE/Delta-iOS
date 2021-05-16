//
//  AppDelegate.swift
//  Delta
//
//  Created by Nathan FALLET on 9/17/18.
//  Copyright © 2018 Nathan FALLET. All rights reserved.
//

import UIKit
import APIRequest
import DigiAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize API
        initializeAPI()
        initializeAnalytics()
        
        // Check account
        Account.current.login()
        
        // Get build numbers
        let data = UserDefaults.standard
        let current_version = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        var build_number = current_version
        if let value = data.value(forKey: "build_number") as? Int {
            build_number = value
        }
        
        // Update database
        Database.current.updateDatabase(build_number: build_number)
        
        // Check to update
        if build_number < 24 {
            // Get all algorithms
            let algorithms = Database.current.getAlgorithms()
            
            // Clear downloaded algorithms
            for algorithm in algorithms {
                // Check if it is a download
                if !algorithm.owner {
                    // Remove it
                    Database.current.deleteAlgorithm(algorithm)
                }
            }
        }
        
        // Get current version and save it
        data.set(current_version, forKey: "build_number")
        
        // Create view
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = SplitViewController()
        window?.makeKeyAndVisible()
        
        return true
    }

    func initializeAPI() {
        // Initialize API
        APIConfiguration.current = APIConfiguration(host: "api.delta-algorithms.com", headers: {
            // Initialize a dict for headers
            var headers = [String: String]()
            
            // Get access token if available
            if let access_token = Account.current.access_token {
                headers["access-token"] = access_token
            }
            
            // Locale and version information
            if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                headers["client-version"] = version
            }
            if Bundle.main.preferredLocalizations.count > 0 {
                headers["Accept-Language"] = Bundle.main.preferredLocalizations[0]
            }
            
            // Return headers
            return headers
        })
    }
    
    func initializeAnalytics() {
        // Send first open
        let datas = UserDefaults.standard
        if !datas.bool(forKey: "first_open") {
            DigiAnalytics.shared.send(path: "first_open")
            datas.set(true, forKey: "first_open")
            datas.synchronize()
        }
        
        // Send open
        DigiAnalytics.shared.send(path: "open_app")
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Check if user comes from URL
        if let url = userActivity.webpageURL, url.host == "delta-algorithms.com" || url.host == "www.delta-algorithms.com" {
            // Set referrer
            DigiAnalytics.shared.referrer = url.absoluteString
            
            // Check if the url corresponds to an algorithm
            if url.pathComponents.count == 3, url.pathComponents[1] == "algorithm", let id = Int64(url.pathComponents[2]) {
                // Get home view controller
                if let split = window?.rootViewController as? SplitViewController {
                    // Open cloud
                    split.leftViewController.openCloud(with: id)
                }
            }
        }
        
        // Not handled
        return false
    }
    
}

#if targetEnvironment(macCatalyst)
extension AppDelegate {
    
    override func buildMenu(with builder: UIMenuBuilder) {
        // Check if it's main menu
        if builder.system == .main {
            // Help feature
            builder.replaceChildren(ofMenu: .help, from: helpMenu(elements:))
        }
    }
    
    func helpMenu(elements: [UIMenuElement]) -> [UIMenuElement] {
        // Create a menu item
        let help = UIKeyCommand(title: "help".localized(), image: nil, action: #selector(openHelp(_:)), input: "?", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: nil, attributes: .destructive, state: .off)
        
        // Return list
        return [help]
    }
    
    @objc func openHelp(_ sender: Any) {
        // Help and documentation
        if let url = URL(string: "https://www.delta-algorithms.com") {
            UIApplication.shared.open(url)
        }
    }

}
#endif
