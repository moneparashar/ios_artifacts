/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class SessionDataManager: NSObject {
    static let sharedInstance = SessionDataManager()
    
    func postSessionData(sessionData:SessionData, isLast: Bool = false, completion:@escaping (Bool, String, Bool) -> ()) {
        APIClient.postSessionData(sessionData: sessionData){ success, errorMessage, authorized in
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
    
    func putSessionData(sessionData:SessionData, isLast: Bool = false, completion:@escaping (Bool, SessionData?, String, Bool) -> ()) {
        APIClient.putSessionData(sessionData: sessionData){ success, result, errorMessage, authorized in
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
    
    func getSessionData(completion:@escaping (Bool, [SessionData?], String) -> ()) {
        APIClient.getSessionData(){ success, result, errorMessage, authorized in
            if success{
                self.newTableSync(sessionsData: result)
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
    
    func newTableSync(sessionsData: [SessionData?]){
        do{
            var count = 0
            for item in sessionsData{
                let found = try SessionDataDataHelper.find(uid: item!.guid.uuidString)
                if found != nil{
                    _ = try SessionDataDataHelper.update(item: item!)
                }
                else{
                    _ = try SessionDataDataHelper.insert(item: item!)
                }
                
                count += 1
                if count == sessionsData.count{
                    DatabaseManager.sharedInstance.sessionDBLoadComplete()
                }
            }
            
            syncSendSessionDataData(){}
        } catch{
            print("error with session sync")
        }
    }
    
    var sessionDataSending = false
    func syncSendSessionDataData(completion:@escaping() -> ()){
        do{
            let leftToSend = try SessionDataDataHelper.getLatestLeftToSend()
            if leftToSend.isEmpty{
                sessionDataSending = false
                completion()
                return
            }
            sessionDataSending = true
            var isLast = false
            var index = 0
            for sd in leftToSend{
                isLast = index == leftToSend.count - 1
                if sd.modified != sd.timestamp{
                    putSessionData(sessionData: sd, isLast: isLast){ success, result, errorMessage, wasLast in
                        if success{
                            do{
                                try SessionDataDataHelper.setSentClean(sentSessionData: sd)
                            } catch{

                            }
                            if wasLast{
                                self.sessionDataSending = false
                                print("completion from success put")
                                completion()
                            }
                        }
                        else{
                            self.syncSendSessionPost(sd: sd, last: wasLast, failedPut: true){ wasLast2 in
                                if wasLast2{
                                    print("completion from fail put, then trying post")
                                    completion()
                                }
                            }
                        }
                    }
                }
                else{
                    self.syncSendSessionPost(sd: sd, last: isLast){ wasLast in
                        if wasLast{
                            print("completion from new post")
                            completion()
                        }
                    }
                }
                index += 1
            }
        } catch{
            Slim.error("error with session db getting left to send")
            print("completion from fail to get left to send")
            completion()
        }
    }
    
    func syncSendSessionPost(sd: SessionData, last: Bool, failedPut: Bool = false, completion:@escaping(Bool) -> ()){
        postSessionData(sessionData: sd){ success, errorMessage, wasLast  in
            if success{
                do{
                    try SessionDataDataHelper.setSentClean(sentSessionData: sd)
                } catch{
                    Slim.error("error with setting sent session clean")
                }
            }
            else{
                failedPut ? Slim.error("error with session post after failing put"): Slim.error("error with session post")
            }
            if last{
                self.sessionDataSending = false
            }
            completion(last)
        }
    }
    
    func getLocalTherapyList(date: Date, onlyComplete: Bool, completion:@escaping([[SessionData]]) -> ()){
        var fullTherapy:[[SessionData]] = []
        do{
            if let name = KeychainManager.sharedInstance.loadAccountData()?.username{
                fullTherapy = try SessionDataDataHelper.findWeekRangeNotDeleted(name: name, isCompleteOnly: onlyComplete, passDate: date) ?? []
            }
        } catch{
            print("error with getting utc therapy list")
        }
        
        completion(fullTherapy)
    }
    
}
