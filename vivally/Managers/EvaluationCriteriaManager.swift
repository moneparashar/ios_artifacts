/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import SwiftKeychainWrapper

class EvaluationCriteriaManager: NSObject {
    static let sharedInstance = EvaluationCriteriaManager()
    
    var evalCrit:EvaluationCriteria?
    
    //user defaults attempt
    func loadEvalCritData() -> PatientEvaluationCriteria?{
        var data = PatientEvaluationCriteria()
        if let evaltDataObject = UserDefaults.standard.data(forKey: "patientEvalCrit"){
            do{
                let decoder = JSONDecoder()
                    data = try decoder.decode(PatientEvaluationCriteria.self, from: evaltDataObject)
            }catch _{
                
                //Slim.info("Patient Eval Data Defaulting because decode fails with error")
                saveEvalConfigData(data: PatientEvaluationCriteria())
                return PatientEvaluationCriteria()
            }
        }
        else{
            //Slim.info("Patient Eval Data Defaulting because evaltDataObject not found")
            saveEvalConfigData(data: PatientEvaluationCriteria())
        }
        return data
    }
    func clearEvalConfigData(){
        UserDefaults.standard.removeObject(forKey: "patientEvalCrit")
    }
    func saveEvalConfigData(data: PatientEvaluationCriteria){
        do{
            //making sure evals screenings guids are saved correctly
            if data.left != nil{
                data.left?.screeningGuid = data.screeningGuid
            }
            if data.right != nil{
                data.right?.screeningGuid = data.screeningGuid
            }
            
            let encoder = JSONEncoder()
            let ado = try encoder.encode(data)
            UserDefaults.standard.set(ado, forKey: "patientEvalCrit")
        } catch{
            print("unable to save patient eval crit data")
        }
    }
    
    func checkEvalCriteriaShouldOverwriteLocal(data: PatientEvaluationCriteria) -> Bool{
        let currentEvalCrit = loadEvalCritData()
        if data.screeningGuid != currentEvalCrit?.screeningGuid{
            return true
        }
        else{
            //left foot checks
            if currentEvalCrit?.left?.guid == data.left?.guid{
                if let remoteMod = data.left?.modified, let currentMod = currentEvalCrit?.left?.modified{
                    if remoteMod > currentMod{
                        return true
                    }
                }
                else if data.left?.modified != nil{
                    return true
                }
            }
            else if let remoteTmstp = data.left?.timestamp, let currentTmstp = currentEvalCrit?.left?.timestamp{
                if remoteTmstp > currentTmstp{
                    return true
                }
            }
            //right foot checks
            else if currentEvalCrit?.right?.guid == data.right?.guid{
                if let remoteMod = data.right?.modified, let currentMod = currentEvalCrit?.right?.modified{
                    if remoteMod > currentMod{
                        return true
                    }
                }
                else if data.right?.modified != nil{
                    return true
                }
            }
            else if let remoteTmstp = data.right?.timestamp, let currentTmstp = currentEvalCrit?.right?.timestamp{
                if remoteTmstp > currentTmstp{
                    return true
                }
            }
        }
        return false
    }
    
    func saveEvalCritTimePulled(){
        let lastTime = Date()
        UserDefaults.standard.set(lastTime.timeIntervalSince1970, forKey: "lastEvalCritPulled")
    }
    
    func checkEvalCritLastTimeOver() -> Bool{
        let lastDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "lastEvalCritPulled"))
        
        if let timeDifference = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day{
            if timeDifference < 32{
                return false
            }
        }
        return true
    }
    
    func postEvalCriteria(evaluationCriteria:EvaluationCriteria, completion:@escaping (Bool, EvaluationCriteria?, String)->()) {
        APIClient.postEvaluationCriteria(evaluationCriteria: evaluationCriteria) { success, result, errorMessage, authorized in
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
    
    func putEvalCriteria(evaluationCriteria:EvaluationCriteria, completion:@escaping (Bool, EvaluationCriteria?, String)->()) {
        APIClient.putEvaluationCriteria(evaluationCriteria: evaluationCriteria) { success, result, errorMessage, authorized in
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
    
    func getEvalCriteriaPatient(completion:@escaping(Bool, PatientEvaluationCriteria?, String) ->()){
        APIClient.getEvalCritPatient(){ success, result, errorMessage, authorized in
            if success{
                self.saveEvalCritTimePulled()
                completion(true, result, errorMessage)
            }
            else{
                //Slim.error("Unsuccessful GET eval: \(errorMessage)")
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(true, result, errorMessage)
            }
        }
    }
    
    func updateEvalSchedule(){
        let accountData = KeychainManager.sharedInstance.loadAccountData()
        let schedule = accountData?.userModel?.therapySchedule
        if let eval = loadEvalCritData(){
            if eval.isValid ?? false{
                if let left = eval.left{
                    left.therapySchedule = schedule ?? 0
                    eval.left = left
                }
                if let right = eval.right{
                    right.therapySchedule = schedule ?? 0
                    eval.right = right
                }
                saveEvalConfigData(data: eval)
            }
        }
    }
    
    var criteriaSending = false
    //currently for patients since admin already has their own check
    func syncSendEvalData(completion:@escaping() -> ()){
        if let critData = loadEvalCritData(){
            if let left = critData.left, let right = critData.right{
                if left.dirty || right.dirty{
                    criteriaSending = true
                    putEvalCriteria(evaluationCriteria: left){ success, result, errorMessage in
                        if success{
                            left.dirty = false
                            self.putEvalCriteria(evaluationCriteria: right){ success2, result2, errorMessage2 in
                                if success2{
                                    right.dirty = false
                                    critData.left = left
                                    critData.right = right
                                    self.saveEvalConfigData(data: critData)
                                }
                                else{
                                    Slim.error("error updating right eval criteria from pair")
                                }
                                self.criteriaSending = false
                                completion()
                            }
                        }
                        else{
                            Slim.error("error updating left eval criteria from pair")
                            self.criteriaSending = false
                            completion()
                        }
                        
                    }
                }
                else{
                    criteriaSending = false
                    completion()
                }
            }
            else if let left = critData.left{
                if left.dirty{
                    criteriaSending = true
                    putEvalCriteria(evaluationCriteria: left){ success, result, errorMessage in
                        if success{
                            left.dirty = false
                            critData.left = left
                            self.saveEvalConfigData(data: critData)
                        }
                        else{
                            Slim.error("error updating left eval criteria")
                        }
                        self.criteriaSending = false
                        completion()
                    }
                }
                else{
                    criteriaSending = false
                    completion()
                }
            }
            else if let right = critData.right{
                if right.dirty{
                    criteriaSending = true
                    putEvalCriteria(evaluationCriteria: right){ sucess, result, errorMessage in
                        if sucess{
                            right.dirty = false
                            critData.right = right
                            self.saveEvalConfigData(data: critData)
                        }
                        else{
                            Slim.error("error updating right eval criteria")
                        }
                        self.criteriaSending = false
                        completion()
                    }
                }
                else{
                    criteriaSending = false
                    completion()
                }
            }
            else{
                criteriaSending = false
                completion()
            }
        }
    }
    
    
}
