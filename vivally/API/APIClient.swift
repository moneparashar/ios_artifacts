/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import Alamofire
import JWTDecode
import Network

class APIClient: NSObject {
    
    static var customHeaders: HTTPHeaders = []
    
    static func convertStringToDictionary(text: String) -> [String:AnyObject]? {
       if let data = text.data(using: .utf8) {
           do {
               let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
               return json
           } catch {
               print("Something went wrong")
           }
       }
       return nil
   }
    
    //MARK: Account
    static func login(username:String, password:String, completion:@escaping(Bool, LoginResult?, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/account/login"
        let URLString = AppSettings.rootUrl + path
        let params = ["username":username, "password":password]
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(LoginResult.self, from: json!)
                        APIClient.customHeaders.add(name: "Authorization", value: "Bearer \(model.authenticationResult.accessToken)")
                        AWSDestination.customLogHeaders.add(name: "Authorization", value: "Bearer \(model.authenticationResult.idToken)")
                        NotificationManager.sharedInstance.setupPushNotifcations()
                        /*
                        //jwt
                        let jwt = try decode(jwt: model.authenticationResult.accessToken)
                        let claim = jwt.claim(name: "cognito:groups")
                        print("this is the claim")
                        
                        let roles = claim.array
                        //print(claim.array)
                        //end of jwt
                        */
                        
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Unable to parse data")
                    }
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    
                    completion(false,nil, "Server Error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
                
            // no internet connection
            } else {
                completion(false, nil, "Error no response")
            }
        }
    }
    
    static func signup(user: String, completion: @escaping(Bool, Bool, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/account/signup"
        let URLString = AppSettings.rootUrl + path
        let params = ["username":user]
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(true, true, "")
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, false, errorString)
                        return
                    }
                    
                    completion(false,false, "Server Error")
                default:
                    completion(false,false, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func refreshToken(token:String, completion:@escaping(Bool, LoginResult?, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/account/refreshtoken"
        let URLString = AppSettings.rootUrl + path
        let params = ["refreshtoken":token]
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(LoginResult.self, from: json!)
                        APIClient.customHeaders.add(name: "Authorization", value: "Bearer \(model.authenticationResult.accessToken)")
                        //NotificationManager.sharedInstance.setupPushNotifcations()
                        completion(true, model, "", false)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Unable to parse data", false)
                    }
                    /*
                case 401:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false, nil, "access token expires")
                    */
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, false)
                        return
                    }
                    
                    completion(false,nil, "Server Error", false)
                default:
                    completion(false,nil, "Access token expired", false)
                }
            }
            else if response.error != nil{
                completion(false, nil, "Timeout", true)
            }
        }
    }
    
    static func forgetPassword(username:String, completion:@escaping(Bool, Bool, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/account/forgotpassword"
        let URLString = AppSettings.rootUrl + path
        let params = ["username":username]
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(true, true, "")
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, false, errorString)
                        return
                    }
                    
                    completion(false,false, "Server Error")
                default:
                    completion(false,false, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func confirmForgotPassword(username: String, newPassword: String, confirmationCode: String, completion:@escaping(Bool, Bool, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/account/confirmforgotpassword"
        let URLString = AppSettings.rootUrl + path
        let params = ["username":username, "newPassword":newPassword, "confirmationCode": confirmationCode]
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    /*
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(LoginResult.self, from: json!)
                        APIClient.customHeaders.add(name: "Authorization", value: "Bearer \(model.authenticationResult.accessToken)")
                        completion(true, true, "")
                    }catch let err{
                        print(err)
                        completion(false,  false, "Unable to parse data")
                    }
                    */
                    completion(true, true, "")
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, false, errorString)
                        return
                    }
                    
                    completion(false,false, "Server Error")
                default:
                    completion(false,false, "Error.  Please try again.")
                }
            }
        }
    }
    
    //change encoding to URLEncoding.default
    static func confirmChangePassword(oldPassword:String, newPassword: String, completion:@escaping(Bool, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/account/changepassword"
        let URLString = AppSettings.rootUrl + path
        let params = ["oldPassword":oldPassword, "newPassword":newPassword]
        
        AF.request(URLString, method: .put, parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status {
                case 200:
                    /*
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(LoginResult.self, from: json!)
                        //APIClient.customHeaders.add(name: "Authorization", value: "Bearer \(model.authenticationResult.accessToken)")
                        completion(true, "")
                    }catch let err{
                        print(err)
                        completion(false, "Unable to parse data")
                    }
                    */
                    completion(true, "")
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, errorString)
                        return
                    }
                    completion(false, "Server Error")
                default:
                    completion(false, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func resetPassword(username:String, newPassword:String, session:String, completion:@escaping(Bool, Bool, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/account/resetpassword"
        let URLString = AppSettings.rootUrl + path
        let params = ["username":username, "newPassword":newPassword, "session":session]
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(LoginResult.self, from: json!)
                        APIClient.customHeaders.add(name: "Authorization", value: "Bearer \(model.authenticationResult.accessToken)")
                        NotificationManager.sharedInstance.setupPushNotifcations()
                        completion(true, true, "")
                    }catch let err{
                        print(err)
                        completion(false,  false, "Unable to parse data")
                    }
                    completion(true, true, "")
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, false, errorString)
                        return
                    }
                    
                    completion(false,false, "Server Error")
                default:
                    completion(false,false, "Error.  Please try again.")
                }
            }
        }
        
    }
    
    //swap responseJSON with responseData
    static func acceptedEula(completion:@escaping(Bool, Bool, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/account/acceptedeula"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .post,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(true, true, "")
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, false, errorString)
                        return
                    }
                    
                    completion(false,false, "Server Error")
                default:
                    completion(false,false, "Error.  Please try again.")
                }
            }
        }
        
    }
    
    //MARK:  Screening
    static func screening(username:String, guid:String, completion:@escaping (Bool, Bool, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/screening/new"
        let URLString = AppSettings.rootUrl + path
        let params = ["username":username, "guid":guid]
        
        AF.request(URLString,method: .post, parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(true, true, "", true)
                case 401:
                    if let message = response.value as? String{
                        completion(false, false, message, false)
                    }
                    completion(false, false, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, false, errorString, true)
                        return
                    }
                    
                    completion(false,false, "Server Error", true)
                default:
                    completion(false,false, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func addPatient(patientExists: PatientExists, completion:@escaping (Bool, PatientScreening?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/screening/patient"
        let URLString = AppSettings.rootUrl + path
        let params = try? patientExists.asDictionary()
        
        AF.request(URLString,method: .post, parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(PatientScreening.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Unable to parse data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    
                    completion(false,nil, "Server Error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func updatePatient(patientExists: PatientExists, completion:@escaping (Bool, PatientScreening?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/screening/patient"
        let URLString = AppSettings.rootUrl + path
        let params = try? patientExists.asDictionary()
        
        AF.request(URLString,method: .put, parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(PatientScreening.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Unable to parse data", true)
                    }
                    
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    
                    completion(false,nil, "Server Error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    //MARK: App Device
    static func getAppDevice(guid:String, completion:@escaping (Bool, AppDevice?, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/appdevice?guid=\(guid)"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(AppDevice.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func putAppDevice(appDevice:AppDevice ,completion:@escaping (Bool, AppDevice?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/appdevice?guid=\(appDevice.guid.uuidString)"
        let URLString = AppSettings.rootUrl + path
        let params = try? appDevice.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(AppDevice.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func postAppDevice(appDevice:AppDevice ,completion:@escaping (Bool, AppDevice?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/appdevice"
        let URLString = AppSettings.rootUrl + path
        let params = try? appDevice.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(AppDevice.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    
    
    //MARK: App Events
    static func getAppEvent(guid:String, completion:@escaping (Bool, AppEvent?, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/appevents?guid=\(guid)"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(AppEvent.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func putAppEvent(appDevice:AppDevice ,completion:@escaping (Bool, AppEvent?, String)->()){
        let path = "/\(AppSettings.apiVersion)/appevents?guid=\(appDevice.guid.uuidString)"
        let URLString = AppSettings.rootUrl + path
        let params = try? appDevice.asDictionary()
        
        AF.request(URLString,method: .put,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(AppEvent.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func postAppEvent(appEvent:AppEvent ,completion:@escaping (Bool, AppEvent?, String)->()){
        let path = "/\(AppSettings.apiVersion)/appevents"
        let URLString = AppSettings.rootUrl + path
        let params = try? appEvent.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(AppEvent.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    //MARK: App Log Messsage
    static func postLogMessage(logMessage:LogMessage ,completion:@escaping (Bool, LogMessage?, String)->()){
        let path = "/\(AppSettings.apiVersion)/applogmessage"
        let URLString = AppSettings.rootUrl + path
        let params = try? logMessage.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(LogMessage.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    //MARK: Demographics
    static func getDemographicsValues(completion:@escaping (Bool, DemographicBulk?, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/demographicsvalue?Deleted=false"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(DemographicBulk.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    //MARK: Device Config
    static func getDeviceConfigQuery(completion:@escaping (Bool, DeviceConfig?, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/deviceconfig/query"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(DeviceConfig.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func getDeviceConfig(guid:String, completion:@escaping (Bool, DeviceConfig?, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/deviceconfig?guid=\(guid)"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(DeviceConfig.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func postDeviceConfig(deviceConfig:DeviceConfig ,completion:@escaping (Bool, DeviceConfig?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/deviceconfig"
        let URLString = AppSettings.rootUrl + path
        let params = try? deviceConfig.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(DeviceConfig.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    //MARK: Device Info
    static func getDeviceInfo(guid:String, completion:@escaping (Bool, DeviceInfo?, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/deviceinfo?guid=\(guid)"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(DeviceInfo.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func postDeviceInfo(deviceInfo:DeviceInfo ,completion:@escaping (Bool, DeviceInfo?, String)->()){
        let path = "/\(AppSettings.apiVersion)/deviceinfo"
        let URLString = AppSettings.rootUrl + path
        let params = try? deviceInfo.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(DeviceInfo.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    //MARK: EMG Data
    static func postEMGData(emgData:EMGData ,completion:@escaping (Bool, EMGData?, String)->()){
        let path = "/\(AppSettings.apiVersion)/emgdata"
        let URLString = AppSettings.rootUrl + path
        let params = try? emgData.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(EMGData.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func postEMGDataBulk(emgData:[EMGData] ,completion:@escaping (Bool, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/emgdata/bulk"
        let URLString = AppSettings.rootUrl + path
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try! encoder.encode(emgData)
        if let url = URL(string: URLString){
            var request = URLRequest(url: url)
            request.headers = APIClient.customHeaders
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            
            AF.request(request).responseJSON{ (response) in
                //debugPrint(response)
                if let status = response.response?.statusCode {
                    switch status {
                    case 200:
                        completion(true, "", true)
                    case 401:
                        if let message = response.value as? String{
                            completion(false, message, false)
                        }
                        completion(false, "Unauthorized. Unable to parse error", false)
                    case 400, 402 ... 499:
                        completion(false, "Error.  Unable to parse error", true)
                    default:
                        completion(false, "Error.  Please try again.", true)
                    }
                }
                
            }
        }
    }
    
    //MARK: EULA
    static func getEulaPatient(completion:@escaping (Bool, EulaHTML?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/eula/patient"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get, parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(EulaHTML.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
            else if response.error != nil{
                completion(false,nil, "Error.  Please try again.", true)
            }
        }
    }
    
    static func getEulaPatientPDF(completion:@escaping (Bool, String, Bool)-> ()){
        let path = "/\(AppSettings.apiVersion)/eula/patientpdf"
        let URLString = AppSettings.rootUrl + path
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("vivally-eula.pdf", conformingTo: .pdf)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(URLString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders, interceptor: nil, requestModifier: nil, to: destination).responseString{ (response) in
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(true, "", true)
                case 401:
                    completion(false, "Unauthorized", false)
                case 400, 402 ... 499:
                    completion(false, "Error. unable to parse error", true)
                default:
                    completion(false, "Error. Please try again", true)
                }
            }
        }
    }
    
    static func getEulaClinician(completion:@escaping (Bool, EulaHTML?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/eula/clinician"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get, parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(EulaHTML.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func getEulaClinicianPDF(completion:@escaping (Bool, String, Bool)-> ()){
        let path = "/\(AppSettings.apiVersion)/eula/clinicianpdf"
        let URLString = AppSettings.rootUrl + path
        let destination: DownloadRequest.Destination = { bah, dah in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("vivally-eula.pdf", conformingTo: .pdf)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(URLString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders, interceptor: nil, requestModifier: nil, to: destination).responseString{ (response) in
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(true, "", true)
                case 401:
                    completion(false, "Unauthorized", false)
                case 400, 402 ... 499:
                    completion(false, "Error. unable to parse error", true)
                default:
                    completion(false, "Error. Please try again", true)
                }
            }
        }
    }
    
    //MARK: Evaluation Criteria
    static func putEvaluationCriteria(evaluationCriteria:EvaluationCriteria ,completion:@escaping (Bool, EvaluationCriteria?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/evaluationcriteria?guid=\(evaluationCriteria.guid.uuidString)"
        let URLString = AppSettings.rootUrl + path
        let params = try? evaluationCriteria.asDictionary()
        
        AF.request(URLString,method: .put,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        
                        let model = try decoder.decode(EvaluationCriteria.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func postEvaluationCriteria(evaluationCriteria:EvaluationCriteria ,completion:@escaping (Bool, EvaluationCriteria?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/evaluationcriteria"
        let URLString = AppSettings.rootUrl + path
        let params = try? evaluationCriteria.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.prettyPrinted, headers: APIClient.customHeaders).responseJSON { (response) in
            
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        
                        let model = try decoder.decode(EvaluationCriteria.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func getEvalCritPatient(completion:@escaping (Bool, PatientEvaluationCriteria?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/evaluationcriteria/screening/current"
        let URLString = AppSettings.rootUrl + path
        AF.request(URLString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON {(response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status {
                case 200:
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        
                        let model = try decoder.decode(PatientEvaluationCriteria.self, from: json!)
                        completion(true, model, "", true)
                    } catch let err{
                        print(err)
                        completion(false, nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false, nil, "Error.  Unable to parse error", true)
                default:
                    completion(false, nil, "Error.  Please try again.", true)
                }
            }
        }
        
    }
    
    //MARK: Help Video Timestamps
    static func getVideoTimestamps(completion:@escaping (Bool, HelpTimestampSet?, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/helpvideotimestamps"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(HelpTimestampSet.self, from: json!)
                        completion(true, model,"")
                    }catch let err{
                        print(err)
                        completion(false, nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    //MARK: Journal Event Focus Periods
    //don't know really need to bother with passing status yet
    //also need to create new model
    static func getLatestFocusPeriod(completion:@escaping (Bool, JournalEventFocusPeriod?, String)->()){
        let path = "/\(AppSettings.apiVersion)/journaleventfocusperiod/latest"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(JournalEventFocusPeriod.self, from: json!)
                        completion(true, model,"")
                    }catch let err{
                        print(err)
                        completion(false, nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    //double check if received anything
    static func postponeLatestFocusPeriod(completion:@escaping (Bool, JournalEventFocusPeriod?, String)->()){
        let path = "/\(AppSettings.apiVersion)/journaleventfocusperiod/postponelatest"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .put,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(JournalEventFocusPeriod.self, from: json!)
                        completion(true, model,"")
                    }catch let err{
                        print(err)
                        completion(false, nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func startLatestFocusPeriod(completion:@escaping (Bool, JournalEventFocusPeriod?, String)->()){
        let path = "/\(AppSettings.apiVersion)/journaleventfocusperiod/postponelatest"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .put,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(JournalEventFocusPeriod.self, from: json!)
                        completion(true, model,"")
                    }catch let err{
                        print(err)
                        completion(false, nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    
    
    //MARK: Journal Events
    static func postJournalEvents(journalEvents:JournalEvents ,completion:@escaping (Bool, JournalEvents?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/journalevents"
        let URLString = AppSettings.rootUrl + path
        let params = try? journalEvents.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.prettyPrinted, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(JournalEvents.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func putJournalEvents(journalEvents:JournalEvents ,completion:@escaping (Bool, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/journalevents?guid=\(journalEvents.guid.uuidString)"
        let URLString = AppSettings.rootUrl + path
        let params = try? journalEvents.asDictionary()
        
        
        AF.request(URLString,method: .put,parameters: params, encoding: JSONEncoding.prettyPrinted, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                completion(true, "", true)
                case 401:
                    if let message = response.value as? String{
                        completion(false, message, false)
                    }
                    completion(false, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, errorString, true)
                        return
                    }
                    completion(false, "Error.  Unable to parse error", true)
                default:
                    completion(false, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    //got not using delete for now
    static func getJournalEvents(deleted:Bool ,completion:@escaping (Bool, [JournalEvents?], String, Bool)->()){
        let path = deleted ? "/\(AppSettings.apiVersion)/journalevents/query/patient?deleted=true" : "/\(AppSettings.apiVersion)/journalevents/query/patient?deleted=false"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        
                        let model = try decoder.decode([JournalEvents].self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  [], "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, [], message, false)
                    }
                    completion(false, [], "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, [], errorString, true)
                        return
                    }
                    completion(false,[], "Error.  Unable to parse error", true)
                default:
                    completion(false,[], "Error.  Please try again.", true)
                }
            }
        }
    }
    
    
    
    //MARK: Notes
    static func putNotes(notes:Note ,completion:@escaping (Bool, Note?, String)->()){
        let path = "/\(AppSettings.apiVersion)/notes?guid=\(notes.guid.uuidString)"
        let URLString = AppSettings.rootUrl + path
        let params = try? notes.asDictionary()
        
        AF.request(URLString,method: .put,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(Note.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func postNotes(notes:Note ,completion:@escaping (Bool, Note?, String)->()){
        let path = "/\(AppSettings.apiVersion)/notes"
        let URLString = AppSettings.rootUrl + path
        let params = try? notes.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(Note.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    
    //MARK: OTA
    static func getOTAVersion(stimDeviceAddress:String, completion:@escaping (Bool, OTA?, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/ota/checkversion?stimDeviceAddress=\(stimDeviceAddress)"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(OTA.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func getOTADownload(guid: String, completion:@escaping (Bool, OTA?, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/ota/download?guid=\(guid)"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(OTA.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
        
    }
    
    static func getOTADownload2(guid: String, completion:@escaping (Bool, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/ota/download?guid=\(guid)"
        let URLString = AppSettings.rootUrl + path
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("updateFile.bin")

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        
        AF.download(URLString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders, interceptor: nil, requestModifier: nil, to: destination).responseString{ (response) in
            //debugPrint(response)
            
            if let status = response.response?.statusCode{
                switch status {
                case 200:
                    completion(true, "", true)
                case 401:
                    completion(false, "Unauthorized", false)
                case 400, 402 ... 499:
                    completion(false, "Error. unable to parse error", true)
                default:
                    completion(false, "Error. Please try again", true)
                }
            }
        }
        
    }
    
    //MARK: Push Notifications
    static func postPushNotificationRegister(appId:String, deviceToken: String, completion:@escaping (Bool, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/pushnotifications/register"
        let URLString = AppSettings.rootUrl + path
        let params = ["appIdentifier":appId, "deviceToken":deviceToken]
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(true, "", true)
                case 401:
                    if let message = response.value as? String{
                        completion(false, message, false)
                    }
                    completion(false, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, errorString, true)
                        return
                    }
                    completion(false, "Error.  Unable to parse error", true)
                default:
                    completion(false, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func postPushNotificationUnRegister(appId:String, completion:@escaping (Bool, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/pushnotifications/unregister"
        let URLString = AppSettings.rootUrl + path
        let params = ["appIdentifier":appId]
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(true, "", true)
                case 401:
                    if let message = response.value as? String{
                        completion(false, message, false)
                    }
                    completion(false, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, errorString, true)
                        return
                    }
                    completion(false, "Error.  Unable to parse error", true)
                default:
                    completion(false, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    //MARK: Session Data
    static func postSessionData(sessionData:SessionData, completion:@escaping (Bool, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/sessiondata"
        let URLString = AppSettings.rootUrl + path
        let params = try? sessionData.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(true, "", true)
                case 401:
                    if let message = response.value as? String{
                        completion(false, message, false)
                    }
                    completion(false, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, errorString, true)
                        return
                    }
                    completion(false, "Error.  Unable to parse error", true)
                default:
                    completion(false, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func putSessionData(sessionData:SessionData, completion:@escaping (Bool, SessionData?, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/sessiondata"
        let URLString = AppSettings.rootUrl + path
        let params = try? sessionData.asDictionary()
        
        AF.request(URLString,method: .put,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(SessionData.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func getSessionData(completion:@escaping (Bool, [SessionData?], String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/sessiondata/query/app/patient"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        
                        let model = try decoder.decode([SessionData].self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false, [], "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, [], message, false)
                    }
                    completion(false, [], "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, [], errorString, true)
                        return
                    }
                    completion(false,[], "Error.  Unable to parse error", true)
                default:
                    completion(false,[], "Error.  Please try again.", true)
                }
            }
        }
    }
    
    //MARK: Stim Data
    //Don't actually ever want to call this, just have it for testing
    static func postStimData(stimData:StimData, completion:@escaping (Bool, StimData?, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/stimdata"
        let URLString = AppSettings.rootUrl + path
        let params = try? stimData.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(StimData.self, from: json!)
                        completion(true, model, "")
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data")
                    }
                    
                case 400 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error")
                default:
                    completion(false,nil, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func postStimDataBulk(stimDataArray:[StimData], completion:@escaping (Bool, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/stimdata/bulk"
        let URLString = AppSettings.rootUrl + path
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try! encoder.encode(stimDataArray)
        if let url = URL(string: URLString){
            var request = URLRequest(url: url)
            request.headers = APIClient.customHeaders
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            AF.request(request).responseJSON{ (response) in
                //debugPrint(response)
                if let status = response.response?.statusCode {
                    switch status {
                    case 200:
                        completion(true, "", true)
                    case 401:
                        if let message = response.value as? String{
                            completion(false, message, false)
                        }
                        completion(false, "Unauthorized. Unable to parse error", false)
                    case 400, 402 ... 499:
                        if let message = response.value as? [String:Any]{
                            var errorString = ""
                            for (_, value) in message{
                                
                                if let errorArray = value as? Array<String>{
                                    for error in errorArray{
                                        errorString.append("\(error)\r")
                                    }
                                }
                            }
                            completion(false, errorString, true)
                            return
                        }
                        completion(false, "Error.  Unable to parse error", true)
                    default:
                        completion(false, "Error.  Please try again.", true)
                    }
                }
                
            }
        }
        
    }
    
    static func getStimDataBulkCount(completion:@escaping (Bool, BulkConfig?, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/stimdata/bulk/config"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(BulkConfig.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    //MARK: Stim Device
    static func postStimDevice(stimDevice:StimDevice, completion:@escaping (Bool, StimDevice?, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/stimdevice"
        let URLString = AppSettings.rootUrl + path
        let params = try? stimDevice.asDictionary()
        
        AF.request(URLString,method: .post,parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(StimDevice.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    //MARK: Study
    static func getStudy(completion:@escaping (Bool, Study?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/study/query"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                        let model = try decoder.decode(Study.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false, nil, "Error reading data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    //MARK: UserLogConfiguration
    static func getUserLogConfig(completion:@escaping(Bool, UserLogConfiguration?, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/userlogconfiguration/me"
        let URLString = AppSettings.rootUrl + path
        AF.request(URLString, method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(UserLogConfiguration.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Unable to parse data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    
                    completion(false,nil, "Server Error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
            else{
                completion(false, nil, "Error.  Please try again.", true)
            }
        }
    }
    
    //MARK: User
    //changed encoding and .responseJson to responseData
    static func findPatientViaEmail(email:String, name:String, completion:@escaping(Bool, PatientExists?, String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/users/patient/query?email=\(email)&name=\(name)"
        let URLString = AppSettings.rootUrl + path
        //let params = ["email":email]
        
        let percentURLString = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        AF.request(percentURLString!,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(PatientExists.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Unable to parse data", true)
                    }
                    
                    //completion(true, true, "")
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    
                    completion(false,nil, "Server Error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func findPatientsViaEmailUsernameFullName(email:String, name: String, username: String, cGuid: String, completion:@escaping(Bool, PatientExists? , String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/users/patient/query?email=\(email)&name=\(name)&username=\(username)&cognitoGuid=\(cGuid)"
        let URLString = AppSettings.rootUrl + path
        
        let percentURLString = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        AF.request(percentURLString!,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(PatientExists.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Unable to parse data", true)
                    }
                    
                    //completion(true, true, "")
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, nil, errorString, true)
                        return
                    }
                    
                    completion(false,nil, "Server Error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func findPatientViaMultipleQuery(searchStr: String, completion:@escaping(Bool, [PatientExists], String, Bool) -> ()){
        let path = "/\(AppSettings.apiVersion)/users/patient/querymultiple?searchText=\(searchStr)"
        let URLString = AppSettings.rootUrl + path
        
        let percentURLString = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        AF.request(percentURLString!,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode([PatientExists].self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  [], "Unable to parse data", true)
                    }
                    
                    //completion(true, true, "")
                case 401:
                    if let message = response.value as? String{
                        completion(false, [], message, false)
                    }
                    completion(false, [], "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? [String:Any]{
                        var errorString = ""
                        for (_, value) in message{
                            
                            if let errorArray = value as? Array<String>{
                                for error in errorArray{
                                    errorString.append("\(error)\r")
                                }
                            }
                        }
                        completion(false, [], errorString, true)
                        return
                    }
                    
                    completion(false,[], "Server Error", true)
                default:
                    completion(false,[], "Error.  Please try again.", true)
                }
            }
        }
        
    }

    static func getUserMe(completion:@escaping(Bool, UserModel?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/users/me"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(UserModel.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Unable to parse data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? String{
                        completion(false, nil, message, true)
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func getUserPermission(completion:@escaping(Bool, Permissions?, String, Bool)->()){
        let path = "/\(AppSettings.apiVersion)/users/me/permissions"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let json = response.data
                    do{
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(Permissions.self, from: json!)
                        completion(true, model, "", true)
                    }catch let err{
                        print(err)
                        completion(false,  nil, "Unable to parse data", true)
                    }
                case 401:
                    if let message = response.value as? String{
                        completion(false, nil, message, false)
                    }
                    completion(false, nil, "Unauthorized. Unable to parse error", false)
                case 400, 402 ... 499:
                    if let message = response.value as? String{
                        completion(false, nil, message, true)
                    }
                    completion(false,nil, "Error.  Unable to parse error", true)
                default:
                    completion(false,nil, "Error.  Please try again.", true)
                }
            }
        }
    }
    
    static func requestDataDeletion(requestDD: RequestDataDeletion, completion: @escaping (Bool, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/users/requestdatadeletion"
        let URLString = AppSettings.rootUrl + path
        let params = try? requestDD.asDictionary()
        
        AF.request(URLString,method: .put, parameters: params, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            //debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(true, "")
                case 400 ... 499:
                    if let message = response.value as? String{
                        completion(false, message)
                    }
                    completion(false, "Error.  Unable to parse error")
                default:
                    completion(false, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func disableDataSharing(completion:@escaping (Bool, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/users/disabledatasharing"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .put, parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(false, "")
                case 400 ... 499:
                    if let message = response.value as? String{
                        completion(false, message)
                    }
                    completion(false, "Error.  Unable to parse error")
                default:
                    completion(false, "Error.  Please try again.")
                }
            }
        }
    }
    
    static func enableDataSharing(completion:@escaping (Bool, String) -> ()){
        let path = "/\(AppSettings.apiVersion)/users/enabledatasharing"
        let URLString = AppSettings.rootUrl + path
        
        AF.request(URLString,method: .put, parameters: nil, encoding: JSONEncoding.default, headers: APIClient.customHeaders).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    completion(false, "")
                case 400 ... 499:
                    if let message = response.value as? String{
                        completion(false, message)
                    }
                    completion(false, "Error.  Unable to parse error")
                default:
                    completion(false, "Error.  Please try again.")
                }
            }
        }
    }
    
    //MARK: Version
    static func getVersion(completion:@escaping (Bool, String, String)->()){
        let path = "/\(AppSettings.apiVersion)/version"
        let URLString = AppSettings.rootUrl + path
        //let params = try? address.asDictionary()
        
        AF.request(URLString,method: .get,parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            debugPrint(response)
            if let status = response.response?.statusCode{
                switch status{
                case 200:
                    
                    let result = response.value as! [String:Any]
                    if let version = result["version"] as? String{
                        completion(true, version, "")
                        return
                    }
                    
                    completion(false, "", "Unable to parse data")
                case 400 ... 499:
                    if let message = response.value as? String{
                        completion(false, "", message)
                    }
                    completion(false,"", "Error.  Unable to parse error")
                default:
                    completion(false,"", "Error.  Please try again.")
                }
            }
        }
    }
}
