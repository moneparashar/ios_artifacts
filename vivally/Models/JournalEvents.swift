/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class JournalEvents: BaseModel{
    var eventTimestamp:String
    var drinksWaterOther:Double?
    var drinksCaffeinated:Double?
    var drinksAlcohol:Double?
    var restroomUrges:Int?
    var restroomDrops:Int?
    var restroomSleep:Int?
    var accidentsDrops:Int?
    var accidentsUrges:Int?
    var accidentsStress:Int?
    var accidentsChanges:Int?
    var accidentsSleep:Int?
    var lifeMedication:Bool?
    var lifeExercise:Bool?
    var lifeDailyRoutine:Bool?
    var lifeDiet:Bool?
    var lifeStress:Bool?
    var lifeOther:Bool?
    var lifeGelPads:Bool?
    var lifeNotes:String?
    var username:String
    
    override init() {
        eventTimestamp = Date().convertDateToOffsetStr() ?? ""
        drinksWaterOther = 0
        drinksCaffeinated = 0
        drinksAlcohol = 0
        restroomUrges = 0
        restroomDrops = 0
        restroomSleep = 0
        accidentsDrops = 0
        accidentsUrges = 0
        accidentsStress = 0
        accidentsChanges = 0
        accidentsSleep = 0
        lifeMedication = false
        lifeExercise = false
        lifeDailyRoutine = false
        lifeDiet = false
        lifeStress = false
        lifeOther = false
        lifeGelPads = false
        lifeNotes = ""
        username = ""
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(eventTimestamp, forKey: .eventTimestamp)
        try container.encodeIfPresent(drinksWaterOther, forKey: .drinksWaterOther)
        try container.encodeIfPresent(drinksCaffeinated, forKey: .drinksCaffeinated)
        try container.encodeIfPresent(drinksAlcohol, forKey: .drinksAlcohol)
        try container.encodeIfPresent(restroomUrges, forKey: .restroomUrges)
        try container.encodeIfPresent(restroomDrops, forKey: .restroomDrops)
        try container.encodeIfPresent(restroomSleep, forKey: .restroomSleep)
        try container.encodeIfPresent(accidentsDrops, forKey: .accidentsDrops)
        try container.encodeIfPresent(accidentsUrges, forKey: .accidentsUrges)
        try container.encodeIfPresent(accidentsStress, forKey: .accidentsStress)
        try container.encodeIfPresent(accidentsChanges, forKey: .accidentsChanges)
        try container.encodeIfPresent(accidentsSleep, forKey: .accidentsSleep)
        try container.encodeIfPresent(lifeMedication, forKey: .lifeMedication)
        try container.encodeIfPresent(lifeExercise, forKey: .lifeExercise)
        try container.encodeIfPresent(lifeDailyRoutine, forKey: .lifeDailyRoutine)
        try container.encodeIfPresent(lifeDiet, forKey: .lifeDiet)
        try container.encodeIfPresent(lifeStress, forKey: .lifeStress)
        try container.encodeIfPresent(lifeOther, forKey: .lifeOther)
        try container.encodeIfPresent(lifeGelPads, forKey: .lifeGelPads)
        try container.encodeIfPresent(lifeNotes, forKey: .lifeNotes)
        try container.encode(username, forKey: .username)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        eventTimestamp = try container.decode(String.self, forKey: .eventTimestamp)
        drinksWaterOther = try container.decodeIfPresent(Double.self, forKey: .drinksWaterOther) ?? 0.0
        drinksCaffeinated = try container.decodeIfPresent(Double.self, forKey: .drinksCaffeinated) ?? 0.0
        drinksAlcohol = try container.decodeIfPresent(Double.self, forKey: .drinksAlcohol) ?? 0.0
        restroomUrges = try container.decodeIfPresent(Int.self, forKey: .restroomUrges) ?? 0
        restroomDrops = try container.decodeIfPresent(Int.self, forKey: .restroomDrops) ?? 0
        restroomSleep = try container.decodeIfPresent(Int.self, forKey: .restroomSleep) ?? 0
        accidentsDrops = try container.decodeIfPresent(Int.self, forKey: .accidentsDrops) ?? 0
        accidentsUrges = try container.decodeIfPresent(Int.self, forKey: .accidentsUrges) ?? 0
        accidentsStress = try container.decodeIfPresent(Int.self, forKey: .accidentsStress) ?? 0
        accidentsChanges = try container.decodeIfPresent(Int.self, forKey: .accidentsChanges) ?? 0
        accidentsSleep = try container.decodeIfPresent(Int.self, forKey: .accidentsSleep) ?? 0
        lifeMedication = try container.decodeIfPresent(Bool.self, forKey: .lifeMedication) ?? false
        lifeExercise = try container.decodeIfPresent(Bool.self, forKey: .lifeExercise) ?? false
        lifeDailyRoutine = try container.decodeIfPresent(Bool.self, forKey: .lifeDailyRoutine) ?? false
        lifeDiet = try container.decodeIfPresent(Bool.self, forKey: .lifeDiet) ?? false
        lifeStress = try container.decodeIfPresent(Bool.self, forKey: .lifeStress) ?? false
        lifeOther = try container.decodeIfPresent(Bool.self, forKey: .lifeOther) ?? false
        lifeGelPads = try container.decodeIfPresent(Bool.self, forKey: .lifeGelPads) ?? false
        //lifeNotes = try container.decode(String.self, forKey: .lifeNotes)
        lifeNotes = try container.decodeIfPresent(String.self, forKey: .lifeNotes) ?? ""
        username = try container.decode(String.self, forKey: .username)
        try super.init(from: decoder)
    }
    
    enum CodingKeys: CodingKey{
        case eventTimestamp
        case drinksWaterOther
        case drinksCaffeinated
        case drinksAlcohol
        case restroomUrges
        case restroomDrops
        case restroomSleep
        case accidentsDrops
        case accidentsUrges
        case accidentsStress
        case accidentsChanges
        case accidentsSleep
        case lifeMedication
        case lifeExercise
        case lifeDailyRoutine
        case lifeDiet
        case lifeStress
        case lifeOther
        case lifeGelPads
        case lifeNotes
        case username
    }
    
    func isEmpty() -> Bool{
        if restroomDrops == 0 && restroomUrges == 0 && restroomSleep == 0 &&
            accidentsDrops == 0 && accidentsUrges == 0 && accidentsChanges == 0 && accidentsSleep == 0 &&
            drinksWaterOther == 0 && drinksCaffeinated == 0 && drinksAlcohol == 0 &&
            !(lifeMedication ?? false) && !(lifeDiet ?? false) && !(lifeExercise ?? false) && !(lifeStress ?? false) && !(lifeGelPads ?? false){
            return true
        }
            return false
    }
    
    func rangeSetCorrectly(isLife: Bool = false) -> Bool{
        if isLife{
            return restroomDrops == 0 && restroomUrges == 0 && restroomSleep == 0 &&
                        accidentsDrops == 0 && accidentsUrges == 0 && accidentsChanges == 0 && accidentsSleep == 0 &&
                        drinksWaterOther == 0 && drinksCaffeinated == 0 && drinksAlcohol == 0
        }
        else{
            return !(lifeMedication ?? false) && !(lifeDiet ?? false) && !(lifeExercise ?? false) && !(lifeStress ?? false) && !(lifeGelPads ?? false) && !(lifeDailyRoutine ?? false) && !(lifeOther ?? false)
        }
    }
    
    func createCopy() -> JournalEvents{
        let je = JournalEvents()
        je.guid = guid
        je.id = id
        je.timestamp = timestamp
        je.modified = modified
        je.dirty = dirty
        je.deleted = deleted
        
        je.eventTimestamp = eventTimestamp
        je.drinksWaterOther = drinksWaterOther
        je.drinksCaffeinated = drinksCaffeinated
        je.drinksAlcohol = drinksAlcohol
        je.restroomUrges = restroomUrges
        je.restroomDrops = restroomDrops
        je.restroomSleep = restroomSleep
        je.accidentsDrops = accidentsDrops
        je.accidentsUrges = accidentsUrges
        je.accidentsStress = accidentsStress
        je.accidentsChanges = accidentsChanges
        je.accidentsSleep = accidentsSleep
        je.lifeMedication = lifeMedication
        je.lifeExercise = lifeExercise
        je.lifeDailyRoutine = lifeDailyRoutine
        je.lifeDiet = lifeDiet
        je.lifeStress = lifeStress
        je.lifeOther = lifeOther
        je.lifeGelPads = lifeGelPads
        je.lifeNotes = lifeNotes
        je.username = username
        return je
    }
    
    func createCopyRange() -> JournalEvents{
        let je = JournalEvents()
        je.drinksWaterOther = drinksWaterOther
        je.drinksCaffeinated = drinksCaffeinated
        je.drinksAlcohol = drinksAlcohol
        je.restroomUrges = restroomUrges
        je.restroomDrops = restroomDrops
        je.restroomSleep = restroomSleep
        je.accidentsDrops = accidentsDrops
        je.accidentsUrges = accidentsUrges
        je.accidentsStress = accidentsStress
        je.accidentsChanges = accidentsChanges
        je.accidentsSleep = accidentsSleep
        je.username = username
        return je
    }
    
    func createCopyLife() -> JournalEvents{
        let je = JournalEvents()
        je.lifeMedication = lifeMedication
        je.lifeExercise = lifeExercise
        je.lifeDiet = lifeDiet
        je.lifeStress = lifeStress
        je.lifeGelPads = lifeGelPads
        je.username = username
        return je
    }
    
}
