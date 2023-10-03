//
//  BaseNavViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 4/23/21.
//

import UIKit
//import ContextMenu

protocol BackPromptDelegate {
    func goBackSelected()
}

class BaseNavViewController: UIViewController {
    
    var removeOnInactivity = false
    
    var logoButton = UIBarButtonItem()
    var accountButton = UIBarButtonItem()
    var stimButton = UIBarButtonItem()
    var shouldClearNavbar = false
    var popToRoot = false
    
    let logoImage = UIImage(named: "navLogo")?.withRenderingMode(.alwaysOriginal)
    let homeImage = UIImage(named: "ic_home_off")?.withRenderingMode(.alwaysTemplate)
    let accountImage = UIImage(named: "ic_account")?.withRenderingMode(.alwaysTemplate)
    let systemManualImage = UIImage(named: "menu_manual")?.withRenderingMode(.alwaysTemplate)
    let helpImage = UIImage(systemName: "play.circle")?.withRenderingMode(.alwaysTemplate)
    let privacyImage = UIImage(named: "menu_privacy")?.withRenderingMode(.alwaysTemplate)
    let contactImage = UIImage(named: "contact")?.withRenderingMode(.alwaysTemplate)
    let settingsImage = UIImage(systemName: "gearshape")?.withRenderingMode(.alwaysTemplate)
    let changePasswordImage = UIImage(named: "change_password")?.withRenderingMode(.alwaysTemplate)
    let changePinImage = UIImage(named: "change_pin")?.withRenderingMode(.alwaysTemplate)
    let logoutImage = UIImage(named: "sign_out")?.withRenderingMode(.alwaysTemplate)
    
    var goBackEnabled = false
    var goBackPrompt = false
    var showLogo = true
    
    var statusPage = false
    var clearRightBarItems = false
    var showOnlyRightLogo = false
    
    var navEnabled = true
    
    var delegate:BackPromptDelegate? = nil
    
    var showBleToast = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let mainVC = revealViewController(){
            mainVC.allowBleToast = showBleToast
        }
        
        if self.navigationController != nil {
            NavigationManager.sharedInstance.currentNav = self.navigationController!
        }
        
        ScreeningProcessManager.sharedInstance.navDelegate = self
        TherapyManager.sharedInstance.navDelegate = self
        BluetoothManager.sharedInstance.navDelegate = self
        BluetoothManager.sharedInstance.errorDelegate = self
        
        
        setupNavView()
        
        let backImage = UIImage(named: "back_button")?.withRenderingMode(.alwaysTemplate)
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(didTapBack(sender:)))
        backButton.tintColor = UIColor.regalBlue
        
        logoButton = UIBarButtonItem(image: logoImage, style: .plain, target: self, action: #selector(didTapLogo(sender:)))
        logoButton.tintColor = UIColor.regalBlue
        logoButton.isEnabled = false

        
        if goBackEnabled{
            navigationItem.leftBarButtonItem = backButton
        }
        
        if shouldClearNavbar{
            clearNavBarItems()
        }
        
        if showOnlyRightLogo{
            navigationItem.rightBarButtonItems = []
            navigationItem.rightBarButtonItem = logoButton
        }
    }
    
    //have activity manager run in correct view controller
    override func viewDidAppear(_ animated: Bool) {
        ActivityManager.sharedInstance.delegate = self
        OTAManager.sharedInstance.updateAvailableDelegate = self
        RefreshManager.sharedInstance.delegate = self
        DeviceErrorManager.sharedInstance.navDelegate = self
        BluetoothManager.sharedInstance.errorDelegate = self
        
        setupNavView()
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    func setupNavView() {
        let accountImage = UIImage(named: "navProfile")?.withRenderingMode(.alwaysOriginal)
        var stimImage = UIImage(named: "navStimulator")?.withRenderingMode(.alwaysOriginal)
        
        if TherapyManager.sharedInstance.therapyRunning || ScreeningProcessManager.sharedInstance.screeningRunning {
            stimImage = UIImage(named: "navPlay")?.withRenderingMode(.alwaysOriginal)
        }
        else{
            if BluetoothManager.sharedInstance.bleON {
                if BluetoothManager.sharedInstance.isConnectedToDevice() {
                    if OTAManager.sharedInstance.updateAvailable || DataRecoveryManager.sharedInstance.recoveryAvailable{
                        stimImage = getUpdateImage()
                    }
                    else{
                        stimImage = UIImage(named: "navStimulator")?.withRenderingMode(.alwaysOriginal)
                    }
                }
                else{
                    if BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired() && !OTAManager.sharedInstance.OTAMode{
                        stimImage = UIImage(named: "navPairedOnly")?.withRenderingMode(.alwaysOriginal)
                    }
                    else{
                        stimImage = UIImage(named: "navBluetooth")?.withRenderingMode(.alwaysOriginal)
                    }
                }
            }
            else{
                stimImage = UIImage(named: "navNoBluetooth")?.withRenderingMode(.alwaysOriginal)
            }
        }

        accountButton = UIBarButtonItem(image: accountImage,  style: .plain, target: self, action: #selector(didTapAccountButton(sender:)))
        stimButton = UIBarButtonItem(image: stimImage,  style: .plain, target: self, action: #selector(didTapStimulator(sender:)))
        
        accountButton.tintColor = UIColor.regalBlue
        stimButton.tintColor = UIColor.regalBlue
        
        //new way
        //note that test therapy hides all nav items so need to deal with that use case
        if let accountData = KeychainManager.sharedInstance.loadAccountData(){
            if accountData.roles.contains("Clinician") {
                navigationItem.rightBarButtonItems = [stimButton, accountButton]
            }
            else if accountData.roles.contains("Patient") && accountData.pinValue != ""{
                let eval = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
                if eval?.left != nil || eval?.right != nil {
                    navigationItem.rightBarButtonItems = [stimButton, accountButton]
                }
                else{
                    navigationItem.rightBarButtonItems = [accountButton]
                }
            }
            //not signed in
            else {
                navigationItem.rightBarButtonItems = [accountButton]
            }
            
            if statusPage {
                navigationItem.rightBarButtonItems = [logoButton]
            }
            if showOnlyRightLogo {
                navigationItem.rightBarButtonItems = [logoButton]
            }
            
            if clearRightBarItems || shouldClearNavbar {
                navigationItem.rightBarButtonItems = []
            }else if showOnlyRightLogo{
                navigationItem.rightBarButtonItems = []
                navigationItem.rightBarButtonItem = logoButton
            }
        }
    }
    
    func getUpdateImage() -> UIImage{
        let bottomImage = UIImage(named: "navStimulator")?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        let topImage = UIImage(named: "nav_circle")!    //need to look into how to make it blue again
        
        let width = bottomImage.size.width
        let size = CGSize(width: width, height: bottomImage.size.height)
        
        UIGraphicsBeginImageContext(size)
        
        let areaSize = CGRect(x: 0, y: 0, width: bottomImage.size.width, height: size.height)
        bottomImage.draw(in: areaSize)
        
        let circleSize = CGRect(x: areaSize.midX, y: 0, width: size.height / 3, height: size.height / 3)
        topImage.draw(in: circleSize)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let noTintImage = newImage.withRenderingMode(.alwaysOriginal)
        return noTintImage
    }
    
    func clearNavBarItems(){
        navigationItem.rightBarButtonItems = []
        navigationItem.leftBarButtonItems = []
        shouldClearNavbar = true
    }
    
    var accountPopup = AccountView()
    func setupAccount(){
        if KeychainManager.sharedInstance.accountData!.roles.contains("Patient") || KeychainManager.sharedInstance.accountData!.roles.contains("Clinician"){
            accountPopup.tableList = [.name, .system, .help, .privacy, .contactAbout, .settings, .changePassword]
            if KeychainManager.sharedInstance.accountData!.roles.contains("Patient"){
                accountPopup.tableList.append(.changePIN)
            }
            accountPopup.tableList.append(.signOut)
        }
        else{
            accountPopup.tableList = [.contactAbout]
        }
        
        accountPopup.tableView.reloadData()
    }
    
    func attemptShowAccount(){
        accountPopup.popupTable(view: self.view)
    }
    
    func signoutRedirect(){
        if !self.isKind(of: AdministratorLoginViewController.self){
            
            let appData = AppManager.sharedInstance.loadAppDeviceData()
            let appId = appData!.appIdentifier
            NotificationManager.sharedInstance.postPushNotificationUnRegister(appId: appId) { success, errorMessage in
                
            }
            
            let initialViewController = NonSignedInMainViewController()
            NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
            NetworkManager.sharedInstance.logoutClear()
        }
    }
    
    @objc func didTapAccountButton(sender: AnyObject){
        let newVC = MenuFullViewController()
        
        if KeychainManager.sharedInstance.accountData!.roles.contains("Patient"){
            newVC.accountType = .patient
            self.navigationController?.pushViewController(newVC, animated: false)
        }
        else if KeychainManager.sharedInstance.accountData!.roles.contains("Clinician"){
            newVC.accountType = .clinician
            self.navigationController?.pushViewController(newVC, animated: false)
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }

    @objc func didTapStimulator(sender: AnyObject){
        if !statusPage {
            let storyboard = UIStoryboard(name: "patientDevicePairing", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "DeviceStatusTabletViewController") as! DeviceStatusTabletViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        print("did tap stimulator button")
        
    }
    
    @objc func didTapLogo(sender: AnyObject){
        
    }
    
    @objc func didTapBack(sender: AnyObject){
        if goBackPrompt {
            delegate?.goBackSelected()
        }
        else{
            if popToRoot {
                self.navigationController?.popToRootViewController(animated: true)
                
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}


extension BaseNavViewController: TherapyManagerConnectionDelegate{
    func therapyInProgress(running: Bool) {
        setupNavView()
    }
}

extension BaseNavViewController: BluetoothManagerNavDelegate{
    func bleChange(on: Bool) {
        setupNavView()
    }
    
    func deviceConnection(connection: Bool) {
        setupNavView()
    }
}

extension BaseNavViewController: ScreeningProcessManagerConnectionDelegate{
    func screeningInProgress(running: Bool) {
        setupNavView()
    }
}

extension BaseNavViewController: BluetoothManagerErrorDelegate{
    func deviceError() {
    }
    
}

extension BaseNavViewController: ActivityManagerDelegate{
    func maxInactivityReached() {
        ActivityManager.sharedInstance.loggedOut()
        
        let accountData = KeychainManager.sharedInstance.loadAccountData()
        if KeychainManager.sharedInstance.accountData!.roles.contains("Clinician") {
           signoutRedirect()
        }
        else if KeychainManager.sharedInstance.accountData!.roles.contains("Patient") {
            //go to PIN page
            ActivityManager.sharedInstance.lockout = true
            
            navigationController?.viewControllers.removeAll(where: { (vc) -> Bool in
                if vc.isKind(of: BaseNavViewController.self){
                    if (vc as! BaseNavViewController?)!.removeOnInactivity{
                        return true
                    }
                }
                return false
            })
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PinLoginViewController") as! PinLoginViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func inactivityReached() {
        //check for topmost viewcontroller
        if let top = navigationController?.topViewController{
            if !(top.isKind(of: LockViewController.self)){
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "LockViewController") as! LockViewController
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension BaseNavViewController: OTAUpdateAvailableDelegate{
    func updateAvailable(available: Bool) {
        setupNavView()
    }
}

extension BaseNavViewController: RefreshManagerDelegate{
    func refreshFailed() {
        //TODO: add popup to tell user of signout,
        //for now just signout and redirect user
        signoutRedirect()
    }
}

extension BaseNavViewController: DeviceErrorManagerNavDelegate{
    func dataRecoveryAvailable() {
        setupNavView()
    }
}
