//
//  AppUpdateManager.swift
//  vivally
//
//  Created by Ryan Levels on 9/19/23.
//

import UIKit

class AppUpdateManager: NSObject {
    static let sharedInstance = AppUpdateManager()
    
    var updateAvailable = false
    func checkForAppUpdate() {
        let appBuildVersion = UIApplication.build ?? ""
        //let appData = AppManager.sharedInstance.loadAppDeviceData()
        let preProdAppId = "6451394364" // MARK: taken from the app store url
        let appId = "1585689224"
        
        AppUpdateManager.sharedInstance.isAppStoreUpdateAvailable(appId: appId, currentVersion: appBuildVersion) { [self] updateIsAvailable, error in
            // Update available
            if updateIsAvailable {
                print("Update available on the App Store.")
                //print("Update available on Testflight.")
                updateAvailable = true

            // Error
            } else if let error = error {
                print("Error: \(error)")

            // No update available
            } else {
                print("No update available on the App Store.")
                //print("No update available on Testflight.")
                updateAvailable = false
            }
        }
    }
    
    // Check testflight for app number differences
    func isAppStoreUpdateAvailable(appId: String, currentVersion: String, completionHandler: @escaping (Bool, String?) -> Void) {
        //let appStoreURL = "https://itunes.apple.com/lookup?bundleId=\(appId)" MARK: bundleId may be the correct query param
        let appStoreURL = "https://itunes.apple.com/lookup?id=\(appId)"
        //let appStoreURL = "https://apps.apple.com/us/app/\(appId)"
        let session = URLSession(configuration: .default)
        
        if let url = URL(string: appStoreURL) {
            let task = session.dataTask(with: url) { (data, _, error) in
                if let error = error {
                    completionHandler(false, "Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    completionHandler(false, "No data received from the App Store.")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let results = json?["results"] as? [[String: Any]], let appData = results.first {
                        if let appVersion = appData["version"] as? String {
                            let updateAvailable = currentVersion.compare(appVersion, options: .numeric) == .orderedAscending
                            
                            completionHandler(updateAvailable, nil)
                            return
                        }
                    }
                    
                    completionHandler(false, "Unable to fetch app version from response.")
                } catch {
                    completionHandler(false, "Error parsing JSON data: \(error.localizedDescription)")
                }
            }
            task.resume()
        } else {
            completionHandler(false, "Invalid App Store URL.")
        }
    }
}
