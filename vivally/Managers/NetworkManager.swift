/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

import Network

protocol NetworkManagerDelegate {
    func networkDisconnect()
}

class NetworkManager: NSObject {
    
    static let sharedInstance = NetworkManager()
    var connected = false
    let monitor = NWPathMonitor()
    
    var receiving = false
    var sending = false
    
    var delegate:NetworkManagerDelegate?
    
    //need to send needs to remember after closing
    var needToSend = false
    
    var syncInProgress = false
    
    func setupManager(){
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                Slim.log(level: LogLevel.verbose, category: [.appInfo], "Network Info: Network Connected")
                print("network connected")
                self.connected = true
                
                if UserDefaults.standard.bool(forKey: "loggedIn") && !self.syncInProgress{
                    self.syncInProgress = true
                    self.syncAllData(){
                        self.syncInProgress = false
                    }
                }
            } else{
                Slim.log(level: LogLevel.verbose, category: [.appInfo], "Network Info: Network Unavailable")
                print("no connection")
                self.connected = false
                self.delegate?.networkDisconnect()
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    func checkIfStillSending() -> Bool{     //need to add journal, stimdevice, deviceconfig in case as well
        if StimDataManager.sharedInstance.stimSending ||
            EMGDataManager.sharedInstance.emgSending {
            
            
            return true
        }
        if KeychainManager.sharedInstance.loadAccountData()?.roles.contains("Patient") == true{
            if SessionDataManager.sharedInstance.sessionDataSending{
                return true
            }
        }
        return false
    }
    
    func sendBulkStimAndEMGData(completion:@escaping() -> ()){
        if connected{
            let group = DispatchGroup()
            if !StimDataManager.sharedInstance.stimSending && !EMGDataManager.sharedInstance.emgSending{     //check that sync isn't already being called
                group.enter()
                group.enter()
                StimDataManager.sharedInstance.syncStimData(){
                    group.leave()
                }
                EMGDataManager.sharedInstance.syncEMGData(){
                    group.leave()
                }
            }
            group.notify(queue: DispatchQueue.global()){
                completion()
            }
        }
        else{
            completion()
        }
    }
    
    func sendTherapyOnlyData(completion:@escaping() -> ()){
        if connected{
            if !SessionDataManager.sharedInstance.sessionDataSending{
                let group = DispatchGroup()
                group.enter()
                group.enter()
                EvaluationCriteriaManager.sharedInstance.syncSendEvalData(){
                    print("finished sync Eval data")
                    group.leave()
                }
                SessionDataManager.sharedInstance.syncSendSessionDataData(){
                    print("finished sync session data")
                    group.leave()
                }
                group.notify(queue: DispatchQueue.global()){
                    completion()
                }
            }
        }
        else{
            completion()
        }
    }
    
    func sendJournalData(completion:@escaping() -> ()){
        if connected{
            if !JournalEventsManager.sharedInstance.journalSending{
                JournalEventsManager.sharedInstance.syncSendJournalEventsData(){
                    completion()
                }
            }
        }
        else{
            completion()
        }
    }
    
    func sendJournalFocusData(completion:@escaping() -> ()){
        if connected{
            if !JournalEventFocusPeriodManager.sharedInstance.journalFocusSending{
                JournalEventFocusPeriodManager.sharedInstance.getLatestFocus(){ success, result, errorMessage in
                    completion()
                }
            }
        }
        else{
            completion()
        }
    }
    
    func sendStimConfigData(completion:@escaping() -> ()){
        if connected{
            if !DeviceConfigManager.sharedInstance.deviceConfigSending && !StimDeviceManager.sharedInstance.stimDeviceSending{
                let group = DispatchGroup()
                group.enter()
                group.enter()
                StimDeviceManager.sharedInstance.syncStimDeviceData(){
                    group.leave()
                }
                DeviceConfigManager.sharedInstance.syncSendDeviceConfigData(){
                    group.leave()
                }
                group.notify(queue: DispatchQueue.global()){
                    completion()
                }
            }
        }
        else{
            completion()
        }
    }
    
    func checkRequestAccountClose(completion:@escaping() -> ()){
        if connected && !AccountManager.sharedInstance.requestCloseSending{
            if let requestDD = AccountManager.sharedInstance.checkForCloseAccountRequest(){
                AccountManager.sharedInstance.requestDeletion(requestdd: requestDD){ success, errorMessage in
                    completion()
                }
            }
        }
    }
    
    func checkUpdate() {
        if !OTAManager.sharedInstance.OTAMode{
            let mac = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac
            if  mac != "" {
                OTAManager.sharedInstance.checkVersion(stimDeviceAddress: mac){
                    success, result, errorMessage in
                    if success{
                        OTAManager.sharedInstance.clearAvailable()
                        if result!.ready {
                            
                            if let cloudVersion = result?.firmwareVersion{
                                let currentVersion = BluetoothManager.sharedInstance.informationServiceData.revision
                                if currentVersion.checkIfNewer(upcomingFirmware: cloudVersion){
                                    
                                    OTAManager.sharedInstance.getOTADownload2(guid: result!.guid!.uuidString){ success, errorMessage in
                                        if success{
                                            OTAManager.sharedInstance.setAvailable()
                                            OTAManager.sharedInstance.ota = result
                                            OTAManager.sharedInstance.saveOTAData(data: result ?? OTA())
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateAvailable"), object: nil)
                                        }
                                        else{
                                            Slim.error(errorMessage)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else{
                        Slim.error(errorMessage)
                    }
                }
            }
        }
    }
    
    func syncAllData(completion:@escaping() -> ()){
        if let accountData = KeychainManager.sharedInstance.loadAccountData(){
            let group = DispatchGroup()
            group.enter()
            if accountData.roles.contains("Patient"){
                NotificationManager.sharedInstance.checkIfGelDone()
                NotificationManager.sharedInstance.checkIfTherapyDone()
                NotificationManager.sharedInstance.checkIfJournalDone()
                
                for _ in 1 ... 5 {
                    group.enter()
                }
                
                checkRequestAccountClose(){
                    group.leave()
                }
                sendBulkStimAndEMGData(){
                    group.leave()
                }
                sendJournalData(){
                    group.leave()
                }
                sendTherapyOnlyData(){
                    group.leave()
                }
                sendJournalFocusData(){
                    group.leave()
                }
            }
            sendStimConfigData(){
                group.leave()
            }
            
            group.notify(queue: DispatchQueue.global()){
                completion()
            }
        }
    }
    
    func logoutClear(){
        //clear everything on logout
        ScreeningManager.sharedInstance.clearAccountData()
        ScreeningManager.sharedInstance.clearDemographics()
        ScreeningProcessManager.sharedInstance.resetValues()
        KeychainManager.sharedInstance.clearAccountData()
        LogManager.sharedInstance.clearLogLevels()
        EvaluationCriteriaManager.sharedInstance.clearEvalConfigData()
        JournalEventFocusPeriodManager.sharedInstance.clearFocus()
        
        RefreshManager.sharedInstance.clearLastRefreshTime()
        RefreshManager.sharedInstance.clearFirstLogin()
        RefreshManager.sharedInstance.stopRefreshTimer()
        
        TherapyManager.sharedInstance.stopCheckTherapyTimer()
        ActivityManager.sharedInstance.loggedOut()
        ConversionManager.sharedInstance.clearFluidUnit()
        
        AccountManager.sharedInstance.clearCloseAccountRequest()
    }
    
    func isReceiving(){
        
    }
    
}
