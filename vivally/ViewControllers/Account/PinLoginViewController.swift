//
//  PinLoginViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 6/18/21.
//

import UIKit

class PinLoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    
    @IBOutlet weak var pinView: PinView!
    
    @IBOutlet weak var incorrectPINError: UILabel!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var signOutButton: ActionButton!
    
    var pinStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackWidth.constant = view.getWidthConstant()
        
        if ActivityManager.sharedInstance.lockout{
            //need to hide back bar
            navigationItem.hidesBackButton = true
        }
        pinView.delegate = self
        signOutButton.toSecondary()
        incorrectPINError.textAlignment = .center
        
        buttonStack.arrangedSubviews[0].isHidden = UIDevice.current.userInterfaceIdiom == .phone
        
    }
    
    func signIn(){
        incorrectPINError.isHidden = true
        _ = KeychainManager.sharedInstance.loadAccountData()
        if pinStr == KeychainManager.sharedInstance.accountData?.pinValue{
            let token = KeychainManager.sharedInstance.accountData?.token
            
            APIClient.customHeaders.add(name: "Authorization", value: "Bearer " + token!)
            
            let accountData = KeychainManager.sharedInstance.loadAccountData()
            if accountData?.refreshToken != nil && accountData?.refreshToken != "" && NetworkManager.sharedInstance.connected{
                //comment out and check in hour if background refresh token truly worked
                
                AccountManager.sharedInstance.refreshToken(token: accountData!.refreshToken){ success, data, errorMessage, timeout  in
                    if success{
                        RefreshManager.sharedInstance.resetRefreshChecks()
                        Slim.log(level: LogLevel.info, category: [.authentication], "successful refresh via PIN")
                        //Slim.info("successful refresh via PIN")
                        NetworkManager.sharedInstance.checkUpdate()
                        self.grabEval()
                        self.grabUserInfo()
                        self.getPatientTherapy()
                        self.getHelpTimestamps()
                        self.getPatientJournalFocus()
                        self.getPatientJournals()
                        self.getDemographics()
                        
                        NetworkManager.sharedInstance.sendBulkStimAndEMGData(){}
                        NetworkManager.sharedInstance.sendTherapyOnlyData(){}
                    }
                    else if !timeout{
                        //refresh failed
                        let initialViewController = NonSignedInMainViewController()
                        NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
                        NetworkManager.sharedInstance.logoutClear()
                        ActivityManager.sharedInstance.loggedOut()
                    }
                }
                
            }
            
            UserDefaults.standard.set(true, forKey: "loggedIn")     //new activity manager fixes
            ActivityManager.sharedInstance.resetInactivityCount()   //
            if ((KeychainManager.sharedInstance.accountData?.roles.contains("Patient")) != nil) {
                if ActivityManager.sharedInstance.lockout{
                    ActivityManager.sharedInstance.lockout = false
                    let viewControllers = self.navigationController?.viewControllers
                    
                    var continueIndex = false
                    for vc in viewControllers!{
                        if vc is LockViewController{
                            continueIndex = true
                        }
                    }
                    if continueIndex{
                        self.navigationController?.popToViewController(viewControllers![viewControllers!.count - 3], animated: false)
                    }
                    else{
                        self.navigationController?.popToViewController(viewControllers![viewControllers!.count - 2], animated: false)
                    }
                    
                }
                else{
                    if BluetoothManager.sharedInstance.isConnectedToDevice(){
                        TherapyManager.sharedInstance.checkIfTherapyInProgress()
                    }
                    let vc = PatientMainViewController()
                    NavigationManager.sharedInstance.setRootViewController(viewController: vc)
                }
            }
            else if ((KeychainManager.sharedInstance.accountData?.roles.contains("Admin")) != nil) {
                let vc = PatientMainViewController()
                NavigationManager.sharedInstance.setRootViewController(viewController: vc)
            }
        }
        else{
            pinView.clearAll()
            incorrectPINError.isHidden = false
            pinViewHighlightError()
            incorrectPINError.text = "Incorrect PIN"
        }
    }
    
    func pinViewHighlightError(){
        pinView.pinTextFieldsArray[0].layer.borderColor = UIColor.red.cgColor
        pinView.pinTextFieldsArray[1].layer.borderColor = UIColor.red.cgColor
        pinView.pinTextFieldsArray[2].layer.borderColor = UIColor.red.cgColor
        pinView.pinTextFieldsArray[3].layer.borderColor = UIColor.red.cgColor
    }
    
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "account", bundle: nil)
        let vc = SignOutConfirmationPopupViewController()
        //let vc = storyboard.instantiateViewController(withIdentifier: "SignOutConfirmationViewController")
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: false, completion: nil)
    }
    
    func checkPatientStudy(){
            if BluetoothManager.sharedInstance.isConnectedToDevice(){
                BluetoothManager.sharedInstance.setMode2()
            }
    }
    
    func grabEval(){
        EvaluationCriteriaManager.sharedInstance.getEvalCriteriaPatient(){ success, data, errorMessage in
            if success{
                print("succesful pull of eval crit for patient")
                if data != nil{
                    let allowOverwrite = EvaluationCriteriaManager.sharedInstance.checkEvalCriteriaShouldOverwriteLocal(data: data!)
                    if allowOverwrite{
                        EvaluationCriteriaManager.sharedInstance.saveEvalConfigData(data: data!)
                        EvaluationCriteriaManager.sharedInstance.updateEvalSchedule()
                    }
                }
            }
        }
    }
    
    func grabUserInfo(){
        AccountManager.sharedInstance.getMe { success, userModel, errorMessage in
            if success{
                let accountData = KeychainManager.sharedInstance.loadAccountData()
                accountData?.userModel = userModel ?? UserModel()
                accountData?.username = userModel?.username ?? ""
                KeychainManager.sharedInstance.saveAccountData(data: accountData!)
               
            }
            else{
                Slim.error("error with grabbing User info via PIN login")
            }
            self.checkPatientStudy()
        }
    }
    func getPatientTherapy(){
        SessionDataManager.sharedInstance.getSessionData(){ success, data, errorMessage in
            if success{
            }
            else{
                print("error with getting session via login")
            }
            
        }
    }
    
    func getPatientJournals(){
        JournalEventsManager.sharedInstance.getJournalEvents(deleted: false){ success, data, errorMessage in
            if success{
            }
            else{
                print("error with getting patient journals via login")
            }
        }
    }
    func handleUpdatingInfo(){
        grabEval()
    }

    func getPatientJournalFocus(){
        JournalEventFocusPeriodManager.sharedInstance.getLatestFocus(){ success, data, errorMessage in
            if success{
                NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.diaryRequest.rawValue), object: nil)
            }
        }
    }
    
    func getHelpTimestamps(){
        HelpManager.sharedInstance.getHelpTimestamps(){ success, errorMessage in
            
        }
    }
    
    func getDemographics(){
        ScreeningManager.sharedInstance.getDemographics(){ success, result, errorMessage in
            if success{
    
            }
            else{
                print(errorMessage)
            }
        }
    }
}
extension PinLoginViewController: PinViewDelegate{
    func didFillView() {
        pinStr = pinView.getPIN()
        signIn()
    }
}
