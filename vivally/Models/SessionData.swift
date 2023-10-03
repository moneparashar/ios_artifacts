/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class SessionData: BaseModel {
    var startTime:Int
    var isComplete:Bool
    var pauseCount:Int
    var duration:Int
    var detectedEMGCount:Int
    var avgEMGStrength:Int
    var avgStimPulseWidth:Int
    var maxStimPulseWidth:Int
    var overallAvgImpedance:Int
    var batteryLevelAtStart:Int
    var deviceConfigurationGuid:UUID?
    var evaluationCriteriaGuid:UUID?
    var username:String
    var eventTimestamp: String?
    var isTestSession: Bool?
    
    override init(){
        startTime = 0
        isComplete = false
        pauseCount = 0
        duration = 0
        detectedEMGCount = 0
        avgEMGStrength = 0
        avgStimPulseWidth = 0
        maxStimPulseWidth = 0
        overallAvgImpedance = 0
        batteryLevelAtStart = 0
        deviceConfigurationGuid = nil
        evaluationCriteriaGuid = nil
        username = ""
        eventTimestamp = Date().convertDateToOffsetStr()
        isTestSession = false
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(startTime, forKey:.startTime)
        try container.encodeIfPresent(isComplete, forKey: .isComplete)
        try container.encodeIfPresent(pauseCount, forKey: .pauseCount)
        try container.encodeIfPresent(duration, forKey:.duration)
        try container.encodeIfPresent(detectedEMGCount, forKey:.detectedEMGCount)
        try container.encodeIfPresent(avgEMGStrength, forKey: .avgEMGStrength)
        try container.encodeIfPresent(avgStimPulseWidth, forKey:.avgStimPulseWidth)
        try container.encodeIfPresent(maxStimPulseWidth, forKey:.maxStimPulseWidth)
        try container.encodeIfPresent(overallAvgImpedance, forKey: .overallAvgImpedance)
        try container.encodeIfPresent(batteryLevelAtStart, forKey:.batteryLevelAtStart)
        try container.encodeIfPresent(deviceConfigurationGuid, forKey:.deviceConfigurationGuid)
        try container.encodeIfPresent(evaluationCriteriaGuid, forKey: .evaluationCriteriaGuid)
        try container.encodeIfPresent(username, forKey:.username)
        try container.encodeIfPresent(eventTimestamp, forKey: .eventTimestamp)
        try container.encodeIfPresent(isTestSession, forKey:.isTestSession)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        startTime = try container.decodeIfPresent(Int.self, forKey: .startTime) ?? 0
        isComplete = try container.decodeIfPresent(Bool.self, forKey: .isComplete) ?? false
        pauseCount = try container.decodeIfPresent(Int.self, forKey: .pauseCount) ?? 0
        duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? 0
        detectedEMGCount = try container.decodeIfPresent(Int.self, forKey: .detectedEMGCount) ?? 0
        avgEMGStrength = try container.decodeIfPresent(Int.self, forKey: .avgEMGStrength) ?? 0
        avgStimPulseWidth = try container.decodeIfPresent(Int.self, forKey: .avgStimPulseWidth) ?? 0
        maxStimPulseWidth = try container.decodeIfPresent(Int.self, forKey: .maxStimPulseWidth) ?? 0
        overallAvgImpedance = try container.decodeIfPresent(Int.self, forKey: .overallAvgImpedance) ?? 0
        batteryLevelAtStart = try container.decodeIfPresent(Int.self, forKey: .batteryLevelAtStart) ?? 0
        deviceConfigurationGuid = try container.decodeIfPresent(UUID.self, forKey: .deviceConfigurationGuid)
        evaluationCriteriaGuid = try container.decodeIfPresent(UUID.self, forKey: .evaluationCriteriaGuid)
        username = try container.decode(String.self, forKey: .username)
        eventTimestamp = try container.decodeIfPresent(String.self, forKey: .eventTimestamp) ?? nil
        isTestSession = try container.decodeIfPresent(Bool.self, forKey: .isTestSession) ?? false
        try super.init(from: decoder)
   }
    
    enum CodingKeys: CodingKey{
        case startTime
        case isComplete
        case pauseCount
        case duration
        case detectedEMGCount
        case avgEMGStrength
        case avgStimPulseWidth
        case maxStimPulseWidth
        case overallAvgImpedance
        case batteryLevelAtStart
        case deviceConfigurationGuid
        case evaluationCriteriaGuid
        case username
        case eventTimestamp
        case isTestSession
    }
}
