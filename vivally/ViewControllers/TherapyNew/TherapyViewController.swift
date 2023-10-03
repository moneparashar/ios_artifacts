//
//  TherapyViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/17/23.
//

import UIKit
import Lottie
import CoreBluetooth

enum TherapyRunViewStates{
    case notStarted
    case running
    case paused
}

enum TherapyNav{
    case disconnect
    case therapyComplete
    case stopTherapy
    case allPausesUsed
    case therapySaveFail
    case dailyLimitReached
    case pauseAboutExpire
    case pauseExpired
    case dataRecoveryAvailable
}

class TherapyViewController: BaseNavViewController {

    @IBOutlet weak var TherapyStateTitle: UILabel!
    @IBOutlet weak var therapyTimeRemainingLabel: UILabel!
    @IBOutlet weak var pauseTimeRemainingLabel: UILabel!
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    
    @IBOutlet weak var currentTickLabel: UILabel!
    @IBOutlet weak var startButton: ActionButton!
    @IBOutlet weak var pauseButton: ActionButton!
    
    @IBOutlet weak var pauseStopButton: ActionButton!
    
    var allAnimationViews:[AnimationView] = []
    let backAV = AnimationView()
    let gaugeAV = AnimationView()
    let squiggleAV = AnimationView()
    
    
    var lastProgress = 0
    var therapyState: TherapyRunViewStates = .notStarted
    
    var observerTherapyStartSet = false
    var userDefaultFoot: Feet = .left
    var addAsyncCheck = false
    var foot = ""
    
    override func viewDidLoad() {
        super.goBackPrompt = true
        super.goBackEnabled = true
        
        super.viewDidLoad()
        super.delegate = self
        
        setupLottie()
        pauseButton.toSecondary()
        pauseStopButton.toSecondary()
        checkDev()

        self.title = TherapyManager.sharedInstance.testTherapy ? "Test Therapy" : "Therapy"
        
        let stimState = BluetoothManager.sharedInstance.informationServiceData.stimStatus.state
        
        if stimState == .running{
            let stim = BluetoothManager.sharedInstance.informationServiceData.stimStatus
            
            // check intensity max/min, fade buttons
            if stim.currentTick == 11 {
                fadeAddButton()
                
            } else if stim.currentTick == 1 {
                fadeMinusButton()
            }
            
            TherapyManager.sharedInstance.loadPauseState()
            Device.sharedInstance.loadErrorValue()
            
            // check if pause is reached, YES: fade pause button
            let pauseState = TherapyManager.sharedInstance.pauseLimitReached
            if pauseState {
                fadePauseButton()
            }
            
            therapyState = .running
            updateTime()
            TherapyManager.sharedInstance.loadPreferredFoot()
        }
        else{
            TherapyManager.sharedInstance.checkBattery()
            disableAddMinus()
            if stimState == .paused{
                therapyState = .paused
            }
        }
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /* TODO: find out if user should be taken to therapy finished screen after completing test therapy
        if TherapyManager.sharedInstance.testTherapyFinished{
            handleNav(nav: .therapyComplete)
            return
        }
         */
        
        BluetoothManager.sharedInstance.delegate = TherapyManager.sharedInstance
        TherapyManager.sharedInstance.delegate = self
        TherapyManager.sharedInstance.errorDelegate = self
        
        if !observerTherapyStartSet && !TherapyManager.sharedInstance.therapyRunning{
            addTherapyStartObservers()
            if BluetoothManager.sharedInstance.isConnectedToDevice(){
                BluetoothManager.sharedInstance.readStimStatus()
            }
        }
        
        checkState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent{
            removeTherapyStartObserver()
        }
    }
    
    func addTherapyStartObservers(){
        if !observerTherapyStartSet{
            NotificationCenter.default.addObserver(self, selector: #selector(self.impNotify(notif:)), name: NSNotification.Name(NotificationNames.impNot.rawValue), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.helpNotify(notif:)), name: NSNotification.Name("GoToHelpNotification"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.statusNotify(notif:)), name: NSNotification.Name(NotificationNames.statusGo.rawValue), object: nil)
            observerTherapyStartSet = true
        }
    }
    @objc func statusNotify(notif:Notification){
        let storyboard = UIStoryboard(name: "patientDevicePairing", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DeviceStatusTabletViewController") as! DeviceStatusTabletViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func removeTherapyStartObserver(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.impNot.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("GoToHelpNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.statusGo.rawValue), object: nil)
        observerTherapyStartSet = false
    }
    
    @objc func helpNotify(notif:Notification){
        print("therapy help Notify called")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
        vc.preRollSection = .garment
        NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: false)
    }
    
    @objc func impNotify(notif:Notification){
        if !TherapyManager.sharedInstance.therapyRunning{
            startTapped(startButton)
        }
    }
    
    func setupLottie(){
        backAV.animation = Animation.named(AnimationLottieNames.therapyBackground.rawValue)
        squiggleAV.animation = Animation.named(AnimationLottieNames.therapySwirl.rawValue)
        gaugeAV.animation = Animation.named(AnimationLottieNames.therapyFillActive.rawValue)
        
        //squiggle needs its own logic
        allAnimationViews = [squiggleAV, backAV, gaugeAV]
        for av in allAnimationViews{
            av.contentMode = .scaleAspectFit
            av.backgroundBehavior = .pauseAndRestore
            av.translatesAutoresizingMaskIntoConstraints = false
            lottieView.addSubview(av)
        }
        squiggleAV.loopMode = .loop
        
        for av in allAnimationViews{
            if av == squiggleAV{
                NSLayoutConstraint.activate([
                    squiggleAV.centerXAnchor.constraint(equalTo: gaugeAV.centerXAnchor),
                    squiggleAV.widthAnchor.constraint(equalTo: lottieView.widthAnchor, multiplier: 209/351),
                    //squiggleAnimationView.widthAnchor.constraint(equalTo: lottieView.widthAnchor, multiplier: 209/360),
                    //squiggleAnimationView.heightAnchor.constraint(equalTo: lottieView.heightAnchor, multiplier: 230/360),
                    squiggleAV.centerYAnchor.constraint(equalTo: gaugeAV.centerYAnchor),
                    squiggleAV.heightAnchor.constraint(equalTo: squiggleAV.widthAnchor)
                ])
            }
            else{
                NSLayoutConstraint.activate([
                    av.centerXAnchor.constraint(equalTo: lottieView.centerXAnchor),
                    av.centerYAnchor.constraint(equalTo: lottieView.centerYAnchor),
                    av.topAnchor.constraint(greaterThanOrEqualTo: lottieView.topAnchor),
                    av.leadingAnchor.constraint(greaterThanOrEqualTo: lottieView.leadingAnchor)
                ])
            }
        }
    }

    
    func checkState(){
        let oldTherapyState = therapyState
        if !BluetoothManager.sharedInstance.isConnectedToDevice(){
            therapyState = .notStarted
            disableAddMinus()
        }
        else{
            switch BluetoothManager.sharedInstance.informationServiceData.stimStatus.state{
            case .idle:
                setupNavView()
                therapyState = .notStarted
                disableAddMinus()
                break
                
            case .running:
                therapyState = .running
                enableAddMinus()
                break
                
            case .paused:
                therapyState = .paused
                disableAddMinus()
                break
                
            case .competed, .stopped:
                therapyState = .notStarted
                unfadePauseButton()
                disableAddMinus()
                setupNavView()
                break
            }
        }
        if oldTherapyState != therapyState{
            setupView()
            if oldTherapyState == .notStarted && TherapyManager.sharedInstance.therapyRunning{
                removeTherapyStartObserver()
            }
            else if !observerTherapyStartSet && !TherapyManager.sharedInstance.therapyRunning{
                addTherapyStartObservers()
            }
        }
    }
    
    func setupView(){
        switch therapyState{
        case .notStarted:
            
            userDefaultFoot = TherapyManager.sharedInstance.isLeft ? .left : .right
            if userDefaultFoot == .left {
                foot = "LEFT"
                
            } else {
              foot = "RIGHT"
            }

            TherapyStateTitle.text = TherapyManager.sharedInstance.testTherapy ? "Start test therapy on \(foot) foot" : "Start therapy on \(foot) foot"
            therapyTimeRemainingLabel.text = " "
            pauseTimeRemainingLabel.text = " "
            setTherapyButtons(startTherapy: true)
            squiggleAV.stop()
            squiggleAV.isHidden = true
            gaugeAV.isHidden = true
            
        case .running:
            TherapyStateTitle.text = "Therapy in progress. You may tap the “+” or “-” \n buttons to adjust Therapy intensity"
            therapyTimeRemainingLabel.textColor = UIColor.androidGreen
            pauseTimeRemainingLabel.text = " "
            setTherapyButtons(pause: true, stop: true)
            squiggleAV.isHidden = false
            setGaugeColor(showColor: true)
            squiggleAV.play()
            gaugeAV.isHidden = false
            
        case .paused:
            squiggleAV.isHidden = true
            squiggleAV.pause()
            gaugeAV.isHidden = true
            TherapyStateTitle.text = "Therapy paused"
            setGaugeColor(showColor: false  )
            therapyTimeRemainingLabel.textColor = UIColor.fontBlue
            setTherapyButtons(stopPause: true, resume: true)
        }
    }
    
    func updateTime(){
        let stim = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        if stim.mainState == .therapy && (stim.state == .running || stim.state == .paused){
            let timeLeft = timeRemainingConvert(time: stim.timeRemaining)
            therapyTimeRemainingLabel.text = timeLeft + " min remaining"
            
            if therapyState == .paused{
                let ptext = timeRemainingConvert(time: stim.pauseTimeRemaining)
                pauseTimeRemainingLabel.text = ptext + " min pause remaining"
            }
        }
    }
    
    func timeRemainingConvert(time: Int16) -> String{
        let min = Int(time / 60)
        let minText = String(min)
        let sec = time % 60
        let secText = String(format: "%02d", sec)
        return minText + ":" + secText
    }
    
    func setTherapyButtons(startTherapy: Bool = false, pause: Bool = false, stop: Bool = false, stopPause: Bool = false, resume: Bool = false){
        buttonStackView.arrangedSubviews[0].isHidden = !startTherapy
        buttonStackView.arrangedSubviews[1].isHidden = !pause
        buttonStackView.arrangedSubviews[4].isHidden = !stop
        buttonStackView.arrangedSubviews[3].isHidden = !resume
        buttonStackView.arrangedSubviews[2].isHidden = !stopPause
    }
    
    //MARK: Lottie
    var displayTick = 0
    var devTick = 0
    var updatingDisplay = false
    
    func checkDev(){
        devTick = Int(BluetoothManager.sharedInstance.informationServiceData.deviceData.currentStrengthTick)
        if displayTick != devTick && !updatingDisplay{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                self.updateTick()
            }
        }
    }
    
    func updateTick(){
        updatingDisplay = true
        
        let newFrameToReach = devTick > 1 ? Float((devTick - 1) * 11) : Float(devTick)
        let lastFrame = displayTick > 1 ? Float((displayTick - 1) * 11) : Float(displayTick)
        
        var progressTime:Float = 0
        let duration:Float = 3
        
        while progressTime <= duration{
            var gaugeFrame = Float(0)
            
            if newFrameToReach > lastFrame{
                 let gaugeProgress = AnimationManager.sharedInstance.easeInOut(val: progressTime/duration)
                gaugeFrame = AnimationManager.sharedInstance.lerp(startValue: lastFrame, endValue: newFrameToReach, progress: gaugeProgress)
            }
            else{
                let gaugeProgress = AnimationManager.sharedInstance.easeInOutNeg(val: progressTime/duration)
                gaugeFrame = AnimationManager.sharedInstance.lerp(startValue: newFrameToReach, endValue: lastFrame, progress: gaugeProgress)
            }
            gaugeAV.currentFrame = CGFloat(gaugeFrame)
            progressTime += 0.01       //.001
        }
        
        displayTick = newFrameToReach > 1 ? Int(newFrameToReach / 11) + 1 : Int(newFrameToReach)
        updatingDisplay = false
        currentTickLabel.text = String(devTick)
    }
    
    func setGaugeColor(showColor: Bool){
        if let emgFillColor = showColor ? UIColor.darkGreen?.lottieColorValue : UIColor.casperBlue?.lottieColorValue{
            let fillColorValueProvider = ColorValueProvider(emgFillColor)
            let trackFillKey = AnimationKeypath(keypath: "**.Stroke 1.Color")
            gaugeAV.setValueProvider(fillColorValueProvider, keypath: trackFillKey)
        }
    }
    
    func enableAddMinus() {
        addButton.isEnabled = true
        minusButton.isEnabled = true
    }
    
    func disableAddMinus() {
        addButton.isEnabled = false
        minusButton.isEnabled = false
    }
    
    //MARK: Nav
    func handleNav(nav: TherapyNav){
        let storyboard = UIStoryboard(name: "therapyNew", bundle: nil)
        var vc = UIViewController()
        var popup = false
        
        switch nav {
        case .disconnect:
            vc = storyboard.instantiateViewController(withIdentifier: "TherapyDisconnectViewController") as! TherapyDisconnectViewController
        case .therapyComplete:
            vc = storyboard.instantiateViewController(withIdentifier: "TherapyCompletedViewController") as! TherapyCompletedViewController
        case .stopTherapy:
            vc = StopTherapyPopupViewController()
            popup = true
        case .allPausesUsed:
            vc = PauseLimitPopupViewController()
            fadePauseButton()
            popup = true
        case .therapySaveFail:
            vc = TherapySessionFailedSavePopupViewController()
            popup = true
        case .dailyLimitReached:
            vc = DailyLimitPopupViewController()
            popup = true
        case .pauseAboutExpire:
            vc = PauseAboutToExpirePopupViewController()
            popup = true
        case .pauseExpired:
            vc = storyboard.instantiateViewController(withIdentifier: "TherapyPauseExpiredViewController") as! TherapyPauseExpiredViewController
        case .dataRecoveryAvailable:
            vc = PrepTherapyDataRecoveryPopupViewController()
            popup = true
        }
        vc.modalPresentationStyle = .overCurrentContext
        popup ? self.present(vc, animated: false) : navigationController?.pushViewController(vc, animated: false)
    }
    
    func fadePauseButton() {
        pauseButton.alpha = 0.5
    }
    
    func unfadePauseButton() {
        pauseButton.alpha = 1.0
    }
    
    func fadeAddButton() {
        self.addButton.alpha = 0.5
    }
    
    func unfadeAddButton() {
        self.addButton.alpha = 1.0
    }
    
    func fadeMinusButton() {
        self.minusButton.alpha = 0.5
    }
    
    func unfadeMinusButton() {
        self.minusButton.alpha = 1.0
    }
    
    func addIntensity() {
        addAsyncCheck = true
        
        BluetoothManager.sharedInstance.sendCommand(command: .changeAmplitude, parameters: [UInt8(BluetoothConstants.param_change_amplitude_increment)])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){ [self] in
            addAsyncCheck = false
            addButton.isEnabled = true
        }
    }
    
    func lowerIntensity() {
        BluetoothManager.sharedInstance.sendCommand(command: .changeAmplitude, parameters: [UInt8(BluetoothConstants.param_change_amplitude_decrement)])
    }
    
    //MARK: Actions
    
    @IBAction func addTapped(_ sender: UIButton) {
        if addAsyncCheck == true {
            return
        }
        
        addButton.isEnabled = false
        unfadeMinusButton()
    
        let stim = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        
        // current tick = 11?
        // YES: fade add button
        if stim.currentTick == 10 {
            addIntensity()
            fadeAddButton()
            
        } else if stim.currentTick == 11 {
            // MARK: intentionally blank
            
        // NO: normal operation
        } else {
            addIntensity()
        }
    }
    @IBAction func minusTapped(_ sender: UIButton) {
        unfadeAddButton()
        
        let stim = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        
        // tick = 1?
        // YES: fade minus button
        if stim.currentTick == 2 {
            lowerIntensity()
            fadeMinusButton()
            
        } else if stim.currentTick == 1 {
            // MARK: intentionally blank
        
        // NO: normal operation
        } else {
            lowerIntensity()
        }
    }
    
    @IBAction func startTapped(_ sender: ActionButton) {
        unfadePauseButton()
        if DataRecoveryManager.sharedInstance.recoveryAvailable{
            handleNav(nav: .dataRecoveryAvailable)
            return
        }
        
        showLoading()
        TherapyManager.sharedInstance.grabPrescriptionInfo()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){  //swap out with completion handler to dismiss loading
            self.hideLoading()
        }
    }
    
    @IBAction func pauseTapped(_ sender: ActionButton) {
        TherapyManager.sharedInstance.pauseTherapy()
    }
    
    @IBAction func stopTapped(_ sender: ActionButton) {
        handleNav(nav: .stopTherapy)
    }
    
    @IBAction func pauseStopTapped(_ sender: ActionButton) {
        handleNav(nav: .stopTherapy)
    }
    @IBAction func resumeTapped(_ sender: ActionButton) {
        TherapyManager.sharedInstance.resumeTherapy()
    }
}

extension TherapyViewController: BluetoothManagerDelegate{
    func didUpdateDevice() {}
    
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {}
    
    func didConnectToDevice(device: CBPeripheral) {}
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        handleNav(nav: .disconnect)
    }
    
    func didBLEChange(on: Bool) {}
    
    func didUpdateData() {}
    
    func didUpdateStimStatus() {}
    
    func didUpdateEMG() {}
    func didUpdateBattery(){}
    func didUpdateTherapySession() {}
    
    func didBondFail() {}
    
    func foundOngoingTherapy() {}
    func pairingTimeExpired() {}
    
    
}

extension TherapyViewController: TherapyManagerDelegate{
    func didUpdateDev() {
        checkDev()
    }
    
    func therapyFinished(state: therapyFinishStates) {
        if state == .complete{
            handleNav(nav: .therapyComplete)
        }
        else if state == .pauseStop{
            //go pause complete page
            handleNav(nav: .pauseExpired)
        }
    }
    
    func therapyPaused() {}
    
    func therapyResumed() {}
    
    func updateBLEData() {
        updateTime()
    }
    
    func didConnectToBLEDevice(device: CBPeripheral) {
    }
    
    func didDisconnectFromBLEDevice(device: CBPeripheral) {
        handleNav(nav: .disconnect)
    }
    
    func pauseLimitReached() {
        //disable/hide pause button
        handleNav(nav: .allPausesUsed)
    }
    
    func didUpdateStatus() {
        checkState()
    }
    func didUpdateTherapyBattery(){}
    
    func pauseAboutToExpire() {
        handleNav(nav: .pauseAboutExpire)
    }
    
    func pauseExpired() {
        handleNav(nav: .pauseExpired)
    }
    
}

extension TherapyViewController:TherapyManagerImpedanceFailDelegate{
    func impedanceChange(impChange: TherapyImpError) {
        let vc = ChecksFailedPopupViewController()
        vc.isLeft = TherapyManager.sharedInstance.isLeft
        vc.checkError = impChange
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func dailyLimitReached() {
        handleNav(nav: .dailyLimitReached)
    }
    
    func invalidScreening() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func therapySaveFailed() {
        handleNav(nav: .therapySaveFail)
    }
    
    func lowBattery() {
        let vc = InsufficientBatteryPopupViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
}

extension TherapyViewController:BackPromptDelegate{
    func goBackSelected() {
        if let roles = KeychainManager.sharedInstance.accountData?.roles{
            if roles.contains("Clinician"){
            //need to show popup for both type therapy started or not started
            handleNav(nav: .stopTherapy)
            return
            } //!clinician
        } //!roles
        if therapyState == .running { // therapy running
            self.navigationController?.popToRootViewController(animated: true)
            
        } else { // therapy not running
            self.navigationController?.popViewController(animated: true)
        }
    } //!func
}
