/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import SwiftKeychainWrapper

class DeviceConfigManager: NSObject {
    static let sharedInstance = DeviceConfigManager()

    var deviceConfig:DeviceConfig?
    
    func clearDeviceConfigData(){
        UserDefaults.standard.removeObject(forKey: "deviceConfig")
    }
    func loadDeviceConfigData() -> DeviceConfig?{
        var data = DeviceConfig()
        if let deviceConfigDataObject = UserDefaults.standard.data(forKey: "deviceConfig"){
            do{
                let decoder = JSONDecoder()
                    data = try decoder.decode(DeviceConfig.self, from: deviceConfigDataObject)
            }catch _{
                
                Slim.info("Device Config Data Defaulting because decode fails with error")
                saveDeviceConfigData(data: DeviceConfig())
                return DeviceConfig()
            }
        }
        else{
            Slim.info("Device Config Data Defaulting because device config object not found")
            saveDeviceConfigData(data: DeviceConfig())
        }
        return data
    }
    func saveDeviceConfigData(data:DeviceConfig){
        do{
            let encoder = JSONEncoder()
            let ddo = try encoder.encode(data)
            UserDefaults.standard.set(ddo, forKey: "deviceConfig")
        } catch{
            print("unable to save device config data")
        }
    }
    
    func postDeviceConfig(deviceConfig:DeviceConfig, isLast: Bool = false, completion:@escaping (Bool, DeviceConfig?, String, Bool) -> ()) {
        APIClient.postDeviceConfig(deviceConfig: deviceConfig){ success, result, errorMessage, authorized in
            if success{
                completion(true, result, errorMessage, isLast)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, result, errorMessage, isLast)
            }
        }
    }
    
    
    /*
    func checkForNewDeviceConfig(){
        if UserDefaults.standard.bool(forKey: "loggedIn"){
            let screening = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
            let mac = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac
            let firmwareVer = BluetoothManager.sharedInstance.informationServiceData.revision.rev
            let appVer = (UIApplication.appVersion ?? "") + "." + (UIApplication.build ?? "")
            let appDevice = AppManager.sharedInstance.loadAppDeviceData()
            let serial = BluetoothManager.sharedInstance.informationServiceData.serialNumber.serialNum
            //let appDeviceGuid = AppManager.sharedInstance.appDeviceData?.guid
            
            let stimDevice = StimDevice()
            stimDevice.address = mac
            stimDevice.serialNumber = String(format: "%06d", serial)
            //always send when connecting
            StimDeviceManager.sharedInstance.postStimDevice(stimDevice: stimDevice) { success, result, errorMessage in
                if success{
                    StimDeviceManager.sharedInstance.saveStimDeviceData(data: stimDevice)
                    let newDeviceConfig = DeviceConfig()
                    newDeviceConfig.stimDeviceGuid = stimDevice.guid
                    newDeviceConfig.screeningGuid = screening?.screeningGuid
                    newDeviceConfig.firmwareVersion = firmwareVer
                    newDeviceConfig.appVersion = appVer
                    newDeviceConfig.appDeviceGuid = appDevice?.guid
                    self.postDeviceConfig(deviceConfig: newDeviceConfig){ success2, result2, errorMessage2 in
                        if success2{
                            //self.saveDeviceConfigData(data: newDeviceConfig)
                            
                            NetworkManager.sharedInstance.checkUpdate()
                        }
                    }
                }
            }
        }
    }
    */
    
    //need to have table of device configs to send up for cases where user isn't connected to internet
    func checkForNewDeviceConfig2(){
        let ref = KeychainManager.sharedInstance.loadAccountData()?.refreshToken
        if ref == nil || ref == ""{
            return
        }
        
        let screening = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
        let mac = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac
        let firmwareVer = BluetoothManager.sharedInstance.informationServiceData.revision.rev
        let appVer = (UIApplication.appVersion ?? "") + "." + (UIApplication.build ?? "")
        let appDevice = AppManager.sharedInstance.loadAppDeviceData()
        let serial = BluetoothManager.sharedInstance.informationServiceData.serialNumber.serialNum
        
        let stimDevice = StimDevice()
        stimDevice.address = mac
        stimDevice.serialNumber = String(format: "%06d", serial)
        
        let newDeviceConfig = DeviceConfig()
        newDeviceConfig.stimDeviceGuid = stimDevice.guid
        newDeviceConfig.screeningGuid = screening?.screeningGuid
        newDeviceConfig.firmwareVersion = firmwareVer
        newDeviceConfig.appVersion = appVer
        newDeviceConfig.appDeviceGuid = appDevice?.guid
        
        do {
            stimDevice.dirty = true
            _ = try StimDeviceDataHelper.insert(item: stimDevice)
            StimDeviceManager.sharedInstance.saveStimDeviceData(data: stimDevice)
            newDeviceConfig.dirty = true
            _ = try DeviceConfigDataHelper.insert(item: newDeviceConfig)
            DeviceConfigManager.sharedInstance.saveDeviceConfigData(data: newDeviceConfig)
            
            NetworkManager.sharedInstance.sendStimConfigData {
                if NetworkManager.sharedInstance.connected{
                    NetworkManager.sharedInstance.checkUpdate()
                }
            }
            
        } catch{
            Slim.error("error with inserting stim/device config")
        }
    }
    //for now under assumption of always sending device config after stim, though that might change
    
    var deviceConfigSending = false
    func syncSendDeviceConfigData(completion:@escaping() -> ()){
        do {
            let leftToSend = try DeviceConfigDataHelper.getLatestLeftToSend()
            if leftToSend.isEmpty{
                deviceConfigSending = false
                completion()
                return
            }
            deviceConfigSending = true
            var isLast = false
            var index = 0
            for dc in leftToSend{
                isLast = index == leftToSend.count - 1
                
                postDeviceConfig(deviceConfig: dc, isLast: isLast){ success, result, errorMessage, wasLast in
                    if success{
                        do{
                            try DeviceConfigDataHelper.setSentClean(sentDeviceConfig: dc)
                        } catch{
                            Slim.error("error with setting sent device config clean")
                        }
                        
                    }
                    if wasLast{
                        self.deviceConfigSending = false
                        do{
                            try DeviceConfigDataHelper.clearClean()
                        } catch{
                            Slim.error("error with deleteing clean device configs")
                        }
                        completion()
                    }
                }
                index += 1
            }
        } catch{
            Slim.error("error with device config db getting left to send")
            completion()
        }
    }
}


