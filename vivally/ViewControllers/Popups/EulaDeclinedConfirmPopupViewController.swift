//
//  EulaDeclinedConfirmPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/28/23.
//

import UIKit

class EulaDeclinedConfirmPopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Terms of Use & Privacy Policy", message: "Are you sure you wish to decline the Terms of Use and Privacy Policy?\nYou cannot contiue unless you agree to the terms of the Terms of Use and Privacy Policy", option1: "Yes", option2: "No", xClose: false, icon: .question)
        super.viewDidLoad()
    }
    
    override func tappedOption1(_ sender: UIButton) {
        let appData = AppManager.sharedInstance.loadAppDeviceData()
        let appId = appData!.appIdentifier
        NotificationManager.sharedInstance.postPushNotificationUnRegister(appId: appId) { success, errorMessage in
            let initialViewController = NonSignedInMainViewController()
            NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
        }
        NetworkManager.sharedInstance.logoutClear()
        ActivityManager.sharedInstance.loggedOut()
    }
    
    override func tappedOption2(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    func acceptTapped(){
        _ = KeychainManager.sharedInstance.loadAccountData()
        AccountManager.sharedInstance.acceptedEula(){ success, didSend, errorMessage in
            if success{
                var accountData = KeychainManager.sharedInstance.accountData
                if accountData == nil{
                    accountData = AccountData()
                }
                accountData?.acceptedEULA = true
                KeychainManager.sharedInstance.saveAccountData(data: accountData!)
                
                if KeychainManager.sharedInstance.accountData!.roles.contains("Patient") || KeychainManager.sharedInstance.accountData!.roles.contains("Admin") {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainVc = storyboard.instantiateViewController(identifier: "AdministratorLoginViewController")
                    
                    let storyboard2 = UIStoryboard(name: "account", bundle: nil)
                    let pinVC = storyboard2.instantiateViewController(withIdentifier: "SetPinViewController")
                    
                    self.navigationController?.setViewControllers([mainVc, pinVC], animated: true)
                }
                else if KeychainManager.sharedInstance.accountData!.roles.contains("Clinician"){
                    let vc = AdminMainViewController()
                    NavigationManager.sharedInstance.setRootViewController(viewController: vc)
                    ActivityManager.sharedInstance.resetInactivityCount()
                }
            }
            
            else{
                //log error
                Slim.error("Failed to accept Eula via cloud")
            }
        }
    }
}
