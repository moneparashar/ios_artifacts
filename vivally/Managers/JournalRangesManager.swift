/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation
class JournalRangesManager: NSObject {
    static let sharedInstance = JournalRangesManager()
    
    
    func getJournalList(jrange: JournalTimeRanges = .daily, jpass: Date, completion:@escaping([[JournalEvents]]) -> ()){ //[day][Journal Events]
        var fullJournal:[[JournalEvents]] = [[]]
        
        do{
            fullJournal = try JournalEventsDataHelper.findAllNotDeletedUTCList(name: KeychainManager.sharedInstance.accountData!.username, journalRange: jrange, passDate: jpass) ?? []
        } catch{
            print("error with getting utc journal list")
        }
        
       // return fullJournal
        completion(fullJournal)
    }
    
    func checkForDrinks(je: JournalEvents) -> Bool{
        if je.drinksWaterOther! > 0 || je.drinksCaffeinated! > 0 || je.drinksAlcohol! > 0{
            
            return true
        }
        
        return false
    }
    
    func checkForRestroomLeaksAndUrges(je: JournalEvents) -> Bool{
        if je.restroomUrges! > 0 || je.restroomDrops! > 0 ||  je.accidentsUrges! > 0 ||
            je.accidentsDrops! > 0 {
            
            return true
        }
        
        return false
    }
    
    func checkForRestroom(je: JournalEvents) -> Bool{
        return je.restroomDrops! > 0 || je.restroomSleep! > 0 || je.restroomUrges! > 0
    }
    
    func checkForLeaks(je: JournalEvents) -> Bool{
        return je.accidentsDrops! > 0 || je.accidentsUrges! > 0 || je.accidentsChanges! > 0
    }
}
