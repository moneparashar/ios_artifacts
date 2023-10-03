/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
//change timestamp to String

class StimDataDataHelper: DataHelperProtocol {
    typealias T = StimData
    static let TABLE_NAME = "StimData"
    static let table = Table(TABLE_NAME)
    
    static let guid = Expression<String>("guid")
    static let id = Expression<Int>("id")
    static let timestamp = Expression<Date>("timestamp")
    static let modified = Expression<Date?>("modified")
    static let dirty = Expression<Bool>("dirty")
    static let deleted = Expression<Bool>("deleted")
    static let sessionGuid = Expression<String?>("sessionGuid")
    static let state = Expression<Int?>("state")
    static let runningState = Expression< Int?>("runningState")
    static let deviceTime = Expression< Int?>("deviceTime")
    static let timeRemaining = Expression< Int?>("timeRemaining")
    static let pauseTimeRemaining = Expression< Int?>("pauseTimeRemaining")
    static let event = Expression< Int?>("event")
    static let currentAmplitude = Expression< Int?>("currentAmplitude")
    static let percentEMGDetect = Expression< Int?>("percentEMGDetect")
    static let percentNoiseDetect = Expression< Int?>("percentNoiseDetect")
    static let emgDetected = Expression< Int?>("emgDetected")
    static let emgTarget = Expression< Int?>("emgTarget")
    static let pulseWidth = Expression< Int?>("pulseWidth")
    static let pulseWidthMax = Expression< Int?>("pulseWidthMax")
    static let pulseWidthMin = Expression< Int?>("pulseWidthMin")
    static let pulseWidthAvg = Expression< Int?>("pulseWidthAvg")
    static let emgStrength = Expression< Int?>("emgStrength")
    static let emgStrengthMax = Expression< Int?>("emgStrengthMax")
    static let emgStrengthMin = Expression< Int?>("emgStrengthMin")
    static let emgStrengthAvg = Expression< Int?>("emgStrengthAvg")
    static let impedanceStim = Expression< Int?>("impedanceStim")
    static let impedanceStimMax = Expression< Int?>("impedanceStimMax")
    static let impedanceStimMin = Expression< Int?>("impedanceStimMin")
    static let impedanceStimAvg = Expression< Int?>("impedanceStimAvg")
    static let screeningGuid = Expression<String?>("patientGuid")
    static let mainState = Expression<Int?>("mainState")
    static let footConnectionADC = Expression<Int?>("footConnectionADC")
    static let tempPainThreshold = Expression<Int?>("tempPainThreshold")
    static let errorCodes = Expression<Int?>("errorCodes")
    static let temperature = Expression<Int?>("temperature")
    static let rawADCAtStimPulse = Expression<Int?>("rawADCAtStimPulse")
    
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
                    t.column(sessionGuid)
                    t.column(state)
                    t.column(runningState)
                    t.column(deviceTime)
                    t.column(timeRemaining)
                    t.column(pauseTimeRemaining)
                    t.column(event)
                    t.column(currentAmplitude)
                    t.column(percentEMGDetect)
                    t.column(percentNoiseDetect)
                    t.column(emgDetected)
                    t.column(emgTarget)
                    t.column(pulseWidth)
                    t.column(pulseWidthMax)
                    t.column(pulseWidthMin)
                    t.column(pulseWidthAvg)
                    t.column(emgStrength)
                    t.column(emgStrengthMax)
                    t.column(emgStrengthMin)
                    t.column(emgStrengthAvg)
                    t.column(impedanceStim)
                    t.column(impedanceStimMax)
                    t.column(impedanceStimMin)
                    t.column(impedanceStimAvg)
                    t.column(screeningGuid)
                    t.column(mainState)
                    t.column(footConnectionADC)
                    t.column(tempPainThreshold)
                    t.column(errorCodes)
                    t.column(temperature)
                    t.column(rawADCAtStimPulse)
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
                    state <- item.state == nil ? nil : Int(item.state!),
                    sessionGuid <- (item.sessionGuid == nil ? nil : item.sessionGuid!.uuidString),
                    runningState <- item.runningState == nil ? nil : Int(item.runningState!),
                    deviceTime <- item.deviceTime == nil ? nil : Int(item.deviceTime!),
                    timeRemaining <- item.timeRemaining == nil ? nil : Int(item.timeRemaining!),
                    pauseTimeRemaining <- item.timeRemaining == nil ? nil : Int(item.timeRemaining!),
                    event <- item.event == nil ? nil : Int(item.event!),
                    currentAmplitude <- item.currentAmplitude == nil ? nil : Int(item.currentAmplitude!),
                    percentEMGDetect <- item.percentEMGDetect == nil ? nil : Int(item.percentEMGDetect!),
                    percentNoiseDetect <- item.percentNoiseDetect == nil ? nil : Int(item.percentNoiseDetect!),
                    emgDetected <- item.emgDetected == nil ? nil : Int(item.emgDetected!),
                    emgTarget <- item.emgTarget == nil ? nil : Int(item.emgTarget!),
                    pulseWidth <- item.pulseWidth == nil ? nil : Int(item.pulseWidth!),
                    pulseWidthMax <- item.pulseWidthMax == nil ? nil : Int(item.pulseWidthMax!),
                    pulseWidthMin <- item.pulseWidthMin == nil ? nil : Int(item.pulseWidthMin!),
                    pulseWidthAvg <- item.pulseWidthAvg == nil ? nil : Int(item.pulseWidthAvg!),
                    emgStrength <- item.emgStrength == nil ? nil : Int(item.emgStrength!),
                    emgStrengthMax <- item.emgStrengthMax == nil ? nil : Int(item.emgStrengthMax!),
                    emgStrengthMin <- item.emgStrengthMin == nil ? nil : Int(item.emgStrengthMin!),
                    emgStrengthAvg <- item.emgStrengthAvg == nil ? nil : Int(item.emgStrengthAvg!),
                    impedanceStim <- item.impedanceStim == nil ? nil : Int(item.impedanceStim!),
                    impedanceStimMax <- item.impedanceStimMax == nil ? nil : Int(item.impedanceStimMax!),
                    impedanceStimMin <- item.impedanceStimMin == nil ? nil : Int(item.impedanceStimMin!),
                    impedanceStimAvg <- item.impedanceStimAvg == nil ? nil : Int(item.impedanceStimAvg!),
                    screeningGuid <- (item.screeningGuid == nil ? nil : item.screeningGuid?.uuidString),
                    mainState <- item.mainState == nil ? nil : Int(item.mainState!),
                    footConnectionADC <- item.footConnectionADC == nil ? nil : Int(item.footConnectionADC!),
                    tempPainThreshold <- item.tempPainThreshold == nil ? nil : Int(item.tempPainThreshold!),
                    errorCodes <- item.errorCodes == nil ? nil : Int(item.errorCodes!),
                    temperature <- item.temperature == nil ? nil : Int(item.temperature!),
                    rawADCAtStimPulse <- item.rawADCAtStimPulse == nil ? nil : Int(item.rawADCAtStimPulse!)
                 )
                do {
                    let rowId = try DB.run(insert)
                    guard rowId > 0 else {
                        throw DataAccessError.Insert_Error
                    }
                    //Slim.info("StimData table insert: emg Strength: \(emgStrength), emgTarget: \(emgTarget)")
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
            state <- item.state == nil ? nil : Int(item.state!),
            sessionGuid <- (item.sessionGuid == nil ? nil : item.sessionGuid!.uuidString),
            runningState <- item.runningState == nil ? nil : Int(item.runningState!),
            deviceTime <- item.deviceTime == nil ? nil : Int(item.deviceTime!),
            timeRemaining <- item.timeRemaining == nil ? nil : Int(item.timeRemaining!),
            pauseTimeRemaining <- item.timeRemaining == nil ? nil : Int(item.timeRemaining!),
            event <- item.event == nil ? nil : Int(item.event!),
            currentAmplitude <- item.currentAmplitude == nil ? nil : Int(item.currentAmplitude!),
            percentEMGDetect <- item.percentEMGDetect == nil ? nil : Int(item.percentEMGDetect!),
            percentNoiseDetect <- item.percentNoiseDetect == nil ? nil : Int(item.percentNoiseDetect!),
            emgDetected <- item.emgDetected == nil ? nil : Int(item.emgDetected!),
            emgTarget <- item.emgTarget == nil  ? nil : Int(item.emgTarget!),
            pulseWidth <- item.pulseWidth == nil ? nil : Int(item.pulseWidth!),
            pulseWidthMax <- item.pulseWidthMax == nil ? nil : Int(item.pulseWidthMax!),
            pulseWidthMin <- item.pulseWidthMin == nil ? nil : Int(item.pulseWidthMin!),
            pulseWidthAvg <- item.pulseWidthAvg == nil ? nil : Int(item.pulseWidthAvg!),
            emgStrength <- item.emgStrength == nil ? nil : Int(item.emgStrength!),
            emgStrengthMax <- item.emgStrengthMax == nil ? nil : Int(item.emgStrengthMax!),
            emgStrengthMin <- item.emgStrengthMin == nil ? nil : Int(item.emgStrengthMin!),
            emgStrengthAvg <- item.emgStrengthAvg == nil ? nil : Int(item.emgStrengthAvg!),
            impedanceStim <- item.impedanceStim == nil ? nil : Int(item.impedanceStim!),
            impedanceStimMax <- item.impedanceStimMax == nil ? nil : Int(item.impedanceStimMax!),
            impedanceStimMin <- item.impedanceStimMin == nil ? nil : Int(item.impedanceStimMin!),
            impedanceStimAvg <- item.impedanceStimAvg == nil ? nil : Int(item.impedanceStimAvg!),
            screeningGuid <- (item.screeningGuid == nil ? nil : item.screeningGuid?.uuidString),
            mainState <- item.mainState == nil ? nil : Int(item.mainState!),
            footConnectionADC <- item.footConnectionADC == nil ? nil : Int(item.footConnectionADC!),
            tempPainThreshold <- item.tempPainThreshold == nil ? nil : Int(item.tempPainThreshold!),
            errorCodes <- item.errorCodes == nil ? nil : Int(item.errorCodes!),
            temperature <- item.temperature == nil ? nil : Int(item.temperature!),
            rawADCAtStimPulse <- item.rawADCAtStimPulse == nil ? nil : Int(item.rawADCAtStimPulse!)
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
                return StimDataDataHelper.convertRow(item: item)
            }
            
            return nil
            
        }
    
    static func findRecent() throws -> T?{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.order(timestamp.desc).limit(1)
        let items = try DB.prepare(query)
        for item in items{
            return StimDataDataHelper.convertRow(item: item)
        }
        
        return nil
    }
    
    //add new func get recent Dirty and grabbing the limit
    static func findAllDirty() throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let query = table.filter(dirty == true)
        let items = try DB.prepare(query)
        for item in items {
            retArray.append(StimDataDataHelper.convertRow(item: item))
        }
        
        return retArray
    }
    
    static func setDirtyFalse() throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        //var query = table.filter(dirty == true)
        //query.update(dirty <- false)
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
                retArray.append(StimDataDataHelper.convertRow(item: item))
            }
            
            return retArray
            
        }
    
    static func convertRow(item:Row) -> StimData{
        
        let model = StimData()
        model.guid = UUID(uuidString: item[guid])!
        model.id = item[id]
        model.timestamp = item[timestamp]
        model.modified = item[modified]
        model.dirty = item[dirty]
        model.deleted = item[deleted]
        model.screeningGuid = item[screeningGuid] == nil ? nil : UUID(uuidString: item[screeningGuid]!)!
        model.sessionGuid = item[sessionGuid] == nil ? nil : UUID(uuidString: item[sessionGuid]!)!
        model.state = item[state] == nil ? nil : Int8(item[state]!)
        model.runningState = item[runningState] == nil ? nil : Int8(item[runningState]!)
        model.deviceTime = item[deviceTime] == nil ? nil : Int32(item[deviceTime]!)
        model.timeRemaining = item[timeRemaining] == nil ? nil : Int16(item[timeRemaining]!)
        model.pauseTimeRemaining = item[pauseTimeRemaining] == nil ? nil : Int16(item[pauseTimeRemaining]!)
        model.event = item[event] == nil ? nil : Int8(item[event]!)
        model.currentAmplitude = item[currentAmplitude] == nil ? 0 : Int16(item[currentAmplitude]!)
        model.percentEMGDetect = item[percentEMGDetect] == nil ? 0 : Int8(item[percentEMGDetect]!)
        model.percentNoiseDetect = item[percentNoiseDetect] == nil ? 0 : Int8(item[percentNoiseDetect]!)
        model.emgDetected = item[emgDetected] == nil ? 0 : Int8(item[emgDetected]!)
        model.emgTarget = item[emgTarget] == nil ? 0 : Int32(item[emgTarget]!)
        model.pulseWidth = item[pulseWidth] == nil ? 0 : Int16(item[pulseWidth]!)
        model.pulseWidthMax = item[pulseWidthMax] == nil ? 0 : Int16(item[pulseWidthMax]!)
        model.pulseWidthMin = item[pulseWidthMin] == nil ? 0 : Int16(item[pulseWidthMin]!)
        model.pulseWidthAvg = item[pulseWidthAvg] == nil ? 0 : Int16(item[pulseWidthAvg]!)
        model.emgStrength = item[emgStrength] == nil ? 0 : Int32(item[emgStrength]!)
        model.emgStrengthMax = item[emgStrengthMax] == nil ? 0 : Int32(item[emgStrengthMax]!)
        model.emgStrengthMin = item[emgStrengthMin] == nil ? 0 : Int32(item[emgStrengthMin]!)
        model.emgStrengthAvg = item[emgStrengthAvg] == nil ? 0 : Int32(item[emgStrengthAvg]!)
        model.impedanceStim = item[impedanceStim] == nil ? 0 : Int32(item[impedanceStim]!)
        model.impedanceStimMax = item[impedanceStimMax] == nil ? 0 : Int32(item[impedanceStimMax]!)
        model.impedanceStimMin = item[impedanceStimMin] == nil ? 0 : Int32(item[impedanceStimMin]!)
        model.impedanceStimAvg = item[impedanceStimAvg] == nil ? 0 : Int32(item[impedanceStimAvg]!)
        model.mainState = item[mainState] == nil ? nil : Int8(item[mainState]!)
        model.footConnectionADC = item[footConnectionADC] == nil ? 0 : Int16(item[footConnectionADC]!)
        model.tempPainThreshold = item[tempPainThreshold] == nil ? 0 : Int32(item[tempPainThreshold]!)
        model.errorCodes = item[errorCodes] == nil ? 0 : Int32(item[errorCodes]!)
        model.temperature = item[temperature] == nil ? nil : Int8(item[temperature]!)
        model.rawADCAtStimPulse = item[rawADCAtStimPulse] == nil ? nil : Int16(item[rawADCAtStimPulse]!)
        return model
    }
    
    
    static func getPauseCount(sessGuid: String) throws -> Int{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let query = table.filter(sessionGuid == sessGuid)
        let items = try DB.prepare(query)
        
        let pausedState = Int(StimStatusStates.paused.rawValue)
        var pauseCount = 0
        var pauseTime = 0
        var lastState = 0
        var first = true
        for item in items{
            let sd = StimDataDataHelper.convertRow(item: item)
            if let sdState = sd.state{
                if sdState == pausedState{
                    pauseTime += 1
                    if pauseCount < 2 && !first && lastState != pausedState{
                        pauseCount += 1
                    }
                }
            }
            if first{
                first = false
            }
            lastState = Int(sd.state ?? 0)
        }
        
        return pauseCount
    }
    
    static func getEMGCount(sessGuid: String) throws -> Int{
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let query = table.filter(sessionGuid == sessGuid)
        let items = try DB.prepare(query)
        
        var emgCount = 0
        for item in items{
            let sd = StimDataDataHelper.convertRow(item: item)
            if sd.emgDetected == 1{
                emgCount += 1
            }
        }
        
        return emgCount
    }
    
    
    static func toString(date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
    
    static func toDate(str: String)-> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: str) ?? Date()
    }

    /*
    static func getLatestWithMax(bulkCount: Int) throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let query = table.filter(dirty == true).limit(bulkCount)        //.order
        let items = try DB.prepare(query)
        for item in items {
            retArray.append(StimDataDataHelper.convertRow(item: item))
        }
        
        return retArray
    }
    */
    static func getTotalRecordsLeftToSend() throws -> Int {
        guard let DB = SQLiteDataStore.sharedInstance.AVATIONDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let query = table.filter(dirty == true)
        //let items = try DB.prepare(query)
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
            retArray[outerIndex].append(StimDataDataHelper.convertRow(item: item))
            //Slim.info("converted Stim Data: EMGStrength: \(retArray[outerIndex][count].emgStrength), EMGTarget: \(retArray[outerIndex][count].emgTarget), TempPain: \(retArray[outerIndex][count].tempPainThreshold)")
            count += 1
            
            
        }
        return retArray
    }
    
    static func setSentClean(sentStimBulk: [T]) throws {
        for stim in sentStimBulk{
            //Slim.info("STIM DATA: guid: \(stim.guid.uuidString), screening guid: \(stim.screeningGuid?.uuidString), session guid: \(stim.sessionGuid?.uuidString), timestamp: \(stim.timestamp)")
            do{
                stim.dirty = false
                try update(item: stim)
            } catch{
                print("error with updating supposedly already sent data")
                break }
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
    
    static func clearClean() throws {
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
            
            //
            //columns to add if not found
            if allOldColumns[sessionGuid.template] == nil{
                try DB.run(table.addColumn(sessionGuid))
            }
            else{
                columnMatch[sessionGuid.template] = true
            }
            if allOldColumns[state.template] == nil{
                try DB.run(table.addColumn(state))
            }
            else{
                columnMatch[state.template] = true
            }
            if allOldColumns[runningState.template] == nil{
                try DB.run(table.addColumn(runningState))
            }
            else{
                columnMatch[runningState.template] = true
            }
            if allOldColumns[deviceTime.template] == nil{
                try DB.run(table.addColumn(deviceTime))
            }
            else{
                columnMatch[deviceTime.template] = true
            }
            if allOldColumns[timeRemaining.template] == nil{
                try DB.run(table.addColumn(timeRemaining))
            }
            else{
                columnMatch[timeRemaining.template] = true
            }
            if allOldColumns[pauseTimeRemaining.template] == nil{
                try DB.run(table.addColumn(pauseTimeRemaining))
            }
            else{
                columnMatch[pauseTimeRemaining.template] = true
            }
            if allOldColumns[event.template] == nil{
                try DB.run(table.addColumn(event))
            }
            else{
                columnMatch[event.template] = true
            }
            if allOldColumns[currentAmplitude.template] == nil{
                try DB.run(table.addColumn(currentAmplitude))
            }
            else{
                columnMatch[currentAmplitude.template] = true
            }
            if allOldColumns[percentEMGDetect.template] == nil{
                try DB.run(table.addColumn(percentEMGDetect))
            }
            else{
                columnMatch[percentEMGDetect.template] = true
            }
            if allOldColumns[percentNoiseDetect.template] == nil{
                try DB.run(table.addColumn(percentNoiseDetect))
            }
            else{
                columnMatch[percentNoiseDetect.template] = true
            }
            if allOldColumns[emgDetected.template] == nil{
                try DB.run(table.addColumn(emgDetected))
            }
            else{
                columnMatch[emgDetected.template] = true
            }
            if allOldColumns[emgTarget.template] == nil{
                try DB.run(table.addColumn(emgTarget))
            }
            else{
                columnMatch[emgTarget.template] = true
            }
            if allOldColumns[pulseWidth.template] == nil{
                try DB.run(table.addColumn(pulseWidth))
            }
            else{
                columnMatch[pulseWidth.template] = true
            }
            if allOldColumns[pulseWidthMax.template] == nil{
                try DB.run(table.addColumn(pulseWidthMax))
            }
            else{
                columnMatch[pulseWidthMax.template] = true
            }
            if allOldColumns[pulseWidthMin.template] == nil{
                try DB.run(table.addColumn(pulseWidthMin))
            }
            else{
                columnMatch[pulseWidthMin.template] = true
            }
            if allOldColumns[pulseWidthAvg.template] == nil{
                try DB.run(table.addColumn(pulseWidthAvg))
            }
            else{
                columnMatch[pulseWidthAvg.template] = true
            }
            if allOldColumns[emgStrength.template] == nil{
                try DB.run(table.addColumn(emgStrength))
            }
            else{
                columnMatch[emgStrength.template] = true
            }
            if allOldColumns[emgStrengthMax.template] == nil{
                try DB.run(table.addColumn(emgStrengthMax))
            }
            else{
                columnMatch[emgStrengthMax.template] = true
            }
            if allOldColumns[emgStrengthMin.template] == nil{
                try DB.run(table.addColumn(emgStrengthMin))
            }
            else{
                columnMatch[emgStrengthMin.template] = true
            }
            if allOldColumns[emgStrengthAvg.template] == nil{
                try DB.run(table.addColumn(emgStrengthAvg))
            }
            else{
                columnMatch[emgStrengthAvg.template] = true
            }
            if allOldColumns[impedanceStim.template] == nil{
                try DB.run(table.addColumn(impedanceStim))
            }
            else{
                columnMatch[impedanceStim.template] = true
            }
            if allOldColumns[impedanceStimMax.template] == nil{
                try DB.run(table.addColumn(impedanceStimMax))
            }
            else{
                columnMatch[impedanceStimMax.template] = true
            }
            if allOldColumns[impedanceStimMin.template] == nil{
                try DB.run(table.addColumn(impedanceStimMin))
            }
            else{
                columnMatch[impedanceStimMin.template] = true
            }
            if allOldColumns[impedanceStimAvg.template] == nil{
                try DB.run(table.addColumn(impedanceStimAvg))
            }
            else{
                columnMatch[impedanceStimAvg.template] = true
            }
            if allOldColumns[screeningGuid.template] == nil{
                try DB.run(table.addColumn(screeningGuid))
            }
            else{
                columnMatch[screeningGuid.template] = true
            }
            if allOldColumns[mainState.template] == nil{
                try DB.run(table.addColumn(mainState))
            }
            else{
                columnMatch[mainState.template] = true
            }
            if allOldColumns[footConnectionADC.template] == nil{
                try DB.run(table.addColumn(footConnectionADC))
            }
            else{
                columnMatch[footConnectionADC.template] = true
            }
            if allOldColumns[tempPainThreshold.template] == nil{
                try DB.run(table.addColumn(tempPainThreshold))
            }
            else{
                columnMatch[tempPainThreshold.template] = true
            }
            if allOldColumns[errorCodes.template] == nil{
                try DB.run(table.addColumn(errorCodes))
            }
            else{
                columnMatch[errorCodes.template] = true
            }
            if allOldColumns[temperature.template] == nil{
                try DB.run(table.addColumn(temperature))
            }
            else{
                columnMatch[temperature.template] = true
            }
            if allOldColumns[rawADCAtStimPulse.template] == nil{
                try DB.run(table.addColumn(rawADCAtStimPulse))
            }
            else{
                columnMatch[rawADCAtStimPulse.template] = true
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
