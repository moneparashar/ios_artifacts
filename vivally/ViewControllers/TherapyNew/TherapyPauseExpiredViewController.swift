//
//  TherapyPauseExpiredViewController.swift
//  vivally
//
//  Created by Ryan Levels on 7/3/23.
//

import UIKit

class TherapyPauseExpiredViewController: BaseNavViewController {
    
    @IBOutlet weak var okButton: ActionButton!
    
    override func viewDidLoad() {
        super.removeOnInactivity = true
        super.showOnlyRightLogo = true
        

        // Do any additional setup after loading the view.
        
        // clinician? YES: 'Ok' button title = 'Sign out'
        if let accountData = KeychainManager.sharedInstance.loadAccountData(){
            if accountData.roles.contains("Clinician"){
                okButton.setTitle("Sign Out", for: .normal)
             
            // patient? YES: show back
            } else {
                super.goBackEnabled = true
                super.popToRoot = true
            }
        }
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // clinician? YES: hide back button
        if let accountData = KeychainManager.sharedInstance.loadAccountData(){
            if accountData.roles.contains("Clinician"){
                navigationItem.setHidesBackButton(true, animated: false)
            }
        }
        
        let vc = PauseExpiredPopupViewController()
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // clinician? YES: unhide back button
        if let accountData = KeychainManager.sharedInstance.loadAccountData(){
            if accountData.roles.contains("Clinician"){
                navigationItem.setHidesBackButton(false, animated: false)
            }
        }
    }

    @IBAction func okTapped(_ sender: ActionButton) {
        if let accountData = KeychainManager.sharedInstance.loadAccountData(){
            if accountData.roles.contains("Clinician"){
                // log user out
                let initialViewController = NonSignedInMainViewController()
                NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
                
                NetworkManager.sharedInstance.logoutClear()
                DataRecoveryManager.sharedInstance.removeRecovery()
            }
            else if accountData.roles.contains("Patient"){
                let storyboard = UIStoryboard(name: "therapyNew", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "TherapyHistoryWeekViewController")

                let storyboard2 = UIStoryboard(name: "Main", bundle: nil)
                let homevc = storyboard2.instantiateViewController(withIdentifier: "HomeViewController")
                
                self.navigationController?.setViewControllers([homevc, vc], animated: true)
            }
        }
        
        
    }
}
