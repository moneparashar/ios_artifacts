/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class DeviceConfigDataHelper: DataHelperProtocol {
    typealias T = DeviceConfig
    static let TABLE_NAME = "DeviceConfig"
    static let table = Table(TABLE_NAME)
    
    static let guid = Expression<String>("guid")
    static let id = Expression<Int>("id")
    static let timestamp = Expression<Date>("timestamp")
    static let modified = Expression<Date?>("modified")
    static let dirty = Expression<Bool>("dirty")
    static let deleted = Expression<Bool>("deleted")
    static let appVersion = Expression<String?>("appVersion")
    static let firmwareVersion = Expression<String?>("firmwareVersion")
    static let appDeviceGuid = Expression<String?>("appDeviceGuid")
    static let stimDeviceGuid = Expression<String?>("stimDeviceGuid")
    static let screeningGuid = Expression<String?>("screeningGuid")
    
    
    
    static func createTable() throws {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
            }
            do {
                let _ = try DB.run( table.create(ifNotExists: true) {t in
                    t.column(guid, primaryKey: true)
                    t.column(id)
                    t.column(timestamp)
                    t.column(modified)
                    t.column(dirty)
                    t.column(deleted)
                    t.column(appVersion)
                    t.column(firmwareVersion)
                    t.column(appDeviceGuid)
                    t.column(stimDeviceGuid)
                    t.column(screeningGuid)
                    })
                
            } catch _ {
                // Error throw if table already exists
            }
            
        }
        
        static func insert(item: T) throws -> Int64 {
            guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
            }
                let insert = table.insert(
                    guid <- item.guid.uuidString,
                    id <- item.id,
                    timestamp <- item.timestamp,
                    modified <- item.modified,
                    dirty <- item.dirty,
                    deleted <- item.deleted,
                    appVersion <- item.appVersion,
                    firmwareVersion <- item.firmwareVersion,
                    appDeviceGuid <- (item.appDeviceGuid == nil ? nil : item.appDeviceGuid?.uuidString) ,
                    stimDeviceGuid <- (item.stimDeviceGuid == nil ? nil : item.stimDeviceGuid?.uuidString),
                    screeningGuid <- (item.screeningGuid == nil ? nil : item.screeningGuid?.uuidString)
                 )
                do {
                    let rowId = try DB.run(insert)
                    guard rowId > 0 else {
                        throw DataAccessError.Insert_Error
                    }
                    return rowId
                } catch {
                    print("Unexpected error: \(error)")
                    throw DataAccessError.Insert_Error
                }
        }
    
    static func update(item: T) throws -> Int {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let filtered = table.filter(guid == item.guid.uuidString)
        let update = filtered.update(
            guid <- item.guid.uuidString,
            id <- item.id,
            timestamp <- item.timestamp,
            modified <- item.modified,
            dirty <- item.dirty,
            deleted <- item.deleted,
            appVersion <- item.appVersion,
            firmwareVersion <- item.firmwareVersion,
            appDeviceGuid <- (item.appDeviceGuid == nil ? nil : item.appDeviceGuid?.uuidString) ,
            stimDeviceGuid <- (item.stimDeviceGuid == nil ? nil : item.stimDeviceGuid?.uuidString),
            screeningGuid <- (item.screeningGuid == nil ? nil : item.screeningGuid?.uuidString)
        )
        do{
            let rowId = try DB.run(update)
            guard rowId > 0 else {
                throw DataAccessError.Update_Error
            }
            return rowId
        } catch{
            throw DataAccessError.Insert_Error
        }
    }
        
        static func delete (item: T) throws -> Void {
            guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
            }
                let query = table.filter(guid == item.guid.uuidString)
                do {
                    let tmp = try DB.run(query.delete())
                    guard tmp == 1 else {
                        throw DataAccessError.Delete_Error
                    }
                } catch _ {
                    throw DataAccessError.Delete_Error
                }
        }
        
        static func find(uid: String) throws -> T? {
            guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
            }
            let query = table.filter(guid == uid)
            let items = try DB.prepare(query)
            for item in  items {
                return DeviceConfigDataHelper.convertRow(item: item)
            }
            
            return nil
            
        }
        
        static func findAll() throws -> [T]? {
            guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
            }
            var retArray = [T]()
            let items = try DB.prepare(table)
            for item in items {
                retArray.append(DeviceConfigDataHelper.convertRow(item: item))
            }
            
            return retArray
            
        }
    
    static func convertRow(item:Row) -> DeviceConfig{
        let model = DeviceConfig()
        model.guid = UUID(uuidString: item[guid])!
        model.id = item[id]
        model.timestamp = item[timestamp]
        model.modified = item[modified]
        model.dirty = item[dirty]
        model.deleted = item[deleted]
        model.appVersion = item[appVersion]
        model.firmwareVersion = item[firmwareVersion]
        model.appDeviceGuid = item[appDeviceGuid] == nil ? nil : UUID(uuidString: item[appDeviceGuid]!)!
        model.stimDeviceGuid = item[stimDeviceGuid] == nil ? nil : UUID(uuidString: item[stimDeviceGuid]!)!
        model.screeningGuid = item[screeningGuid] == nil ? nil : UUID(uuidString: item[screeningGuid]!)!
        
        return model
    }
    
    static func getLatestLeftToSend() throws -> [T] {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let query = table.filter(dirty == true)
        let items = try DB.prepare(query)
        
        for item in items{
            retArray.append(DeviceConfigDataHelper.convertRow(item: item))
        }
        
        return retArray
    }
    
    static func setSentClean(sentDeviceConfig: T) throws{
        do{
            sentDeviceConfig.dirty = false
            try update(item: sentDeviceConfig)
        } catch{
            print("error with updating device config dirty")
        }
        
    }
 
    static func getTotalRecordsLeftToSend() throws -> Int {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let query = table.filter(dirty == true)
        let count = try DB.scalar(query.count)
        return count
    }
    
    static func checkDirty() throws -> Bool{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(dirty == true)
        let items = try DB.prepare(query)
        for _ in items {
            return true
        }
        return false
    }
    
    static func clearClean() throws{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(dirty == false)
        do{
            try DB.run(query.delete())
        } catch _{
            throw DataAccessError.Delete_Error
        }
    }
    
    static func handleMigration() throws{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        var allOldColumns:[String: Int] = [:]
        var columnMatch:[String:Bool] = [:]
        
        let bep = Array(try DB.prepare(table))
        if let firstRow = bep.first{
            allOldColumns = firstRow.columnNames
            for oldCol in allOldColumns{
                columnMatch[oldCol.key] = false
            }
            
            //values that should always be there

            if allOldColumns[guid.template] != nil{
                columnMatch[guid.template] = true
            }
            if allOldColumns[id.template] != nil{
                columnMatch[id.template] = true
            }
            if allOldColumns[timestamp.template] != nil{
                columnMatch[timestamp.template] = true
            }
            if allOldColumns[modified.template] != nil{
                columnMatch[modified.template] = true
            }
            if allOldColumns[dirty.template] != nil{
                columnMatch[dirty.template] = true
            }
            if allOldColumns[deleted.template] != nil{
                columnMatch[deleted.template] = true
            }
            
            if allOldColumns[appVersion.template] == nil{
                try DB.run(table.addColumn(appVersion))
            }
            else{
                columnMatch[appVersion.template] = true
            }
            if allOldColumns[firmwareVersion.template] == nil{
                try DB.run(table.addColumn(firmwareVersion))
            }
            else{
                columnMatch[firmwareVersion.template] = true
            }
            if allOldColumns[appDeviceGuid.template] == nil{
                try DB.run(table.addColumn(appDeviceGuid))
            }
            else{
                columnMatch[appDeviceGuid.template] = true
            }
            if allOldColumns[stimDeviceGuid.template] == nil{
                try DB.run(table.addColumn(stimDeviceGuid))
            }
            else{
                columnMatch[stimDeviceGuid.template] = true
            }
            if allOldColumns[screeningGuid.template] == nil{
                try DB.run(table.addColumn(screeningGuid))
            }
            else{
                columnMatch[screeningGuid.template] = true
            }
            
            //remove old columns no longer present
            for col in columnMatch{
                if !col.value{
                    try DB.run(table.dropColumn(colName: col.key))
                }
            }
        }
    }
}
