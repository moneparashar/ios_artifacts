/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import CoreBluetooth

protocol ScreeningProcessManagerConnectionDelegate {
    func screeningInProgress(running: Bool)
}
protocol ScreeningProcessManagerDelegate {
    func emgDetected()
    func updateBLEData()
    func metCriteria(pass: Bool)
    func evalErrorUpload(message: String)
    
    func updateStimStatus()
    func updateScreeningBattery()
    func rampChange()
}

class ScreeningProcessManager: NSObject {
    static let sharedInstance = ScreeningProcessManager()
    
    var navDelegate:ScreeningProcessManagerConnectionDelegate?
    var errorDelegate:TherapyManagerImpedanceFailDelegate?
    
    var screeningRunning = false
    var screeningPaused = false
    var delegate:ScreeningProcessManagerDelegate?
    
    var pulseWidth:Int16 = 0
    var emgDetected = false
    var evalCrit:EvaluationCriteria = EvaluationCriteria()
    
    var tolerableThresholdPulseWidth:Int32 = 0
    var comfortLevelEMGStrength = 0
    var pulseWidthAtEMGDetect:Int32 = 0
    var emgDetectionPointStrength:Int32 = 0
    var currentStrength:Int32 = 0
    var isLeft = false
    //var currentFoot = Feet.right
    var emgStrengthMax:Int32 = 0
    var targetEMGStrenght:Int32 = 0
    var stimCurrentAmplitude:Int16 = 0
    
    
    var deviceConfigGuid:UUID? = nil
    var screeningGuid:UUID? = nil
    var therapyLength:Int = 1800
    var therapySchedule:Int = 0
    
    var impedanceCheckTimer:Timer?
    
    var criteriaRetrieved = false
    
    var isRamping = false
    
    func resetScreeningPair(){
        screeningRunning = false
        screeningPaused = false
    }
    
    func resetValues(){
        screeningRunning = false
        screeningPaused = false
        pulseWidth = 0
        emgDetected = false
        isRamping = false
        
        evalCrit = EvaluationCriteria()
        tolerableThresholdPulseWidth = 0
        comfortLevelEMGStrength = 0
        pulseWidthAtEMGDetect = 0
        emgDetectionPointStrength = 0
        currentStrength = 0
        targetEMGStrenght = 0
        
        deviceConfigGuid = nil
        screeningGuid = nil
        therapyLength = 1800
        
        if BluetoothManager.sharedInstance.isConnectedToDevice(){
            BluetoothManager.sharedInstance.sendCommand(command: .discontinueStimEval, parameters: [])
            BluetoothManager.sharedInstance.setReadyToSend(value: 0)
        }
        //setting multiple values to 0
        BluetoothManager.sharedInstance.resetScreeningInfo()
        
        criteriaRetrieved = false
        
        StimDataManager.sharedInstance.stimData = StimData()
    }
    func preChecks(){
        ActivityManager.sharedInstance.stopActivityTimers()
        DeviceErrorManager.sharedInstance.resetAll()
        DeviceErrorManager.sharedInstance.impedanceCheckRunning = true
        DeviceErrorManager.sharedInstance.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            self.startScreening()
        }
    }
    func startScreening(){
        BluetoothManager.sharedInstance.delegate = self
        BluetoothManager.sharedInstance.readStimStatus()
        BluetoothManager.sharedInstance.readEMGStatus()
        BluetoothManager.sharedInstance.readDevice()
        
        if let sGuid = ScreeningManager.sharedInstance.loadScreeningGuid(){
            screeningGuid = UUID(uuidString: sGuid)
        }
        else{
            return
        }
        deviceConfigGuid = DeviceConfigManager.sharedInstance.deviceConfig?.guid
        evalCrit.screeningGuid = screeningGuid
        evalCrit.deviceConfigurationGuid = deviceConfigGuid
        
        evalCrit.foot = isLeft ? Feet.left.getIntVal() : Feet.right.getIntVal()
        
        //info about patient should already be pulled
        evalCrit.therapyLength = therapyLength
        evalCrit.therapySchedule = therapySchedule
        
        //post new eval crit
        if NetworkManager.sharedInstance.connected{
            EvaluationCriteriaManager.sharedInstance.postEvalCriteria(evaluationCriteria: evalCrit){ success, result, errorMessage in
                if success{
                    BluetoothManager.sharedInstance.sendCommand(command: .startStimEval, parameters: [])
                    self.screeningRunning = true
                    
                    self.navDelegate?.screeningInProgress(running: true)
                }
            }
        }
    }
    
    func pauseScreening(){
        BluetoothManager.sharedInstance.sendCommand(command: .pauseStim, parameters: [])
        screeningPaused = true
        //delegate?.screeningPaused()
        
        NotificationManager.sharedInstance.removeScreeningTimeNotifications(isRunning: true, isPaused: false)
    }
    
    func resumeScreening(){
        BluetoothManager.sharedInstance.sendCommand(command: .resumeStim, parameters: [])
        screeningPaused = false
        NotificationManager.sharedInstance.removeScreeningTimeNotifications(isRunning: false, isPaused: true)
    }
    func stopScreening(){
        tolerableThresholdPulseWidth = Int32(pulseWidth)
        BluetoothManager.sharedInstance.setPulseWidthAtComfort(pulseWidth: tolerableThresholdPulseWidth)
        comfortLevelEMGStrength = Int(currentStrength)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            BluetoothManager.sharedInstance.setReadyToSend(value: 1)
        }
    }
    
    //look into why this works when going back, but this doesn't work when trying to stop screening after restarting the app
    func stopPausedScreening(){
        let stim = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        if stim.state == .paused{
            BluetoothManager.sharedInstance.sendCommand(command: .resumeStim, parameters: [])
        }
        
        BluetoothManager.sharedInstance.sendCommand(command: .stopStim, parameters: [])
        DeviceErrorManager.sharedInstance.impedanceCheckRunning = false
    }
    
    func stopScreeningInvalid(){    //called when stopping screening via back
        stopPausedScreening()
        resetScreeningPair()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.resetValues()
        }
        StimDataManager.sharedInstance.stopStimDataTimer()
    }
    
    func userStopScreening() {
        //
        stopScreening()
        //delegate?.screeningStopped()
        
        navDelegate?.screeningInProgress(running: false)
    }
    
    func updateStatus(){
        let stim = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        
        //targetEMGStrength
        //assign currentAmplitude, currentstrength, emgStrengthMax, targetEMGStrength
        
        if stim.mainState == .screening{
            
            if stim.state == .running && !screeningRunning{
                ScreeningProcessManager.sharedInstance.screeningRunning = true
                navDelegate?.screeningInProgress(running: true)
                ActivityManager.sharedInstance.stopActivityTimers()
            }
            else if stim.state == .idle || stim.state == .competed || stim.state == .stopped{
                screeningRunning = false
                navDelegate?.screeningInProgress(running: false)
                NotificationManager.sharedInstance.removeScreeningTimeNotifications(isRunning: true, isPaused: true)
                return
            }
            
            pulseWidth = stim.pulseWidth
            stimCurrentAmplitude = stim.amplitude
            currentStrength = stim.emgStrength
            emgStrengthMax = stim.emgStrengthMax
            //targetEMGStrenght = stim.emgTarget
            let emgTarget = stim.emgTarget
            if emgTarget != 0{
                targetEMGStrenght = emgTarget
                //Slim.info("Non-zero target EMG: \(targetEMGStrenght)")
            }
            
            if !emgDetected && screeningRunning{
                if stim.emgDetected {
                    emgDetected = true
                    pulseWidthAtEMGDetect = Int32(pulseWidth)
                    BluetoothManager.sharedInstance.setPulseWidthAtEMG(pulseWidth: pulseWidthAtEMGDetect)
                    emgDetectionPointStrength = currentStrength
                    delegate?.emgDetected()
                    //evalCrit.emgDetectionPointPulseWidth = Int(pulseWidth)
                }
            }
            
            if screeningRunning{
                let currentlyRamping = stim.runningState == .manualRampUp
                if !isRamping && currentlyRamping{
                    delegate?.rampChange()
                    isRamping = true
                }
                else if isRamping && !currentlyRamping{
                    delegate?.rampChange()
                    isRamping = false
                }
            }
        }
        else{
            if screeningRunning{
                screeningRunning = false
                navDelegate?.screeningInProgress(running: false)
                NotificationManager.sharedInstance.removeScreeningTimeNotifications(isRunning: true, isPaused: true)
            }
            
            if stim.mainState == .idle{
                print("idle")
            }
        }
    }
    
    func checkCriterias(){
        if !criteriaRetrieved{
            watchMeetsCriteria()
            watchDoesNotMeetCriteria()
        }
    }
    
    func watchMeetsCriteria(){
        if DeviceErrorManager.sharedInstance.meetsCriteria == true{
            criteriaRetrieved = true
            
            updateEval()
            delegate?.metCriteria(pass: true)
            
            Slim.info("Criteria met")
            
            BluetoothManager.sharedInstance.readTargetEMG()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                self.updateEval()
                NetworkManager.sharedInstance.sendBulkStimAndEMGData(){}
            }
        }
    }
    
    func watchDoesNotMeetCriteria(){
        if DeviceErrorManager.sharedInstance.doesNotMeetCriteria == true {
            criteriaRetrieved = true
            
            delegate?.metCriteria(pass: false)
            
            Slim.info("Criteria not met")
            
            updateEval()
            NetworkManager.sharedInstance.sendBulkStimAndEMGData(){}
            
        }
    }
    
    func attemptPostDeviceConfig(){ //check if this is even called anymore
        let deviceConfig = DeviceConfig()
        
        let stimDeviceGuid = StimDeviceManager.sharedInstance.stimDevice?.guid
        let screeningGuid = ScreeningManager.sharedInstance.screeningGuid
        let firmwareVer = BluetoothManager.sharedInstance.informationServiceData.revision.rev
        let appVer = (UIApplication.appVersion ?? "") + "." + (UIApplication.build ?? "")
        let appDeviceGuid = AppManager.sharedInstance.appDeviceData?.guid
        
        deviceConfig.stimDeviceGuid = stimDeviceGuid
        deviceConfig.screeningGuid = screeningGuid
        deviceConfig.firmwareVersion = firmwareVer
        deviceConfig.appVersion = appVer
        deviceConfig.appDeviceGuid = appDeviceGuid
        
        
        DeviceConfigManager.sharedInstance.postDeviceConfig(deviceConfig: deviceConfig){ success, result, errorMessage, wasLast in
            if success{
                print("successful device config post")
                DeviceConfigManager.sharedInstance.saveDeviceConfigData(data: result!)
                
                //hopefully this way we get deviceconfig guid properly passed
                self.evalCrit.deviceConfigurationGuid = result?.guid

            }
            else{
                print(errorMessage)
            }
        }
    }
    
    func attemptPostEval(){
        evalCrit.modified = Date()
        EvaluationCriteriaManager.sharedInstance.postEvalCriteria(evaluationCriteria: evalCrit){ success, result, errorMessage in
            if success{
                print("succesful evaluation post")
                BluetoothManager.sharedInstance.setReadyToSend(value: 2)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                    self.evalCrit.therapyLength = 300
                    BluetoothManager.sharedInstance.setEvaluationCriteria(criteria: self.evalCrit)
                }
            }
            else{
                print(errorMessage)
            }
        }
    }
    
    func updateEval(){
        
        /*
         guid                   //already set
         skinsensation pw       //skin sensation pulse width, set at skin button, writes ble
         tolerable threshold pw
         temp pain threshold pw //tol + temp both are from tolerableThresholdPulseWidth
         emg detect pw      //once emg detects  writes ble as well
         current amp        //updated in stim status
         target emg strength    //stimstatus.emgTarget
         comfort level emg strength //set to currentStrength right after settolerable threshold(stop) currentStrength is from
         emg strength max   //after setting skin sensation, have emgdection be currentstrength
         foot
         */
        
        evalCrit.modified = Date()
        evalCrit.comfortLevelPulseWidth = Int(tolerableThresholdPulseWidth)
        evalCrit.tempPainThreshold = Int(tolerableThresholdPulseWidth)
        evalCrit.emgDetectionPointPulseWidth = Int(pulseWidthAtEMGDetect)
        evalCrit.stimulationCurrentAmplitude = Int(stimCurrentAmplitude)
        evalCrit.targetEMGStrength = Int(targetEMGStrenght)
        evalCrit.comfortLevelEMGStrength = Int(comfortLevelEMGStrength)
        evalCrit.emgDetectionPointEMGStrength = Int(emgDetectionPointStrength)
        evalCrit.emgStrengthMax = Int(emgDetectionPointStrength)
        
        
        ActivityManager.sharedInstance.stopActivityTimers()
        
        if NetworkManager.sharedInstance.connected{
        EvaluationCriteriaManager.sharedInstance.putEvalCriteria(evaluationCriteria: evalCrit){ success, result, errorMessage in
            if success{
                //Slim.info("New Eval Criteria guid: \(self.evalCrit.guid), Screening guid: \(self.evalCrit.screeningGuid)")
                BluetoothManager.sharedInstance.setReadyToSend(value: 2)
                ActivityManager.sharedInstance.resetInactivityCount()
            }
            else{
                self.delegate?.evalErrorUpload(message: errorMessage)
            }
        }
        }
        else{
            self.delegate?.evalErrorUpload(message: "An error occurred while trying to connect to the Avation portal")
        }
    }
    
    func setTestTherapyEvalCrit(){
        BluetoothManager.sharedInstance.setEvaluationCriteria(criteria: evalCrit)
        
        let patienteval = PatientEvaluationCriteria()
        patienteval.isValid = true
        patienteval.screeningGuid = self.evalCrit.screeningGuid ?? UUID()
        if self.evalCrit.foot == 0{
            patienteval.left = self.evalCrit
        }
        else{
            patienteval.right = self.evalCrit
        }
        EvaluationCriteriaManager.sharedInstance.saveEvalConfigData(data: patienteval)
    }
    
    func prepStimData() {
        if screeningRunning{
            //let stimData = StimData()
            let stimData = StimData()
            let oldStimData = StimDataManager.sharedInstance.stimData
            
            stimData.screeningGuid = screeningGuid
            let stimStatus = BluetoothManager.sharedInstance.informationServiceData.stimStatus
            stimData.dirty = true
            stimData.modified = Date()
            stimData.sessionGuid = nil
            stimData.state = stimStatus.state.rawValue
            stimData.runningState = stimStatus.runningState.rawValue
            stimData.deviceTime = Int32(stimStatus.deviceTime)
            stimData.timeRemaining = stimStatus.timeRemaining == 0 ? oldStimData.timeRemaining : stimStatus.timeRemaining
            stimData.pauseTimeRemaining = stimStatus.pauseTimeRemaining == 0 ? oldStimData.pauseTimeRemaining : stimStatus.pauseTimeRemaining
            stimData.event  = stimStatus.event
            stimData.currentAmplitude  = stimStatus.amplitude == 0 ? oldStimData.currentAmplitude : stimStatus.amplitude
            stimData.percentEMGDetect  = stimStatus.percentageEMGDetection == 0 ? oldStimData.percentEMGDetect : stimStatus.percentageEMGDetection
            stimData.percentNoiseDetect  = stimStatus.percentagePulsesEMGNoisy == 0 ? oldStimData.percentNoiseDetect : stimStatus.percentagePulsesEMGNoisy
            stimData.emgDetected  = stimStatus.emgDetected ?  1 : (oldStimData.emgDetected)
            stimData.emgTarget  = Int32(stimStatus.emgTarget) == 0 ? oldStimData.emgTarget : Int32(stimStatus.emgTarget)
            stimData.pulseWidth  = Int16(stimStatus.pulseWidth) == 0 ? oldStimData.pulseWidth : Int16(stimStatus.pulseWidth)
            stimData.pulseWidthMax  = stimStatus.pulseWidthMax == 0 ? oldStimData.pulseWidthMax : stimStatus.pulseWidthMax
            stimData.pulseWidthMin  = stimStatus.pulseWidthMin == 0 ? oldStimData.pulseWidthMin : stimStatus.pulseWidthMin
            stimData.pulseWidthAvg  = stimStatus.pulseWidthAvg == 0 ? oldStimData.pulseWidthAvg : stimStatus.pulseWidthAvg
            stimData.emgStrength  = Int32(stimStatus.emgStrength) == 0 ? oldStimData.emgStrength : Int32(stimStatus.emgStrength)
            stimData.emgStrengthMax  = Int32(stimStatus.emgStrengthMax) == 0 ? oldStimData.emgStrengthMax : Int32(stimStatus.emgStrengthMax)
            stimData.emgStrengthMin  = Int32(stimStatus.emgStrengthMin) == 0 ? oldStimData.emgStrengthMin : Int32(stimStatus.emgStrengthMin)
            stimData.emgStrengthAvg  = Int32(stimStatus.emgStrengthAvg) == 0 ? oldStimData.emgStrengthAvg : Int32(stimStatus.emgStrengthAvg)
            stimData.impedanceStim  = Int32(stimStatus.impedanceStim) == 0 ? oldStimData.impedanceStim : Int32(stimStatus.impedanceStim)
            stimData.impedanceStimMax  = Int32(stimStatus.impedanceStimMax) == 0 ? oldStimData.impedanceStimMax : Int32(stimStatus.impedanceStimMax)
            stimData.impedanceStimMin  = Int32(stimStatus.impedanceStimMin) == 0 ? oldStimData.impedanceStimMin : Int32(stimStatus.impedanceStimMin)
            stimData.impedanceStimAvg  = Int32(stimStatus.impedanceStimAvg) == 0 ? oldStimData.impedanceStimAvg : Int32(stimStatus.impedanceStimAvg)
            stimData.mainState = stimStatus.mainState.rawValue
            stimData.footConnectionADC = stimStatus.footConnectionADC == 0 ? oldStimData.footConnectionADC : stimStatus.footConnectionADC
            stimData.tempPainThreshold = Int32(stimStatus.tempPainThreshold) == 0 ? oldStimData.tempPainThreshold : Int32(stimStatus.tempPainThreshold)
            stimData.errorCodes = Int32(stimStatus.errorCodes)
            stimData.temperature = stimStatus.temperature == 0 ? oldStimData.temperature : stimStatus.temperature
            stimData.rawADCAtStimPulse = stimStatus.rawADCAtStimPulse == 0 ? oldStimData.rawADCAtStimPulse : stimStatus.rawADCAtStimPulse
            StimDataManager.sharedInstance.stimData = stimData
        }
    }
    
    func prepEMGData(){
        if screeningRunning{
            let emgData = EMGData()
            let status = BluetoothManager.sharedInstance.informationServiceData.emgStatus
            emgData.dirty = true
            emgData.modified = Date()
            emgData.sessionGuid = nil
            emgData.deviceConfigurationGuid = evalCrit.deviceConfigurationGuid
            emgData.screeningGuid = screeningGuid
            emgData.index = status.index
            emgData.dataTimestamp = Int(status.timestamp)
            emgData.data = convertToInt(theData: status.theData)
        }
    }
    
    func attemptPostEMG(){
        let emg = EMGData()
        
        let status = BluetoothManager.sharedInstance.informationServiceData.emgStatus
        
        emg.deviceConfigurationGuid = evalCrit.deviceConfigurationGuid
        emg.screeningGuid = evalCrit.screeningGuid
        emg.index = status.index
        emg.dataTimestamp = Int(status.timestamp)
        emg.data = convertToInt(theData: status.theData)
        
        EMGDataManager.sharedInstance.postEMGData(emgData: emg){ success, result, errorMessage in
            if success{
                print("success with EMG post")
            }
            else{
                print(errorMessage)
            }
        }
        
    }
    
    func convertToInt(theData:[Int32]) -> [Int] {
        var data = [Int]()
        for item in theData {
            let sub = Int(item)
            data.append(sub)
        }
        return data
    }
}


extension ScreeningProcessManager: BluetoothManagerDelegate{
    func didUpdateDevice() {
        checkCriterias()
        delegate?.updateBLEData()
    }
    
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {
       
    }
    
    func didConnectToDevice(device: CBPeripheral) {
        
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        ScreeningProcessManager.sharedInstance.screeningRunning = false
        ActivityManager.sharedInstance.resetInactivityCount()
    }
    func didBLEChange(on: Bool){}
    
    func didUpdateData() {
        //checkCriterias()
        //delegate?.updateBLEData()
    }
    func didUpdateStimStatus(){
        updateStatus()
        
        let stimStatus = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        if stimStatus.mainState == .screening {
            StimDataManager.sharedInstance.handleStimStatus(stimStatus: stimStatus, therapy: false, screenGuid: screeningGuid, user: "")
        }
        
        delegate?.updateStimStatus()
    }
    func didUpdateEMG() {
        let emgStatus = BluetoothManager.sharedInstance.informationServiceData.emgStatus
        EMGDataManager.sharedInstance.handleEMGStatus(status: emgStatus, therapy: false, screenGuid: screeningGuid, user: "")
    }
    func didUpdateBattery(){
        delegate?.updateScreeningBattery()
    }
    func didUpdateTherapySession(){}
    func didBondFail(){}
    func foundOngoingTherapy(){}
    func pairingTimeExpired() {}
}

extension ScreeningProcessManager: DeviceErrorManagerDelegate{
    func dataRecoveryAvailable() {
    }
    
    func dailyLimitReachedError() {
    }
    
    func batteryLowError() {
        
    }
    
    func impedanceError(imp: TherapyImpError) {
        errorDelegate?.impedanceChange(impChange: imp)
    }
}
