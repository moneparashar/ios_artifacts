/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class EvaluationCriteria: BaseModel {
    var deviceConfigurationGuid: UUID? = nil
    //var patientGuid: UUID? = nil
    var screeningGuid: UUID? = nil
    var foot: Int = 0
    var stimulationCurrentAmplitude: Int = 0
    var skinParesthesiaPulseWidth: Int = 0
    var footParesthesiaPulseWidth: Int = 0
    var comfortLevelPulseWidth: Int = 0
    var emgDetectionPointPulseWidth: Int = 0
    var targetTherapyLevelPulseWidth: Int = 0
    var comfortLevelEMGStrength: Int = 0
    var emgDetectionPointEMGStrength: Int = 0
    var targetEMGStrength: Int = 0
    var therapyLength: Int = 0
    var therapySchedule: Int = 0
    var emgStrengthMax: Int = 0
    var currentTick: Int = 6
    var tempPainThreshold: Int = 0
    var lastCompletedTime: Int = 0
    var dailyTherapyTime: Int = 0
    var eventTimestamp: String?
    
    enum CodingKeys: CodingKey{
        case deviceConfigurationGuid
        //case patientGuid
        case screeningGuid
        case foot
        case stimulationCurrentAmplitude
        case skinParesthesiaPulseWidth
        case footParesthesiaPulseWidth
        case comfortLevelPulseWidth
        case emgDetectionPointPulseWidth
        case targetTherapyLevelPulseWidth
        case comfortLevelEMGStrength
        case emgDetectionPointEMGStrength
        case targetEMGStrength
        case therapyLength
        case therapySchedule
        case emgStrengthMax
        case currentTick
        case tempPainThreshold
        case lastCompletedTime
        case dailyTherapyTime
        case eventTimestamp
    }
    
    override init() {
         deviceConfigurationGuid = nil
         //patientGuid = nil
         screeningGuid = nil
         foot = 0
         stimulationCurrentAmplitude = 0
         skinParesthesiaPulseWidth = 0
         footParesthesiaPulseWidth = 0
         comfortLevelPulseWidth = 0
         emgDetectionPointPulseWidth = 0
         targetTherapyLevelPulseWidth = 0
         comfortLevelEMGStrength = 0
         emgDetectionPointEMGStrength = 0
         targetEMGStrength = 0
         therapyLength = 0
         therapySchedule = 0
         emgStrengthMax = 0
         currentTick = 6
         tempPainThreshold = 0
         lastCompletedTime = 0
        eventTimestamp = Date().convertDateToOffsetStr()
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(deviceConfigurationGuid, forKey:.deviceConfigurationGuid)
        //try container.encodeIfPresent(patientGuid, forKey:.patientGuid)
        try container.encodeIfPresent(screeningGuid, forKey:.screeningGuid)
        try container.encodeIfPresent(foot, forKey: .foot)
        try container.encodeIfPresent(stimulationCurrentAmplitude, forKey: .stimulationCurrentAmplitude)
        try container.encodeIfPresent(skinParesthesiaPulseWidth, forKey: .skinParesthesiaPulseWidth)
        try container.encodeIfPresent(footParesthesiaPulseWidth, forKey: .footParesthesiaPulseWidth)
        try container.encodeIfPresent(comfortLevelPulseWidth, forKey: .comfortLevelPulseWidth)
        try container.encodeIfPresent(emgDetectionPointPulseWidth, forKey: .emgDetectionPointPulseWidth)
        try container.encodeIfPresent(targetTherapyLevelPulseWidth, forKey: .targetTherapyLevelPulseWidth)
        try container.encodeIfPresent(comfortLevelEMGStrength, forKey: .comfortLevelEMGStrength)
        try container.encodeIfPresent(emgDetectionPointEMGStrength, forKey: .emgDetectionPointEMGStrength)
        try container.encodeIfPresent(targetEMGStrength, forKey: .targetEMGStrength)
        try container.encodeIfPresent(therapyLength, forKey: .therapyLength)
        try container.encodeIfPresent(therapySchedule, forKey: .therapySchedule)
        try container.encodeIfPresent(emgStrengthMax, forKey: .emgStrengthMax)
        try container.encodeIfPresent(currentTick, forKey: .currentTick)
        try container.encodeIfPresent(tempPainThreshold, forKey: .tempPainThreshold)
        try container.encodeIfPresent(lastCompletedTime, forKey: .lastCompletedTime)
        try container.encodeIfPresent(dailyTherapyTime, forKey: .dailyTherapyTime)
        try container.encodeIfPresent(eventTimestamp, forKey: .eventTimestamp)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        deviceConfigurationGuid = try container.decodeIfPresent(UUID.self, forKey: .deviceConfigurationGuid)
        //patientGuid = try container.decodeIfPresent(UUID.self, forKey: .patientGuid)
        screeningGuid = try container.decodeIfPresent(UUID.self, forKey: .screeningGuid)
        foot = try container.decode(Int.self, forKey: .foot)
        stimulationCurrentAmplitude = try container.decode(Int.self, forKey: .stimulationCurrentAmplitude)
        skinParesthesiaPulseWidth = try container.decode(Int.self, forKey: .skinParesthesiaPulseWidth)
        footParesthesiaPulseWidth = try container.decode(Int.self, forKey: .footParesthesiaPulseWidth)
        comfortLevelPulseWidth = try container.decode(Int.self, forKey: .comfortLevelPulseWidth)
        emgDetectionPointPulseWidth = try container.decode(Int.self, forKey: .emgDetectionPointPulseWidth)
        targetTherapyLevelPulseWidth = try container.decode(Int.self, forKey: .targetTherapyLevelPulseWidth)
        comfortLevelEMGStrength = try container.decode(Int.self, forKey: .comfortLevelEMGStrength)
        emgDetectionPointEMGStrength = try container.decode(Int.self, forKey: .emgDetectionPointEMGStrength)
        targetEMGStrength = try container.decode(Int.self, forKey: .targetEMGStrength)
        therapyLength = try container.decode(Int.self, forKey: .therapyLength)
        therapySchedule = try container.decode(Int.self, forKey: .therapySchedule)
        emgStrengthMax = try container.decode(Int.self, forKey: .emgStrengthMax)
        currentTick = try container.decode(Int.self, forKey: .currentTick)
        tempPainThreshold = try container.decode(Int.self, forKey: .tempPainThreshold)
        lastCompletedTime = try container.decode(Int.self, forKey: .lastCompletedTime)
        dailyTherapyTime = try container.decode(Int.self, forKey: .dailyTherapyTime)
        eventTimestamp = try container.decodeIfPresent(String.self, forKey: .eventTimestamp) ?? nil
        
        try super.init(from: decoder)
    }
}
