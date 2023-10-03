/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class EvaluationCriteriaDataHelper: DataHelperProtocol {
    typealias T = EvaluationCriteria
    static let TABLE_NAME = "EvaluationCriteria"
    static let table = Table(TABLE_NAME)
    
    static let guid = Expression<String>("guid")
    static let id = Expression<Int>("id")
    static let timestamp = Expression<Date>("timestamp")
    static let modified = Expression<Date?>("modified")
    static let dirty = Expression<Bool>("dirty")
    static let deleted = Expression<Bool>("deleted")
    static let  deviceConfigurationGuid = Expression<String?>("deviceConfigurationGuid")
    //static let  patientGuid = Expression<String?>("patientGuid")
    static let  screeningGuid = Expression<String?>("screeningGuid")
    static let foot = Expression<Int>("foot")
    static let stimulationCurrentAmplitude = Expression<Int>("stimulationCurrentAmplitude")
    static let skinParesthesiaPulseWidth = Expression<Int>("skinParesthesiaPulseWidth")
    static let footParesthesiaPulseWidth = Expression<Int>("footParesthesiaPulseWidth")
    static let comfortLevelPulseWidth = Expression<Int>("comfortLevelPulseWidth")
    static let emgDetectionPointPulseWidth = Expression<Int>("emgDetectionPointPulseWidth")
    static let targetTherapyLevelPulseWidth = Expression<Int>("targetTherapyLevelPulseWidth")
    static let comfortLevelEMGStrength = Expression<Int>("comfortLevelEmgStrength")
    static let emgDetectionPointEMGStrength = Expression<Int>("emgDetectionPointEMGStrength")
    static let targetEMGStrength = Expression<Int>("targetEMGStrength")
    static let therapyLength = Expression<Int>("therapyLength")
    static let therapySchedule = Expression<Int>("therapySchedule")
    
    
    
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
                    t.column(deviceConfigurationGuid)
                    //t.column(patientGuid)
                    t.column(screeningGuid)
                    t.column( foot)
                    t.column( stimulationCurrentAmplitude)
                    t.column( skinParesthesiaPulseWidth)
                    t.column( footParesthesiaPulseWidth)
                    t.column( comfortLevelPulseWidth)
                    t.column( emgDetectionPointPulseWidth)
                    t.column(targetTherapyLevelPulseWidth)
                    t.column( comfortLevelEMGStrength)
                    t.column( emgDetectionPointEMGStrength)
                    t.column( targetEMGStrength)
                    t.column( therapyLength)
                    t.column( therapySchedule)
                    
                })
                
            } catch _ {
                // Error throw if table already exists
            }
            
        }
        
        static func insert(item: T) throws -> Int64 {
            guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
                throw DataAccessError.Datastore_Connection_Error
            }
            
            //let newdatestr = item.timestamp
            //let date = toDate(str: newdatestr)
            
                let insert = table.insert(
                    guid <- item.guid.uuidString,
                    id <- item.id,
                    timestamp <- item.timestamp,
                    modified <- item.modified,
                    dirty <- item.dirty,
                    deleted <- item.deleted,
                    deviceConfigurationGuid <- (item.deviceConfigurationGuid == nil ? nil : item.deviceConfigurationGuid?.uuidString),
                    //patientGuid <- (item.patientGuid == nil ? nil : item.patientGuid?.uuidString),
                    screeningGuid <- (item.screeningGuid == nil ? nil : item.screeningGuid?.uuidString),
                    foot <- item.foot,
                    skinParesthesiaPulseWidth <- item.skinParesthesiaPulseWidth,
                    footParesthesiaPulseWidth <- item.footParesthesiaPulseWidth,
                    comfortLevelPulseWidth <- item.comfortLevelPulseWidth,
                    emgDetectionPointPulseWidth <- item.emgDetectionPointPulseWidth,
                    targetTherapyLevelPulseWidth <- item.targetTherapyLevelPulseWidth,
                    comfortLevelEMGStrength <- item.comfortLevelEMGStrength,
                    emgDetectionPointEMGStrength <- item.emgDetectionPointEMGStrength,
                    targetEMGStrength <- item.targetEMGStrength,
                    therapyLength <- item.therapyLength,
                    therapySchedule <- item.therapySchedule,
                    stimulationCurrentAmplitude <- item.stimulationCurrentAmplitude
                    
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
                deviceConfigurationGuid <- (item.deviceConfigurationGuid == nil ? nil : item.deviceConfigurationGuid?.uuidString),
                //patientGuid <- (item.patientGuid == nil ? nil : item.patientGuid?.uuidString),
                screeningGuid <- (item.screeningGuid == nil ? nil : item.screeningGuid?.uuidString),
                foot <- item.foot,
                skinParesthesiaPulseWidth <- item.skinParesthesiaPulseWidth,
                footParesthesiaPulseWidth <- item.footParesthesiaPulseWidth,
                comfortLevelPulseWidth <- item.comfortLevelPulseWidth,
                emgDetectionPointPulseWidth <- item.emgDetectionPointPulseWidth,
                targetTherapyLevelPulseWidth <- item.targetTherapyLevelPulseWidth,
                comfortLevelEMGStrength <- item.comfortLevelEMGStrength,
                emgDetectionPointEMGStrength <- item.emgDetectionPointEMGStrength,
                targetEMGStrength <- item.targetEMGStrength,
                therapyLength <- item.therapyLength,
                therapySchedule <- item.therapySchedule,
                stimulationCurrentAmplitude <- item.stimulationCurrentAmplitude
                
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
                return EvaluationCriteriaDataHelper.convertRow(item: item)
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
                retArray.append(EvaluationCriteriaDataHelper.convertRow(item: item))
            }
            
            return retArray
            
        }
    
    static func convertRow(item:Row) -> EvaluationCriteria{
        
        let model = EvaluationCriteria()
        model.guid = UUID(uuidString: item[guid])!
        model.id = item[id]
        model.timestamp = item[timestamp]
        model.modified = item[modified]
        model.dirty = item[dirty]
        model.deleted = item[deleted]
        model.deviceConfigurationGuid = item[deviceConfigurationGuid] == nil ? nil : UUID(uuidString: item[deviceConfigurationGuid]!)!
        //model.patientGuid = item[patientGuid] == nil ? nil : UUID(uuidString: item[patientGuid]!)!
        model.screeningGuid = item[screeningGuid] == nil ? nil : UUID(uuidString: item[screeningGuid]!)!
        model.foot = item[foot]
        model.stimulationCurrentAmplitude = item[stimulationCurrentAmplitude]
        model.skinParesthesiaPulseWidth = item[skinParesthesiaPulseWidth]
        model.footParesthesiaPulseWidth = item[footParesthesiaPulseWidth]
        model.comfortLevelPulseWidth = item[comfortLevelPulseWidth]
        model.emgDetectionPointPulseWidth = item[emgDetectionPointPulseWidth]
        model.targetTherapyLevelPulseWidth = item[targetTherapyLevelPulseWidth]
        model.comfortLevelEMGStrength = item[comfortLevelEMGStrength]
        model.emgDetectionPointEMGStrength = item[emgDetectionPointEMGStrength]
        model.targetEMGStrength = item[targetEMGStrength]
        model.therapyLength = item[therapyLength]
        model.therapySchedule = item[therapySchedule]
        
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
