/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

protocol DataHelperProtocol {
    associatedtype T
    static func createTable() throws -> Void
    static func insert(item: T) throws -> Int64
    static func update(item: T) throws -> Int
    static func delete(item: T) throws -> Void
    static func findAll() throws -> [T]?
}

class AppDeviceDataHelper: DataHelperProtocol {
    typealias T = AppDevice
    static let TABLE_NAME = "AppDevice"
    static let table = Table(TABLE_NAME)
    
    static let guid = Expression<String>("guid")
    static let id = Expression<Int>("id")
    static let timestamp = Expression<Date>("timestamp")
    static let modified = Expression<Date?>("modified")
    static let dirty = Expression<Bool>("dirty")
    static let delete = Expression<Bool>("delete")
    static let appIdentifier = Expression<String>("appIdentifier")
    static let deviceToken = Expression<String?>("deviceToken")
    static let awsEndpointarn = Expression<String?>("awsEndpointarn")
    static let awsSubscriptionArnList = Expression<String?>("awsSubscritionArnList")
    
    static func createTable() throws {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
            }
            do {
                let _ = try DB.run( table.create(ifNotExists: true) {t in
                    //t.column(guid, primaryKey: true)
                    t.column(guid, primaryKey: false)
                    t.column(id)
                    t.column(timestamp)
                    t.column(modified)
                    t.column(dirty)
                    t.column(delete)
                    t.column(appIdentifier)
                    t.column(deviceToken)
                    t.column(awsEndpointarn)
                    t.column(awsSubscriptionArnList)
                    })
                
            } catch _ {
                // Error throw if table already exists
            }
            
        }
        
    static func getColumns() throws {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
        }
        
        let bep = Array(try DB.prepare(table))
        if let firstRow = bep.first{
            let allColumns = firstRow.columnNames
            
            for col in allColumns{
                print("\(col.key), \(col.value)")
            }
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
            if allOldColumns[delete.template] != nil{
                columnMatch[delete.template] = true
            }
            if allOldColumns[appIdentifier.template] != nil{
                columnMatch[appIdentifier.template] = true
            }
            
            //columns to add if not found
            if allOldColumns[deviceToken.template] == nil{
                try DB.run(table.addColumn(deviceToken))
            }
            else{
                columnMatch[deviceToken.template] = true
            }
            if allOldColumns[awsEndpointarn.template] == nil{
                try DB.run(table.addColumn(awsEndpointarn))
            }
            else{
                columnMatch[awsEndpointarn.template] = true
            }
            if allOldColumns[awsSubscriptionArnList.template] == nil{
                try DB.run(table.addColumn(awsSubscriptionArnList))
            }
            else{
                columnMatch[awsSubscriptionArnList.template] = true
            }
            
            
            //remove old columns no longer present
            for col in columnMatch{
                if !col.value{
                    try DB.run(table.dropColumn(colName: col.key))
                }
            }
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
                delete <- item.deleted,
                appIdentifier <- item.appIdentifier,
                deviceToken <- item.deviceToken,
                awsEndpointarn <- item.awsEndpointarn,
                awsSubscriptionArnList <- item.awsSubscriptionArnList
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
            delete <- item.deleted,
            appIdentifier <- item.appIdentifier,
            deviceToken <- item.deviceToken,
            awsEndpointarn <- item.awsEndpointarn,
            awsSubscriptionArnList <- item.awsSubscriptionArnList
        )
        do{
            let rowId = try DB.run(update)
            guard rowId > 0 else {
                throw DataAccessError.Update_Error
            }
            return rowId
        } catch{
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
            return AppDeviceDataHelper.convertRow(item: item)
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
            retArray.append(AppDeviceDataHelper.convertRow(item: item))
        }
        
        return retArray
        
    }
    
    static func convertRow(item:Row) -> AppDevice{
        let date = item[timestamp]
        let datestr = toString(date: date)
        
        let model = AppDevice()
        model.guid = UUID(uuidString: item[guid])!
        model.id = item[id]
        model.timestamp = item[timestamp]
        model.modified = item[modified]
        model.dirty = item[dirty]
        model.deleted = item[delete]
        model.appIdentifier = item[appIdentifier]
        model.deviceToken = item[deviceToken]
        model.awsEndpointarn = item[awsEndpointarn]
        model.awsSubscriptionArnList = item[awsSubscriptionArnList]
        
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
}
