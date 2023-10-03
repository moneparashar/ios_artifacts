/*
 * Copyright 2022, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation
import CoreBluetooth

protocol DataRecoveryManagerDelegate{
    func dataRecoveryProgressUpdated()
    func dataRecoveryFinished(noError: Bool)
}


class DataRecoveryManager: NSObject{
     static let sharedInstance = DataRecoveryManager()
    
    var recoveryAvailable = false
    var delegate: DataRecoveryManagerDelegate?
    var showPopup = true
    var progress: Double? = nil
    
    var stimProgress:Double? = nil
    var emgProgress:Double? = nil
    
    var startedDataRecovery = false
    var startingTime = Int32(0)
    
    var runningRecovery = false
    var recoveryComplete = false
    
    var lastRecordedTime: Int32?
    var lastStimDataUUID: UUID?
    
    var recoverTimer:Timer?
    
    func recoverData(){
        _ = KeychainManager.sharedInstance.loadAccountData()
        TherapyManager.sharedInstance.stopCheckTherapyTimer()
        emgIndexCount = 0
        startedDataRecovery = false
        BluetoothManager.sharedInstance.delegate = self
        getLatestGuidAndStartingTime()
        
        BluetoothManager.sharedInstance.readEMGStatus()
        BluetoothManager.sharedInstance.readStimStatus()
        BluetoothManager.sharedInstance.readTherapySession()
        BluetoothManager.sharedInstance.readDevice()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){      //may shorten time
            if self.lastRecordedTime != nil{
                
                let unArg = withUnsafeBytes(of: self.lastRecordedTime!.littleEndian, Array.init)
                var par:[UInt8] = []
                for un in unArg{
                    par.append(UInt8(un))
                }
                
                self.startInactiveRecoverTimerCheck()
                self.startedDataRecovery = true
                BluetoothManager.sharedInstance.sendCommand(command: .startDataRecovery, parameters: par)
                
                self.runningRecovery = true
            }
        }
    }
    
    func startInactiveRecoverTimerCheck(){
        stopInactiveRecover()
        recoverTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(inactiveRecover), userInfo: nil, repeats: false)
    }
    
    func stopInactiveRecover(){
        if recoverTimer != nil {
            recoverTimer?.invalidate()
        }
        recoverTimer = nil
    }
    
    @objc func inactiveRecover(){
        delegate?.dataRecoveryFinished(noError: false)
        runningRecovery = false
        ActivityManager.sharedInstance.resetInactivityCount()
    }
    
    var emgIndexCount = 0       //may change this
    func emgUpdated(){
        //print("emg: \(BluetoothManager.sharedInstance.informationServiceData.emgStatus.index)")
        if startedDataRecovery{
            stopInactiveRecover()
            let status = BluetoothManager.sharedInstance.informationServiceData.emgStatus
            emgIndexCount += 1
            if Int(status.index) % 10 == 0 {
                //let calcProgress = Double((Double(status.index) / 2400) * 100)
                let calcProgress = ((Double(emgIndexCount)) / 2400) * 100
                emgProgress = calcProgress.isNaN ? 0 : calcProgress
                progress = (emgProgress ?? 0) + (stimProgress ?? 0)
                delegate?.dataRecoveryProgressUpdated()
            }
            
            let username = KeychainManager.sharedInstance.accountData!.username
            EMGDataManager.sharedInstance.handleEMGStatus(startingTime: startingTime, status: status, screenGuid: screeningGuid, user: username)
        }
    }
     
    func stimUpdated(){
        //print("stim: \(BluetoothManager.sharedInstance.informationServiceData.stimStatus.timeRemaining)")
        if startedDataRecovery{
            stopInactiveRecover()
            let status = BluetoothManager.sharedInstance.informationServiceData.stimStatus
            if Int(status.timeRemaining) % 10 == 0{
                let calcProgress = (((Double(status.timeRemaining) - 1800) / (-2400)) * 100)
                //let calcProgress = (((Double(status.timeRemaining) - 2400) / (-2400)) * 100)
                stimProgress = calcProgress.isNaN ? 0 : calcProgress
                progress = (emgProgress ?? 0) + (stimProgress ?? 0)
                delegate?.dataRecoveryProgressUpdated()
            }
            
            let username = KeychainManager.sharedInstance.accountData!.username
            StimDataManager.sharedInstance.handleStimStatus(startingTime: startingTime, stimStatus: status, screenGuid: screeningGuid, user: username)
        }
    }
    
    func therapySessionUpdated(){
        if startedDataRecovery{
            stopInactiveRecover()
            print("therapySession updated & started Data Recovery")
            Slim.log(level: LogLevel.info, category: [.therapy], "Therapy Session updated and started Data Recovery")
            
            let therapySession = BluetoothManager.sharedInstance.informationServiceData.therapySession
            startingTime = therapySession.startTime
            handleTherapySession(session: therapySession)
            BluetoothManager.sharedInstance.sendCommand(command: .clearDataRecovery, parameters: [])
            startedDataRecovery = false
            removeRecovery()
            delegate?.dataRecoveryFinished(noError: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                NetworkManager.sharedInstance.sendBulkStimAndEMGData(){}
                NetworkManager.sharedInstance.sendTherapyOnlyData(){}
            }
        }
    }
    
    func handleTherapySession(session: TherapySession){
        let deviceGuid = DeviceConfigManager.sharedInstance.loadDeviceConfigData()?.guid
        
        if session.isNewSession == 1{
            let username = KeychainManager.sharedInstance.accountData!.username
            do{
                if let latest = try SessionDataDataHelper.getLatestRunning(startingTime: session.startTime,name: username){
                    if latest.timestamp == SessionData().timestamp{
                        return
                    }
                }
            }
            catch{
                Slim.info("failed to get latest therapy via recovery new session")
            }
            Slim.info("new therapy session started via recovery new session")
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
                
                //save to local then trigger post immediately
                do{
                    _ = try SessionDataDataHelper.insert(item: newSession)
                    TherapyManager.sharedInstance.handleTherapyPost(sessionDataPost: newSession)
                    
                } catch{
                    print("fail to insert therapy session via recovery new session")
                }
            }
        }
        else{
            Slim.info("therapy session updated via recovery")
            if session.startTime == 0 {
                return
            }
            
            let username = KeychainManager.sharedInstance.loadAccountData()?.username ?? " "
            do{
                if let latestSession = try SessionDataDataHelper.getLatestRunning(startingTime: session.startTime, name: username){
                    
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
                    TherapyManager.sharedInstance.handleTherapyPut(sessionDataPut: latestSession)
                }
            } catch{
                Slim.error("fail with getting latest session via recovery")
            }
        }
    }
    
    var screeningGuid:UUID?
    func getLatestGuidAndStartingTime(){
        screeningGuid = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()?.screeningGuid
        do{
            let lastStartTime = try SessionDataDataHelper.getLatestStartTime(name: KeychainManager.sharedInstance.accountData?.username ?? "")
            startingTime = Int32(lastStartTime ?? 0)
        } catch{
            print("Couldn't find latest start time")
        }
    }
    
    func saveTimestampStimGuid(guid: UUID){
        let timestamp = Int32(BluetoothManager.sharedInstance.informationServiceData.time)
        let userDefaults = UserDefaults.standard
        userDefaults.set(timestamp, forKey: "TherapyDisconnectTimestamp")
        let guidData = Data(from: guid)
        userDefaults.set(guidData, forKey: "stimGuidRecovery")
    }
    
    func deleteTimestamp(){
        let userdefaults = UserDefaults.standard
        userdefaults.removeObject(forKey: "TherapyDisconnectTimestamp")
        userdefaults.removeObject(forKey: "stimGuidRecovery")
        lastRecordedTime = nil
        recoveryAvailable = false
    }
    
    func timeStampAvailable() -> Int32?{
        let userdefaults = UserDefaults.standard
        /*
        if let timestampData = userdefaults.data(forKey: "TherapyDisconnectTimestamp"){
            let timestamp = UInt32(timestampData.to(type: UInt32.self))
            lastRecordedTime = timestamp
            if let lastStimData = userdefaults.data(forKey: "stimGuidRecovery"){
                lastStimDataUUID = UUID(uuidString: String(decoding: lastStimData, as: UTF8.self))
                return timestamp
            }
        }
        */
        if let timestamp = userdefaults.object(forKey: "TherapyDisconnectTimestamp") as? Int32{
            lastRecordedTime = timestamp
            if let lastStimData = userdefaults.data(forKey: "stimGuidRecovery"){
                lastStimDataUUID = UUID(uuidString: String(decoding: lastStimData, as: UTF8.self))
                return timestamp
            }
        }
        
        return nil
    }
    
    func removeRecovery(){
        Slim.log(level: LogLevel.info, category: [.therapy], "Data Recovery Information: User Deleting Recovery Data")
        recoveryAvailable = false
        deleteTimestamp()
        
        runningRecovery = false
        
        progress = nil
        stimProgress = nil
        emgProgress = nil
        
        startedDataRecovery = false
        startingTime = Int32(0)
        
        lastRecordedTime = nil
        lastStimDataUUID = nil
    }
}

extension DataRecoveryManager: BluetoothManagerDelegate{
    func didUpdateDevice() {}
    
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {}
    
    func didConnectToDevice(device: CBPeripheral) {}
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        // in the case delegate is still running, check if data recovery did not complete before executing recovery fail logic
        if !recoveryComplete{
            delegate?.dataRecoveryFinished(noError: false)
            runningRecovery = false
            ActivityManager.sharedInstance.resetInactivityCount()
        }
        
        recoveryComplete = false // reset
    }
    
    func didBLEChange(on: Bool) {}
    
    func didUpdateData() {}
    
    func didUpdateStimStatus() {
        stimUpdated()
    }
    
    func didUpdateEMG() {
        emgUpdated()
    }
    
    func didUpdateBattery(){}
    
    func didUpdateTherapySession() {
        print("updated therapy session")
        therapySessionUpdated()
    }
    
    func didBondFail() {}
    
    func foundOngoingTherapy() {}
    func pairingTimeExpired() {}
}
