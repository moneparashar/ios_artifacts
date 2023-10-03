/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum NavigationViewControllers:Int{
    case login
    case patientHome
    case adminHome
}

protocol NavigationManagerDelegate {
    
}

class NavigationManager: NSObject {
    static let sharedInstance = NavigationManager()
    
    var currentNav = UINavigationController()
    
    func setRootViewController(viewController:UIViewController){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        appDelegate.window?.rootViewController = viewController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    func setRootViewControllerWithPush(rootViewController:UINavigationController, pushVC:UIViewController){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = rootViewController
        rootViewController.pushViewController(pushVC, animated: true)
    }
    
    
}



