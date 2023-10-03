/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import CoreBluetooth
import SwiftKeychainWrapper

enum TherapyImpError: Int{
    case continuity = 0
    case foot = 1
    case impedance = 2
}

enum therapyFinishStates: Int {
    case complete = 0
    case stopped = 1
    case pauseStop = 2
}

protocol TherapyManagerConnectionDelegate {
    func therapyInProgress(running: Bool)
}

protocol TherapyManagerImpedanceFailDelegate {
    func impedanceChange(impChange: TherapyImpError)
    func dailyLimitReached()
    func invalidScreening()
    func therapySaveFailed()
    func lowBattery()
}

protocol TherapyManagerDelegate {
    func therapyFinished(state: therapyFinishStates)
    func updateBLEData()
    func didConnectToBLEDevice(device: CBPeripheral)
    func didDisconnectFromBLEDevice(device: CBPeripheral)
    func pauseLimitReached()
    func didUpdateStatus()
    func didUpdateDev()
    func didUpdateTherapyBattery()
    func pauseAboutToExpire()
    func pauseExpired()
}

class TherapyManager: NSObject {
    static let sharedInstance = TherapyManager()
    
    var navDelegate:TherapyManagerConnectionDelegate?
    var errorDelegate:TherapyManagerImpedanceFailDelegate?
    
    var therapyRunning = false
    var therapyPaused = false
    var delegate:TherapyManagerDelegate?
    var testTherapy = false
    var timesPaused = 0
    var timeSession = 0.0
    var timeAssigned = false
    var sessionData = SessionData()
    var screeningGuid:UUID? = nil
    var deviceGuid:UUID? = nil
    var pauseSet = false
    var displayPauseExpire = false
    var resumeSet = false
    var pauseLimitReached = false
    var isLeft = false
    var testTherapyFinished = false
    
    var startingTime = Int32(0)
    
    var sessionTimer:Timer?
    var impedanceCheckTimer:Timer?
    
    var checkIfRunningTimer:Timer?
    
    func clearPreferredFoot(){
        UserDefaults.standard.removeObject(forKey: "isPreferredFootLeft")
    }
    
    func savePreferredFoot(foot: Feet){
        isLeft = foot == .left ? true : false
        UserDefaults.standard.set(isLeft, forKey: "isPreferredFootLeft")
    }
    
    func loadPreferredFoot(){
        let userDefaults = UserDefaults.standard
        isLeft =  userDefaults.bool(forKey: "isPreferredFootLeft")
    }
    
    func savePauseState() {
        UserDefaults.standard.set(pauseLimitReached, forKey: "pauseLimitReached")
    }
    
    func loadPauseState() {
        let userPauseState = UserDefaults.standard
        
        pauseLimitReached = userPauseState.bool(forKey: "pauseLimitReached")
    }
    
    func clearPauseState() {
        UserDefaults.standard.removeObject(forKey: "pauseLimitReached")
    }
    
    func resetValues(){
        timesPaused = 0
        therapyRunning = false
        therapyPaused = false
        timeAssigned = false
        timeSession = 0.0
        pauseLimitReached = false
        savePauseState()
        testTherapyFinished = false
        displayPauseExpire = false
        
        StimDataManager.sharedInstance.stimData = StimData()
        startingTime = 0
    }
    func newTherapy(){
        sessionData = SessionData()     //should be able to get rid of this
        let eval = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
        screeningGuid = eval?.screeningGuid
        let dev = DeviceConfigManager.sharedInstance.loadDeviceConfigData()
        deviceGuid = dev?.guid
        resetValues()
    }
    
    func checkBattery(){
        let batteryLowReached = DeviceErrorManager.sharedInstance.insufficientBattery
        if batteryLowReached != nil{
            if batteryLowReached == true{
                errorDelegate?.lowBattery()
            }
        }
    }
    
    func grabLatestSession(){
        if NetworkManager.sharedInstance.connected && !testTherapy{
            EvaluationCriteriaManager.sharedInstance.getEvalCriteriaPatient(){ success, data, errorMessage in
                if success{
                    if data != nil{
                        let allowOverwrite = EvaluationCriteriaManager.sharedInstance.checkEvalCriteriaShouldOverwriteLocal(data: data!)
                        if allowOverwrite{
                            EvaluationCriteriaManager.sharedInstance.saveEvalConfigData(data: data!)
                            EvaluationCriteriaManager.sharedInstance.updateEvalSchedule()
                        }
                        self.preChecks()
                    }
                    else{
                        Slim.info("Successful eval get but data nil")
                        EvaluationCriteriaManager.sharedInstance.clearEvalConfigData()
                        self.errorDelegate?.invalidScreening()
                    }
                }
                else{
                    self.preChecks()
                }
            }
        }
        else{
            preChecks()
        }
    }
    
    func grabPrescriptionInfo(){
        if NetworkManager.sharedInstance.connected && !testTherapy{
            AccountManager.sharedInstance.getMe { success, userModel, errorMessage in
                if success{
                    let accountData = KeychainManager.sharedInstance.loadAccountData()
                    accountData?.userModel = userModel ?? UserModel()
                    accountData?.username = userModel?.username ?? ""
                    KeychainManager.sharedInstance.saveAccountData(data: accountData!)
                    if KeychainManager.sharedInstance.accountData?.userModel?.deviceMode != nil{
                        BluetoothManager.sharedInstance.setMode2()
                        self.grabLatestSession()
                    }
                    else{
                        self.errorDelegate?.invalidScreening()
                        Slim.info("no deviceMode in succesful userModel get")
                    }
                }
                else{
                    self.errorDelegate?.invalidScreening()
                    Slim.info("error with getting userModel")
                }
            }
        }
        else{
            if !testTherapy{
                _ = KeychainManager.sharedInstance.loadAccountData()
                if KeychainManager.sharedInstance.accountData?.userModel?.deviceMode != nil{
                    BluetoothManager.sharedInstance.setMode2()
                    grabLatestSession()
                }
                else{
                    self.errorDelegate?.invalidScreening()
                    Slim.info("no study in cached UserModel before starting Therapy")
                }
            }
            else{
                self.grabLatestSession()
            }
        }
    }
    
    func preChecks(){
        if let eval = EvaluationCriteriaManager.sharedInstance.loadEvalCritData(){
            if !(eval.isValid ?? false){
                errorDelegate?.invalidScreening()
                return
            }
            
            ActivityManager.sharedInstance.stopActivityTimers()
            let foot = isLeft ? Feet.left : Feet.right
            BluetoothManager.sharedInstance.updateScreeningCriteria(foot: foot)
            
            DeviceErrorManager.sharedInstance.resetAll()
            DeviceErrorManager.sharedInstance.impedanceCheckRunning = true
            
            DeviceErrorManager.sharedInstance.checkDailyWeeklyLimits = true
            DeviceErrorManager.sharedInstance.delegate = self
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                self.startTherapy()
            }
        }
        else{
            errorDelegate?.invalidScreening()
        }
    }
    func startDataTimers(){
        StimDataManager.sharedInstance.startStimDataTimer()
    }
    func therapyStarted(){
        therapyRunning = true
        ActivityManager.sharedInstance.stopActivityTimers()
        navDelegate?.therapyInProgress(running: true)
    }
    func startTherapy(){
        newTherapy()
        BluetoothManager.sharedInstance.delegate = self
        BluetoothManager.sharedInstance.readStimStatus()
        BluetoothManager.sharedInstance.readEMGStatus()
        BluetoothManager.sharedInstance.readTherapySession()
        BluetoothManager.sharedInstance.readDevice()
        
        //comment out if testing with someone who has both clinician and admin/patient roles
        dump(KeychainManager.sharedInstance.accountData!.roles)
        if KeychainManager.sharedInstance.accountData!.roles.contains("Clinician") {
            testTherapy = true
        }
        else{ testTherapy = false}
        
        
        if testTherapy {
            BluetoothManager.sharedInstance.sendCommand(command: .startStimTest, parameters: [])
            Slim.log(level: LogLevel.info, category: [.therapy], "Therapy Started")

        }
        else{
            BluetoothManager.sharedInstance.sendCommand(command: .startStim, parameters: [])
            Slim.log(level: LogLevel.info, category: [.therapy], "Therapy Started")

        }
    }
    
    func pauseTherapy(){
        BluetoothManager.sharedInstance.sendCommand(command: .pauseStim, parameters: [])
        Slim.log(level: LogLevel.info, category: [.therapy], "Therapy Paused")

        timesPaused += 1
        
        therapyPaused = true
        NotificationManager.sharedInstance.removeTherapyTimeNotifications(isRunning: true, isPaused: false)
        
        if pauseLimitReached {
            delegate?.pauseLimitReached()
        }
    }
    
    func resumeTherapy(){
        BluetoothManager.sharedInstance.sendCommand(command: .resumeStim, parameters: [])
        Slim.log(level: LogLevel.info, category: [.therapy], "Therapy Resumed")
        therapyPaused = false
        
        NotificationManager.sharedInstance.removeTherapyTimeNotifications(isRunning: false, isPaused: true)
    }
    
    func stopTherapy(){
        BluetoothManager.sharedInstance.sendCommand(command: .stopStim, parameters: [])
        Slim.log(level: LogLevel.info, category: [.therapy], "Therapy Stopped")
        StimDataManager.sharedInstance.stopStimDataTimer()
        
        NetworkManager.sharedInstance.sendBulkStimAndEMGData(){}
        NetworkManager.sharedInstance.sendTherapyOnlyData(){}
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            self.updateStatus()
        }
    }
    
    func checkIfTherapyInProgress(){
        let stim = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        if stim.state != .idle && stim.deviceTime != 0 && stim.mainState == .therapy{
            if stim.state == .running || stim.state == .paused{
                testTherapy = KeychainManager.sharedInstance.accountData!.roles.contains("Clinician") ? true : false
                
                therapyRunning = true
                ActivityManager.sharedInstance.stopActivityTimers()
                BluetoothManager.sharedInstance.delegate?.foundOngoingTherapy()     //new
                
                BluetoothManager.sharedInstance.delegate = self
                setBLEReads()
                
                navDelegate?.therapyInProgress(running: true)
            }
        }
        else{
            startCheckTherapyTimer()
        }
    }
    
    @objc func fireTherapyCheckTimer(){
        let stim = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        if stim.state != .idle && stim.deviceTime != 0 && stim.mainState == .therapy{
                if stim.state == .running || stim.state == .paused{
                    
                    stopCheckTherapyTimer()
                    
                    testTherapy = KeychainManager.sharedInstance.accountData!.roles.contains("Clinician") ? true : false
                    
                    therapyRunning = true
                    ActivityManager.sharedInstance.stopActivityTimers()
                    BluetoothManager.sharedInstance.delegate?.foundOngoingTherapy()
                    
                    BluetoothManager.sharedInstance.delegate = self
                    setBLEReads()
                    
                    navDelegate?.therapyInProgress(running: true)
                }
        }
    }
    
    func startCheckTherapyTimer(){
        stopCheckTherapyTimer()
        checkIfRunningTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(fireTherapyCheckTimer), userInfo: nil, repeats: true)
    }
    func stopCheckTherapyTimer(){
        if checkIfRunningTimer != nil{
            checkIfRunningTimer?.invalidate()
        }
        checkIfRunningTimer = nil
    }
    
    func setBLEReads(){
        BluetoothManager.sharedInstance.readStimStatus()
        BluetoothManager.sharedInstance.readEMGStatus()
        BluetoothManager.sharedInstance.readTherapySession()
        BluetoothManager.sharedInstance.readDevice()
    }
    
    func userStopTherapy(){
        stopTherapy()
        delegate?.therapyFinished(state: .stopped)
        
        //resetValues()
        navDelegate?.therapyInProgress(running: false)
    }
    
    var lastState:StimStatusStates = .idle
    var lastMainState:StimStatusMainState = .idle
    func updateStatus(){
        let stim = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        if stim.mainState == .therapy{
            switch stim.state{
            case .running:
                if !therapyRunning{
                    therapyRunning = true
                    ActivityManager.sharedInstance.stopActivityTimers()
                }
                if !resumeSet {
                    resumeSet = true
                }
                pauseSet = false
                therapyPaused = false
            case .paused:
                if !therapyRunning{
                    therapyRunning = true
                    ActivityManager.sharedInstance.stopActivityTimers()
                }
                if stim.pauseTimeRemaining == 0{
                    stopTherapy()
                    delegate?.therapyFinished(state: .pauseStop)
                    //resetValues()
                }
                else{
                    if !pauseSet{
                        pauseSet = true
                    }
                    if stim.pauseTimeRemaining < 120 && !displayPauseExpire{
                        displayPauseExpire = true
                        delegate?.pauseAboutToExpire()
                    }
                    if stim.pauseTimeRemaining == 0 && displayPauseExpire{
                        delegate?.pauseExpired()
                    }
                }
                
                resumeSet = false
                therapyPaused = true
            case .competed, .stopped, .idle:
                closePopUp() // notify vc to close popup

                if therapyRunning{
                    if !testTherapy{
                        updateEvalCriteria(tempPainThreshold: stim.tempPainThreshold, currentTick: stim.currentTick, dailyTherapyTime: stim.dailyTherapyTime, lastCompletedTime: stim.lastCompletedTime)
                    }
                    
                    therapyRunning = false
                    StimDataManager.sharedInstance.stopStimDataTimer()
                    NetworkManager.sharedInstance.sendBulkStimAndEMGData(){}
                    NetworkManager.sharedInstance.sendTherapyOnlyData(){}
                    
                    if stim.state == .competed{
                        if testTherapy{
                            testTherapyFinished = true
                        }
                        delegate?.therapyFinished(state: .complete)
                        NotificationManager.sharedInstance.resetTherapyNotify()
                    }
                    NotificationManager.sharedInstance.removeTherapyTimeNotifications(isRunning: true, isPaused: true)
                }
            }
        }
        else {
            if therapyRunning{
                if !testTherapy{
                    updateEvalCriteria(tempPainThreshold: stim.tempPainThreshold, currentTick: stim.currentTick, dailyTherapyTime: stim.dailyTherapyTime, lastCompletedTime: stim.lastCompletedTime)
                }
                therapyRunning = false
                StimDataManager.sharedInstance.stopStimDataTimer()
                NetworkManager.sharedInstance.sendBulkStimAndEMGData(){}
                NetworkManager.sharedInstance.sendTherapyOnlyData(){}
                resetValues()
                
                if stim.state == .competed{
                    delegate?.therapyFinished(state: .complete)
                }
                NotificationManager.sharedInstance.removeTherapyTimeNotifications(isRunning: true, isPaused: true)
            }
        }
        
    }
    
    func handleTherapyPost(sessionDataPost: SessionData){
        if NetworkManager.sharedInstance.connected{
            SessionDataManager.sharedInstance.postSessionData(sessionData: sessionDataPost){ success, errorMessage, last in
                if success{
                    print("success session post")
                    sessionDataPost.dirty = false
                    do{
                        _ = try SessionDataDataHelper.update(item: sessionDataPost)
                    } catch{ print("fail with local update")}
                }
                else{
                    print(errorMessage)
                }
            }
        }
    }
    func handleTherapyPut(sessionDataPut: SessionData){
        if NetworkManager.sharedInstance.connected{
            SessionDataManager.sharedInstance.putSessionData(sessionData: sessionDataPut){ success, result, errorMessage, last in
                if success{
                    print("success session put")
                    sessionDataPut.dirty = false
                    do{
                        _ = try SessionDataDataHelper.update(item: sessionDataPut)
                    } catch{ print("fail with local update")}
                }
                else{
                    print("failed Therapy cloud put: \(errorMessage)")
                }
            }
        }
    }
   
    func handleTherapySession(session: TherapySession){
        let addStr = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac
        let addArr: [UInt8] = Array(addStr.utf8)
        BluetoothManager.sharedInstance.sendCommand(command: .sessionStatusAck, parameters: addArr)
        
        if session.isNewSession == 1{
            if let username = testTherapy ? ScreeningManager.sharedInstance.patientData?.email : KeychainManager.sharedInstance.loadAccountData()?.username{
                do{
                    if let latest = try SessionDataDataHelper.getLatestRunning(startingTime: session.startTime,name: username){
                        if latest.timestamp == SessionData().timestamp || latest.startTime == session.startTime{
                            return
                        }
                    }
                }
                catch{
                    Slim.info("failed to get latest therapy")
                }
                Slim.info("new therapy session started")
                var evalGuid:UUID? = nil
                if let sessionFoot = Feet(rawValue: Int32(session.foot)){
                    let therapyEval = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
                    if sessionFoot == .left{
                        evalGuid = therapyEval?.left?.guid
                    }
                    else if sessionFoot == .right{
                        evalGuid = therapyEval?.right?.guid
                    }
                    
                    let newSession = SessionData()
                    newSession.dirty = true
                    newSession.modified = Date()
                    newSession.deviceConfigurationGuid = deviceGuid
                    newSession.startTime = Int(session.startTime)
                    newSession.isComplete = (session.isComplete != 0)
                    newSession.pauseCount = Int(session.pauseCount)
                    newSession.duration = Int(session.duration)
                    newSession.detectedEMGCount = Int(session.detectedEMGCount)
                    newSession.avgEMGStrength = Int(session.avgEMGStrength)
                    newSession.avgStimPulseWidth = Int(session.avgStimPulseWidth)
                    newSession.maxStimPulseWidth = Int(session.maxStimPulseWidth)
                    newSession.overallAvgImpedance = Int(session.overallAvgImpedance)
                    newSession.batteryLevelAtStart = Int(session.batteryLevelAtStart)
                    newSession.evaluationCriteriaGuid = evalGuid
                    newSession.username = username
                    newSession.isTestSession = testTherapy
                    
                    sessionData.guid = newSession.guid
                    
                    //save to local then trigger post immediately
                    do{
                        _ = try SessionDataDataHelper.insert(item: newSession)
                        therapyStarted()
                        handleTherapyPost(sessionDataPost: newSession)
                        
                    } catch{
                        print("fail to insert therapy session")
                    }
                }
            }
        }
        else{
            if session.startTime == 0{
                return
            }
            if let username = testTherapy ? ScreeningManager.sharedInstance.patientData?.email : KeychainManager.sharedInstance.loadAccountData()?.username{
                do{
                    if let latestSession = try SessionDataDataHelper.getLatestRunning(startingTime:session.startTime, name: username){
                        latestSession.dirty = true
                        latestSession.modified = Date()
                        latestSession.deviceConfigurationGuid = deviceGuid
                        latestSession.startTime = Int(session.startTime) == 0 ? latestSession.startTime : Int(session.startTime)
                        latestSession.isComplete = (session.isComplete != 0) ? true : latestSession.isComplete
                        latestSession.pauseCount = Int(session.pauseCount) == 0 ? latestSession.pauseCount : Int(session.pauseCount)
                        latestSession.duration = Int(session.duration) == 0 ? latestSession.duration : Int(session.duration)
                        latestSession.detectedEMGCount = Int(session.detectedEMGCount)  == 0 ? latestSession.detectedEMGCount : Int(session.detectedEMGCount)
                        latestSession.avgEMGStrength = Int(session.avgEMGStrength)  == 0 ? latestSession.avgEMGStrength : Int(session.avgEMGStrength)
                        latestSession.avgStimPulseWidth = Int(session.avgStimPulseWidth)  == 0 ? latestSession.avgStimPulseWidth : Int(session.avgStimPulseWidth)
                        latestSession.maxStimPulseWidth = Int(session.maxStimPulseWidth)  == 0 ? latestSession.maxStimPulseWidth : Int(session.maxStimPulseWidth)
                        latestSession.overallAvgImpedance = Int(session.overallAvgImpedance)  == 0 ? latestSession.overallAvgImpedance : Int(session.overallAvgImpedance)
                        latestSession.batteryLevelAtStart = Int(session.batteryLevelAtStart)  == 0 ? latestSession.batteryLevelAtStart : Int(session.batteryLevelAtStart)
                        
                        _ = try SessionDataDataHelper.update(item: latestSession)
                        handleTherapyPut(sessionDataPut: latestSession)
                    }
                } catch{
                    print("fail with getting latest session")
                }
            }
        }
    }
    
    func updateEvalCriteria(tempPainThreshold: Int32, currentTick: Int8, dailyTherapyTime: Int16, lastCompletedTime: Int32){
        let patientEvalCrit = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
        
        let evalCrit = isLeft ? patientEvalCrit?.left : patientEvalCrit?.right
        if evalCrit != nil{
            evalCrit?.tempPainThreshold = Int(tempPainThreshold)
            evalCrit?.currentTick = Int(currentTick)
            evalCrit?.dailyTherapyTime = Int(dailyTherapyTime)
            evalCrit?.lastCompletedTime = Int(lastCompletedTime)
            
            evalCrit?.screeningGuid = screeningGuid               //shouldn't be needed since fixing save evalconfig
            evalCrit?.deviceConfigurationGuid = deviceGuid
            evalCrit?.modified = Date()
            Slim.info("Update to cloud Eval: guid: \(evalCrit?.guid), currentTick: \(evalCrit?.currentTick), lastCompletedTime: \(evalCrit?.lastCompletedTime)")
            
            if isLeft{
                let leftEval = evalCrit
                patientEvalCrit?.left = leftEval
                if let rightEval = patientEvalCrit?.right{
                    rightEval.lastCompletedTime = leftEval?.lastCompletedTime ?? 0
                    rightEval.dailyTherapyTime = leftEval?.dailyTherapyTime ?? 0
                    patientEvalCrit?.right = rightEval
                    patientEvalCrit?.right?.modified = Date()
                    if NetworkManager.sharedInstance.connected{
                        EvaluationCriteriaManager.sharedInstance.putEvalCriteria(evaluationCriteria: rightEval){ success, result, errorMessage in
                            if success{
                                print("update Eval Criteria from Therapy")
                            }
                            else{
                                Slim.error("Fail to update eval criteria")
                            }
                        }
                    }
                }
            }
            else{
                let rightEval = evalCrit
                patientEvalCrit?.right = rightEval
                if let leftEval = patientEvalCrit?.left{
                    leftEval.lastCompletedTime = rightEval?.lastCompletedTime ?? 0
                    leftEval.dailyTherapyTime = rightEval?.dailyTherapyTime ?? 0
                    patientEvalCrit?.left = leftEval
                    patientEvalCrit?.left?.modified = Date()
                    if NetworkManager.sharedInstance.connected{
                        EvaluationCriteriaManager.sharedInstance.putEvalCriteria(evaluationCriteria: leftEval){ success, result, errorMessage in
                            if success{
                                print("update Eval Criteria from Therapy")
                            }
                            else{
                                Slim.error("Fail to update eval criteria")
                            }
                        }
                    }
                }
            }
            EvaluationCriteriaManager.sharedInstance.saveEvalConfigData(data: patientEvalCrit!)
            
            if NetworkManager.sharedInstance.connected{
                EvaluationCriteriaManager.sharedInstance.putEvalCriteria(evaluationCriteria: evalCrit!){ success, result, errorMessage in
                    if success{
                        print("update Eval Criteria from Therapy")
                    }
                }
            }
        }
    }
    
    func updateDeviceData(){
        if !pauseLimitReached && therapyRunning{
            if DeviceErrorManager.sharedInstance.pauselimitReached == true{
                pauseLimitReached = true
                savePauseState()
                delegate?.pauseLimitReached()
            }
        }
    }
    
    func prepStimData() {
        if therapyRunning{
            let stimData = StimData()
            let oldStimData = StimDataManager.sharedInstance.stimData
            stimData.screeningGuid = screeningGuid
            
            let stimStatus = BluetoothManager.sharedInstance.informationServiceData.stimStatus
            
            stimData.dirty = true
            stimData.modified = Date()
            stimData.sessionGuid = sessionData.guid
            stimData.state = stimStatus.state.rawValue
            stimData.runningState = stimStatus.runningState.rawValue
            stimData.deviceTime = Int32(stimStatus.deviceTime) == 0 ? 0 : Int32(stimStatus.deviceTime)
            stimData.timeRemaining = stimStatus.timeRemaining == 0 ? oldStimData.timeRemaining : stimStatus.timeRemaining
            stimData.pauseTimeRemaining = stimStatus.pauseTimeRemaining == 0 ? oldStimData.pauseTimeRemaining : stimStatus.pauseTimeRemaining
            stimData.event  = stimStatus.event
            stimData.currentAmplitude  = stimStatus.amplitude == 0 ? oldStimData.currentAmplitude : stimStatus.amplitude
            stimData.percentEMGDetect  = stimStatus.percentageEMGDetection == 0 ? oldStimData.percentEMGDetect : stimStatus.percentageEMGDetection
            stimData.percentNoiseDetect  = stimStatus.percentagePulsesEMGNoisy == 0 ? oldStimData.percentNoiseDetect : stimStatus.percentagePulsesEMGNoisy
            stimData.emgDetected  = stimStatus.emgDetected ?  1 : (oldStimData.emgDetected)
            stimData.emgTarget  = Int32(stimStatus.emgTarget) == 0 ? oldStimData.emgTarget : Int32(stimStatus.emgTarget)
            stimData.pulseWidth  = stimStatus.pulseWidth == 0 ? oldStimData.pulseWidth : stimStatus.pulseWidth
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
            stimData.errorCodes = Int32(stimStatus.errorCodes) == 0 ? oldStimData.errorCodes : Int32(stimStatus.errorCodes)
            stimData.temperature = stimStatus.temperature == 0 ? oldStimData.temperature : stimStatus.temperature
            stimData.rawADCAtStimPulse = stimStatus.rawADCAtStimPulse == 0 ? oldStimData.rawADCAtStimPulse : stimStatus.rawADCAtStimPulse
        
            StimDataManager.sharedInstance.stimData = stimData
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
    
    func assignTimeSession(){
        if !timeAssigned && therapyRunning{
            let temp = Double(BluetoothManager.sharedInstance.informationServiceData.stimStatus.timeRemaining)
            if temp != 0{
                timeSession = temp
                timeAssigned = true
            }
        }
    }
    
    func checkStimStatus(stimStatus: StimulationStatus, startingTime: Int32 = 0){
        if (stimStatus.state == .competed || stimStatus.state == .stopped || stimStatus.state == .idle) && therapyRunning{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
                do{
                    let user = KeychainManager.sharedInstance.loadAccountData()?.username ?? ""
                    if let latestSession = try SessionDataDataHelper.getLatestRunning(startingTime: startingTime, name: user){
                        if latestSession.duration == 0{
                            //manual update therapy session
                            let manualTherapySession = SessionData()
                            manualTherapySession.startTime = (latestSession.startTime)
                            manualTherapySession.isComplete = stimStatus.state == .competed || stimStatus.timeRemaining < 3
                            manualTherapySession.pauseCount = try StimDataDataHelper.getPauseCount(sessGuid: latestSession.guid.uuidString)
                            manualTherapySession.duration = Int(stimStatus.deviceTime - startingTime)
                            manualTherapySession.detectedEMGCount = try StimDataDataHelper.getEMGCount(sessGuid: latestSession.guid.uuidString)
                            manualTherapySession.avgEMGStrength = Int(stimStatus.emgStrengthAvg)
                            manualTherapySession.avgStimPulseWidth = Int(stimStatus.pulseWidthAvg)
                            manualTherapySession.maxStimPulseWidth = Int(stimStatus.pulseWidthMax)
                            manualTherapySession.overallAvgImpedance = Int(stimStatus.impedanceStimAvg)
                            manualTherapySession.batteryLevelAtStart = latestSession.batteryLevelAtStart
                            manualTherapySession.deviceConfigurationGuid = latestSession.deviceConfigurationGuid
                            manualTherapySession.evaluationCriteriaGuid = latestSession.evaluationCriteriaGuid
                            manualTherapySession.username = user
                            manualTherapySession.isTestSession = self.testTherapy
                        }
                    }
                    else{
                        Slim.error("latest Session returned nil")
                        self.errorDelegate?.therapySaveFailed()
                        self.stopTherapy()
                    }
                }
                catch{
                    Slim.error("Error with getting latest session")
                    self.errorDelegate?.therapySaveFailed()
                    self.stopTherapy()
                }
            }
        }
    }
}


extension TherapyManager: BluetoothManagerDelegate{
    func didUpdateDevice() {
        updateDeviceData()
        delegate?.didUpdateDev()
    }
    
    func didUpdateData() {
        assignTimeSession()
        delegate?.updateBLEData()
        //updateDeviceData()
    }
    
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {
        
    }
    
    func didConnectToDevice(device: CBPeripheral) {
        delegate?.didConnectToBLEDevice(device: device)
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        delegate?.didDisconnectFromBLEDevice(device: device)
        
        DeviceErrorManager.sharedInstance.resetAll()
        
        if therapyRunning{
            let stimGuid = StimDataManager.sharedInstance.stimData.guid
            DataRecoveryManager.sharedInstance.saveTimestampStimGuid(guid: stimGuid)
        }
        TherapyManager.sharedInstance.therapyRunning = false
        ActivityManager.sharedInstance.resetInactivityCount()
    }
    func didBLEChange(on: Bool){}
    func didUpdateStimStatus(){
        updateStatus()
        
        let stimStatus = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        let username = testTherapy ? ScreeningManager.sharedInstance.patientData?.email ?? "" : KeychainManager.sharedInstance.accountData?.username ?? ""
        if username != ""{
            StimDataManager.sharedInstance.handleStimStatus(startingTime: startingTime, stimStatus: stimStatus, screenGuid: screeningGuid, user: username)
            
            checkStimStatus(stimStatus: stimStatus)
        }
        
        delegate?.didUpdateStatus()
    }
    func didUpdateEMG() {
        let emgStatus = BluetoothManager.sharedInstance.informationServiceData.emgStatus
        let username = testTherapy ? ScreeningManager.sharedInstance.patientData?.email ?? "" : KeychainManager.sharedInstance.accountData?.username ?? "" // should add checks
        if username != ""{
            EMGDataManager.sharedInstance.handleEMGStatus(startingTime: startingTime, status: emgStatus, screenGuid: screeningGuid, user: username)
        }
    }
    func didUpdateBattery(){
        delegate?.didUpdateTherapyBattery()
    }
    func didUpdateTherapySession(){
        
        let therapySession = BluetoothManager.sharedInstance.informationServiceData.therapySession
        //handleTherapySession(session: therapySession)
        startingTime = therapySession.startTime
        Slim.log(level: LogLevel.warning, category: [.appEvents], "Received a session from the controller with a start time of \(startingTime)")
    }
    
    func closePopUp() {
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.closePopup.rawValue), object: nil)
    }
    
    func didBondFail(){}
    
    func foundOngoingTherapy(){}
    func pairingTimeExpired() {}
}

extension TherapyManager: DeviceErrorManagerDelegate{
    func impedanceError(imp: TherapyImpError) {
        errorDelegate?.impedanceChange(impChange: imp)
    }
    
    func dataRecoveryAvailable() {}
    
    func dailyLimitReachedError() {
        errorDelegate?.dailyLimitReached()
        Slim.log(level: LogLevel.error, category: [.therapy], "Daily Limit Reached")
    }
    
    func batteryLowError() {
        errorDelegate?.lowBattery()
        Slim.log(level: LogLevel.error, category: [.deviceInfo], "Low Battery Level")
    }
    
    
}
