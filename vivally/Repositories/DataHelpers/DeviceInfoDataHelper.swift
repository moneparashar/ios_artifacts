/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class DeviceInfoDataHelper: DataHelperProtocol {
    typealias T = DeviceInfo
    static let TABLE_NAME = "DeviceInfo"
    static let table = Table(TABLE_NAME)
    
    static let guid = Expression<String>("guid")
    static let id = Expression<Int>("id")
    static let timestamp = Expression<Date>("timestamp")
    static let modified = Expression<Date?>("modified")
    static let dirty = Expression<Bool>("dirty")
    static let deleted = Expression<Bool>("deleted")
    static let voluntaryEMG = Expression<Int?>("voluntaryEMG")
    static let impedance = Expression<Int?>("impedance")
    static let error = Expression<Int?>("error")
    static let charging = Expression<Int?>("charging")
    static let level = Expression<Int?>("level")
    static let empty = Expression<Int?>("empty")
    static let  low = Expression<Int?>("low")
    static let  half = Expression< Int?>("half")
    static let  high = Expression< Int?>("high")
    static let  full = Expression< Int?>("full")
    static let  deviceConfigurationGuid = Expression<String?>("deviceConfigurationGuid")
    static let  patientGuid = Expression<String?>("patientGuid")
    
    
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
                    t.column(voluntaryEMG)
                    t.column(impedance)
                    t.column(error)
                    t.column(charging)
                    t.column(level)
                    t.column(empty)
                    t.column(low)
                    t.column(half)
                    t.column(high)
                    t.column(full)
                    t.column(deviceConfigurationGuid)
                    t.column(patientGuid)
                    
                    })
                
            } catch _ {
                // Error throw if table already exists
            }
            
        }
        
        static func insert(item: T) throws -> Int64 {
            guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
            }
            
            //let date = toDate(str: newdatestr)
            
                let insert = table.insert(
                    guid <- item.guid.uuidString,
                    id <- item.id,
                    timestamp <- item.timestamp,
                    modified <- item.modified,
                    dirty <- item.dirty,
                    deleted <- item.deleted,
                    voluntaryEMG <- item.voluntaryEMG == nil ? nil : Int(item.voluntaryEMG!),
                    impedance <- item.impedance == nil ? nil : Int(item.impedance!),
                    error <- item.error,
                    charging <- item.charging == nil ? nil : Int(item.charging!),
                    level <- item.level,
                    empty <- item.empty,
                    low <- item.low,
                    half <- item.half,
                    high <- item.high,
                    full <- item.full,
                    deviceConfigurationGuid <- (item.deviceConfigurationGuid == nil ? nil : item.deviceConfigurationGuid?.uuidString),
                    patientGuid <- (item.patientGuid == nil ? nil : item.patientGuid?.uuidString)
                    
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
                voluntaryEMG <- item.voluntaryEMG == nil ? nil : Int(item.voluntaryEMG!),
                impedance <- item.impedance == nil ? nil : Int(item.impedance!),
                error <- item.error,
                charging <- item.charging == nil ? nil : Int(item.charging!),
                level <- item.level,
                empty <- item.empty,
                low <- item.low,
                half <- item.half,
                high <- item.high,
                full <- item.full,
                deviceConfigurationGuid <- (item.deviceConfigurationGuid == nil ? nil : item.deviceConfigurationGuid?.uuidString),
                patientGuid <- (item.patientGuid == nil ? nil : item.patientGuid?.uuidString)
                
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
                return DeviceInfoDataHelper.convertRow(item: item)
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
                retArray.append(DeviceInfoDataHelper.convertRow(item: item))
            }
            
            return retArray
            
        }
    
    static func convertRow(item:Row) -> DeviceInfo{
        //let date = item[timestamp]
        //let datestr = toString(date: date)
        
        let model = DeviceInfo()
        model.guid = UUID(uuidString: item[guid])!
        model.id = item[id]
        model.timestamp = item[timestamp]
        model.modified = item[modified]
        model.dirty = item[dirty]
        model.deleted = item[deleted]
        model.voluntaryEMG = item[voluntaryEMG] == nil ? nil : UInt8(item[voluntaryEMG]!)
        model.impedance = item[impedance] == nil ? nil : UInt8(item[impedance]!)
        model.error = item[error]
        model.charging = item[charging] == nil ? nil : UInt8(item[charging]!)
        model.level = item[level]
        model.empty = item[empty]
        model.low = item[low]
        model.half = item[half]
        model.high = item[high]
        model.full = item[full]
        model.deviceConfigurationGuid = item[deviceConfigurationGuid] == nil ? nil : UUID(uuidString: item[deviceConfigurationGuid]!)!
        model.patientGuid = item[patientGuid] == nil ? nil : UUID(uuidString: item[patientGuid]!)!
        
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
