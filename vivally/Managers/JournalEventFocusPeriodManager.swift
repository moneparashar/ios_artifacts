/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import Alamofire

class JournalEventFocusPeriodManager: NSObject {
    static let sharedInstance = JournalEventFocusPeriodManager()
    
    var inFocus = false
    var currentFocusPeriod: JournalEventFocusPeriod?
    
    func getLatestFocus(completion:@escaping (Bool, JournalEventFocusPeriod?, String)->()){
        APIClient.getLatestFocusPeriod(){ success, result, errorMessage in
            if success{
                self.syncJournalFocus(cloudFocus: result){
                    completion(true, result, errorMessage)
                }
            }
            else{
                completion(success, result, errorMessage)
            }
        }
    }
    
    func postpostLatestFocusPeriod(completion:@escaping (Bool, JournalEventFocusPeriod?, String)->()){
        APIClient.postponeLatestFocusPeriod(){ success, result, errorMessage in
            if success{
                completion(true, result, errorMessage)
            }
            else{
                completion(success, result, errorMessage)
            }
        }
    }
    
    func startLatestFocusPeriod(completion:@escaping (Bool, JournalEventFocusPeriod?, String)->()){
        APIClient.startLatestFocusPeriod(){ success, result, errorMessage in
            if success{
                completion(true, result, errorMessage)
            }
            else{
                completion(success, result, errorMessage)
            }
        }
    }
    
    
    
    //to display banner
    func checkForFocus(focus: JournalEventFocusPeriod?) -> Bool{
        inFocus = false
        if let fp = focus{
            inFocus = fp.postponedCount < 3 && fp.acknowledged != nil
            let today = Date()
            if fp.acknowledged != nil{
                if let differenceDays = Calendar.utcCal.dateComponents([.day], from: fp.acknowledged!, to: today).day{
                    inFocus = differenceDays < 3
                }
            }
        }
        else{
            inFocus = false
        }
        return inFocus
    }
    
    func askToBeginFocus() -> Bool{
        if currentFocusPeriod != nil{
            return (currentFocusPeriod!.acknowledged == nil && currentFocusPeriod!.startedDateUtc <= Date())
        }
        return false
    }
    
    
    
    func loadFocus() -> JournalEventFocusPeriod?{
        let defaults = UserDefaults.standard
        if let journalFocus = defaults.object(forKey: "JournalFocus"){
            do{
                currentFocusPeriod = try JSONDecoder().decode(JournalEventFocusPeriod.self, from: journalFocus as! Data)
            } catch{ currentFocusPeriod = nil}
        }
        return currentFocusPeriod
    }
    
    func saveFocus(){
        if currentFocusPeriod != nil{
            let journalFocus = try? JSONEncoder().encode(currentFocusPeriod)
            let defaults = UserDefaults.standard
            defaults.set(journalFocus, forKey: "JournalFocus")
        }
        else{
            clearFocus()
        }
    }
    
    func clearFocus(){
        UserDefaults.standard.removeObject(forKey: "JournalFocus")
    }
    
    
    var journalFocusSending = false
    func syncJournalFocus(cloudFocus: JournalEventFocusPeriod?, completion:@escaping() -> ()){
        journalFocusSending = true
        if cloudFocus == nil{
            clearFocus()
            journalFocusSending = false
            completion()
        }
        else if let appFocus = loadFocus(){
            if let appModified = appFocus.modified{
                var needsUpdate = false
                if let cloudModified = cloudFocus?.modified{
                    if Calendar.utcCal.compare(appModified, to: cloudModified, toGranularity: .minute) == .orderedDescending {
                        needsUpdate = true
                    }
                }
                else{
                    needsUpdate = true
                }
                
                if needsUpdate{
                    let group = DispatchGroup()
                    group.enter()
                    group.enter()
                    
                    if appFocus.acknowledged != nil && cloudFocus?.acknowledged == nil{
                        startLatestFocusPeriod(){ success, result, errorMessage in
                            group.leave()
                        }
                    }
                    else{
                        group.leave()
                        
                    }
                    
                    if appFocus.postponedCount > cloudFocus?.postponedCount ?? 0{
                        let postponements = appFocus.postponedCount - (cloudFocus?.postponedCount ?? 0)
                        let postponeGroup = DispatchGroup()
                        for _ in 1...postponements{
                            postponeGroup.enter()
                        }
                        for _ in 1...postponements{
                            postpostLatestFocusPeriod(){ success, result, errorMessage in
                                postponeGroup.leave()
                            }
                        }
                        postponeGroup.notify(queue: DispatchQueue.global()){
                            group.leave()
                        }
                    }
                    else{
                        group.leave()
                    }
                    
                    group.notify(queue: DispatchQueue.global()){
                        completion()
                    }
                }
                else{
                    currentFocusPeriod = cloudFocus
                    saveFocus()
                    journalFocusSending = false
                    completion()
                }
            }
            else{
                currentFocusPeriod = cloudFocus
                saveFocus()
                journalFocusSending = false
                completion()
            }
        }
        else{
            currentFocusPeriod = cloudFocus
            saveFocus()
            journalFocusSending = false
            completion()
        }
        
    }
}
