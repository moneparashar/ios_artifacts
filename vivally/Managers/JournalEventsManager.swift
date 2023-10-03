/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import Alamofire

class JournalEventsManager: NSObject {
    static let sharedInstance = JournalEventsManager()
    
    var selectedDateCheck = Date()
    var monthlyDateContainer = Date()
    var scrollDate = Date()
    
    var edit = false
    var comingFromHomeVc = false
    
    var isEdit = false
        
    func postJournalEvents(journalEvents:JournalEvents, isLast: Bool = false ,completion:@escaping (Bool, JournalEvents?, String, Bool)->()){
        APIClient.postJournalEvents(journalEvents: journalEvents){ success, result, errorMessage, authorized in
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
    
    func putJournalEvents(journalEvents:JournalEvents, isLast: Bool = false ,completion:@escaping (Bool, String, Bool)->()){
        APIClient.putJournalEvents(journalEvents: journalEvents){ success, errorMessage, authorized in
            if success{
                completion(true, errorMessage, isLast)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, errorMessage, isLast)
            }
        }
    }
    
    func getJournalEvents(deleted:Bool, completion:@escaping (Bool, [JournalEvents?], String) -> ()) {
        print("get journal events start")
        APIClient.getJournalEvents(deleted: deleted){ success, result, errorMessage, authorized in
            if success{
                APIClient.getJournalEvents(deleted: true){ success2, result2, errorMessage2, authorized2 in
                    if success{
                        self.newTableSync(events: result, deletedEvents: result2)
                        completion(true, result, errorMessage)
                    }
                    else{
                        if !authorized2{
                            RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                        }
                        completion(success2, result, errorMessage2)
                    }
                }
               
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, result, errorMessage)
            }

        }
    }
    
    var journalSending = false
    func syncSendJournalEventsData(completion:@escaping() -> ()){
        // do post after failed put
        //for when user creates a new journal but edits it before it was ever sent to cloud
        do{
            let leftToSend = try JournalEventsDataHelper.getLatestLeftToSend()
            if leftToSend.isEmpty{
                journalSending = false
                print("completion 1")
                completion()
                return
            }
            journalSending = true
            var isLast = false
            var index = 0
            for je in leftToSend{
                isLast = index == leftToSend.count - 1
                
                if je.modified != je.timestamp{
                    putJournalEvents(journalEvents: je, isLast: isLast){ success, errorMessage, wasLast in
                        if success{
                            do{
                                try JournalEventsDataHelper.setSentClean(sentJournalEvents: je)
                            } catch{
                                print("error with journal put")
                            }
                            if wasLast{
                                self.journalSending = false
                                print("completion 2")
                                completion()
                            }
                        }
                        else{
                            self.syncSendJournalPost(je: je, last: wasLast, failedPut: true){ wasLast2 in
                                if wasLast2{
                                    print("completion 3")
                                    completion()
                                }
                            }
                        }
                    }
                }
                else{
                    syncSendJournalPost(je: je, last: isLast){ wasLast in
                        if wasLast{
                            print("completion 4")
                            completion()
                        }
                    }
                }
                index += 1
            }
        } catch{
            Slim.error("error with journal db getting left to send")
            print("completion 5")
            completion()
        }
    }
    
    func syncSendJournalPost(je: JournalEvents, last: Bool, failedPut: Bool = false, completion:@escaping(Bool) -> ()){
        postJournalEvents(journalEvents: je) { success, count, errorMessage, wasLast in
            if success{
                do{
                    try JournalEventsDataHelper.setSentClean(sentJournalEvents: je)
                } catch{
                    Slim.error("error with setting sent journal clean")
                }
            }
            else{
                failedPut ? Slim.error("error with journal post after failing put"): Slim.error("error with journal post")
            }
            if last{
                self.journalSending = false
            }
            completion(last)
        }
    }
    
    
    //following assumption to pull then push events
    func newTableSync(events: [JournalEvents?], deletedEvents: [JournalEvents?]){
        do{
            //let user = KeychainManager.sharedInstance.accountData!.username
            for item in events{
                let found = try JournalEventsDataHelper.find(uid: item!.guid.uuidString)
                if found != nil{
                    _ = try JournalEventsDataHelper.update(item: item!)
                }
                else{
                    _ = try JournalEventsDataHelper.insert(item: item!)
                }
            }
            
            for del in deletedEvents{
                let found = try JournalEventsDataHelper.find(uid: del!.guid.uuidString)
                if found != nil{
                    try JournalEventsDataHelper.delete(item: del!)
                }
            }
            
            syncSendJournalEventsData(){}
            
            
        } catch{
            print("error with journal sync")
        }
    }
    
    //new journal changes
    
    var allDayJournals:[JournalEvents] = []     //also used for main entry 
    var journalSects:[JournalDayEntryNavigationPages:JournalEvents] = [:]       //used in main entry
    
    //need to tweak to get just day, week, month
    func getJournalList(jrange: JournalTimeRanges = .daily,completion:@escaping([[JournalEvents]]) -> ()){ //[day][Journal Events]
        var fullJournal:[[JournalEvents]] = [[]]
        
        do{
            fullJournal = try JournalEventsDataHelper.findAllNotDeletedUTCList(name: KeychainManager.sharedInstance.accountData!.username) ?? []
        } catch{
            print("error with getting utc journal list")
        }
        
       // return fullJournal
        completion(fullJournal)
    }
    
    //for main entry
    func idRange(event: JournalEvents) -> JournalDayEntryNavigationPages?{
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        if let eventDate = event.eventTimestamp.treatTimestampStrAsDate(){
            let hour = cal.component(.hour, from: eventDate)
            
            switch hour {
            case 6 ... 11:
                return .morning
            case 12 ... 17:
                return .afternoon
            case 18 ... 23:
                return .evening
            case 0 ... 5:
                return .night
            default:
                return nil
            }
        }
        return nil
    }
    
    func setRange(journalEvent: JournalEvents, navpage: JournalDayEntryNavigationPages) -> JournalEvents{
        let je = journalEvent
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        
        var hour = 0
        switch navpage{
        case .morning:
            hour = 6
        case .afternoon:
            hour = 12
        case .evening:
            hour = 18
        case .night:
            hour = 0
        }
        
        if let tmstp = je.eventTimestamp.treatTimestampStrAsDate(){
            let startDay = cal.startOfDay(for: tmstp)
            if let newDate = cal.date(byAdding: .hour, value: hour, to: startDay){
                je.eventTimestamp = newDate.convertDateToOffsetStr()
            }
        }
        
        return je
    }
    
    //when adding/editing entries
    func setNewEntries(date: Date) -> [JournalEvents]{
        var rangeJournals:[JournalEvents] = []
        let username = KeychainManager.sharedInstance.loadAccountData()?.username ?? ""
                
        for nav in JournalDayEntryNavigationPages.allCases{
            let je = JournalEvents()
            je.eventTimestamp = date.convertDateToOffsetStr()
            
            let rangeJe = setRange(journalEvent: je, navpage: nav)
            rangeJe.username = username
            rangeJournals.append(rangeJe)
        }
        
        return rangeJournals
    }
    
    func setOldEntries(currentJes: [JournalEvents]) -> [JournalEvents]{
        var rangeJournals:[JournalEvents] = []
        let username = KeychainManager.sharedInstance.loadAccountData()?.username ?? ""
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        for nav in JournalDayEntryNavigationPages.allCases{
            var navSet = false
            
            for je in currentJes{
                if let tstmp = je.eventTimestamp.treatTimestampStrAsDate(){
                    let hour = cal.component(.hour, from: tstmp)
                    
                    if nav.insideRange(hour: hour){
                        rangeJournals.append(je)
                        navSet = true
                        break
                    }
                }
            }
            
            if !navSet{
                let je = JournalEvents()
                je.eventTimestamp = currentJes.first?.eventTimestamp ?? ""
                let rangeJe = setRange(journalEvent: je, navpage: nav)
                
                rangeJe.username = username
                rangeJournals.append(rangeJe)
            }
        }
        return rangeJournals
    }
    
    func didJournalsChange(oldJe: JournalEvents, currentJe: JournalEvents) -> Bool{
        if oldJe.eventTimestamp != currentJe.eventTimestamp && !oldJe.isEmpty(){
            return true
        }
        
        if oldJe.drinksWaterOther == currentJe.drinksWaterOther && oldJe.drinksCaffeinated == currentJe.drinksCaffeinated && oldJe.drinksAlcohol == currentJe.drinksAlcohol &&
            oldJe.restroomDrops == currentJe.restroomDrops && oldJe.restroomUrges == currentJe.restroomUrges && oldJe.restroomSleep == currentJe.restroomSleep &&
            oldJe.accidentsDrops == currentJe.accidentsDrops && oldJe.accidentsUrges == currentJe.accidentsUrges && oldJe.accidentsChanges == currentJe.accidentsChanges && oldJe.accidentsSleep == currentJe.accidentsSleep && oldJe.lifeGelPads == currentJe.lifeGelPads && oldJe.lifeMedication == currentJe.lifeMedication && oldJe.lifeExercise == currentJe.lifeExercise && oldJe.lifeDiet == currentJe.lifeDiet && oldJe.lifeStress == currentJe.lifeStress{
            return false
        }
        
        return true
    }

    
    //returns only the journals the db needs to change
    func saveAllowed(oldEntry: [JournalDayEntryNavigationPages: JournalEvents], currentEntry: [JournalDayEntryNavigationPages: JournalEvents]) -> [JournalDayEntryNavigationPages: JournalEvents]?{
        var changedJournals:[JournalDayEntryNavigationPages: JournalEvents] = [:]
        
        for nav in JournalDayEntryNavigationPages.allCases{
            if let newJ = currentEntry[nav], let oldJ = oldEntry[nav]{
                //let dayRange = nav != .life
                if didJournalsChange(oldJe: oldJ, currentJe: newJ){
                    changedJournals[nav] = newJ
                }
                
            }
        }
        
        if !changedJournals.isEmpty{
            return changedJournals
        }
        
        return nil
    }
    
    func addJournalEvent(je: JournalEvents){
        let journalAdd = je
        do{
            journalAdd.dirty = true
            _ = try JournalEventsDataHelper.insert(item: journalAdd)
        } catch{
            Slim.info("error with journal insert")
        }
    }
    
    func updateJournalEvent(je: JournalEvents){
        let journalUpdate = je
        journalUpdate.deleted = journalUpdate.isEmpty()
        do{
            journalUpdate.dirty = true
            _ = try JournalEventsDataHelper.update(item: journalUpdate)
        } catch{
            Slim.info("error with journal update")
        }
    }
    
    //pass only the journals to update
    func saveEntry(rangeJournals: [JournalEvents], completion:@escaping() -> ()){
        for je in rangeJournals{
            if je.modified != nil{
                updateJournalEvent(je: je)
            }
            else{
                addJournalEvent(je: je)
                NotificationManager.sharedInstance.resetJournalNotify()
            }
            if je.lifeGelPads == true{
                NotificationManager.sharedInstance.resetGelNotify()
            }
        }
        NetworkManager.sharedInstance.sendJournalData(){}
        completion()
    }
    
    func deleteEntry(rangeJournals: [JournalEvents], completion:@escaping() -> ()){
        for je in rangeJournals{
            je.deleted = true
            je.modified = Date()
            je.dirty = true
            do{
                _  = try JournalEventsDataHelper.update(item: je)
            } catch{
                Slim.info("error with journal delete")
            }
        }
        NetworkManager.sharedInstance.sendJournalData {}
        completion()
    }
    
    //end of utc journal changes
}
