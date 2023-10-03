//
//  TherapyPrepViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/18/23.
//

import UIKit
import CoreBluetooth

class TherapyPrepViewController: BaseNavViewController {
    //@IBOutlet weak var minScrollHeight: NSLayoutConstraint!
    @IBOutlet weak var disconnectBannerView: BannerView!
    
    @IBOutlet weak var topStackWidth: NSLayoutConstraint!
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    
    @IBOutlet weak var whichFootMessage: UILabel!
    @IBOutlet weak var footSegmentContainerView: UIView!
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var roundPrepView: UIView!
    
    @IBOutlet weak var cleanStack: UIStackView!
    @IBOutlet weak var gelStack: UIStackView!
    @IBOutlet weak var garmentStack: UIStackView!
    @IBOutlet weak var controllerStack: UIStackView!
    
    @IBOutlet weak var cleanLabel: UILabel!
    @IBOutlet weak var garmentLabel: UILabel!
    
    @IBOutlet weak var garmentImageView: UIImageView!
    
    @IBOutlet weak var batteryView: StimulatorBatteryStatusView!
    
    @IBOutlet weak var cancelButton: ActionButton!
    @IBOutlet weak var continueButton: ActionButton!
    
    var footSegment = GroupedSegmentView(optionNum: 2)
    
    var leftSet = false
    
    var footcheck = false
    var imp = false
    var continuity = false
    var impFailed = 0
    var footFailed = 0
    
    var impError:TherapyImpError = .foot
    
    var connectTimer:Timer?
    var sessionTimer:Timer?
    
    var observersSet = false
    var prepTherapy = true
    
    var checksRunning = false
    
    var allowShowFootWarning = false
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.viewDidLoad()

        topStackWidth.constant = view.getWidthConstant()
        stackWidth.constant = view.getWidthConstant()
        // Do any additional setup after loading the view.
        title = prepTherapy ? "Prepare for Therapy" : "Therapy Personalization"
        whichFootMessage.text = prepTherapy ? "Which foot would you like to perform Therapy on?" : "Which foot would you like to perform Therapy Personalization on?"
        
        disconnectBannerView.setup(title: "Controller not connected", sub: "Tap here to check Controller status")
        disconnectBannerView.delegate = self
        
        roundPrepView.layer.cornerRadius = 10
        roundPrepView.layer.borderWidth = 1
        roundPrepView.layer.borderColor = UIColor.casperBlue?.cgColor
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBattery()
        setFootControl()
        
        leftSet = footSegment.selectedOption == 0
        setFootInstructions()
        
        //changedOption()
        
        if TherapyManager.sharedInstance.therapyRunning{
            footSegment.disableAll()
        }
        if TherapyManager.sharedInstance.therapyRunning {
            TherapyManager.sharedInstance.delegate = self
        }
        else{
            BluetoothManager.sharedInstance.delegate = self
        }
        
        if !observersSet{
            addObservers()
            observersSet = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent{
            dismissObservers()
        }
    }

    func setupView(){
        footSegment.translatesAutoresizingMaskIntoConstraints = false
        footSegmentContainerView.addSubview(footSegment)
        NSLayoutConstraint.activate([
            footSegment.leadingAnchor.constraint(equalTo: footSegmentContainerView.leadingAnchor),
            footSegment.centerXAnchor.constraint(equalTo: footSegmentContainerView.centerXAnchor),
            footSegment.topAnchor.constraint(equalTo: footSegmentContainerView.topAnchor),
            footSegment.centerYAnchor.constraint(equalTo: footSegmentContainerView.centerYAnchor)
        ])
        footSegment.delegate = self
        footSegment.setup(textArr: ["LEFT", "RIGHT"])
        
        cancelButton.toSecondary()
        addStackTargets()
        setupBattery()
        setFootInstructions()
    }
    
    func setFootControl(){
        if prepTherapy{
            let currentEval = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
            footSegment.enableAll()
            
            if currentEval?.left == nil || currentEval?.right == nil{
                TherapyManager.sharedInstance.clearPreferredFoot()
                leftSet = currentEval?.left != nil
                //footSegment.disableAll()
                allowShowFootWarning = true
            }
            else{
                TherapyManager.sharedInstance.loadPreferredFoot()
                leftSet = TherapyManager.sharedInstance.isLeft
                allowShowFootWarning = false
                //footSegment.enableAll()
            }
            footSegment.selectSegment(segment: leftSet ? 0 : 1)
        }
        else{
            footSegment.enableAll()
        }
    }
    
    func setFootInstructions(){
        let footTxt = leftSet ? "LEFT" : "RIGHT"
        
        cleanLabel.text = "Ensure the " + footTxt + " ankle is clean and moisten the skin if excessively dry"
        garmentLabel.text = "Place garment on the " + footTxt + " foot and ensure a snug fit"
        
        garmentImageView.transform = CGAffineTransformIdentity
        garmentImageView.transform = leftSet ? CGAffineTransformMakeScale(-1, 1) : CGAffineTransformMakeScale(1, 1)
    }
    
    func addStackTargets(){
        let cleanTap = UITapGestureRecognizer(target: self, action: #selector(didTapCleanStep))
        cleanStack.addGestureRecognizer(cleanTap)
        
        let gelTap = UITapGestureRecognizer(target: self, action: #selector(didTapGelStep))
        gelStack.addGestureRecognizer(gelTap)
        
        let garmentTap = UITapGestureRecognizer(target: self, action: #selector(didTapGarmentStep))
        garmentStack.addGestureRecognizer(garmentTap)
        
        let controllerTap = UITapGestureRecognizer(target: self, action: #selector(didTapControllerStep))
        controllerStack.addGestureRecognizer(controllerTap)
    }
    
    func setupBattery(){
        
        // device connected = yes
        if BluetoothManager.sharedInstance.isConnectedToDevice(){
            batteryView.setupBattery(battery: BluetoothManager.sharedInstance.informationServiceData.batteryStateOfCharge.level)
            
            disconnectBannerView.isHidden = true
            continueButton.isEnabled = !checksRunning
            
            // battery less than 50%? YES: continue button is disabled
            let percent = (BluetoothManager.sharedInstance.informationServiceData.batteryStateOfCharge.level)
            if !DeviceErrorManager.sharedInstance.impedanceCheckRunning {
                continueButton.isEnabled = percent > 50 ? true: false
            }
        // device connected = no
        } else {
            continueButton.isEnabled = false
            disconnectBannerView.isHidden = false
            batteryView.showDisconnect()
        }
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.statusNotify(notif:)), name: NSNotification.Name(NotificationNames.statusGo.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checksNotify(notif:)), name: NSNotification.Name(NotificationNames.checksGo.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.impNotify(notif:)), name: NSNotification.Name(NotificationNames.impNot.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.helpNotify(notif:)), name: NSNotification.Name(NotificationNames.helpGo.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.callSetupBatteryNotify(notif:)), name: NSNotification.Name(NotificationNames.callSetupBatteryNotify.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.wrongFootDismiss(notif:)), name: NSNotification.Name(NotificationNames.prepWrongFootDismissed.rawValue), object: nil)
    }
    
    @objc func wrongFootDismiss(notif:Notification){
        setFootControl()
    }
    
    @objc func statusNotify(notif:Notification){
        dismissObservers()
        let storyboard = UIStoryboard(name: "patientDevicePairing", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DeviceStatusTabletViewController") as! DeviceStatusTabletViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func checksNotify(notif:Notification){
        preImpChecks()
        
    }
    
    @objc func impNotify(notif:Notification){
        //start imp checks again
        showLoading()
        startImpedanceChecks()
    }
    
    
    @objc func helpNotify(notif:Notification){
        HelpManager.sharedInstance.playSectionVideo(vc: self, helpInfo: .garment)
    }
    
    func dismissObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.statusGo.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.checksGo.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.impNot.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.helpGo.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.callSetupBatteryNotify.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.prepWrongFootDismissed.rawValue), object: nil)
        observersSet = false
    }
    
    //MARK: Impedence
    func startImpedanceChecks(){
        checksRunning = true
        BluetoothManager.sharedInstance.sendCommand(command: .startStimImpedance, parameters: [])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            DeviceErrorManager.sharedInstance.impedanceCheckRunning = true
            BluetoothManager.sharedInstance.readDevice()
            self.connectTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checks), userInfo: nil, repeats: true)
        }
    }
    
    func preImpChecks(){
        checksRunning = true
        continueButton.isEnabled = false
        showLoading()
        leftSet ? BluetoothManager.sharedInstance.setFoot(foot: .left) : BluetoothManager.sharedInstance.setFoot(foot: .right)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            BluetoothManager.sharedInstance.readDevice()
            DeviceErrorManager.sharedInstance.checkDailyWeeklyLimits = true
            self.sessionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.SessionChecks), userInfo: nil, repeats: true)
        }
    }
    
    //TODO check if these are being checked before stimulation
    @objc func SessionChecks(){
        if DeviceErrorManager.sharedInstance.checkDailyWeeklyLimits{
            let dailyLimitReached = DeviceErrorManager.sharedInstance.dailyLimitReached
            let weeklyLimitReached = DeviceErrorManager.sharedInstance.weeklyLimitReached
            if dailyLimitReached != nil && weeklyLimitReached != nil{
                if dailyLimitReached! || weeklyLimitReached!{
                    DeviceErrorManager.sharedInstance.checkDailyWeeklyLimits = false
                }
                else{
                    DeviceErrorManager.sharedInstance.checkDailyWeeklyLimits = false
                    startImpedanceChecks()
                }
            }
        }
        else{
            if sessionTimer != nil {
                sessionTimer?.invalidate()
            }
            sessionTimer = nil
        }
        
    }
    
    @objc func checks(){
        if DeviceErrorManager.sharedInstance.impedanceCheck != nil{
            continuity = DeviceErrorManager.sharedInstance.impedanceCheckContinuity == true
            imp = DeviceErrorManager.sharedInstance.impedanceCheckImpedance == true
            footcheck = DeviceErrorManager.sharedInstance.impedanceCheckFoot == true
            
            if continuity && imp && footcheck {
                stopChecks()
                
                //go to therapy
                if prepTherapy{
                    let foot = leftSet ? Feet.left : Feet.right
                    TherapyManager.sharedInstance.savePreferredFoot(foot: foot)
                    TherapyManager.sharedInstance.testTherapy = false
                    headToTherapy()
                    return
                }
                else{
                    ScreeningProcessManager.sharedInstance.resetValues()
                    headToScreening()
                    return
                }
            }
            
            if !continuity && !imp && !footcheck {
                return
            }
        
            else{
                if !continuity{
                    Slim.log(level: LogLevel.error, category: [.therapy], "Therapy Preperation Error: Continuity")
                    impError = .continuity
                }
                else if !footcheck{
                    Slim.log(level: LogLevel.error, category: [.therapy], "Therapy Preperation Error: Foot Check")
                    impError = .foot
                }
                else if !imp{
                    Slim.log(level: LogLevel.error, category: [.therapy], "Therapy Preperation Error: Impedance")
                    impError = .impedance
                }
                
                stopChecks()
                
                self.navigationController?.navigationBar.isUserInteractionEnabled = false
                let vc = ChecksFailedPopupViewController()
                vc.isLeft = TherapyManager.sharedInstance.isLeft
                vc.checkError = impError
                vc.modalPresentationStyle = .overCurrentContext
                present(vc, animated: false)
            }
        }
    }
    
    func stopChecks(){
        checksRunning = false
        DeviceErrorManager.sharedInstance.impedanceCheckRunning = false
        hideLoading()
        if connectTimer != nil {
            connectTimer?.invalidate()
        }
        connectTimer = nil
    }
    
    @objc func callSetupBatteryNotify(notif: Notification) {
        setupBattery()
    }
    
    @IBAction func footChanged(_ sender: UISegmentedControl) {
        leftSet = sender.selectedSegmentIndex == 0
        setFootInstructions()
    }
    
    @objc func didTapCleanStep(){
        openManual(toPage: 9)
    }
    
    @objc func didTapGelStep(){
        openManual(toPage: 9)
    }
    
    @objc func didTapGarmentStep(){
        openManual(toPage: 9)
    }
    
    @objc func didTapControllerStep(){
        openManual(toPage: 10)
    }
    
    
    @IBAction func tappedCancel(_ sender: ActionButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedContinue(_ sender: ActionButton) {
        continueButton.isEnabled = false
        if TherapyManager.sharedInstance.therapyRunning{
            headToTherapy()
        }
        else{
            if !checkForBatteryPopup(){
                return
            }
            
            if DataRecoveryManager.sharedInstance.recoveryAvailable && prepTherapy{
                //show recover popup
                let vc = PrepTherapyDataRecoveryPopupViewController()
                vc.modalPresentationStyle = .overCurrentContext
                present(vc, animated: false)
            }
            else if prepTherapy{
                preImpChecks()
            }
            else{
                showLoading()
                let sch = TherapySchedules(rawValue: ScreeningProcessManager.sharedInstance.therapySchedule)
                BluetoothManager.sharedInstance.setSchedule(schedule: sch)
                BluetoothManager.sharedInstance.setTherapyLength(lengthInSeconds: Int32(ScreeningProcessManager.sharedInstance.therapyLength))
                
                leftSet ? BluetoothManager.sharedInstance.setFoot(foot: .left) : BluetoothManager.sharedInstance.setFoot(foot: .right)
                ScreeningProcessManager.sharedInstance.isLeft = leftSet
                startImpedanceChecks()
            }
        }
    }
    
    func checkForBatteryPopup() -> Bool{
        var pass = false
        let batteryState = BluetoothManager.sharedInstance.informationServiceData.batteryStateOfCharge
        pass = batteryState.minBatteryRequired()
        if !pass{
            Slim.log(level: LogLevel.info, category: [.deviceInfo], "insufficient batter charge device selected")
            let vc = InsufficientBatteryPopupViewController()
            vc.attemptTherapy = prepTherapy
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: false)
        }
        
        return pass
    }
    
    //MARK: Navigation
    func headToTherapy(){
        dismissObservers()
        let storyboard = UIStoryboard(name: "therapyNew", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TherapyViewController") as! TherapyViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func headToScreening(){
        dismissObservers()
        let storyboard = UIStoryboard(name: "screening", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ScreeningViewController") as! ScreeningViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func openManual(toPage:Int){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SubjectManualViewController") as! SubjectManualViewController
        vc.startingPage = toPage
        navigationController?.pushViewController(vc, animated: true)
    }

}
extension TherapyPrepViewController:GroupedSegmentViewDelegate{
    func changedOption() {
        if allowShowFootWarning{
            let vc = WrongFootSelectedPopupViewController()
            
            vc.currentAllowedFoot = leftSet ? Feet.left : Feet.right
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false)
        }
        else{
            leftSet = footSegment.selectedOption == 0
            setFootInstructions()
        }
    }
}

extension TherapyPrepViewController:BluetoothManagerDelegate{
    func didUpdateDevice() {}
    
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {}
    
    func didConnectToDevice(device: CBPeripheral) {
        setupBattery()
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        setupBattery()
        stopChecks()
    }
    
    func didBLEChange(on: Bool) {}
    
    func didUpdateData() {
        setupBattery()
    }
    
    func didUpdateStimStatus() {}
    
    func didUpdateEMG() {}
    func didUpdateBattery(){
        setupBattery()
    }
    func didUpdateTherapySession() {}
    
    func didBondFail() {}
    
    func foundOngoingTherapy() {}
    func pairingTimeExpired() {}
    
}

extension TherapyPrepViewController:TherapyManagerDelegate{
    func didUpdateDev() {}
    
    func therapyFinished(state: therapyFinishStates) {
        BluetoothManager.sharedInstance.delegate = self
    }
    
    func therapyPaused() {}

    func therapyResumed() {}
    
    func updateBLEData() {
        setupBattery()
    }
    
    func didConnectToBLEDevice(device: CBPeripheral) {
        setupBattery()
    }
    
    func didDisconnectFromBLEDevice(device: CBPeripheral) {
        setupBattery()
    }
    
    func pauseLimitReached() {}
    
    func didUpdateStatus() {}
    func didUpdateTherapyBattery(){
        setupBattery()
    }
    func pauseAboutToExpire() {}
    func pauseExpired() {}
}

extension TherapyPrepViewController: BannerViewDelegate{
    func tappedBanner(bannerType: BannerView) {
        if bannerType == disconnectBannerView {
            let storyboard = UIStoryboard(name: "patientDevicePairing", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "DeviceStatusTabletViewController") as! DeviceStatusTabletViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
