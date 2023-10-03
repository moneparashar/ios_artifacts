/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class EulaManager: NSObject{
    static let sharedInstance = EulaManager()
    
    var eulaHtml: EulaHTML?
    
    func clearEulaData(){
        UserDefaults.standard.removeObject(forKey: "eula")
    }
    
    func loadEula() -> EulaHTML?{
        var data = EulaHTML()
        if let eda = UserDefaults.standard.data(forKey: "eula"){
            do{
                let decoder = JSONDecoder()
                data = try decoder.decode(EulaHTML.self, from: eda)
                eulaHtml = data
            } catch _{
                saveEula(data: EulaHTML())
                eulaHtml = EulaHTML()
                return EulaHTML()
            }
        }
        else{
            saveEula(data: EulaHTML())
            eulaHtml = EulaHTML()
            return EulaHTML()
        }
        return data
    }
    
    func saveEula(data: EulaHTML){
        do{
            let encoder = JSONEncoder()
            let edo = try encoder.encode(data)
            UserDefaults.standard.set(edo, forKey: "eula")
            eulaHtml = data
        } catch{
            print("unable to save eula")
        }
    }
    
    func getPatientEulaPDF(completion:@escaping(Bool, String) -> ()){
        APIClient.getEulaPatientPDF(){ success, errorMessage, authorized in
            if success{
                completion(true, errorMessage)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, errorMessage)
            }
        }
    }
    
    func getClinicianEulaPDF(completion:@escaping(Bool, String) -> ()){
        APIClient.getEulaPatientPDF(){ success, errorMessage, authorized in
            if success{
                completion(true, errorMessage)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, errorMessage)
            }
        }
    }
    
    func getEulaClinician(completion:@escaping(Bool, EulaHTML?, String) -> ()){
        APIClient.getEulaClinician(){ success, result, errorMessage, authorized in
            if success{
                if self.eulaHtml != nil && result != nil{
                    if self.eulaHtml?.html != result?.html{
                        self.saveEula(data: result!)
                    }
                }
                else if result != nil{
                    self.saveEula(data: result!)
                }
            }
            completion(success, result, errorMessage)
        }
    }
    
    func getEulaPatient(completion:@escaping(Bool, EulaHTML?, String) -> ()){
        APIClient.getEulaPatient(){ success, result, errorMessage, authorized in
            if success{
                if self.eulaHtml != nil && result != nil{
                    if self.eulaHtml?.html != result?.html{
                        self.saveEula(data: result!)
                    }
                }
                else if result != nil{
                    self.saveEula(data: result!)
                }
            }
            completion(success, result, errorMessage)
        }
    }
}
