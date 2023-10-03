/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */



import UIKit
import SwiftKeychainWrapper

class PatientStudyManager: NSObject {
    static let sharedInstance = PatientStudyManager()
    
    var patientStudy:Study?
    var isSham = false
    
    func loadPatientData() -> Study? {
        var data = Study()
        if let studyDataObject = UserDefaults.standard.data(forKey: "patientStudy"){
            do{
                let decoder = JSONDecoder()
                    data = try decoder.decode(Study.self, from: studyDataObject)
            }catch _{
                
                Slim.info("Patient Data Defaulting because decode fails with error")
                savePatientClinicData(data: Study())
                return Study()
            }
        }
        else{
            Slim.info("Patient Data Defaulting because studyDataObject not found")
            savePatientClinicData(data: Study())
        }
        return data
    }
    func clearPatientStudy(){
        UserDefaults.standard.removeObject(forKey: "patientStudy")
    }
    func savePatientClinicData(data: Study){
        do{
            let encoder = JSONEncoder()
            let ado = try encoder.encode(data)
            UserDefaults.standard.set(ado, forKey: "patientStudy")
            patientStudy = data
        } catch{
            print("unable to save patient data")
        }
    }
    
    func getClinic(completion:@escaping(Bool, Study?, String) -> ()){
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
    
    
}

