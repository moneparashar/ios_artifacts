//
//  LockViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/8/22.
//

import UIKit

class LockViewController: BaseNavViewController {

    @IBOutlet weak var messageLabel: UILabel!
    
    
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    
    @IBOutlet weak var buttonStack: UIStackView!
    //var lockOutTimer:Timer?
    override func viewDidLoad() {
        super.shouldClearNavbar = true
        super.viewDidLoad()
        
        buttonStack.arrangedSubviews[0].isHidden = UIDevice.current.userInterfaceIdiom == .phone
        stackWidth.constant = view.getWidthConstant()
        self.navigationItem.setHidesBackButton(true, animated: true)

        // Do any additional setup after loading the view.
        if KeychainManager.sharedInstance.accountData!.roles.contains("Clinician") {
            messageLabel.text = "You will be signed out in 1 minute due to inactivity.\n Tap Continue to stay signed in."
        }
        else{
            messageLabel.text = "The application will lock in 1 minute due to inactivity.\n Tap Continue if you don't want the application to lock."
        }
        //lockOutTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(lockOut), userInfo: nil, repeats: false)
        
    }
    
    @objc func lockOut(){
        ActivityManager.sharedInstance.loggedOut()
        if let accountData = KeychainManager.sharedInstance.loadAccountData(){
            if accountData.roles.contains("Clinician") {
                Slim.info("Clear Account Data Being Called")
                KeychainManager.sharedInstance.clearAccountData()
                let appData = AppManager.sharedInstance.loadAppDeviceData()
                let appId = appData!.appIdentifier
                NotificationManager.sharedInstance.postPushNotificationUnRegister(appId: appId) { success, errorMessage in
                    let initialViewController = NonSignedInMainViewController()
                    NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
                }
            }
            else if accountData.roles.contains("Patient"){
                ActivityManager.sharedInstance.lockout = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "PinLoginViewController") as! PinLoginViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func tappedContinue(_ sender: ActionButton) {
        self.navigationController?.popViewController(animated: true)
        ActivityManager.sharedInstance.resetInactivityCount()
    }
    

}
