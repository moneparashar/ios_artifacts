/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class LogManager: NSObject{
    static let sharedInstance = LogManager()
    
    var userLogConfig:UserLogConfiguration?
    
    func clearLogLevels(){
        UserDefaults.standard.removeObject(forKey: "userLogConfig")
    }
    
    func loadLogLevels() -> UserLogConfiguration?{
        var data = UserLogConfiguration()
        if let logDataObject = UserDefaults.standard.data(forKey: "userLogConfig"){
            do{
                let deocder = JSONDecoder()
                data = try deocder.decode(UserLogConfiguration.self, from: logDataObject)
            } catch _{
                saveLogLevels(data: UserLogConfiguration())
                userLogConfig = nil
                return userLogConfig
            }
        }
        else{
            if !areTestsRunning(){
                saveLogLevels(data: UserLogConfiguration())
                userLogConfig = nil
                return userLogConfig
            }
        }
        userLogConfig = data
        return data
    }
    
    func saveLogLevels(data: UserLogConfiguration){
        do{
            let encoder = JSONEncoder()
            let ado = try encoder.encode(data)
            UserDefaults.standard.set(ado, forKey: "userLogConfig")
            userLogConfig = data
        } catch{
            Slim.error("Unable to save log levels")
        }
    }
    
    
    func getLogConfig(completion:@escaping(Bool, UserLogConfiguration?, String) -> ()){
        if !AppSettings.debug{
            APIClient.getUserLogConfig(){ success, result, errorString, authorized in
                if success{
                    if result != nil{
                        self.saveLogLevels(data: result!)
                    }
                    completion(success, result, errorString)
                }
            }
        }
        else{
            completion(true, nil, "")
        }
    }
}
