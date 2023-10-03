/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import SwiftKeychainWrapper

class KeychainManager: NSObject {
    static let sharedInstance = KeychainManager()
    
    var accountData:AccountData?
    
    func setupManager(){
        accountData = loadAccountData()
    }
    
    //new attempt with userdefaults
    func clearAccountData(){
        UserDefaults.standard.removeObject(forKey: "accountData")
    }
    
    func saveAccountData(data: AccountData){
        do{
            let encoder = JSONEncoder()
            let ado = try encoder.encode(data)
            UserDefaults.standard.set(ado, forKey: "accountData")
            accountData = data
        } catch{
            print("unable to save account data")
        }
    }
    
    func loadAccountData() -> AccountData?{
        var data = AccountData()
        if let accountDataObject = UserDefaults.standard.data(forKey: "accountData"){
            do{
                let decoder = JSONDecoder()
                    data = try decoder.decode(AccountData.self, from: accountDataObject)
            }catch _{
                
                Slim.info("Account Data Defaulting because decode fails with error")
                saveAccountData(data: AccountData())
                accountData = AccountData()
                return AccountData()
            }
        }
        else{
            if !areTestsRunning(){
              //Slim.info("Account Data Defaulting because accountDataObject not found")
              saveAccountData(data: AccountData())
              accountData = AccountData()
            }
        }
        accountData = data
        return data
    }
    /*
    func checkForSham() -> Bool?{
        //for now assumes account data already pulled
        if let studyId = accountData?.userModel?.studyId{
            if studyId > 0{
                BluetoothManager.sharedInstance.isSham = studyId == 5
                return studyId == 5
            }
        }
        BluetoothManager.sharedInstance.isSham = nil
        return nil
    }
    */
}
