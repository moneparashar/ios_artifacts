//
//  PatientEnrollmentMessagePopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/11/23.
//

import UIKit

enum PatientEnrollmentStatus{
    case failedAddPatient
    case added
    case addedWithoutPersonalization
    case failedEdit
}

class PatientEnrollmentMessagePopupViewController: BasicPopupViewController {
    
    var status: PatientEnrollmentStatus?
    
    override func viewDidLoad() {
        setup()
        super.viewDidLoad()
        
        if status == .addedWithoutPersonalization{
            option2Button.isEnabled = false
        }
    }
    
    func setup(){
        if status != nil{
            switch status!{
            case .failedAddPatient:
                baseContent = BasicPopupContent(title: "Unable to add patient", message: "Adding Patient failed, email address was registered already", option1: "OK")
            case .added:
                baseContent = BasicPopupContent(title: "Patient added", message: "Patient added successfully", option1: "Sign out", option2: "Personalization", icon: .check)
            case .addedWithoutPersonalization:
                baseContent = BasicPopupContent(title: "Patient added", message: "Patient added successfully.\nTo continue with screening, therapy personalization info is required", option1: "Sign out", option2: "Personalization", icon: .check)
            case .failedEdit:
                baseContent = BasicPopupContent(title: "Unable to save", message: "Saving new edited info failed.", option1: "OK")
            }
        }
    }
    
    override func tappedOption1(_ sender: UIButton) {
        switch status!{
        case .failedAddPatient, .failedEdit:
            self.dismiss(animated: false)
        case .added, .addedWithoutPersonalization:
            //sign out
            NetworkManager.sharedInstance.logoutClear()
            let initialViewController = NonSignedInMainViewController()
            NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
        }
    }
    
    override func tappedOption2(_ sender: UIButton) {
        if status == .added{
            //go to new screening page
            
            
            if let patientData = ScreeningManager.sharedInstance.loadAccountData(){
                let screenGuid = UUID()
                let therapyLength = Int32(1800)
                ScreeningProcessManager.sharedInstance.therapySchedule = patientData.therapySchedule
                ScreeningProcessManager.sharedInstance.therapyLength = Int(therapyLength)
                ScreeningManager.sharedInstance.screening(username: patientData.username ?? "", screenGuid: screenGuid.uuidString){ success, didSend, errorMessage in
                    if success{
                        ScreeningManager.sharedInstance.screeningGuid = screenGuid
                        ScreeningManager.sharedInstance.saveScreeningGuid()
                        
                        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.screeningPrepGo.rawValue), object: nil)
                        self.dismiss(animated: false)
                    }
                    else{
                        self.dismiss(animated: false)
                        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.screeningCreateFail.rawValue), object: nil)
                    }
                }
            }
            else{
                self.dismiss(animated: false)
                NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.screeningCreateFail.rawValue), object: nil)
            }
        }
    }
    
    override func tappedClose(_ sender: UIButton) {
        
        if status == .added || status == .addedWithoutPersonalization{
            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.navigationBackScreen.rawValue), object: nil)
        }
        self.dismiss(animated: false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
