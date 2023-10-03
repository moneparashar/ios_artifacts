/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class SessionDataDataHelper: DataHelperProtocol {
    typealias T = SessionData
    static let TABLE_NAME = "SessionData"
    static let table = Table(TABLE_NAME)
    
    static let guid = Expression<String>("guid")
    static let id = Expression<Int>("id")
    static let timestamp = Expression<Date>("timestamp")
    static let modified = Expression<Date?>("modified")
    static let dirty = Expression<Bool>("dirty")
    static let deleted = Expression<Bool>("deleted")
    static let startTime = Expression<Int>("startTime")
    static let isComplete = Expression<Bool>("isComplete")
    static let pauseCount = Expression<Int>("pauseCount")
    static let duration = Expression<Int>("duration")
    static let detectedEMGCount = Expression<Int>("detectedEMGCount")
    static let avgEMGStrength = Expression<Int>("avgEMGStrength")
    static let avgStimPulseWidth = Expression<Int>("avgStimPulseWidth")
    static let maxStimPulseWidth = Expression<Int>("maxStimPulseWidth")
    static let overallAvgImpedance = Expression<Int>("overallAvgImpedance")
    static let batteryLevelAtStart = Expression<Int>("batteryLevelAtStart")
    static let deviceConfigurationGuid = Expression<String?>("deviceConfigurationGuid")
    static let evaluationCriteriaGuid = Expression<String?>("evaluationCriteriaGuid")
    static let username = Expression<String>("username")
    static let eventTimestamp = Expression<String?>("eventTimestamp")
    static let isTestSession = Expression<Bool?>("isTestSession")
    static let eventDate = Expression<Date?>("eventDate")
    
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
                    t.column(startTime)
                    t.column(isComplete)
                    t.column(pauseCount)
                    t.column(duration)
                    t.column(detectedEMGCount)
                    t.column(avgEMGStrength)
                    t.column(avgStimPulseWidth)
                    t.column(maxStimPulseWidth)
                    t.column(overallAvgImpedance)
                    t.column(batteryLevelAtStart)
                    t.column(deviceConfigurationGuid)
                    t.column(evaluationCriteriaGuid)
                    t.column(username)
                    t.column(eventTimestamp)
                    t.column(isTestSession)
                    t.column(eventDate)
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
                    startTime <- item.startTime,
                    isComplete <- item.isComplete,
                    pauseCount <- item.pauseCount,
                    duration <- item.duration,
                    detectedEMGCount <- item.detectedEMGCount,
                    avgEMGStrength <- item.avgEMGStrength,
                    avgStimPulseWidth <- item.avgStimPulseWidth,
                    maxStimPulseWidth <- item.maxStimPulseWidth,
                    overallAvgImpedance <- item.overallAvgImpedance,
                    batteryLevelAtStart <- item.batteryLevelAtStart,
                    deviceConfigurationGuid <- (item.deviceConfigurationGuid == nil ? nil : item.deviceConfigurationGuid?.uuidString),
                    evaluationCriteriaGuid <- (item.evaluationCriteriaGuid == nil ? nil : item.evaluationCriteriaGuid?.uuidString),
                    username <- item.username,
                    eventTimestamp <- item.eventTimestamp,
                    isTestSession <- item.isTestSession,
                    eventDate <- item.eventTimestamp?.treatTimestampStrAsDate()
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
                startTime <- item.startTime,
                isComplete <- item.isComplete,
                pauseCount <- item.pauseCount,
                duration <- item.duration,
                detectedEMGCount <- item.detectedEMGCount,
                avgEMGStrength <- item.avgEMGStrength,
                avgStimPulseWidth <- item.avgStimPulseWidth,
                maxStimPulseWidth <- item.maxStimPulseWidth,
                overallAvgImpedance <- item.overallAvgImpedance,
                batteryLevelAtStart <- item.batteryLevelAtStart,
                deviceConfigurationGuid <- (item.deviceConfigurationGuid == nil ? nil : item.deviceConfigurationGuid?.uuidString),
                evaluationCriteriaGuid <- (item.evaluationCriteriaGuid == nil ? nil : item.evaluationCriteriaGuid?.uuidString),
                username <- item.username,
                eventTimestamp <- item.eventTimestamp,
                isTestSession <- item.isTestSession,
                eventDate <- item.eventTimestamp?.treatTimestampStrAsDate()
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
                return SessionDataDataHelper.convertRow(item: item)
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
                retArray.append(SessionDataDataHelper.convertRow(item: item))
            }
            
            return retArray
        }
    
    static func findAllNotDeleted(name: String, isCompleteOnly: Bool = false) throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        var query = table.filter(username == name && deleted == false).order(timestamp.desc)
        if isCompleteOnly{
            query = table.filter(username == name && deleted == false && isComplete).order(timestamp.desc)
        }
        let items = try DB.prepare(query)
        for item in items {
            retArray.append(SessionDataDataHelper.convertRow(item: item))
        }
        
        return retArray
    }
    
    static func findWeekRangeNotDeleted(name: String, isCompleteOnly: Bool = true, passDate: Date) throws -> [[T]]? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let earliestDate = Calendar.current.startOfDay(for: passDate.startOfWeek())
        let latestDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: earliestDate) ?? Date()
        var retArray = [[T]]()
        var query = table.filter(username == name && deleted == false && !isTestSession && eventDate >= earliestDate && eventDate < latestDate && eventDate != nil).order(eventDate.desc)
        if isCompleteOnly{
            query = table.filter(username == name && deleted == false && !isTestSession && eventDate >= earliestDate && eventDate < latestDate && isComplete && eventDate != nil).order(eventDate.desc)
        }
        
        let items = try DB.prepare(query)
        var first = true
        var index = 0
        var prevMonth = Date()
        for item in items {
            let converted = SessionDataDataHelper.convertRow(item: item)
            let iTmstmp = converted.eventTimestamp?.treatTimestampStrAsDate() ?? Date()
            if first{
                var temp:[T] = []
                temp.append(converted)
                retArray.append(temp)
                first = false
            }
            else{
                let sameMonth = Calendar.current.isDate(prevMonth, equalTo: iTmstmp, toGranularity: .month)
                if sameMonth{
                    retArray[index].append(converted)
                }
                else{
                    var temp:[T] = []
                    temp.append(converted)
                    retArray.append(temp)
                    index += 1
                }
            }
            prevMonth = iTmstmp
        }
        
        return retArray
    }
    
    static func getLatestStartTime(name: String) throws -> Int?{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(username  == name).order(timestamp.desc)
        let items = try DB.prepare(query)
        for item in items{
            let sd = SessionDataDataHelper.convertRow(item: item)
            return sd.startTime
        }
        return nil
    }
    
    static func hasAttemptedSession(name: String) throws -> Bool {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let query = table.filter(deleted == false && username == name)
        let items = try DB.prepare(query)
        for _ in items{
            return true
        }
        return false
    }
    
    static func getLatest(name: String, onlyCompleted: Bool = true) throws -> T? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        var query = table.filter(deleted == false && isComplete && !isTestSession && username == name).order(timestamp.desc)
        if !onlyCompleted{
            var query = table.filter(deleted == false && !isTestSession && username == name).order(eventDate.desc)
        }
        let items = try DB.prepare(query)
        for item in items {
            let sd = SessionDataDataHelper.convertRow(item: item)
            return sd
        }
        
        return nil
    }
    
    static func getLatestRunning(startingTime: Int32, name: String) throws -> T? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(username == name && startTime == Int(startingTime)).order(timestamp.desc)
        let items = try DB.prepare(query)
        
        for item in items {
            let sd = SessionDataDataHelper.convertRow(item: item)
            return sd
        }
        
        return nil
    }
    
    static func getCompletedSessionsInWeek(passDate: Date, name: String) throws -> Int?{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var count = 0
        let passStart = Calendar.current.startOfDay(for: passDate)
        let oldestDate = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: passStart).date ?? Date()
        let newestDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: oldestDate) ?? Date()
        let query = table.filter(username == name && isComplete && !isTestSession && eventDate >= oldestDate && eventDate < newestDate)
        let items = try DB.prepare(query)
        
        for _ in items{
            count += 1
        }
        
        return count
    }
    
    static func getCompletedDatesInMonth(name: String, passDate: Date) throws -> [Date]? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        var completedDates:[Date] = []
        
        var monthStart = passDate.startOfMonth()
        monthStart = Calendar.current.startOfDay(for: monthStart)
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: monthStart) ?? Date()
        
        let oldestDate = Calendar.current.date(byAdding: .day, value: -6, to: monthStart) ?? Date()
        let newestDate = Calendar.current.date(byAdding: .day, value: 6, to: nextMonth) ?? Date()
        let query = table.filter(username == name && isComplete && eventDate >= oldestDate && eventDate < newestDate)
        let items = try DB.prepare(query)
        
        for item in items{
            let sd = SessionDataDataHelper.convertRow(item: item)
            let tmstmp = sd.eventTimestamp?.treatTimestampStrAsDate() ?? Date()
            completedDates.append(tmstmp)
        }
        
        return completedDates
    }
    
    static func convertRow(item:Row) -> SessionData{
        let model = SessionData()
        model.guid = UUID(uuidString: item[guid])!
        model.id = item[id]
        model.timestamp = item[timestamp]
        model.modified = item[modified]
        model.dirty = item[dirty]
        model.deleted = item[deleted]
        model.startTime = item[startTime]
        model.isComplete = item[isComplete]
        model.pauseCount = item[pauseCount]
        model.duration = item[duration]
        model.detectedEMGCount = item[detectedEMGCount]
        model.avgEMGStrength = item[avgEMGStrength]
        model.avgStimPulseWidth = item[avgStimPulseWidth]
        model.maxStimPulseWidth = item[maxStimPulseWidth]
        model.overallAvgImpedance = item[overallAvgImpedance]
        model.batteryLevelAtStart = item[batteryLevelAtStart]
        model.deviceConfigurationGuid = item[deviceConfigurationGuid] == nil ? nil : UUID(uuidString: item[deviceConfigurationGuid]!)!
        model.evaluationCriteriaGuid = item[evaluationCriteriaGuid] == nil ? nil : UUID(uuidString: item[evaluationCriteriaGuid]!)!
        model.username = item[username]
        model.eventTimestamp = item[eventTimestamp]
        model.isTestSession = item[isTestSession]
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
            retArray.append(SessionDataDataHelper.convertRow(item: item))
        }
        
        return retArray
    }
    
    static func setSentClean(sentSessionData: T) throws{
        do{
            sentSessionData.dirty = false
            try update(item: sentSessionData)
        } catch{
            print("error with updating already sent session data")
        }
    }
    
    static func setAllDirty(user: String) throws{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let query = table.filter(username == user)
        let items = try DB.prepare(query)
        let count = items.underestimatedCount
        if count == 0 {
            return
        }
        
        let update = query.update(dirty <- true)
        do{
            try DB.run(update)
        }
        catch{
            print("error in setting all dirty")
            throw DataAccessError.Update_Error
        }
    }
    
    static func removeAllDirty(user: String) throws{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
    
        let query = table.filter(dirty && username == user)
        
        let items = try DB.prepare(query)
        let count = items.underestimatedCount
        if count == 0 {
            return
        }
        
        do{
            try DB.run(query.delete())
        } catch{
            throw DataAccessError.Delete_Error
        }
    }
    
    
    
    static func toString(date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
    
    static func toDate(str: String)-> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: str) ?? Date()
    }
    
    static func handleMigration() throws {
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
            if allOldColumns[startTime.template] == nil{
                try DB.run(table.addColumn(startTime, defaultValue: 0))
            }
            else{
                columnMatch[startTime.template] = true
            }
            if allOldColumns[isComplete.template] == nil{
                try DB.run(table.addColumn(isComplete, defaultValue: false))
            }
            else{
                columnMatch[isComplete.template] = true
            }
            if allOldColumns[pauseCount.template] == nil{
                try DB.run(table.addColumn(pauseCount, defaultValue: 0))
            }
            else{
                columnMatch[pauseCount.template] = true
            }
            if allOldColumns[duration.template] == nil{
                try DB.run(table.addColumn(duration, defaultValue: 0))
            }
            else{
                columnMatch[duration.template] = true
            }
            if allOldColumns[detectedEMGCount.template] == nil{
                try DB.run(table.addColumn(detectedEMGCount, defaultValue: 0))
            }
            else{
                columnMatch[detectedEMGCount.template] = true
            }
            if allOldColumns[avgEMGStrength.template] == nil{
                try DB.run(table.addColumn(avgEMGStrength, defaultValue: 0))
            }
            else{
                columnMatch[avgEMGStrength.template] = true
            }
            if allOldColumns[avgStimPulseWidth.template] == nil{
                try DB.run(table.addColumn(avgStimPulseWidth, defaultValue: 0))
            }
            else{
                columnMatch[avgStimPulseWidth.template] = true
            }
            if allOldColumns[maxStimPulseWidth.template] == nil{
                try DB.run(table.addColumn(maxStimPulseWidth, defaultValue: 0))
            }
            else{
                columnMatch[maxStimPulseWidth.template] = true
            }
            if allOldColumns[overallAvgImpedance.template] == nil{
                try DB.run(table.addColumn(overallAvgImpedance, defaultValue: 0))
            }
            else{
                columnMatch[overallAvgImpedance.template] = true
            }
            if allOldColumns[batteryLevelAtStart.template] == nil{
                try DB.run(table.addColumn(batteryLevelAtStart, defaultValue: 0))
            }
            else{
                columnMatch[batteryLevelAtStart.template] = true
            }
            if allOldColumns[deviceConfigurationGuid.template] == nil{
                try DB.run(table.addColumn(deviceConfigurationGuid))
            }
            else{
                columnMatch[deviceConfigurationGuid.template] = true
            }
            if allOldColumns[evaluationCriteriaGuid.template] == nil{
                try DB.run(table.addColumn(evaluationCriteriaGuid))
            }
            else{
                columnMatch[evaluationCriteriaGuid.template] = true
            }
            if allOldColumns[username.template] == nil{
                try DB.run(table.addColumn(username, defaultValue: ""))
            }
            else{
                columnMatch[username.template] = true
            }
            if allOldColumns[eventTimestamp.template] == nil{
                try DB.run(table.addColumn(eventTimestamp))
            }
            else{
                columnMatch[eventTimestamp.template] = true
            }
            if allOldColumns[isTestSession.template] == nil{
                try DB.run(table.addColumn(isTestSession))
            }
            else{
                columnMatch[isTestSession.template] = true
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


