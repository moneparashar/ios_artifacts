/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class JournalEventsDataHelper: DataHelperProtocol {
    typealias T = JournalEvents
    static let TABLE_NAME = "JournalEvents"
    static let table = Table(TABLE_NAME)
    
    static let guid = Expression<String>("guid")
    static let id = Expression<Int>("id")
    static let timestamp = Expression<Date>("timestamp")
    static let modified = Expression<Date?>("modified")
    static let dirty = Expression<Bool>("dirty")
    static let deleted = Expression<Bool>("deleted")
    static let  eventTimestamp = Expression<String>("eventTimestamp")
    static let  drinksWaterOther = Expression<Double>("drinksWaterOther")
    static let  drinksCaffeinated = Expression<Double>("drinksCaffeinated")
    static let  drinksAlcohol = Expression<Double>("drinksAlcohol")
    static let  restroomUrges = Expression<Int>("restroomUrges")
    static let  restroomDrops = Expression<Int>("restroomDrops")
    static let  restroomSleep = Expression<Int>("restroomSleep")
    static let  accidentsDrops = Expression<Int>("accidentsDrops")
    static let  accidentsUrges = Expression<Int>("accidentsUrges")
    static let  accidentsStress = Expression<Int>("accidentsStress")
    static let  accidentsChanges = Expression<Int>("accidentsChanges")
    static let  accidentsSleep = Expression<Int>("accidentsSleep")
    static let  lifeMedication = Expression<Bool>("lifeMedication")
    static let  lifeExercise = Expression<Bool>("lifeExercise")
    static let  lifeDailyRoutine = Expression<Bool>("lifeDailyRoutine")
    static let  lifeDiet = Expression<Bool>("lifeDiet")
    static let  lifeStress = Expression<Bool>("lifeStress")
    static let  lifeOther = Expression<Bool>("lifeOther")
    static let  lifeGelPads = Expression<Bool>("lifeGelPads")
    static let  lifeNotes = Expression<String>("lifeNotes")
    static let  username = Expression<String>("username")
    static let  eventDate = Expression<Date?>("eventDate")
    
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
                    t.column(eventTimestamp)
                    t.column(drinksWaterOther)
                    t.column(drinksCaffeinated)
                    t.column(drinksAlcohol)
                    t.column(restroomUrges)
                    t.column(restroomDrops)
                    t.column(restroomSleep)
                    t.column(accidentsDrops)
                    t.column(accidentsUrges)
                    t.column(accidentsStress)
                    t.column(accidentsChanges)
                    t.column(accidentsSleep)
                    t.column(lifeMedication)
                    t.column(lifeExercise)
                    t.column(lifeDailyRoutine)
                    t.column(lifeDiet)
                    t.column(lifeStress)
                    t.column(lifeOther)
                    t.column(lifeGelPads)
                    t.column(lifeNotes)
                    t.column(username)
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
                    eventTimestamp <- item.eventTimestamp,
                    drinksWaterOther <- item.drinksWaterOther!,
                    drinksCaffeinated <- item.drinksCaffeinated!,
                    drinksAlcohol <- item.drinksAlcohol!,
                    restroomUrges <- item.restroomUrges!,
                    restroomDrops <- item.restroomDrops!,
                    restroomSleep <- item.restroomSleep!,
                    accidentsDrops <- item.accidentsDrops!,
                    accidentsUrges <- item.accidentsUrges!,
                    accidentsStress <- item.accidentsStress!,
                    accidentsChanges <- item.accidentsChanges!,
                    accidentsSleep <- item.accidentsSleep!,
                    lifeMedication <- item.lifeMedication!,
                    lifeExercise <- item.lifeExercise!,
                    lifeDailyRoutine <- item.lifeDailyRoutine!,
                    lifeDiet <- item.lifeDiet!,
                    lifeStress <- item.lifeStress!,
                    lifeOther <- item.lifeOther!,
                    lifeGelPads <- item.lifeGelPads!,
                    lifeNotes <- item.lifeNotes!,
                    username <- item.username,
                    eventDate <- item.eventTimestamp.treatTimestampStrAsDate()
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
                eventTimestamp <- item.eventTimestamp,
                drinksWaterOther <- item.drinksWaterOther!,
                drinksCaffeinated <- item.drinksCaffeinated!,
                drinksAlcohol <- item.drinksAlcohol!,
                restroomUrges <- item.restroomUrges!,
                restroomDrops <- item.restroomDrops!,
                restroomSleep <- item.restroomSleep!,
                accidentsDrops <- item.accidentsDrops!,
                accidentsUrges <- item.accidentsUrges!,
                accidentsStress <- item.accidentsStress!,
                accidentsChanges <- item.accidentsChanges!,
                accidentsSleep <- item.accidentsSleep!,
                lifeMedication <- item.lifeMedication!,
                lifeExercise <- item.lifeExercise!,
                lifeDailyRoutine <- item.lifeDailyRoutine!,
                lifeDiet <- item.lifeDiet!,
                lifeStress <- item.lifeStress!,
                lifeOther <- item.lifeOther!,
                lifeGelPads <- item.lifeGelPads!,
                lifeNotes <- item.lifeNotes!,
                username <- item.username,
                eventDate <- item.eventTimestamp.treatTimestampStrAsDate()
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
                return JournalEventsDataHelper.convertRow(item: item)
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
                retArray.append(JournalEventsDataHelper.convertRow(item: item))
            }
            
            return retArray
            
        }
    
    static func findAllNotDeleted(name: String) throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let query = table.filter(username == name && deleted == false)
        let items = try DB.prepare(query)
        for item in items {
            retArray.append(JournalEventsDataHelper.convertRow(item: item))
        }
        
        return retArray
        
    }
    
    static func findAllNotDeletedUTCList(name: String, journalRange: JournalTimeRanges = .daily, passDate: Date = Date()) throws -> [[T]]? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        //let utc = TimeZone(identifier: "UTC")
        var cal = Calendar(identifier: .gregorian)
        
        cal.timeZone = .current
        //cal.timeZone = utc ?? .current
        
        //ranges
        let passStart = cal.startOfDay(for: passDate)
        var newestDate = cal.date(byAdding: .day, value: 0, to: passDate) ?? Date()
        var oldestDate = passStart
        
        switch journalRange {
        case .daily:
            newestDate = cal.date(byAdding: .day, value: 1, to: oldestDate) ?? Date()
        case .weekly:
            oldestDate = cal.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: passStart).date ?? Date()
            newestDate = cal.date(byAdding: .weekOfYear, value: 1, to: oldestDate) ?? Date()
        case .monthly:
            let components = cal.dateComponents([.year, .month], from: passStart)
            oldestDate = cal.date(from: components) ?? Date()
            newestDate = cal.date(byAdding: .month, value: 1, to: oldestDate) ?? Date()
        }
        
        var seqArray = [T]()
        var retArray = [[T]]()
        let query = table.filter(username == name && deleted == false && eventDate >= oldestDate && eventDate < newestDate).order(eventDate.asc)
        let items = try DB.prepare(query)
        
        
        for item in items {
            seqArray.append(JournalEventsDataHelper.convertRow(item: item))
        }
        
        //seqArray = seqArray.sorted(by: {$1.eventDate > $0.eventDate})
        
        var first = true
        var prevDate = Date()
        var index = 0
        for je in seqArray{
            let tmpTmstmp = je.eventTimestamp.treatTimestampStrAsDate() ?? Date()
            if first{
                first = false
                retArray.append([je])
            }
            else{
                let sameDay = cal.isDate(prevDate, inSameDayAs: tmpTmstmp)
                if sameDay{
                    retArray[index].append(je)
                }
                else{
                    //reorder the prev day first if needed before adding new day
                    var oldGroup = retArray[index]
                    oldGroup = oldGroup.sorted(by: {$0.eventTimestamp < $1.eventTimestamp})
                    retArray[index] = oldGroup
                    //new day add
                    retArray.append([je])
                    index += 1
                }
            }
            prevDate = tmpTmstmp
        }
        
        //reorder the last group
        if let lastGroup = retArray.last{
            let orderedGroup = lastGroup.sorted(by: {$0.eventTimestamp < $1.eventTimestamp})
            retArray[retArray.count - 1] = orderedGroup
        }
        
        return retArray
    }
    
    static func getLatest(name: String) throws -> T? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        //var date = Date()
        let query = table.filter(username == name && deleted == false).order(eventDate.desc)
        let items = try DB.prepare(query)
        
        for item in items {
            if !item[deleted] {
                //print("guid: \(item[guid]) eventTimestamp: \(item[eventTimestamp])")
                let je = JournalEventsDataHelper.convertRow(item: item)
                return je
            }
            
        }
        
        return nil
    }
    
    static func getLastGel() throws -> T? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        //var date = Date()
        let query = table.filter(lifeGelPads).order(eventDate.desc)
        let items = try DB.prepare(query)
        
        for item in items {
            //print("guid: \(item[guid]) eventTimestamp: \(item[eventTimestamp])")
            let je = JournalEventsDataHelper.convertRow(item: item)
            return je
        }
        
        return nil
    }
    
    static func getJournalDatesInMonth(name: String, passDate: Date) throws -> [Date]? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        var completedDates:[Date] = []
        
        var monthStart = passDate.startOfMonth()
        monthStart = Calendar.current.startOfDay(for: monthStart)
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: monthStart) ?? Date()
        
        let oldestDate = Calendar.current.date(byAdding: .day, value: -6, to: monthStart) ?? Date()
        let newestDate = Calendar.current.date(byAdding: .day, value: 6, to: nextMonth) ?? Date()
        
        let query = table.filter(username == name && eventDate >= oldestDate && eventDate < newestDate).order(eventDate.desc)
        let items = try DB.prepare(query)
        
        var first = true
        var lastDate = Date()
        for item in items{
            let sd = JournalEventsDataHelper.convertRow(item: item)
            let tmstmp = sd.eventTimestamp.treatTimestampStrAsDate() ?? Date()
            
            if first{
                completedDates.append(tmstmp)
                first = false
            }
            else{
                if !Calendar.current.isDate(tmstmp, inSameDayAs: lastDate){
                    completedDates.append(tmstmp)
                }
            }
            lastDate = tmstmp
        }
        
        return completedDates
    }
    
    static func convertRow(item:Row) -> JournalEvents{
        
        let model = JournalEvents()
        model.guid = UUID(uuidString: item[guid])!
        model.id = item[id]
        model.timestamp = item[timestamp]
        model.modified = item[modified]
        model.dirty = item[dirty]
        model.deleted = item[deleted]
        model.eventTimestamp = item[eventTimestamp]
        model.drinksWaterOther = item[drinksWaterOther]
        model.drinksCaffeinated = item[drinksCaffeinated]
        model.drinksAlcohol = item[drinksAlcohol]
        model.restroomUrges = item[restroomUrges]
        model.restroomDrops = item[restroomDrops]
        model.restroomSleep = item[restroomSleep]
        model.accidentsDrops = item[accidentsDrops]
        model.accidentsUrges = item[accidentsUrges]
        model.accidentsStress = item[accidentsStress]
        model.accidentsChanges = item[accidentsChanges]
        model.accidentsSleep = item[accidentsSleep]
        model.lifeMedication = item[lifeMedication]
        model.lifeExercise = item[lifeExercise]
        model.lifeDailyRoutine = item[lifeDailyRoutine]
        model.lifeDiet = item[lifeDiet]
        model.lifeStress = item[lifeStress]
        model.lifeOther = item[lifeOther]
        model.lifeGelPads = item[lifeGelPads]
        model.lifeNotes = item[lifeNotes]
        model.username = item[username]
        
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
            retArray.append(JournalEventsDataHelper.convertRow(item: item))
        }
        
        return retArray
    }
    
    static func setSentClean(sentJournalEvents: T) throws{
        do{
            sentJournalEvents.dirty = false
            try update(item: sentJournalEvents)
        } catch{
            print("error with updating already sent journal event")
        }
        
    }
    
    static func setAllDirty(user: String) throws{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        
        
        //let update = table.update(dirty <- true)
        let query = table.filter(username == user)
        
        //check
        let items = try DB.prepare(query)
        /*
        for item in items {
            empty = false
            break
        }
        */
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
        
        //let query = table.filter(username == user)
    
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
    
    static func eventExists(date: Date, name: String) throws -> Bool{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        //print(date)
        let hour = Calendar.current.component(.hour, from: date)
        let leftDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: date)
        let rightDate = leftDate!.addingTimeInterval(3600)
        
        let query = table.filter(eventDate >= leftDate! && eventDate < rightDate && deleted == false && username == name)
        let items = try DB.prepare(query)
        
        for item in items {
            let je = JournalEventsDataHelper.convertRow(item: item)
            //print(je.eventTimestamp)
            return true
        }
        
        /*
        if items.underestimatedCount > 0 {
            return true
        }
        */
        return false
    }
    
    static func eventExistsExcept(date: Date, event: JournalEvents) throws -> Bool{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        //print(date)
        let hour = Calendar.current.component(.hour, from: date)
        let leftDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: date)
        let rightDate = leftDate!.addingTimeInterval(3600)
        
        let user = event.username
        let query = table.filter(eventDate >= leftDate! && eventDate < rightDate && deleted == false && username == user)
        let items = try DB.prepare(query)
        
        for item in items {
            let je = JournalEventsDataHelper.convertRow(item: item)
            if je.eventTimestamp != event.eventTimestamp{
            //print(je.eventTimestamp)
                return true
            }
        }
        return false
    }
    
    static func getEvent(date: Date) throws -> T?{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(eventDate == date && deleted == false)
        let items = try DB.prepare(query)
        for item in  items {
            return JournalEventsDataHelper.convertRow(item: item)
        }
        
        return nil
    }
    
    static func eventDayExists(date: Date, name: String) throws -> Bool{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        //let utc = TimeZone(identifier: "UTC")
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        
        let earliestDay = cal.startOfDay(for: date)
        let nextDay = cal.date(byAdding: .day, value: 1, to: earliestDay) ?? Date()
        
        let query = table.filter(eventDate >= earliestDay && eventDate < nextDay && username == name && deleted == false)
        let items = try DB.prepare(query)
        
        for _ in items {
            return true
        }
        
        return false
    }
    
    static func eventDayExistsExcept(date: Date, events: [JournalEvents]) throws -> Bool{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        
        let earliestDay = cal.startOfDay(for: date)
        let nextDay = cal.date(byAdding: .day, value: 1, to: earliestDay) ?? Date()
        
        let eDate = events.first?.eventTimestamp.treatTimestampStrAsDate() ?? Date()
        
        if let user = events.first?.username{
            let query = table.filter(eventDate >= earliestDay && eventDate < nextDay && username == user && deleted == false)
            let items = try DB.prepare(query)
            
            for item in items{
                let je = JournalEventsDataHelper.convertRow(item: item)
                let jeEventTimestamp = je.eventTimestamp.treatTimestampStrAsDate() ?? Date()
                if !(cal.isDate(jeEventTimestamp, inSameDayAs: eDate)){
                    return true
                }
            }
        }
        return false
    }
    
    static func getDayEvents(date: Date, user: String) throws -> [T]{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        //let utc = TimeZone(identifier: "UTC")
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        
        var dayEvents:[JournalEvents] = []
        let earliestDay = cal.startOfDay(for: date)
        //let earliestDay = cal.date(bySettingHour: 0, minute: 0, second: 0, of: date) ?? Date()
        let nextDay = cal.date(byAdding: .day, value: 1, to: earliestDay)
        
        let query = table.filter(eventDate >= earliestDay && eventDate < nextDay! && username == user && deleted == false)
        let items = try DB.prepare(query)
        for item in items{
            //let hour = cal.component(.hour, from: item[eventTimestamp])
            //if JournalDayEntryNavigationPages.allCases.contains(where: {$0.rawValue == hour}){
                dayEvents.append(JournalEventsDataHelper.convertRow(item: item))
            //}
        }
        
        return dayEvents
    }
    
    static func getLatestGel(user: String) throws -> T?{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let query = table.filter(deleted == false && lifeGelPads)
        let items = try DB.prepare(query)
        for item in items{
            return convertRow(item: item)
        }
        
        return nil
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
            /*
            if allOldColumns[eventTimestamp.template] != nil{
                columnMatch[eventTimestamp.template] = true
            }
            */
            
            //columns to add if not found
            
            if allOldColumns[eventTimestamp.template] == nil{
                try DB.run(table.addColumn(eventTimestamp, defaultValue: ""))
            }
            else{
                columnMatch[eventTimestamp.template] = true
            }
            
            if allOldColumns[drinksWaterOther.template] == nil{
                try DB.run(table.addColumn(drinksWaterOther, defaultValue: 0))
            }
            else{
                columnMatch[drinksWaterOther.template] = true
            }
            if allOldColumns[drinksCaffeinated.template] == nil{
                try DB.run(table.addColumn(drinksCaffeinated, defaultValue: 0))
            }
            else{
                columnMatch[drinksCaffeinated.template] = true
            }
            if allOldColumns[drinksAlcohol.template] == nil{
                try DB.run(table.addColumn(drinksAlcohol, defaultValue: 0))
            }
            else{
                columnMatch[drinksAlcohol.template] = true
            }
            if allOldColumns[restroomUrges.template] == nil{
                try DB.run(table.addColumn(restroomUrges, defaultValue: 0))
            }
            else{
                columnMatch[restroomUrges.template] = true
            }
            if allOldColumns[restroomDrops.template] == nil{
                try DB.run(table.addColumn(restroomDrops, defaultValue: 0))
            }
            else{
                columnMatch[restroomDrops.template] = true
            }
            if allOldColumns[restroomSleep.template] == nil{
                try DB.run(table.addColumn(restroomSleep, defaultValue: 0))
            }
            else{
                columnMatch[restroomSleep.template] = true
            }
            if allOldColumns[accidentsDrops.template] == nil{
                try DB.run(table.addColumn(accidentsDrops, defaultValue: 0))
            }
            else{
                columnMatch[accidentsDrops.template] = true
            }
            if allOldColumns[accidentsUrges.template] == nil{
                try DB.run(table.addColumn(accidentsUrges, defaultValue: 0))
            }
            else{
                columnMatch[accidentsUrges.template] = true
            }
            if allOldColumns[accidentsStress.template] == nil{
                try DB.run(table.addColumn(accidentsStress, defaultValue: 0))
            }
            else{
                columnMatch[accidentsStress.template] = true
            }
            if allOldColumns[accidentsChanges.template] == nil{
                try DB.run(table.addColumn(accidentsChanges, defaultValue: 0))
            }
            else{
                columnMatch[accidentsChanges.template] = true
            }
            if allOldColumns[accidentsSleep.template] == nil{
                try DB.run(table.addColumn(accidentsSleep, defaultValue: 0))
            }
            else{
                columnMatch[accidentsSleep.template] = true
            }
            if allOldColumns[lifeMedication.template] == nil{
                try DB.run(table.addColumn(lifeMedication, defaultValue: false))
            }
            else{
                columnMatch[lifeMedication.template] = true
            }
            if allOldColumns[lifeExercise.template] == nil{
                try DB.run(table.addColumn(lifeExercise, defaultValue: false))
            }
            else{
                columnMatch[lifeExercise.template] = true
            }
            if allOldColumns[lifeDailyRoutine.template] == nil{
                try DB.run(table.addColumn(lifeDailyRoutine, defaultValue: false))
            }
            else{
                columnMatch[lifeDailyRoutine.template] = true
            }
            if allOldColumns[lifeDiet.template] == nil{
                try DB.run(table.addColumn(lifeDiet, defaultValue: false))
            }
            else{
                columnMatch[lifeDiet.template] = true
            }
            if allOldColumns[lifeStress.template] == nil{
                try DB.run(table.addColumn(lifeStress, defaultValue: false))
            }
            else{
                columnMatch[lifeStress.template] = true
            }
            if allOldColumns[lifeOther.template] == nil{
                try DB.run(table.addColumn(lifeOther, defaultValue: false))
            }
            else{
                columnMatch[lifeOther.template] = true
            }
            if allOldColumns[lifeGelPads.template] == nil{
                try DB.run(table.addColumn(lifeGelPads, defaultValue: false))
            }
            else{
                columnMatch[lifeGelPads.template] = true
            }
            if allOldColumns[lifeNotes.template] == nil{
                try DB.run(table.addColumn(lifeNotes, defaultValue: ""))
            }
            else{
                columnMatch[lifeNotes.template] = true
            }
            if allOldColumns[username.template] == nil{
                try DB.run(table.addColumn(username, defaultValue: ""))
            }
            else{
                columnMatch[username.template] = true
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

