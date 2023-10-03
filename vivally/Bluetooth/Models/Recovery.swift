/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class Recovery: NSObject {
    var patientSchedule:UInt32
    var patientTimeSet:UInt32
    var skinParesthesia:UInt32
    var soleParesthesia:UInt32
    var painThreshold:UInt32
    var pulseWidthAtEmg:UInt32
    var comfortLevelEMG:UInt32
    var detectionLevelEMG:UInt32
    var foot:UInt32
    var amplitude:UInt16
    var pulseWidthTarget:UInt16
    var evalEmgTarget:UInt32
    var patientInfoComplete:UInt16
    var pulseWidthStrengthMax:UInt16
    var strengthMax:UInt32
    var pauseCount:UInt16
    var tempPainThreshold:UInt16
    var painThresholdMax:UInt16
    var emgTargetIncrement:UInt32
    var lastCompletedTime1:UInt32
    var lastCompletedTime2:UInt32
    var lastCompletedTime3:UInt32
    var nextAvailableTime:UInt32
    var emgTargetUpdated:UInt32
    var numTicks:UInt8
    var currentTick:UInt8
    var evalTick:UInt8
    var pwIncrement:UInt16
    var subjectID:String
    var screenTime:UInt32
    var dailyTherapyTime:UInt16
    
    override init(){
         patientSchedule = 0
         patientTimeSet = 0
         skinParesthesia = 0
         soleParesthesia = 0
         painThreshold = 0
         pulseWidthAtEmg = 0
         comfortLevelEMG = 0
         detectionLevelEMG = 0
         foot = 0
         amplitude = 0
         pulseWidthTarget = 0
         evalEmgTarget = 0
         patientInfoComplete = 0
         pulseWidthStrengthMax = 0
         strengthMax = 0
         pauseCount = 0
         tempPainThreshold = 0
         painThresholdMax = 0
         emgTargetIncrement = 0
         lastCompletedTime1 = 0
         lastCompletedTime2 = 0
         lastCompletedTime3 = 0
         nextAvailableTime = 0
         emgTargetUpdated = 0
         numTicks = 0
         currentTick = 0
         evalTick = 0
         pwIncrement = 0
         subjectID = ""
         screenTime = 0
         dailyTherapyTime = 0
    }
    
    func toDataModel()->Data{
        var data = Data()
        
        data.append(Data(from: patientSchedule))
        data.append(Data(from: patientTimeSet))
        
        return data
    }
    
    func parse(data:Data) -> Bool{
        if data.count != 113{
            return false
        }
        
        patientSchedule = UInt32(data.subdata(in: 0..<4).to(type: UInt32.self))
        patientTimeSet = UInt32(data.subdata(in: 4..<8).to(type: UInt32.self))
        skinParesthesia = UInt32(data.subdata(in: 8..<12).to(type: UInt32.self))
        soleParesthesia = UInt32(data.subdata(in: 12..<16).to(type: UInt32.self))
        painThreshold = UInt32(data.subdata(in: 16..<20).to(type: UInt32.self))
        pulseWidthAtEmg = UInt32(data.subdata(in: 20..<24).to(type: UInt32.self))
        comfortLevelEMG = UInt32(data.subdata(in: 24..<28).to(type: UInt32.self))
        detectionLevelEMG = UInt32(data.subdata(in: 28..<32).to(type: UInt32.self))
        foot = UInt32(data.subdata(in: 32..<36).to(type: UInt32.self))
        amplitude = UInt16(data.subdata(in: 36..<38).to(type: UInt16.self))
        pulseWidthTarget = UInt16(data.subdata(in: 38..<40).to(type: UInt16.self))
        evalEmgTarget = UInt32(data.subdata(in: 40..<44).to(type: UInt32.self))
        patientInfoComplete = UInt16(data.subdata(in: 44..<46).to(type: UInt16.self))
        pulseWidthStrengthMax = UInt16(data.subdata(in: 46..<48).to(type: UInt16.self))
        strengthMax = UInt32(data.subdata(in: 48..<52).to(type: UInt16.self))
        pauseCount = UInt16(data.subdata(in: 52..<54).to(type: UInt16.self))
        tempPainThreshold = UInt16(data.subdata(in: 54..<56).to(type: UInt16.self))
        painThresholdMax = UInt16(data.subdata(in: 56..<58).to(type: UInt16.self))
        emgTargetIncrement = UInt32(data.subdata(in: 58..<62).to(type: UInt32.self))
        lastCompletedTime1 = UInt32(data.subdata(in: 62..<66).to(type: UInt32.self))
        lastCompletedTime2 = UInt32(data.subdata(in: 66..<70).to(type: UInt32.self))
        lastCompletedTime3 = UInt32(data.subdata(in: 70..<74).to(type: UInt32.self))
        nextAvailableTime = UInt32(data.subdata(in: 74..<78).to(type: UInt32.self))
        emgTargetUpdated = UInt32(data.subdata(in: 78..<82).to(type: UInt32.self))
        numTicks = UInt8(data.subdata(in: 82..<83).to(type: UInt8.self))
        currentTick = UInt8(data.subdata(in: 83..<84).to(type: UInt8.self))
        evalTick = UInt8(data.subdata(in: 84..<85).to(type: UInt8.self))
        pwIncrement = UInt16(data.subdata(in: 85..<87).to(type: UInt16.self))
        subjectID = String(bytes: data.subdata(in: 87..<107), encoding: String.Encoding.utf8) ?? ""
        screenTime = UInt32(data.subdata(in: 107..<111).to(type: UInt32.self))
        dailyTherapyTime = UInt16(data.subdata(in: 111..<113).to(type: UInt16.self))
        
        return true
    }
}
