//
//  AdministratorLoginViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 4/23/21.
//

import UIKit
import CoreBluetooth

import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class AdministratorLoginViewController: BaseNavViewController {
    
    @IBOutlet weak var userStackView: TextFieldStackView!
    @IBOutlet weak var passwordStackView: TextFieldStackView!
    
    @IBOutlet weak var signInButton: ActionButton!
    @IBOutlet weak var signUpButton: ActionButton!
    
    @IBOutlet weak var invalidLoginLabel: UILabel!
    
    
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    
    var observersSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signUpButton.toSecondary()
        
        stackWidth.constant = view.getWidthConstant()
        
        BluetoothManager.sharedInstance.delegate = self
        BluetoothManager.sharedInstance.readStimStatus()
        stopStimulation()
        
        
        //for default values for testing- dev
        //userStackView.tf.text = "abarker@sancsoft.com"
        //userStackView.tf.text = "nkcamachocabrera+21@gmail.com"
        //passwordStackView.tf.text = "Password0!"
        
        //dev clinic
        //userStackView.tf.text = "tclinician20"
        //passwordStackView.tf.text = "Sancsoft1234!"
        
        // MARK: Ryan patient
        //userStackView.tf.text = "rlevels+3@sancsoft.com"
        //passwordStackView.tf.text = "Abcd1234!"
        
        // MARK: Utkarsh patient
        //userStackView.tf.text = "usanadhya@avation.com"
        //passwordStackView.tf.text = "Zimetrics@123"
        
        //for staging
        //clinician
        
        //usernameMD.tF.text = "sancsoftclinician"
        //passwordMD.tF.text = "Password0!"
        
        //preprod clinic
        //userStackView.tf.text = "acbarker19+clinician@gmail.com"
        //userStackView.tf.text = "vivallyclinician@gmail.com"
        //passwordStackView.tf.text = "Password0!"
        
        //userStackView.tf.text = "lfritzsancsofttest@gmail.com"
        //passwordStackView.tf.text = "Sancsoft1234!"
        
        // Do any additional setup after loading the view.
        AccountManager.sharedInstance.comingFromEmailLogin = true // for pin masking logic
        
        userStackView.setup(title: "Email", placeholder: "Somebody@email.com")
        passwordStackView.setup(title: "Password", toggle: true)
        
        setupTextFields()
        clearFields()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ActivityManager.sharedInstance.stopActivityTimers()
        UserDefaults.standard.set(false, forKey: "loggedIn")
    }

    @IBAction func signInButtonTapped(_ sender: Any) {
        attemptLogin()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "account", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "SendAccessCodeViewController") as SendAccessCodeViewController
        vc.signup = true
        vc.title = "Access code"
        navigationController?.pushViewController(vc, animated: true)
        clearFields()
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "account", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "SendAccessCodeViewController") as SendAccessCodeViewController
        vc.signup = false
        navigationController?.pushViewController(vc, animated: true)
        clearFields()
    }
    
    func stopStimulation(){
        if BluetoothManager.sharedInstance.isConnectedToDevice(){
            let stimStatus = BluetoothManager.sharedInstance.informationServiceData.stimStatus
            if stimStatus.mainState == .screening{
                BluetoothManager.sharedInstance.stopAllStimulation()
            }
            ScreeningProcessManager.sharedInstance.resetValues()
        }
    }
    
    func clearFields(){
        userStackView.tf.text = ""
        passwordStackView.tf.text = ""
        invalidLoginLabel.text = " "
        signInButton.isEnabled = false
    }
    
    // check for user input into text fields
    func setupTextFields() {
        userStackView.tf.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                        for: .editingChanged)
        passwordStackView.tf.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                        for: .editingChanged)
    }

    func validateEmail() -> Bool{
        let emailPattern = #"^\S+@\S+\.\S+$"#
        // For now we just return true because usernames are valid as well.
        //return true
        
        if let email = userStackView.tf.text{
            if email.firstIndex(of: "@") != nil{
                let result = email.range(
                    of: emailPattern,
                    options: .regularExpression
                )
                
                return (result != nil)
            }
            return true
        }
        else{
            return false
        }
    }
    
    func removeExcessWhitespace(){
        let trimmedUsername = userStackView.tf.text!.trimmingCharacters(in: .whitespaces)
        userStackView.tf.text = trimmedUsername
    }
    
    func attemptLogin(){
        invalidLoginLabel.text = " "
        userStackView.resetErrorMessage()
        removeExcessWhitespace()
        
        if !validateEmail(){
            userStackView.setErrorMessage(message: "Invalid Email Address")
            return
        }
        showLoading()
        AccountManager.sharedInstance.login(username: userStackView.tf.text!, password: passwordStackView.tf.text!) { success, data, errorMessage in
            //self.hideLoading()
            self.invalidLoginLabel.text = " "
            if success{
                UserDefaults.standard.set(true, forKey: "loggedIn")
                RefreshManager.sharedInstance.saveLastTime()
                
                var accountData = KeychainManager.sharedInstance.accountData
                if accountData == nil{
                    accountData = AccountData()
                }
                accountData?.refreshToken = data?.authenticationResult.refreshToken ?? ""
                accountData?.token = data?.authenticationResult.accessToken ?? ""
                
                KeychainManager.sharedInstance.saveAccountData(data: accountData!)
                RefreshManager.sharedInstance.saveFirstLogin()
                RefreshManager.sharedInstance.resetRefreshChecks()
                
                AccountManager.sharedInstance.getMe { success, userModel, errorMessage in

                    if success{
                        
                        // MARK: roles not populating on fresh install
                        if ((userModel?.roles) != nil) {
                            // check that there is a role assigned to user. YES: pass to accountData, NO: return
                            guard let roles = userModel?.roles else {
                                self.hideLoading()
                                return }
                            accountData?.roles = roles
                        }
                        
                        accountData?.userModel = userModel ?? UserModel()
                        accountData?.username = userModel?.username ?? ""
                        
                        KeychainManager.sharedInstance.saveAccountData(data: accountData!)
                        
                        dump(KeychainManager.sharedInstance.accountData!.roles)
                        
                        LogManager.sharedInstance.getLogConfig(){ success2, bah, errorMessage2 in
                            if success2{
                                Slim.log(level: LogLevel.info, category: [.authentication], "fresh new login")
                                
                                let isPatient = accountData?.userModel?.roles?.contains("Patient") == true
                                let isClinician = accountData?.userModel?.roles?.contains("Clinician") == true
                                if !(isPatient || isClinician) {
                                    self.hideLoading()
                                    self.invalidLoginLabel.text = "This user is not enrolled in a study"
                                    return
                                }
                                
                                if ((accountData?.userModel?.acceptedEULA) == true) {
                                    isPatient ? self.getPatientEula(){} : self.getClinicEula(){}
                                    if isPatient {
                                        self.getPatientData()
                                        self.hideLoading()
                                        self.performSegue(withIdentifier: "GoToSetPin", sender: self)
                                        self.clearFields()
                                    }
                                    else if isClinician{
                                        self.getClinicianData()
                                        self.hideLoading()
                                        let vc = AdminMainViewController()
                                        NavigationManager.sharedInstance.setRootViewController(viewController: vc)
                                        ActivityManager.sharedInstance.resetInactivityCount()
                                    }
                                }
                                else{
                                    isPatient ? self.getPatientEula(){self.goToEula()} : self.getClinicEula(){self.goToEula()}
                                    isPatient ? self.getPatientData() : self.getClinicianData()
                                }
                            }
                            else{
                                self.hideLoading()
                                self.invalidLoginLabel.text = errorMessage2
                            }
                        }
                    }
                    else{
                        self.hideLoading()
                        self.invalidLoginLabel.text = errorMessage
                    }
                }
                
                AppManager.sharedInstance.setupManager()
             
            // some login error from the api
            }
            else {
                self.hideLoading()
                // invalid email address and password
                if errorMessage == "No user with that name exists\r" {
                    self.invalidLoginLabel.text = "No user with that name exists"
                }
                else if errorMessage == "Incorrect username or password.\r" {
                    self.invalidLoginLabel.text = "Incorrect username or password."
                }
                else {
                    self.invalidLoginLabel.text = "Invalid login credentials"
                    
                }
            }// !error
            
            // error: no internet
            if errorMessage == "Error no response" {
                self.hideLoading()
                self.invalidLoginLabel.text = "Please use a stable internet connection to continue."
            }
            
        } // !AccountManager
    }
    
    func hideErrorMessages() {
        invalidLoginLabel.text = " "
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
    
    func getClinic(){
        ScreeningManager.sharedInstance.getStudies(){ success, result, errorMessage in
            if success{
                print("got Clinic")
                if result?.filteredCount != 0 {
                    ScreeningManager.sharedInstance.hasClinic = true
                    ScreeningManager.sharedInstance.clinicList = result!.records
                }
            }
        }
    }
    
    func getPermissions(){
        AccountManager.sharedInstance.getPermissions(){ success, result, errorMessage in
            if success{
                print("got permissions")
                AccountManager.sharedInstance.clinicPermissions = result
            }
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
    
    func checkPatientStudy(){
        if BluetoothManager.sharedInstance.isConnectedToDevice(){
            BluetoothManager.sharedInstance.setMode2()
        }
    }
    
    func getPatientTherapy(){
        SessionDataManager.sharedInstance.getSessionData(){ success, data, errorMessage in
            
            if success{
                //print("success")
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
    
    func getPatientEula(completion:@escaping() -> ()){
        let group = DispatchGroup()
        group.enter()
        EulaManager.sharedInstance.getEulaPatient(){ success, data, errorMessage in
            if success{
                group.leave()
            }
            print("eula patinet")
        }
        EulaManager.sharedInstance.getPatientEulaPDF(){ success2, errorMessage2 in
            if success2{
                
            }
            print("eula pdf")
        }
        group.notify(queue: DispatchQueue.global()){
            print("finished eula calls")
            completion()
        }
    }
    
    func getClinicEula(completion:@escaping() -> ()){
        let group = DispatchGroup()
        group.enter()
        group.enter()
        EulaManager.sharedInstance.getEulaClinician(){ success, data, errorMessage in
            if success{
                group.leave()
            }
        }
        EulaManager.sharedInstance.getClinicianEulaPDF(){ success2, errorMessage2 in
            if success2{
                group.leave()
            }
            group.notify(queue: DispatchQueue.global()){
                completion()
            }
        }
    }
    
    // no text in email and password fields? Sign in button disabled
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        // email and password isEmpty
        guard
            let email = userStackView.tf.text, !email.isEmpty,
            let password = passwordStackView.tf.text, !password.isEmpty
        
        else {
            hideErrorMessages()
            self.signInButton.isEnabled = false
            return
        }
        
        // !isEmpty
        signInButton.isEnabled = true
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
    
    func getPatientData(){
        grabEval()
        getHelpTimestamps()
        checkPatientStudy()
        getPatientTherapy()
        getPatientJournalFocus()
        getPatientJournals()
        getDemographics()
        NetworkManager.sharedInstance.checkUpdate()
        NetworkManager.sharedInstance.sendTherapyOnlyData(){}
        NetworkManager.sharedInstance.sendBulkStimAndEMGData(){}
    }
    
    func getClinicianData(){
        getClinic()
        getPermissions()
        getDemographics()
        getHelpTimestamps()
        NetworkManager.sharedInstance.checkUpdate()
    }
    
    func goToEula(){
        DispatchQueue.main.async {
            self.hideLoading()
            print("Eula UI go")
            let vc = EulaViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            self.clearFields()
        }
    }
}

extension AdministratorLoginViewController: BluetoothManagerDelegate{
    func pairingTimeExpired() {}
    
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {}
    
    func didConnectToDevice(device: CBPeripheral) {
        stopStimulation()
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {}
    
    func didBLEChange(on: Bool) {}
    
    func didUpdateData() {}
    
    func didUpdateStimStatus() {
        stopStimulation()
    }
    
    func didUpdateEMG() {}
    func didUpdateBattery(){}
    func didUpdateTherapySession() {}
    
    func didBondFail() {}
    
    func didUpdateDevice() {}
    
    func foundOngoingTherapy() {}
    
    
}
