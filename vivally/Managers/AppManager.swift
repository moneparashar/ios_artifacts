/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import SwiftKeychainWrapper

class AppManager: NSObject {
    static let sharedInstance = AppManager()
    
    var appDeviceData:AppDevice?

    func setupManager(){
        appDeviceData = loadAppDeviceData()
    }
    
    func clearAppDeviceData(){
        UserDefaults.standard.removeObject(forKey: "appDeviceData")
    }
    func saveAppDeviceData(data:AppDevice){
        do{
            let encoder = JSONEncoder()
            let ado = try encoder.encode(data)
            UserDefaults.standard.set(ado, forKey: "appDeviceData")
            appDeviceData = data
        } catch{
            print("unable to save app device data data")
        }
    }
    func loadAppDeviceData() -> AppDevice?{
        var data = AppDevice()
        if let appDeviceDataObject = UserDefaults.standard.data(forKey: "appDeviceData"){
            do{
                let decoder = JSONDecoder()
                    data = try decoder.decode(AppDevice.self, from: appDeviceDataObject)
            }catch _{
                
                Slim.info("App Data Defaulting because decode fails with error")
                saveAppDeviceData(data: AppDevice())
                return AppDevice()
            }
        }
        else{
            let deviceToken = UIDevice.current.identifierForVendor
            data.deviceToken = deviceToken?.uuidString
            data.appIdentifier = deviceToken?.uuidString ?? ""
            
            postAppDevice(appDevice: data){ success, result, errorMessage in
                if success{
                    //self.saveAppDeviceData(data: data)
                    data.guid = result!.guid
                    data.timestamp = result!.timestamp
                    self.saveAppDeviceData(data: result!)
                    
                    //do appdevicedatahelper.insert here
                    do{
                        try AppDeviceDataHelper.insert(item: result!)
                    }
                    catch{
                        print("error with insert")
                    }
                }
                else{
                    print("Error with postAppDeviceData")
                    data = AppDevice()
                    self.saveAppDeviceData(data: AppDevice())
                }
            }
            
            Slim.info("App Data Defaulting because appDataObject not found")
            //saveAppDeviceData(data: AppDevice())
            return data
        }
        return data
    }
    
    func postAppDevice(appDevice:AppDevice ,completion:@escaping (Bool, AppDevice?, String)->()){
        APIClient.postAppDevice(appDevice: appDevice){ success, result, errorMessage, authorized in
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

    func putAppDevice(appDevice:AppDevice ,completion:@escaping (Bool, AppDevice?, String)->()){
        APIClient.putAppDevice(appDevice: appDevice){ success, result, errorMessage, authorized in
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
}
