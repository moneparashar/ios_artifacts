//
//  ScreeningViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/31/23.
//

import UIKit
import Lottie
import CoreBluetooth


enum ScreeningNav{
    case exitScreeningAsk
    case screeningCompleted
    //case screeningCompletedButFailed
}

enum ScreenStates{
    case notStarted
    case running
    case paused
    case completed
}

class ScreeningViewController: BaseNavViewController {

    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var screeningInstructionLabel: UILabel!
    @IBOutlet weak var instructionImageView: UIImageView!
    
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var currentPulse: UILabel!
    
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var roundStackView: UIStackView!
    
    @IBOutlet weak var emgDetectedLabel: UILabel!
    @IBOutlet weak var emgNumLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    @IBOutlet weak var maxToleranceLabel: UILabel!
    @IBOutlet weak var maxTolValueLabel: UILabel!
    @IBOutlet weak var maxTolImageView: UIImageView!
    
    @IBOutlet weak var restartView: UIView!
    @IBOutlet weak var restartLabel: UILabel!
    
    //bottomStack
    @IBOutlet weak var leftSpacer: UIView!
    @IBOutlet weak var startButton: ActionButton!
    @IBOutlet weak var rightSpacer: UIView!
    @IBOutlet weak var restartButton: ActionButton!
    @IBOutlet weak var pauseButton: ActionButton!
    @IBOutlet weak var exitButton: ActionButton!
    @IBOutlet weak var completeButton: ActionButton!
    @IBOutlet weak var continueButton: ActionButton!
    @IBOutlet weak var signOutButton: ActionButton!
    
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    var screenState:ScreenStates = .notStarted
    var bottomStackSubviews:[UIView] = []
    
    var emgFound = false
    var metCriteria = false
    var receivedCriteria = false
    
    var allAnimationViews:[AnimationView] = []
    let backAV = AnimationView()
    let screeningEMGLabelAV = AnimationView()
    let gaugeAV = AnimationView()
    let emgActiveAV = AnimationView()
    
    var passIcon = PopupIcons.check.getIconImage()
    var failIcon = PopupIcons.warning.getIconImage()
    
    var displayTick = 0
    var devTick = 0
    var updatingDisplay = false
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.goBackPrompt = true
        super.viewDidLoad()
        
        super.delegate = self
        setupLottie()
        
        contentWidth.constant = view.getWidthConstant()
        pauseButton.toSecondary()
        exitButton.toSecondary()
        restartButton.toSecondary()
        title = "Therapy Personalizaiton"
        
        let name = ScreeningManager.sharedInstance.patientData?.patientId ?? ""
        let foot = ScreeningProcessManager.sharedInstance.isLeft ? "LEFT" : "RIGHT"
        subTitleLabel.text = "Personalizing \(name) on \(foot) foot"
        
        bottomStackSubviews = [leftSpacer, startButton, rightSpacer, restartButton, pauseButton, exitButton, completeButton, continueButton, signOutButton]
        
        roundView.layer.borderWidth = 1.0
        roundView.layer.borderColor = UIColor.casperBlue?.cgColor
        roundView.layer.cornerRadius = 15
        
        resetAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //demoLottie()
        ScreeningProcessManager.sharedInstance.delegate = self
        ScreeningProcessManager.sharedInstance.errorDelegate = self
        checkState()
        displayRampChange()
    }
    
    func demoLottie(){
        //gaugeAV.currentFrame = 60
        let balh = gaugeAV.animation?.endFrame
        //print(balh)
        var val = 116
        gaugeAV.currentFrame = AnimationFrameTime(val)
        self.currentPulse.text = String(val)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            val = 117
            self.gaugeAV.currentFrame = AnimationFrameTime(val)
            self.currentPulse.text = String(val)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                val = 118
                self.gaugeAV.currentFrame = AnimationFrameTime(val)
                self.currentPulse.text = String(val)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    val = 119
                    self.gaugeAV.currentFrame = AnimationFrameTime(val)
                    self.currentPulse.text = String(val)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                        val = 120
                        self.gaugeAV.currentFrame = 120
                        self.currentPulse.text = String(val)
                    }
                }
            }
        }
    }
    
    func shamCheck(pulseWidth: Int16){
        if let devMode = ScreeningManager.sharedInstance.patientData?.deviceMode{
            if (BluetoothManager.sharedInstance.isDeviceModeActive(devMode: devMode, bit: Modes.noStim.getDeviceModeEquivalent()) == true){
                if pulseWidth >= 85 && ScreeningProcessManager.sharedInstance.tolerableThresholdPulseWidth <= 0{
                    completeButton.isEnabled = true
                    completeButton.sendActions(for: .touchUpInside)
                }
                completeButton.isEnabled = false
            }
            else if (BluetoothManager.sharedInstance.isDeviceModeActive(devMode: devMode, bit: Modes.lowStim.getDeviceModeEquivalent()) == true){
                if pulseWidth >= 55 && ScreeningProcessManager.sharedInstance.tolerableThresholdPulseWidth <= 0{
                    completeButton.isEnabled = true
                    completeButton.sendActions(for: .touchUpInside)
                }
                completeButton.isEnabled = false
            }
            
        }
    }
    
    func checkState(){
        let oldScreenState = screenState
        let stimState = BluetoothManager.sharedInstance.informationServiceData.stimStatus.state
        switch stimState{
        case .idle:
            screenState = .notStarted
            if receivedCriteria{
                screenState = .completed
            }
        case .running:
            screenState = .running
        case .paused:
            screenState = .paused
        case .competed, .stopped:
            screenState = .completed
        }
        if oldScreenState != screenState{
            updateView()
        }
    }
    
    func updateView(){
        switch screenState {
        case .notStarted:
            screeningInstructionLabel.text = "Tap start below to begin Therapy Personalization"
            minusButton.isEnabled = false
            plusButton.isEnabled = false
            setRoundViewColor(faded: true)
            screeningEMGLabelAV.isHidden = true
        case .running:
            screeningInstructionLabel.text =  emgFound ? "Continue to slowly increase intensity. When maximum tolerance is reached tap Complete" : "Press the “+” button to slowly increase intensity. When max comfort level is reached, tap Max tolerance."
            minusButton.isEnabled = true
            plusButton.isEnabled = true
            setRoundViewColor()
            setEMGColor()
        case .paused:
            screeningInstructionLabel.text = "Tap Continue to resume Therapy Personalization"
            minusButton.isEnabled = false
            plusButton.isEnabled = false
            setRoundViewColor(faded: true)
            setEMGColor(showColor: false)
        case .completed:
            minusButton.isEnabled = false
            plusButton.isEnabled = false
            setRoundViewColor()
            maxToleranceLabel.text = "Max tolerance"
            let tol = Int(ScreeningProcessManager.sharedInstance.tolerableThresholdPulseWidth)
            maxTolValueLabel.text = String(tol)
            restartLabel.isHidden = false
            setEMGColor()
            
            if receivedCriteria{
                if metCriteria{
                    let foot = ScreeningProcessManager.sharedInstance.isLeft ? "LEFT" : "RIGHT"
                    screeningInstructionLabel.text = "Personalization for the \(foot) foot was completed successfully"
                    instructionImageView.image = passIcon
                    maxTolImageView.image = passIcon
                }
                else{
                    screeningInstructionLabel.text = "Sorry, patient did not meet the criteria for Personalization."
                    instructionImageView.image = failIcon
                    maxTolImageView.image = failIcon
                }
                
                instructionImageView.isHidden = false
                maxTolImageView.isHidden = false
            }
        }
        
        getButtonStack()
    }
    
    var canEnableAdd = true
    func setIntensityEnabling(){
        if screenState != .running{
            minusButton.isEnabled = false
            plusButton.isEnabled = false
        }
        let pw = BluetoothManager.sharedInstance.informationServiceData.stimStatus.pulseWidth
       
        minusButton.isEnabled = pw > 0
        if canEnableAdd{
            plusButton.isEnabled = pw < 600
        }
    }
        
    func setRoundViewColor(faded: Bool = false){
        let passColor = faded ? UIColor.lavendarMist : UIColor.fontBlue
        emgDetectedLabel.textColor = passColor
        emgNumLabel.textColor = passColor
        maxToleranceLabel.textColor = passColor
    }

    func getButtonStack(){
        let isTablet = UIDevice.current.userInterfaceIdiom == .pad
        var bottomViewsToShow: [UIView] = []
        switch screenState {
        case .notStarted:
            // old implem.
            // bottomViewsToShow = isTablet ? [leftSpacer, startButton, rightSpacer] : [startButton]
            bottomViewsToShow = [startButton]
        case .running:
            bottomViewsToShow = [pauseButton, completeButton]
        case .paused:
            // old implem.
            // bottomViewsToShow = isTablet ? [leftSpacer, exitButton, continueButton, rightSpacer] : [exitButton, continueButton]
            bottomViewsToShow = [exitButton, continueButton]
        case .completed:
            if metCriteria{
                bottomViewsToShow = [restartButton, continueButton]
            }
            else{
                bottomViewsToShow = [restartButton, signOutButton]
            }
        }
        hideAllBut(showList: bottomViewsToShow)
    }
    
    func hideAllBut(showList: [UIView]){
        for sv in bottomStackSubviews{
            var match = false
            for sl in showList{
                if sl == sv{
                    match = true
                }
            }
            sv.isHidden = !match
        }
    }
    
    func displayEMG(){
        emgFound = true
        emgDetectedLabel.text = "EMG detected"
        let emg = Int(ScreeningProcessManager.sharedInstance.pulseWidthAtEMGDetect)
        emgNumLabel.text = String(emg)
        emgNumLabel.isHidden = false
        checkImageView.isHidden = false
        
        updateView()
        
        let emgDetect = Int(ScreeningProcessManager.sharedInstance.pulseWidthAtEMGDetect)
        let minTol = emgDetect + 20
        maxTolValueLabel.text = "Minimum " + String(minTol)
        maxTolValueLabel.isHidden = false
        
        //screeningEMGLabelAV.isHidden = false
        emgActiveAV.currentFrame = CGFloat(emgDetect) / 5
        
        //show line and tolerance stack
        roundStackView.arrangedSubviews[1].isHidden = false
        roundStackView.arrangedSubviews[2].isHidden = false
    }
    
    func resetAll(){
        devTick = 0
        receivedCriteria = false
        instructionImageView.isHidden = true
        currentPulse.text = "0"
        displayTick = 0
        
        emgFound = false
        emgNumLabel.isHidden = true
        checkImageView.isHidden = true
        setEMGColor(showColor: false)
        screeningEMGLabelAV.isHidden = true
        
        emgActiveAV.stop()
        gaugeAV.stop()
        
        maxTolValueLabel.isHidden = true
        
        screenState = .notStarted
        
        //completeButton.isEnabled = false
        
        maxTolImageView.isHidden = true
        restartLabel.isHidden = true
        
        maxToleranceLabel.text = "Tolerance"
        emgDetectedLabel.text = "EMG not detected"
        
        //hide line and tolerance
        if !roundStackView.arrangedSubviews[1].isHidden{
            roundStackView.arrangedSubviews[1].isHidden = true
        }
        if !roundStackView.arrangedSubviews[2].isHidden{
            roundStackView.arrangedSubviews[2].isHidden = true
        }
        
        updateView()
    }
    
    //MARK: lottie
    func setupLottie(){
        backAV.animation = Animation.named(AnimationLottieNames.screeningBackground.rawValue)
        screeningEMGLabelAV.animation = Animation.named(AnimationLottieNames.screeningEMGLabel.rawValue)
        gaugeAV.animation = Animation.named(AnimationLottieNames.screeningFillActive.rawValue)
        emgActiveAV.animation = Animation.named(AnimationLottieNames.screeningEMGActive.rawValue)
        
        allAnimationViews = [backAV, screeningEMGLabelAV, gaugeAV, emgActiveAV]
        for av in allAnimationViews{
            av.contentMode = .scaleAspectFit
            av.backgroundBehavior = .pauseAndRestore
            av.translatesAutoresizingMaskIntoConstraints = false
            lottieView.addSubview(av)
            
            NSLayoutConstraint.activate([
                av.centerXAnchor.constraint(equalTo: lottieView.centerXAnchor),
                av.centerYAnchor.constraint(equalTo: lottieView.centerYAnchor),
                av.topAnchor.constraint(greaterThanOrEqualTo: lottieView.topAnchor),
                av.leadingAnchor.constraint(greaterThanOrEqualTo: lottieView.leadingAnchor)
            ])
        }
    }
    
    //there's 120 frames
    func checkPulse(){
        let stimStat = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        if stimStat.mainState == .screening{
            let pulse = stimStat.pulseWidth
            
            shamCheck(pulseWidth: pulse)
            
            devTick = Int(pulse)
            currentPulse.text = String(devTick)
            if displayTick != devTick && !updatingDisplay{
                updatingDisplay = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    self.updateTick()
                }
            }
        }
    }
    
    func updateTick(){
        
        let newFrameToReach = Float(devTick / 5)
        let lastFrame = Float(displayTick / 5)
        
        var progressTime:Float = 0
        let duration:Float = 3
        while progressTime <= duration{
            var gaugeFrame = Float(0)
            if newFrameToReach > lastFrame{
                let gaugeProcess = AnimationManager.sharedInstance.easeInOut(val: progressTime/duration)
                gaugeFrame = AnimationManager.sharedInstance.lerp(startValue: lastFrame, endValue: newFrameToReach, progress: gaugeProcess)
            }
            else{
                let gaugeProcess = AnimationManager.sharedInstance.easeInOutNeg(val: progressTime/duration)
                gaugeFrame = AnimationManager.sharedInstance.lerp(startValue: newFrameToReach, endValue: lastFrame, progress: gaugeProcess)
            }
            gaugeAV.currentFrame = CGFloat(gaugeFrame)
            progressTime += 0.1
        }
        displayTick = Int(newFrameToReach * 5)
        updatingDisplay = false
    }
    
    func setEMGColor(showColor: Bool = true){
        if let emgFillColor = showColor ? UIColor.fontBlue?.lottieColorValue : UIColor.casperBlue?.lottieColorValue{
            let fillColorValueProvider = ColorValueProvider(emgFillColor)
            let trackFillKey = AnimationKeypath(keypath: "**.Stroke 1.Color")
            emgActiveAV.setValueProvider(fillColorValueProvider, keypath: trackFillKey)
        }
    }
    
    func setLabelColor(showColor: Bool = true){
        if let labelFillColr = showColor ? UIColor.fontBlue?.lottieColorValue : UIColor.casperBlue?.lottieColorValue{
            let fillColorValueProvider = ColorValueProvider(labelFillColr)
            let trackFillKey = AnimationKeypath(keypath: "**.Stroke 1.Color")
            backAV.setValueProvider(fillColorValueProvider, keypath: trackFillKey)
        }
    }
    
    
    //MARK: Navigation
    func handleNav(nav: ScreeningNav){
        var vc = UIViewController()
        
        switch nav {
        case .exitScreeningAsk:
            vc = ExitScreeningPopupViewController()
        case .screeningCompleted:
            if ScreeningManager.sharedInstance.patientData?.hasCompletedScreening == true{
                vc = CompletedScreeningPoupViewController()
            }
            else{
                ScreeningProcessManager.sharedInstance.setTestTherapyEvalCrit()
                TherapyManager.sharedInstance.testTherapy = true
                TherapyManager.sharedInstance.isLeft = ScreeningProcessManager.sharedInstance.isLeft
                let storyboard = UIStoryboard(name: "therapyNew", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TherapyViewController") as! TherapyViewController
                NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: true)
                return
            }
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    @IBAction func minusTapped(_ sender: UIButton) {
        BluetoothManager.sharedInstance.sendCommand(command: .changeAmplitude, parameters:  [UInt8(BluetoothConstants.param_change_amplitude_decrement)])
    }
    
    @IBAction func plusTapped(_ sender: UIButton) {
        plusButton.isEnabled = false
        canEnableAdd = false
        BluetoothManager.sharedInstance.sendCommand(command: .changeAmplitude, parameters:  [UInt8(BluetoothConstants.param_change_amplitude_increment)])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.canEnableAdd = true
            self.setIntensityEnabling()
        }
    }
    
    
    
    @IBAction func startTapped(_ sender: ActionButton) {
        if BluetoothManager.sharedInstance.informationServiceData.batteryStateOfCharge.level > 50{
            showLoading()
            ScreeningProcessManager.sharedInstance.preChecks()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                self.hideLoading()
            }
        }
    }
    
    @IBAction func continueTapped(_ sender: ActionButton) {
        if screenState == .completed{
            handleNav(nav: .screeningCompleted)
        }
        else if ScreeningProcessManager.sharedInstance.screeningRunning{
            ScreeningProcessManager.sharedInstance.resumeScreening()
        }
    }
    
    @IBAction func restartTapped(_ sender: ActionButton) {
        ScreeningProcessManager.sharedInstance.resetValues()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pauseTapped(_ sender: ActionButton) {
        ScreeningProcessManager.sharedInstance.pauseScreening()
    }
    
    @IBAction func exitTapped(_ sender: ActionButton) {
        handleNav(nav: .exitScreeningAsk)
    }
    
    @IBAction func completeTapped(_ sender: ActionButton) {
        ScreeningProcessManager.sharedInstance.userStopScreening()
    }
    
    @IBAction func signoutTapped(_ sender: ActionButton) {
        if NetworkManager.sharedInstance.checkIfStillSending(){
            let vc = SignOutConfirmationPopupViewController()
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: false)
        }
        else{
            let appData = AppManager.sharedInstance.loadAppDeviceData()
            let appId = appData!.appIdentifier
            if NetworkManager.sharedInstance.connected{
                NotificationManager.sharedInstance.postPushNotificationUnRegister(appId: appId) { success, errorMessage in
                    if !success{
                        Slim.error(errorMessage)
                    }
                }
            }
            
            BluetoothManager.sharedInstance.stopAllStimulation()
            NetworkManager.sharedInstance.logoutClear()
            let initialViewController = NonSignedInMainViewController()
            NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
        }
    }
    
    func displayRampChange(){
        let runningState = BluetoothManager.sharedInstance.informationServiceData.stimStatus.runningState
        completeButton.isEnabled = runningState != .manualRampUp
    }
}

extension ScreeningViewController: ScreeningProcessManagerDelegate{
    func rampChange() {
        displayRampChange()
    }
    
    func updateStimStatus() {
        checkPulse()
        checkState()
    }
    
    func screeningStopped() {
        
    }
    
    func screeningPaused() {
    }
    
    func screeningResumed() {
    }
    
    func emgDetected() {
        displayEMG()
        //completeButton.isEnabled = true
    }
    
    func updateScreeningBattery(){
        
    }
    
    func updateBLEData() {
    }
    
    func metCriteria(pass: Bool) {
        receivedCriteria = true
        if pass{
            metCriteria = pass
        }
        checkState()
        //updateView()
    }
    
    func evalErrorUpload(message: String) {
        
    }
    
    
}

extension ScreeningViewController: BackPromptDelegate{
    func goBackSelected() {
        if ScreeningProcessManager.sharedInstance.screeningRunning{
            handleNav(nav: .exitScreeningAsk)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension ScreeningViewController: TherapyManagerImpedanceFailDelegate {
    
    func impedanceChange(impChange: TherapyImpError) {
        let vc = ChecksFailedPopupViewController()
        vc.isLeft = TherapyManager.sharedInstance.isLeft
        vc.checkError = impChange
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func dailyLimitReached() {}
    func invalidScreening() {}
    func therapySaveFailed() {}
    func lowBattery() {
        let vc = InsufficientBatteryPopupViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
}
