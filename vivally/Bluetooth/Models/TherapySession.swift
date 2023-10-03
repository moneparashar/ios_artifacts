/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class TherapySession: NSObject, ReflectedStringConvertible {
    var startTime:Int32
    var isNewSession:UInt8
    var isComplete:UInt8
    var pauseCount:UInt16
    var duration:UInt16
    var detectedEMGCount:UInt16
    var avgEMGStrength:Int32
    var avgStimPulseWidth:Int32
    var maxStimPulseWidth:Int32
    var overallAvgImpedance:Int32
    var batteryLevelAtStart:Int32
    var foot:UInt8
    
    override init(){
        startTime = 0
        isNewSession = 0
        isComplete = 0
        pauseCount = 0
        duration = 0
        detectedEMGCount = 0
        avgEMGStrength = 0
        avgStimPulseWidth = 0
        maxStimPulseWidth = 0
        overallAvgImpedance = 0
        batteryLevelAtStart = 0
        foot = 0
    }
    
    func parse(data:Data) -> Bool{
        if data.count != 33 {
            return false
        }
        
        startTime = Int32(data.subdata(in: 0..<4).to(type: Int32.self))
        isNewSession = UInt8(data.subdata(in: 4..<5).to(type: UInt8.self))
        isComplete = UInt8(data.subdata(in: 5..<6).to(type: UInt8.self))
        pauseCount = UInt16(data.subdata(in: 6..<8).to(type: UInt16.self))
        duration = UInt16(data.subdata(in: 8..<10).to(type: UInt16.self))
        detectedEMGCount = UInt16(data.subdata(in: 10..<12).to(type: UInt16.self))
        avgEMGStrength = Int32(data.subdata(in: 12..<16).to(type: Int32.self))
        avgStimPulseWidth = Int32(data.subdata(in: 16..<20).to(type: Int32.self))
        maxStimPulseWidth = Int32(data.subdata(in: 20..<24).to(type: Int32.self))
        overallAvgImpedance = Int32(data.subdata(in: 24..<28).to(type: Int32.self))
        batteryLevelAtStart = Int32(data.subdata(in: 28..<32).to(type: Int32.self))
        foot = UInt8(data.subdata(in: 32..<33).to(type: UInt8.self))
        
        //Slim.info("ble avgEMGStrength: \(avgEMGStrength)")
        return true
    }
    
    func getSessionStr() -> String{
        return "startTime: \(String(startTime)), isNewSession: \(String(isNewSession)), isComplete: \(String(isComplete)), pauseCount: \(pauseCount), duration: \(String(duration)), detectedEMGCount: \(String(detectedEMGCount)), avgEMGStrength: \(String(avgEMGStrength)), avgStimPulseWidth: \(String(avgStimPulseWidth)), maxStimPulseWidth: \(String(maxStimPulseWidth)), overallAvgImpedance: \(String(overallAvgImpedance)), batteryLevelAtStart: \(String(batteryLevelAtStart)), foot: \(String(foot))"
    }
}
