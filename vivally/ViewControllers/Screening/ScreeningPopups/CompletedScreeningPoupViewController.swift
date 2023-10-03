//
//  CompletedScreeningPoupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/13/23.
//

import UIKit

class CompletedScreeningPoupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Therapy Personalization completed", message: "Would you like to run a short test Therapy?", option1: "Sign out",option2: "Test Therapy", flipPrimary:true, xClose: true, icon: .check)
        
        super.viewDidLoad()
    }
    
    override func tappedOption1(_ sender: UIButton) {
        //sign out
        self.dismiss(animated: true){
            let initialViewController = NonSignedInMainViewController()
            NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
            
            NetworkManager.sharedInstance.logoutClear()
            DataRecoveryManager.sharedInstance.removeRecovery()
        }
    }
    
    override func tappedOption2(_ sender: UIButton) {
        //go to test Therapy
        self.dismiss(animated: true){
            ScreeningProcessManager.sharedInstance.setTestTherapyEvalCrit()
            TherapyManager.sharedInstance.testTherapy = true
            TherapyManager.sharedInstance.isLeft = ScreeningProcessManager.sharedInstance.isLeft
            let storyboard = UIStoryboard(name: "therapyNew", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TherapyViewController") as! TherapyViewController
            //self.navigationController?.pushViewController(vc, animated: true)
            NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: true)
        }
    }
    
    override func tappedClose(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
