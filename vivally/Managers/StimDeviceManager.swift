/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import SwiftKeychainWrapper

class StimDeviceManager: NSObject {
    static let sharedInstance = StimDeviceManager()

    var stimDevice:StimDevice?
    
    func clearStimDeviceData(){
        UserDefaults.standard.removeObject(forKey: "stimDevice")
    }
    func saveStimDeviceData(data:StimDevice){
        do{
            let encoder = JSONEncoder()
            let ado = try encoder.encode(data)
            UserDefaults.standard.set(ado, forKey: "stimDevice")
            stimDevice = data
        } catch{
            print("unable to save account data")
        }
    }
    func loadStimDeviceData() -> StimDevice?{
        var data = StimDevice()
        if let stimDataObject = UserDefaults.standard.data(forKey: "stimDevice"){
            do{
                let decoder = JSONDecoder()
                    data = try decoder.decode(StimDevice.self, from: stimDataObject)
            }catch _{
                
                Slim.info("Stim Data Defaulting because decode fails with error")
                saveStimDeviceData(data: StimDevice())
                return StimDevice()
            }
        }
        else{
            Slim.info("Stim Data Defaulting because accountDataObject not found")
            saveStimDeviceData(data: StimDevice())
        }
        return data
    }
    
    func postStimDevice(stimDevice:StimDevice, isLast: Bool = false, completion:@escaping (Bool, StimDevice?, String, Bool) -> ()) {
        APIClient.postStimDevice(stimDevice: stimDevice){ success, result, errorMessage, authorized in
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
    
    var stimDeviceSending = false
    func syncStimDeviceData(completion:@escaping() -> ()){
        do {
            let leftToSend = try StimDeviceDataHelper.getLatestLeftToSend()
            if leftToSend.isEmpty{
                stimDeviceSending = false
                completion()
                return
            }
            stimDeviceSending = true
            var isLast = false
            var index = 0
            for sd in leftToSend{
                isLast = index == leftToSend.count - 1
                
                postStimDevice(stimDevice: sd, isLast: isLast){ success, result, errorMessage, wasLast in
                    if success{
                        do{
                            try StimDeviceDataHelper.setSentClean(sentStimDevice: sd)
                        } catch{
                            Slim.error("error with setting sent stim device clean")
                        }
                        
                    }
                    if wasLast{
                        self.stimDeviceSending = false
                        do{
                            try StimDeviceDataHelper.clearClean()
                        } catch{
                            Slim.error("error with deleteing cleaned stim devices")
                        }
                        completion()
                    }
                }
                index += 1
            }
        } catch{
            Slim.error("error with stim device db getting left to send")
            completion()
        }
    }

}
