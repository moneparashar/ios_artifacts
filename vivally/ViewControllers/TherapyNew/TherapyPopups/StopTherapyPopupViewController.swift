//
//  StopTherapyPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/27/23.
//

import UIKit

class StopTherapyPopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        if TherapyManager.sharedInstance.testTherapy
        {
            baseContent = BasicPopupContent(title: "Exit test Therapy", message: "Are you sure you want to exit the Test Therapy and Sign out?", option1: "No", option2: "Yes",flipPrimary: false, xClose: false)
        }else
        {
            baseContent = BasicPopupContent(title: "Stop Therapy", message: "Are you sure you would like to stop the Therapy?", option1: "Stop", option2: "Cancel",flipPrimary: true, xClose: false)
        }
       
        
        addObserver()
        
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObserver()
    }
    
    override func tappedOption1(_ sender: UIButton) {

        if TherapyManager.sharedInstance.testTherapy{
            self.dismiss(animated: false)
        }
        else{
            TherapyManager.sharedInstance.userStopTherapy()
            self.dismiss(animated: false)
        }
        
    }
    
    override func tappedOption2(_ sender: UIButton) {
        
        if TherapyManager.sharedInstance.testTherapy{
            TherapyManager.sharedInstance.userStopTherapy()
            let initialViewController = NonSignedInMainViewController()
            NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
            
            NetworkManager.sharedInstance.logoutClear()
            DataRecoveryManager.sharedInstance.removeRecovery()
            
        }else
        {
            self.dismiss(animated: false)
        }
        
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeVC(notif:)), name: NSNotification.Name(NotificationNames.closePopup.rawValue), object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func closeVC(notif: Notification) {
        self.dismiss(animated: false)
    }
}
