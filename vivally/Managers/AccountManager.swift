/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import JWTDecode

class AccountManager: NSObject {

    static let sharedInstance = AccountManager()
    var token = ""
    var isClinician = false
    var username = "" // MARK: for testing
    var dob = ""
    var roles = [String]()
    var comingFromEmailLogin = false
    
    var clinicPermissions:Permissions? = nil
    
    func login(username:String, password:String, completion:@escaping (Bool, LoginResult?, String) -> ()){
        APIClient.login(username: username, password: password) { success, result, errorString in
            if success{
                completion(success, result, errorString)
                self.token = (result?.authenticationResult.accessToken)!
                do{
                    let jwt = try decode(jwt: self.token)
                    let claim = jwt.claim(name: "cognito:groups")
                    self.roles = claim.array!
                    KeychainManager.sharedInstance.accountData?.roles = self.roles
                    //var data = KeychainManager.sharedInstance.accountData
                    //KeychainManager.sharedInstance.saveAccountData(data: data)
                } catch{
                    print("Error with jwt")
                }
                /*
                let jwt = try decode(jwt: self.token)
                let claim = jwt.claim(name: "cognito:groups")
                let roles = claim.array
                */
            }
            else{
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Login")
                completion(success, result, errorString)
            }
        }
    }
    
    func signup(username:String, completion:@escaping (Bool, Bool, String) -> ()){
        APIClient.signup(user: username) { success, didSend, errorMessage in
            if success{
                completion(true, true, errorMessage)
            }
            else{
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Signup")
                completion(success, didSend, errorMessage)
            }
        }
    }
    
    func refreshToken(token:String, completion:@escaping (Bool, LoginResult?, String, Bool) -> ()){
        APIClient.refreshToken(token: token){ success, result, errorString, timeout in
            if success{
                completion(success, result, errorString, timeout)
                
                var accountData = KeychainManager.sharedInstance.accountData
                if accountData == nil{
                    accountData = AccountData()
                }
                
                accountData?.token = result?.authenticationResult.accessToken ?? ""
                
                KeychainManager.sharedInstance.saveAccountData(data: accountData!)
            }
            else{
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Timeout")
                completion(success, result, errorString, timeout)
            }
        }
    }
    
    
    func forgetPassword(username:String, completion:@escaping (Bool, Bool, String) -> ()){
        APIClient.forgetPassword(username: username) { success, didSend, errorMessage in
            if success{
                completion(true, true, errorMessage)
            }
            else{
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Forgot Password")
                completion(success, didSend, errorMessage)
            }
        }
    }
    
    func confirmForgotPassword(username:String, newPassword:String, confirmationCode:String, completion:@escaping (Bool, Bool, String) -> ()){
        APIClient.confirmForgotPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode){ success, didSend, errorMessage in
            if success{
                completion(true, true, errorMessage)
            }
            else{
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Confirm Forgot Password")
                completion(success, didSend, errorMessage)
            }
        }
    }
    
    func confirmChangePassword(oldPassword:String, newPassword:String, completion:@escaping (Bool, String) -> ()){
        APIClient.confirmChangePassword(oldPassword: oldPassword, newPassword: newPassword){ success, errorMessage in
            if success{
                completion(true, errorMessage)
            }
            else{
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Confirm Change Password")
                completion(success, errorMessage)
            }
        }
    }
    
    func resetPassword(username:String, newPassword:String, session:String, completion:@escaping (Bool, Bool, String) -> ()){
        APIClient.resetPassword(username: username, newPassword: newPassword, session: session) { success, didSend, errorMessage in
            if success{
                completion(true, true, errorMessage)
            }
            else{
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Reset Password")
                completion(success, didSend, errorMessage)
            }
        }
    }
    
    func confirmFindPatientViaEmail(email:String, name:String, completion:@escaping (Bool, PatientExists?, String) -> ()) {
        APIClient.findPatientViaEmail(email: email, name: name){ sucess, result, errorMessage, authorized in
            if sucess{
                completion(true, result, errorMessage)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Confirm 'Find Patient Via Email'")
                completion(sucess, result, errorMessage)
            }
        }
    }
    
    func confirmFindPatient(email:String, name:String, user: String, cogGuid: String, completion:@escaping (Bool, PatientExists?, String) -> ()) {
        APIClient.findPatientsViaEmailUsernameFullName(email: email, name: name, username: user, cGuid: cogGuid){ sucess, result, errorMessage, authorized in
            if sucess{
                completion(true, result, errorMessage)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Confirming 'Find Patient'")
                completion(sucess, result, errorMessage)
            }
        }
    }
    
    func confirmFindPatientQuery(searchText:String, completion:@escaping (Bool, [PatientExists], String) -> ()) {
        APIClient.findPatientViaMultipleQuery(searchStr: searchText){ sucess, result, errorMessage, authorized in
            if sucess{
                completion(true, result, errorMessage)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Confirm 'Find Patient' Query")
                completion(sucess, result, errorMessage)
            }
        }
    }
    
    func acceptedEula(completion:@escaping (Bool, Bool, String) -> ()) {
        APIClient.acceptedEula(){ success, result, errorMessage in
            if success{
                completion(true, result, errorMessage)
            }
            else{
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Accepting Eula Aggreement")
                completion(success, result, errorMessage)
            }
        }
    }
    
    func getMe(completion:@escaping(Bool, UserModel?, String) -> ()){
        APIClient.getUserMe { success, userModel, errorMessage, authorized in
            if !authorized{
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Get User Info")
                RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
            }
            completion(success, userModel, errorMessage)
        }
    }
    
    func getPermissions(completion:@escaping(Bool, Permissions?, String) -> ()){
        APIClient.getUserPermission { success, result, errorMessage, authorized in
            if success{
                completion(true, result, errorMessage)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Get User Permissions")
                completion(success, result, errorMessage)
            }
        }
    }
    
    func requestDeletion(requestdd: RequestDataDeletion, completion:@escaping(Bool, String) -> ()){
        requestCloseSending = true
        APIClient.requestDataDeletion(requestDD: requestdd){ success, errorMessage in
            if success{
                self.clearCloseAccountRequest()
                completion(true, errorMessage)
            }
            else{
                Slim.log(level: LogLevel.error, category: [.appInfo], "API Error: Request Data Deletion")
                completion(success, errorMessage)
            }
            self.requestCloseSending = false
        }
    }
    
    //save actual request
    var requestCloseSending = false
    func requestCloseAccount(rdd: RequestDataDeletion, completion:@escaping() -> ()){
        do{
            let encoder = JSONEncoder()
            let rddo = try encoder.encode(rdd)
            UserDefaults.standard.set(rddo, forKey: "requestClose")
            NetworkManager.sharedInstance.checkRequestAccountClose{
                completion()
            }
        } catch{
            Slim.log(level: LogLevel.error, category: [.appInfo], "Close Account Error: Unable To Save Request Close Account")
            print("Unable to save request close account")
            clearCloseAccountRequest()
            completion()
        }
    }
    
    func clearCloseAccountRequest(){
        UserDefaults.standard.removeObject(forKey: "requestClose")
    }
    
    func checkForCloseAccountRequest() -> RequestDataDeletion?{
        var data = RequestDataDeletion()
        if let requestDeletionDataObject = UserDefaults.standard.data(forKey: "requestClose"){
            do{
                let decoder = JSONDecoder()
                data = try decoder.decode(RequestDataDeletion.self, from: requestDeletionDataObject)
                return data
            } catch{
                Slim.log(level: LogLevel.error, category: [.appInfo], "Close Account Error: Decode For Close Account Failed")
                print("decode for close account failed")
                return nil
            }
        }
        return nil
    }
    
    
    //disable data sharing
    func disableDataSharing(completion:@escaping() -> ()){
        APIClient.disableDataSharing(){ success, errorMessage in
            Slim.log(level: LogLevel.warning, category: [.appInfo], "API Warning: Disabled Data Sharing")
        }
    }
    
    func enableDataSharing(completion:@escaping() -> ()){
        APIClient.enableDataSharing(){ success, errorMessage in
            Slim.log(level: LogLevel.warning, category: [.appInfo], "API Warning Error: Enabled Data Sharing")
        }
    }
}
