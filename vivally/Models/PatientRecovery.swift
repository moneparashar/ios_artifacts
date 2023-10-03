/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class PatientRecovery: BaseModel {
    var patientSchedule: Int? = 0
    var patientTimeSet: Int? = 0
    var skinParesthesia: Int? = 0
    var soleParesthesia: Int? = 0
    var painThreshold: Int? = 0
    var pulseWidthAtEmg: Int? = 0
    var comfortLevelEMG: Int? = 0
    var detectionLevelEMG: Int? = 0
    var foot: Int? = 0
    var amplitude: Int16? = 0
    var pulseWidthTarget: Int16? = 0
    var evalEmgTarget: Int? = 0
    var patientInfoComplete: Int16? = 0
    var pulseWidthStrengthMax: Int16? = 0
    var strengthMax: Int? = 0
    var pauseCount: Int16? = 0
    var tempPainThreshold: Int16? = 0
    var painThresholdMax: Int16? = 0
    var emgTargetIncrement: Int? = 0
    var lastCompletedTime: [Int]? = []
    var nextAvailableTime: Int? = 0
    var emgTargetUpdated: Int? = 0
    var numTicks: UInt8? = 0
    var currentTick: UInt8? = 0
    var evalTick: UInt8? = 0
    var pwIncrement: Int16? = 0
    var subjectID: [UInt8]? = []
    var screenTime: Int? = 0
    var dailyTherapyTime: Int16? = 0
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(patientSchedule, forKey:.patientSchedule)
        try container.encodeIfPresent(patientTimeSet, forKey: .patientTimeSet)
        try container.encodeIfPresent(skinParesthesia, forKey:.skinParesthesia)
        try container.encodeIfPresent(soleParesthesia, forKey:.soleParesthesia)
        try container.encodeIfPresent(painThreshold, forKey:.painThreshold)
        try container.encodeIfPresent(pulseWidthAtEmg, forKey:.pulseWidthAtEmg)
        try container.encodeIfPresent(comfortLevelEMG, forKey:.comfortLevelEMG)
        try container.encodeIfPresent(detectionLevelEMG, forKey:.detectionLevelEMG)
        try container.encodeIfPresent(foot, forKey:.foot)
        try container.encodeIfPresent(amplitude, forKey:.amplitude)
        try container.encodeIfPresent(pulseWidthTarget, forKey:.pulseWidthTarget)
        try container.encodeIfPresent(evalEmgTarget, forKey:.evalEmgTarget)
        try container.encodeIfPresent(patientInfoComplete, forKey:.patientInfoComplete)
        try container.encodeIfPresent(pulseWidthStrengthMax, forKey:.pulseWidthStrengthMax)
        try container.encodeIfPresent(strengthMax, forKey:.strengthMax)
        try container.encodeIfPresent(pauseCount, forKey:.pauseCount)
        try container.encodeIfPresent(tempPainThreshold, forKey:.tempPainThreshold)
        try container.encodeIfPresent(painThresholdMax, forKey:.painThresholdMax)
        try container.encodeIfPresent(emgTargetIncrement, forKey:.emgTargetIncrement)
        try container.encodeIfPresent(lastCompletedTime, forKey:.lastCompletedTime)
        try container.encodeIfPresent(nextAvailableTime, forKey:.nextAvailableTime)
        try container.encodeIfPresent(emgTargetUpdated, forKey:.emgTargetUpdated)
        try container.encodeIfPresent(numTicks, forKey:.numTicks)
        try container.encodeIfPresent(currentTick, forKey:.currentTick)
        try container.encodeIfPresent(evalTick, forKey:.evalTick)
        try container.encodeIfPresent(pwIncrement, forKey:.pwIncrement)
        try container.encodeIfPresent(subjectID, forKey:.subjectID)
        try container.encodeIfPresent(screenTime, forKey:.screenTime)
        try container.encodeIfPresent(dailyTherapyTime, forKey:.dailyTherapyTime)
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
         patientSchedule = try container.decodeIfPresent(Int.self, forKey: .patientSchedule)
         patientTimeSet = try container.decodeIfPresent(Int.self, forKey: .patientTimeSet)
         skinParesthesia = try container.decodeIfPresent( Int.self, forKey: .skinParesthesia)
         soleParesthesia = try container.decodeIfPresent( Int.self, forKey: .soleParesthesia)
         painThreshold = try container.decodeIfPresent(  Int.self, forKey: .painThreshold)
         pulseWidthAtEmg  = try container.decodeIfPresent( Int.self, forKey: .pulseWidthAtEmg)
         comfortLevelEMG = try container.decodeIfPresent( Int.self, forKey: .comfortLevelEMG)
         detectionLevelEMG = try container.decodeIfPresent( Int.self, forKey: .detectionLevelEMG)
         foot = try container.decodeIfPresent( Int.self, forKey: .foot)
         amplitude = try container.decodeIfPresent( Int16.self, forKey: .amplitude)
         pulseWidthTarget = try container.decodeIfPresent( Int16.self, forKey: .pulseWidthTarget)
         evalEmgTarget = try container.decodeIfPresent( Int.self, forKey: .evalEmgTarget)
         patientInfoComplete = try container.decodeIfPresent( Int16.self, forKey: .patientInfoComplete)
         pulseWidthStrengthMax = try container.decodeIfPresent( Int16.self, forKey: .pulseWidthStrengthMax)
         strengthMax = try container.decodeIfPresent( Int.self, forKey: .strengthMax)
         pauseCount = try container.decodeIfPresent( Int16.self, forKey: .pauseCount)
         tempPainThreshold = try container.decodeIfPresent( Int16.self, forKey: .tempPainThreshold)
         painThresholdMax = try container.decodeIfPresent( Int16.self, forKey: .painThresholdMax)
         emgTargetIncrement = try container.decodeIfPresent( Int.self, forKey: .emgTargetIncrement)
         lastCompletedTime = try container.decodeIfPresent( [Int].self, forKey: .lastCompletedTime)
         nextAvailableTime = try container.decodeIfPresent( Int.self, forKey: .nextAvailableTime)
         emgTargetUpdated = try container.decodeIfPresent( Int.self, forKey: .emgTargetUpdated)
         numTicks = try container.decodeIfPresent( UInt8.self, forKey: .numTicks)
         currentTick = try container.decodeIfPresent( UInt8.self, forKey: .currentTick)
         evalTick = try container.decodeIfPresent( UInt8.self, forKey: .evalTick)
         pwIncrement = try container.decodeIfPresent( Int16.self, forKey: .pwIncrement)
         subjectID = try container.decodeIfPresent( [UInt8].self, forKey: .subjectID)
         screenTime = try container.decodeIfPresent( Int.self, forKey: .screenTime)
         dailyTherapyTime = try container.decodeIfPresent( Int16.self, forKey: .dailyTherapyTime)
        
        try super.init(from: decoder)
   }
    
    enum CodingKeys: CodingKey{
        case patientSchedule
        case patientTimeSet
        case skinParesthesia
        case soleParesthesia
        case painThreshold
        case pulseWidthAtEmg
        case comfortLevelEMG
        case detectionLevelEMG
        case foot
        case amplitude
        case pulseWidthTarget
        case evalEmgTarget
        case patientInfoComplete
        case pulseWidthStrengthMax
        case strengthMax
        case pauseCount
        case tempPainThreshold
        case painThresholdMax
        case emgTargetIncrement
        case lastCompletedTime
        case nextAvailableTime
        case emgTargetUpdated
        case numTicks
        case currentTick
        case evalTick
        case pwIncrement
        case subjectID
        case screenTime
        case dailyTherapyTime
    }
}
