/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */
import UIKit

class EMGDataDataHelper: DataHelperProtocol {
    typealias T = EMGData
    static let TABLE_NAME = "EMGData"
    static let table = Table(TABLE_NAME)
    
    static let guid = Expression<String>("guid")
    static let id = Expression<Int>("id")
    static let timestamp = Expression<Date>("timestamp")
    static let modified = Expression<Date?>("modified")
    static let dirty = Expression<Bool>("dirty")
    static let deleted = Expression<Bool>("delete")
    static let dataTimestamp = Expression<Int?>("dataTimestamp")
    static let index = Expression<Int?>("index")
    static let data = Expression<Data?>("data")
    static let deviceConfigurationGuid = Expression<String?>("deviceConfigurationGuid")
    static let screeningGuid = Expression<String?>("screeningGuid")
    static let sessionGuid = Expression<String?>("sessionGuid")
    
    
    static func createTable() throws {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
            }
            do {
                let _ = try DB.run( table.create(ifNotExists: true) {t in
                    t.column(guid, primaryKey: false)
                    t.column(id)
                    t.column(timestamp)
                    t.column(modified)
                    t.column(dirty)
                    t.column(deleted)
                    t.column(dataTimestamp)
                    t.column(index)
                    t.column(data)
                    t.column(deviceConfigurationGuid)
                    t.column(screeningGuid)
                    t.column(sessionGuid)
                    })
                
            } catch _ {
                // Error throw if table already exists
            }
            
        }
        
        static func insert(item: T) throws -> Int64 {
            guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
            }
            
            let encoder = JSONEncoder()
            let encodedData = try? encoder.encode(item.data)
            
                let insert = table.insert(
                    guid <- item.guid.uuidString,
                    id <- item.id,
                    timestamp <- item.timestamp,
                    modified <- item.modified,
                    dirty <- item.dirty,
                    deleted <- item.deleted,
                    dataTimestamp <- item.dataTimestamp,
                    index <- item.index == nil ? nil : Int(item.index!),
                    data <- encodedData,
                    deviceConfigurationGuid <- (item.deviceConfigurationGuid == nil ? nil : item.deviceConfigurationGuid?.uuidString),
                    screeningGuid <- (item.screeningGuid == nil ? nil : item.screeningGuid?.uuidString),
                    sessionGuid <- (item.sessionGuid == nil ? nil : item.sessionGuid!.uuidString)
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
        
        let encoder = JSONEncoder()
        let encodedData = try? encoder.encode(item.data)
        let filtered = table.filter(guid == item.guid.uuidString)
            let update = filtered.update(
                guid <- item.guid.uuidString,
                id <- item.id,
                timestamp <- item.timestamp,
                modified <- item.modified,
                dirty <- item.dirty,
                deleted <- item.deleted,
                dataTimestamp <- item.dataTimestamp,
                index <- item.index == nil ? nil : Int(item.index!),
                data <- encodedData,
                deviceConfigurationGuid <- (item.deviceConfigurationGuid == nil ? nil : item.deviceConfigurationGuid?.uuidString),
                screeningGuid <- (item.screeningGuid == nil ? nil : item.screeningGuid?.uuidString),
                sessionGuid <- (item.sessionGuid == nil ? nil : item.sessionGuid!.uuidString)
             )
            do {
                let rowId = try DB.run(update)
                guard rowId > 0 else {
                    throw DataAccessError.Update_Error
                }
                return rowId
            } catch {
                print("Unexpected error: \(error)")
                throw DataAccessError.Update_Error
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
                return EMGDataDataHelper.convertRow(item: item)
            }
            
            return nil
            
        }
    
    static func findAllDirty() throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let query = table.filter(dirty == true)
        let items = try DB.prepare(query)
        for item in items {
            retArray.append(EMGDataDataHelper.convertRow(item: item))
        }
        
        return retArray
    }
    
    static func setDirtyFalse() throws -> Void {    //double check if this is called
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let update = table.update(dirty <- false)
        do{
            try DB.run(update)
        }catch{
            print("set all dirty false error")
        }
    }
    
    
    
        static func findAll() throws -> [T]? {
            guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
            }
            var retArray = [T]()
            let items = try DB.prepare(table)
            for item in items {
                retArray.append(EMGDataDataHelper.convertRow(item: item))
            }
            
            return retArray
            
        }
    
    static func convertRow(item:Row) -> EMGData{
        
        let model = EMGData()
        model.guid = UUID(uuidString: item[guid])!
        model.id = item[id]
        model.timestamp = item[timestamp]
        model.modified = item[modified]
        model.dirty = item[dirty]
        model.deleted = item[deleted]
        model.dataTimestamp = item[dataTimestamp]
        model.index = item[index] == nil ? nil : UInt8(item[index]!)
        
        if let theData = item[data]{
            let decoder = JSONDecoder()
            let dat = try? decoder.decode([Int].self, from: theData)
            model.data = dat
        }
        
        model.deviceConfigurationGuid = item[deviceConfigurationGuid] == nil ? nil : UUID(uuidString: item[deviceConfigurationGuid]!)!
        model.screeningGuid = item[screeningGuid] == nil ? nil : UUID(uuidString: item[screeningGuid]!)!
        model.sessionGuid = item[sessionGuid] == nil ? nil : UUID(uuidString: item[sessionGuid]!)!
        return model
    }
    
    static func toString(date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
    
    static func toDate(str: String)-> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: str) ?? Date()
    }
    
    static func getTotalRecordsLeftToSend() throws -> Int {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let query = table.filter(dirty == true)
        let count = try DB.scalar(query.count)
        return count
    }
    
    static func getLatestWithMax(bulkCount: Int) throws  -> [[T]?] {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [[T]]()
        let query = table.filter(dirty == true).limit(bulkCount)        //.order
        let items = try DB.prepare(query)
        var count = 0
        var outerIndex = 0
        for item in items{
            if retArray == []{
                retArray.append([])
            }
            else if count == bulkCount{
                outerIndex += 1
                retArray.append([])
                count = 0
            }
            retArray[outerIndex].append(EMGDataDataHelper.convertRow(item: item))
            count += 1
        }
        return retArray
    }
    
    static func setSentClean(sentEMGBulk: [T]) throws{
        for emg in sentEMGBulk{
            //Slim.info("EMG DATA: guid: \(emg.guid.uuidString), screening guid: \(String(describing: emg.screeningGuid?.uuidString)), session guid: \(String(describing: emg.sessionGuid?.uuidString))")
            do{
                emg.dirty = false
                let _ = try update(item: emg)
            } catch{
                print("error with updating supposedly already sent data")
                break
            }
        }
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
            
            //columns to add if not found
            
            if allOldColumns[dataTimestamp.template] == nil{
                try DB.run(table.addColumn(dataTimestamp))
            }
            else{
                columnMatch[dataTimestamp.template] = true
            }
            if allOldColumns[index.template] == nil{
                try DB.run(table.addColumn(index))
            }
            else{
                columnMatch[index.template] = true
            }
            if allOldColumns[data.template] == nil{
                try DB.run(table.addColumn(data))
            }
            else{
                columnMatch[data.template] = true
            }
            if allOldColumns[deviceConfigurationGuid.template] == nil{
                try DB.run(table.addColumn(deviceConfigurationGuid))
            }
            else{
                columnMatch[deviceConfigurationGuid.template] = true
            }
            if allOldColumns[screeningGuid.template] == nil{
                try DB.run(table.addColumn(screeningGuid))
            }
            else{
                columnMatch[screeningGuid.template] = true
            }
            if allOldColumns[sessionGuid.template] == nil{
                try DB.run(table.addColumn(sessionGuid))
            }
            else{
                columnMatch[sessionGuid.template] = true
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
