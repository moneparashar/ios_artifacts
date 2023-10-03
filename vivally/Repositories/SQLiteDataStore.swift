/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum DataAccessError: Error {
    case Datastore_Connection_Error
    case Insert_Error
    case Update_Error
    case Delete_Error
    case Search_Error
    case Nil_In_Data
}

class SQLiteDataStore: NSObject {
    static let sharedInstance = SQLiteDataStore()
        let AVATIONDB: Connection?
       
    let latestVersion = 2
    
    func setupDatabase(){
        do{
            try createTables()
            try checkVersion()
        }
        catch{
            print(error)
        }
    }
    
    func saveDBVersion(ver: Int){
        UserDefaults.standard.set(ver, forKey: "dbVersion")
    }
    
    func loadDBVersion() -> Int{
        let version = UserDefaults.standard.integer(forKey: "dbVersion")
        return version
    }
    
    func checkVersion() throws{
        let version = loadDBVersion()
        if version != latestVersion{
            //trigger migration checks for all repos
            /*
            do{
                try AppDeviceDataHelper.handleMigration()
                try DeviceConfigDataHelper.handleMigration()
                try EMGDataDataHelper.handleMigration()
                try JournalEventsDataHelper.handleMigration()
                try SessionDataDataHelper.handleMigration()
                try StimDataDataHelper.handleMigration()
                try StimDeviceDataHelper.handleMigration()
                
                saveDBVersion(ver: latestVersion)
            } catch{
                throw DataAccessError.Datastore_Connection_Error
            }
            */
            if version == 0 || version == 1{
                //timestamps change
                do{
                    guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                            throw DataAccessError.Datastore_Connection_Error
                    }
                    
                    try DB.run(JournalEventsDataHelper.table.dropColumn(colName: "\"eventTimestamp\""))
                    try DB.run(SessionDataDataHelper.table.dropColumn(colName: "\"eventTimestamp\""))
                    
                    try DB.run(JournalEventsDataHelper.table.addColumn(JournalEventsDataHelper.eventTimestamp, defaultValue: ""))
                    try DB.run(SessionDataDataHelper.table.addColumn(SessionDataDataHelper.eventTimestamp, defaultValue: ""))
                    
                    try DB.run(JournalEventsDataHelper.table.addColumn(JournalEventsDataHelper.eventDate))
                    try DB.run(SessionDataDataHelper.table.addColumn(SessionDataDataHelper.eventDate))
                    
                    saveDBVersion(ver: latestVersion)
                } catch{
                    throw DataAccessError.Datastore_Connection_Error
                }
            }
            
        }
    }
    
    private override init() {
           
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        
           
            do {
                AVATIONDB = try Connection("\(path)/AVATION.sqlite3")
            } catch _ {
                AVATIONDB = nil
            }
        }
       
        func createTables() throws{
            do {
                try AppDeviceDataHelper.createTable()
                try StimDataDataHelper.createTable()
                try EMGDataDataHelper.createTable()
                try JournalEventsDataHelper.createTable()
                try SessionDataDataHelper.createTable()
                try DeviceConfigDataHelper.createTable()
                try StimDeviceDataHelper.createTable()
            } catch {
                throw DataAccessError.Datastore_Connection_Error
            }
        }
}
