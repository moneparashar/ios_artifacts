/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import SwiftKeychainWrapper

class ScreeningManager: NSObject {
    static let sharedInstance = ScreeningManager()
    
    var patientData:PatientExists?
    var hasClinic = false
    var clinicList = [Clinic]()
    var demographicDict:[DemographicsTypeValues : [Demographic]] = [:]
    var screeningGuid:UUID?
    
    let maxWeight = 300
    let minWeight = 50
    
    func clearAccountData(){
        UserDefaults.standard.removeObject(forKey: "patientData")
        UserDefaults.standard.removeObject(forKey: "screeningGuid")
    }
    func saveAccountData(data:PatientExists){
        do{
            let encoder = JSONEncoder()
            let ado = try encoder.encode(data)
            UserDefaults.standard.set(ado, forKey: "patientData")
            patientData = data
        } catch{
            print("unable to save account data")
        }
    }
    
    func loadAccountData() -> PatientExists?{
        var data = PatientExists()
        if let accountDataObject = UserDefaults.standard.data(forKey: "patientData"){
            do{
                let decoder = JSONDecoder()
                data = try decoder.decode(PatientExists.self, from: accountDataObject)
            } catch _{
                saveAccountData(data: PatientExists())
                patientData = nil
                return patientData
            }
        }
        else{
            if !areTestsRunning(){
                saveAccountData(data: PatientExists())
                patientData = nil
                return patientData
            }
        }
        patientData = data
        return data
    }
    
    func getStudies(completion:@escaping(Bool, Study?, String) -> ()){
        APIClient.getStudy(){ success, result, errorMessage, authorized in
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
    
    func screening(username:String, screenGuid:String, completion:@escaping (Bool, Bool, String) -> ()) {
        
        APIClient.screening(username: username, guid: screenGuid){ success, didSend, errorMessage, authorized in
            if success{
                completion(true, true, errorMessage)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, didSend, errorMessage)
            }
        }
    }
    func addPatient(patientExists: PatientExists, completion:@escaping(Bool, PatientScreening?, String) -> ()){
        APIClient.addPatient(patientExists: patientExists){ success, result, errorMessage, authorized in
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
    
    func updatePatient(patientExists: PatientExists, completion:@escaping (Bool, PatientScreening?, String) -> ()){
        APIClient.updatePatient(patientExists: patientExists){ success, result, errorMessage, authorized in
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
    
    func getDemographics(completion:@escaping (Bool, DemographicBulk?, String) -> ()){
        APIClient.getDemographicsValues(){ success, result, errorMessage in
            if success{
                if result != nil{
                    self.demographicDict = self.getDemographicsSorted(demoBulk: result!)
                    self.saveDemographics()
                }
                completion(true, result, errorMessage)
            }
            else{
                completion(success, result, errorMessage)
            }
        }
    }
    
    func getDemographicsSorted(demoBulk: DemographicBulk) -> [DemographicsTypeValues : [Demographic]]{
        var demoDict:[DemographicsTypeValues : [Demographic]] = [:]
        for demo in demoBulk.records{
            if let demoType = DemographicsTypeValues(rawValue: demo.type){
                if demoDict[demoType] != nil{
                    demoDict[demoType]?.append(demo)
                }
                else{
                    demoDict[demoType] = [demo]
                }
            }
        }
        return demoDict
    }
    
    
    func loadCloseReasonDemographics() -> [Demographic]{
        var data:[Demographic] = []
        
        if let ddo = UserDefaults.standard.data(forKey: "patientCloseDemographics"){
            do{
                let decoder = JSONDecoder()
                data = try decoder.decode([Demographic].self, from: ddo)
            } catch _{
                return []
            }
        }
        
        return data
    }
    
    func saveDemographics(){
        if let data = demographicDict[.closeAccountReason]{
            do{
                let encoder = JSONEncoder()
                let ddo = try encoder.encode(data)
                UserDefaults.standard.set(ddo, forKey: "patientCloseDemographics")
            } catch{
                print("failed to save patient demographics")
            }
        }
    }
    
    func clearDemographics(){
        UserDefaults.standard.removeObject(forKey: "patientCloseDemographics")
    }
    
    func saveScreeningGuid(){
        if screeningGuid != nil{
            UserDefaults.standard.set(screeningGuid!.uuidString, forKey: "screeningGuid")
        }
    }
    
    func loadScreeningGuid() -> String?{
        if let sGuid = UserDefaults.standard.string(forKey: "screeningGuid"){
            screeningGuid = UUID(uuidString: sGuid)
            return screeningGuid?.uuidString
        }
        return nil
    }
    
    //MARK: Validations
    func validateEmail(emailStr: String?) -> Bool{
        let emailPattern = #"^\S+@\S+\.\S+$"#
        
        if let email = emailStr{
            let result = email.range(
                of: emailPattern,
                options: .regularExpression
            )
            
            return (result != nil)
        }
        else{
            return false
        }
    }
    
    func validateBirth(birthday: Date?) -> Bool{
        if let date = birthday{
            let currentDate = Date()
            return currentDate > date
        }
        return false
    }
    
    func checkForPersonalization(pData: PatientExists) -> Bool{
        var valid = true
        if !(pData.garmentSize == "Small" || pData.garmentSize == "Medium"){
            valid = false
        }
        
        let sch = TherapySchedules(rawValue: pData.therapySchedule)
        if sch == .unknownSchedule {
            valid = false
        }
        
        if pData.mostBothersomeSymptom == nil{
            valid = false
        }
        if pData.diagnosisCode == nil{
            valid = false
        }
        return valid
    }
}
