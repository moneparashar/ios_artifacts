//
//  EulaViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 5/18/21.
//

import UIKit

class EulaViewController: BaseNavViewController {
    
    var textView = UITextView()
    
    var overallBottomStack = UIStackView() //with paddings
    var vertBottomStack = UIStackView()
    
    var privacyStack = UIStackView()
    var consentStack = UIStackView()
    var bottomButtonStack = UIStackView()
    
    var privacyPolicyLabel = UILabel()
    var privacyPolicyToggle = UISwitch()
    
    var consentLabel = UILabel()
    var consentToggle = UISwitch()
    
    var declineButton = ActionButton()
    var acceptButton = ActionButton()
    let leftPadding = UIView()
    let rightPadding = UIView()
    
    var loggedIn = true
    var username = ""
    var pw = ""
    
    var reachedBottom = false
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.clearRightBarItems = true
        super.viewDidLoad()
        title = "Terms of Use & Privacy Policy"
       
        configure()
        
        overallBottomStack.arrangedSubviews[0].isHidden = UIDevice.current.userInterfaceIdiom == .phone
        overallBottomStack.arrangedSubviews[2].isHidden = UIDevice.current.userInterfaceIdiom == .phone
        
        privacyPolicyToggle.isEnabled = false
        consentToggle.isEnabled = false
        
        textView.delegate = self
        
        acceptButton.isEnabled = false
    }
    
    func configure(){
        view.backgroundColor = UIColor.white
        EulaManager.sharedInstance.loadEula()
        if let eulaHtml = EulaManager.sharedInstance.eulaHtml?.html{
            let parsed = eulaHtml.replacingOccurrences(of: "\n", with: "")
            
            textView.attributedText = parsed.htmlToAttributedString
            textView.textColor = UIColor.fontBlue
            textView.isEditable = false
            textView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(textView)
            
            privacyPolicyLabel.text = "Accept Terms of use and Privacy policy"
            privacyPolicyLabel.numberOfLines = 0
            privacyPolicyLabel.textAlignment = .right
            privacyPolicyLabel.font = UIFont.bodyMed
            privacyPolicyLabel.textColor = UIColor.navy
            
            privacyPolicyToggle.isOn = false
            
            privacyStack = UIStackView(arrangedSubviews: [privacyPolicyLabel, privacyPolicyToggle])
            privacyStack.spacing = 10
            privacyStack.arrangedSubviews[1].setContentHuggingPriority(.required, for: .horizontal)
            
            consentLabel.text = "Accept Informed consent"
            consentLabel.numberOfLines = 0
            consentLabel.textAlignment = .right
            consentLabel.font = UIFont.bodyMed
            consentLabel.textColor = UIColor.navy
            
            consentToggle.isOn = false
            
            consentStack = UIStackView(arrangedSubviews: [consentLabel, consentToggle])
            consentStack.spacing = 10
            consentStack.arrangedSubviews[1].setContentHuggingPriority(.required, for: .horizontal)
            
            
            declineButton.toSecondary()
            acceptButton.setTitle("Accept", for: .normal)
            declineButton.setTitle("Decline", for: .normal)
            
            bottomButtonStack = UIStackView(arrangedSubviews: [declineButton, acceptButton])
            bottomButtonStack.spacing = 24
            bottomButtonStack.distribution = .fillEqually
            
            // Clinician?
            // YES: don't show toggles
            if (KeychainManager.sharedInstance.accountData!.roles.contains("Clinician")) {
                vertBottomStack = UIStackView(arrangedSubviews: [bottomButtonStack])
            // NO: show toggles
            } else {
                vertBottomStack = UIStackView(arrangedSubviews: [privacyStack, consentStack, bottomButtonStack])
            }
            vertBottomStack.axis = .vertical
            vertBottomStack.spacing = 10
            vertBottomStack.distribution = .equalSpacing
            
            
            overallBottomStack = UIStackView(arrangedSubviews: [leftPadding, vertBottomStack, rightPadding])
            
            overallBottomStack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(overallBottomStack)
            
            let width = view.getWidthConstant()
            let contentWidthConstraint = textView.widthAnchor.constraint(equalToConstant: width)
            contentWidthConstraint.priority = UILayoutPriority(999)
            let safe = view.safeAreaLayoutGuide
            
            overallBottomStack.arrangedSubviews[0].setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
            overallBottomStack.arrangedSubviews[2].setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
            overallBottomStack.arrangedSubviews[0].setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
            overallBottomStack.arrangedSubviews[2].setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
            overallBottomStack.arrangedSubviews[0].setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
            overallBottomStack.arrangedSubviews[2].setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
            
            overallBottomStack.arrangedSubviews[1].setContentHuggingPriority(.required, for: .vertical)
            
            overallBottomStack.setContentHuggingPriority(.required, for: .vertical)
            
            
            
            NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(greaterThanOrEqualTo: safe.leadingAnchor),
                textView.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
                textView.topAnchor.constraint(equalTo: safe.topAnchor),
                textView.bottomAnchor.constraint(equalTo: overallBottomStack.topAnchor, constant: -12),
                contentWidthConstraint,
                
                overallBottomStack.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
                overallBottomStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                //bottomButtonStack.widthAnchor.constraint(equalTo: textView.widthAnchor),
                overallBottomStack.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -24),
                
                
                
                overallBottomStack.arrangedSubviews[0].widthAnchor.constraint(equalTo: overallBottomStack.arrangedSubviews[2].widthAnchor)
            ])
            /*
            bottomButtonStack = UIStackView(arrangedSubviews: [leftPadding, declineButton, acceptButton, rightPadding])
            bottomButtonStack.spacing = 24
            bottomButtonStack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomButtonStack)
            
            let width = view.getWidthConstant()
            let contentWidthConstraint = textView.widthAnchor.constraint(equalToConstant: width)
            contentWidthConstraint.priority = UILayoutPriority(999)
            let safe = view.safeAreaLayoutGuide
            
            bottomButtonStack.arrangedSubviews[0].setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
            bottomButtonStack.arrangedSubviews[3].setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
            bottomButtonStack.arrangedSubviews[1].setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
            bottomButtonStack.arrangedSubviews[1].setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
            bottomButtonStack.arrangedSubviews[1].setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
            bottomButtonStack.arrangedSubviews[2].setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
            bottomButtonStack.arrangedSubviews[2].setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
            NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(greaterThanOrEqualTo: safe.leadingAnchor),
                textView.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
                textView.topAnchor.constraint(equalTo: safe.topAnchor),
                textView.bottomAnchor.constraint(equalTo: bottomButtonStack.topAnchor, constant: -12),
                contentWidthConstraint,
                
                bottomButtonStack.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
                bottomButtonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                //bottomButtonStack.widthAnchor.constraint(equalTo: textView.widthAnchor),
                bottomButtonStack.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -24),
                
                bottomButtonStack.arrangedSubviews[1].widthAnchor.constraint(greaterThanOrEqualToConstant: 144),
                bottomButtonStack.arrangedSubviews[1].widthAnchor.constraint(equalTo: bottomButtonStack.arrangedSubviews[2].widthAnchor),
                bottomButtonStack.arrangedSubviews[0].widthAnchor.constraint(equalTo: bottomButtonStack.arrangedSubviews[3].widthAnchor)
            ])
            */
            
            acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchDown)
            declineButton.addTarget(self, action: #selector(declineButtonTapped), for: .touchDown)
            
            privacyPolicyToggle.addTarget(self, action: #selector(toggleTapped), for: .valueChanged)
            consentToggle.addTarget(self, action: #selector(toggleTapped), for: .valueChanged)
        }
    }
    
    @objc func toggleTapped(_ sender: Any){
        checkAcceptEnabling()
    }
    
    @objc func declineButtonTapped(_ sender: Any) {
        let vc = EulaDeclinedConfirmPopupViewController()
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    @objc func acceptButtonTapped(_ sender: Any) {
        acceptButton.isEnabled = false
        acceptTapped()
    }
    
    func checkAcceptEnabling(){
        // Clinician?
        // YES: accept enabled when they completely scroll down
        if (KeychainManager.sharedInstance.accountData!.roles.contains("Clinician")) {
            acceptButton.isEnabled = true
        } else {
            acceptButton.isEnabled = consentToggle.isOn && privacyPolicyToggle.isOn
        }
    }
    
    func acceptTapped(){
        privacyPolicyToggle.isOn = true
        consentToggle.isOn = true
        
        
        if loggedIn{
            AccountManager.sharedInstance.acceptedEula(){ success, didSend, errorMessage in
                if success{
                    var accountData = KeychainManager.sharedInstance.accountData
                    if accountData == nil{
                        accountData = AccountData()
                    }
                    accountData?.acceptedEULA = true
                    KeychainManager.sharedInstance.saveAccountData(data: accountData!)
                    
                    if (KeychainManager.sharedInstance.accountData!.roles.contains("Patient")) || (KeychainManager.sharedInstance.accountData!.roles.contains("Admin")){
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainVc = storyboard.instantiateViewController(identifier: "AdministratorLoginViewController")
                        
                        let storyboard2 = UIStoryboard(name: "account", bundle: nil)
                        let pinVC = storyboard2.instantiateViewController(withIdentifier: "SetPinViewController")
                        
                        self.navigationController?.setViewControllers([mainVc, pinVC], animated: true)
                        
                    }
                    else if (KeychainManager.sharedInstance.accountData!.roles.contains("Clinician")){
                        let vc = AdminMainViewController()
                        NavigationManager.sharedInstance.setRootViewController(viewController: vc)
                        ActivityManager.sharedInstance.resetInactivityCount()
                    }
                }
            }
        }
        //in case wish to display eula after setting password in sign up page
        else{
            //need to login in first then accept eula
            //add grab evals & all that
            AccountManager.sharedInstance.login(username: self.username, password: self.pw){ success, data, errorMessage in
                if success{
                    var accountData = KeychainManager.sharedInstance.accountData
                    if accountData == nil{
                        accountData = AccountData()
                    }
                    accountData?.refreshToken = data?.authenticationResult.refreshToken ?? ""
                    accountData?.token = data?.authenticationResult.accessToken ?? ""
                    
                    KeychainManager.sharedInstance.saveAccountData(data: accountData!)
                    
                    AccountManager.sharedInstance.getMe{ success, userModel, errorMessage in
                        if success{
                            accountData?.userModel = userModel ?? UserModel()
                            accountData?.username = userModel?.username ?? ""
                            KeychainManager.sharedInstance.saveAccountData(data: accountData!)
                            
                            //attempt to fix eula thing
                            AccountManager.sharedInstance.acceptedEula(){ success, didSend, errorMessage in
                                if success{
                                    print("success with passing eula")
                                }
                                else{
                                    print("error with eula api call")
                                }
                            }
                            
                            if (KeychainManager.sharedInstance.accountData!.roles.contains("Patient")) || (KeychainManager.sharedInstance.accountData!.roles.contains("Admin")){
                                self.grabEval()
                                self.getPatientTherapy()
                                self.getPatientJournals()
                                NetworkManager.sharedInstance.checkUpdate()
                                
                                let vc = PatientMainViewController()
                                NavigationManager.sharedInstance.setRootViewController(viewController: vc)
                            }
                            else if (KeychainManager.sharedInstance.accountData!.roles.contains("Clinician")){
                                self.getClinic()
                                NetworkManager.sharedInstance.checkUpdate()
                                
                                let vc = AdminMainViewController()
                                NavigationManager.sharedInstance.setRootViewController(viewController: vc)
                            }
                        }
                    }
                    
                    //app manager setup
                    AppManager.sharedInstance.setupManager()
                }
            }
        }
        
    }

    func grabEval(){
        EvaluationCriteriaManager.sharedInstance.getEvalCriteriaPatient(){ success, data, errorMessage in
            if success{
                print("succesful pull of eval crit for patient")
                EvaluationCriteriaManager.sharedInstance.saveEvalConfigData(data: data!)
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
}

extension EulaViewController: UITextViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !reachedBottom{
            if scrollView.contentOffset.y + scrollView.bounds.height >= scrollView.contentSize.height{
                checkAcceptEnabling()
                reachedBottom = true
                UIView.animate(withDuration: 0.3){
                    self.privacyPolicyToggle.isEnabled = true
                    self.consentToggle.isEnabled = true
                    //self.overallBottomStack.isHidden = false
                }
            }
        }
    }
}
