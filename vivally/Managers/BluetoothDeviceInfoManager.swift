/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class BluetoothDeviceInfo:NSObject, Codable{
    var deviceMac:String = ""
    var deviceName:String = ""
    var deviceID:String = ""
    
    func getMac() -> String{
        var mac = ""
        if deviceMac.count > 5{
            let bah = deviceMac.filter{ $0.isLetter || $0.isNumber}
            mac = String(bah.suffix(4)).uppercased()
        }
        return mac
    }
}


class BluetoothDeviceInfoManager: NSObject {
    var deviceInfo:BluetoothDeviceInfo
    
    static let sharedInstance = BluetoothDeviceInfoManager()
    override init(){
        deviceInfo = BluetoothDeviceInfo()
        super.init()
    }
    
    func setupManager(){
        loadData()
    }
    
    func isDevicedPaired() -> Bool{
        if deviceInfo.deviceID != "" && deviceInfo.deviceMac != "" && deviceInfo.deviceName != ""{
            return true
        }
        return false
    }
    
    func clearDevice(){
        deviceInfo = BluetoothDeviceInfo()
        saveData()
    }
    
    func saveData(){
        let config = try? JSONEncoder().encode(deviceInfo)
        
        let defaults = UserDefaults.standard
        defaults.set(config, forKey: "DeviceInfo")
    }
    
    private func loadData(){
        let defaults = UserDefaults.standard
        if let config = defaults.object(forKey: "DeviceInfo"){
            do{
                deviceInfo = try JSONDecoder().decode(BluetoothDeviceInfo.self, from: config as! Data)
            }catch{ deviceInfo = BluetoothDeviceInfo() }
        }
    }
}
