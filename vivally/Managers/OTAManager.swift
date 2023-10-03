/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum OTAStates {
    case requestingReboot
    case rebooting
    case searching
    case connected
    case flashing
    case completed
    case failed
    case idle
}

protocol OTAManagerDelegate {
    func stateUpdated()
}

protocol OTAUpdateAvailableDelegate{
    func updateAvailable(available: Bool)
}

class OTAManager: NSObject {
    static let sharedInstance = OTAManager()
        
    var updateRunning = false
    var ota:OTA?
    var delegate:OTAManagerDelegate? = nil
    var updateAvailableDelegate:OTAUpdateAvailableDelegate? = nil
    var OTAMode = false
    var otaFileUploadFinishedReceived = false
    var updateAvailable = false
    var state:OTAStates = .idle
    var progress:Double? = nil
    var otaMACAddress = ""
    var oldMac = ""
    var oldDevice: BluetoothDeviceInfo?
    
    //for recovery
    var recovery = false
    
    var otaIgnoreBLEChanges = false
    
    func setupManager(){
        do{
            OTAMode = UserDefaults.standard.bool(forKey: "otaMode")
            recovery = OTAMode  //new
            ota = loadOTAData()
            updateAvailable = ota?.ready == true
        }
    }
    
    func loadOTAData() -> OTA?{
        var data = OTA()
        if let otaDataObject = UserDefaults.standard.data(forKey: "ota"){
            do{
                let decoder = JSONDecoder()
                data = try decoder.decode(OTA.self, from: otaDataObject)
            } catch _{
            saveOTAData(data: OTA())
            return OTA()
            }
        }
        else{
            saveOTAData(data: OTA())
        }
        return data
    }
    
    func saveOTAData(data: OTA){
        do{
            let encoder = JSONEncoder()
            let odo = try encoder.encode(data)
            UserDefaults.standard.set(odo, forKey: "ota")
            ota = data
        } catch{
            print("unable to save ota data")
        }
    }
    
    func checkForAllowRecoveryToggle() -> Bool{
        if BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired(){
            let major = BluetoothManager.sharedInstance.informationServiceData.revision.major
            
            if String(Character(UnicodeScalar(major))) == "2"{
                return false
            }
        }
        return true
    }
    
    func clearOTAData(){
        UserDefaults.standard.removeObject(forKey: "ota")
    }
    
    func calcOTAMac(){      //need to check for lowercase
        let mac = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac
        //believe it increase the mac by one
        let macEnd = String(mac.suffix(2))
        if let hexMacEnd = UInt(macEnd, radix: 16){
            let otaMacNum = hexMacEnd + 1
            let otamacEnd = String(format:"%02X", otaMacNum).lowercased()
            let endIndex = mac.index(mac.endIndex, offsetBy: -3)
            otaMACAddress = String(mac[...endIndex]) + otamacEnd
            oldMac = mac
            print("mac: \(mac)")
            print("otamac: \(otaMACAddress)")
            
            let oldDev = BluetoothDeviceInfo()
            oldDev.deviceID = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceID
            oldDev.deviceMac = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac
            oldDev.deviceName = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceName
            
            oldDevice = oldDev
        }
    }
    
    func calcMacfromOTA(){
        let otamac = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac
        let otaMacEnd = String(otamac.suffix(2))
        if let hexOtaMacEnd = UInt(otaMacEnd, radix: 16){
            let macNum = hexOtaMacEnd - 1
            let macEnd = String(format: "%02X", macNum)
            let endIndex = otamac.index(otamac.endIndex, offsetBy: -3)
            oldMac = String(otamac[...endIndex]) + macEnd
            otaMACAddress = otamac
        }
    }
    
    func checkVersion(stimDeviceAddress: String, completion:@escaping (Bool, OTA?, String) -> ()){
        APIClient.getOTAVersion(stimDeviceAddress: stimDeviceAddress){ success, result, errorMessage, authorized in
            if success{
                completion(true, result, errorMessage)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, result, errorMessage)
            }
        }
    }
    
    func getOTADownload(guid: String, completion:@escaping (Bool, OTA?, String) -> ()) {
        APIClient.getOTADownload(guid: guid){ success, result, errorMessage in
            if success{
                completion(true, result, errorMessage)
            }
            else{
                completion(success, result, errorMessage)
            }
        }
    }
    
    func getOTADownload2(guid: String, completion:@escaping(Bool, String) -> ()){
        APIClient.getOTADownload2(guid: guid){ success, errorMessage, authorized in
            if success{
                completion(true, errorMessage)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, errorMessage)
            }
        }
    }
    
    func updateState(){
        delegate?.stateUpdated()
    }
    
    func setAvailable(){
        //file shenans
        updateAvailable = true
        updateAvailableDelegate?.updateAvailable(available: true)
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.otaUpdateAvailable.rawValue), object:  nil)
    }
    
    func clearAvailable(){
        //file shenans
        clearOTAData()
        
        do{
            let fileName = getDocumentsDirectory().appendingPathComponent("updateFile.bin")
            
            if FileManager.default.fileExists(atPath: fileName.path){
                print("file exists")
                try FileManager.default.removeItem(at: fileName)
            }
            else{
                print("file doesn't exist")
            }
            
        } catch{
            print("fail to delete updateFile.bin")
        }
        
        updateAvailable = false
        updateAvailableDelegate?.updateAvailable(available: false)
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.otaUpdateUnavailable.rawValue), object:  nil)
    }
   
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func recoverOTA(){
        //disconnect, then after delay scan
        state = .searching
    }
}
