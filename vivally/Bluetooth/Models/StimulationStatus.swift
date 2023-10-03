/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class StimulationStatus: NSObject, ReflectedStringConvertible {
    var state:StimStatusStates
    var runningState:StimStatusRunningStates
    var deviceTime:Int32
    var timeRemaining:Int16
    var pauseTimeRemaining:Int16
    var event:Int8
    var amplitude:Int16
    var percentageEMGDetection:Int8
    var percentagePulsesEMGNoisy:Int8
    var emgDetected:Bool
    var emgTarget:Int32
    var pulseWidth:Int16
    var pulseWidthMax:Int16
    var pulseWidthMin:Int16
    var pulseWidthAvg:Int16
    var emgStrength:Int32
    var emgStrengthMax:Int32
    var emgStrengthMin:Int32
    var emgStrengthAvg:Int32
    var impedanceStim:Int32
    var impedanceStimMax:Int32
    var impedanceStimMin:Int32
    var impedanceStimAvg:Int32
    var mainState:StimStatusMainState
    var footConnectionADC: Int16
    var tempPainThreshold: Int32
    var errorCodes: Int32
    var temperature: Int8
    var rawADCAtStimPulse: Int16
    var currentTick: Int8
    var dailyTherapyTime: Int16
    var lastCompletedTime:Int32
 
    override init(){
        state = .idle
        runningState = .idle
        deviceTime = 0
        timeRemaining = 0
        pauseTimeRemaining = 0
        event = 0
        amplitude = 0
        percentageEMGDetection = 0
        percentagePulsesEMGNoisy = 0
        emgDetected = false
        emgTarget = 0
        pulseWidth = 0
        pulseWidthMax = 0
        pulseWidthMin = 0
        pulseWidthAvg = 0
        emgStrength = 0
        emgStrengthMax = 0
        emgStrengthMin = 0
        emgStrengthAvg = 0
        impedanceStim = 0
        impedanceStimMax = 0
        impedanceStimMin = 0
        impedanceStimAvg = 0
        mainState = .idle
        footConnectionADC = 0
        tempPainThreshold = 0
        errorCodes = 0
        temperature = 0
        rawADCAtStimPulse = 0
        currentTick = 0
        dailyTherapyTime = 0
        lastCompletedTime = 0
        
    }
    
    func parse(data:Data) -> Bool{
        //print(data.hexEncodedString())
        
        
        state = StimStatusStates(rawValue: Int8(data.subdata(in: 0..<1).to(type: Int8.self))) ?? .idle
        runningState = StimStatusRunningStates(rawValue: Int8(data.subdata(in: 1..<2).to(type: Int8.self))) ?? .idle
        deviceTime = Int32(data.subdata(in: 2..<6).to(type: Int32.self))
        timeRemaining = Int16(data.subdata(in: 6..<8).to(type: Int16.self))
        pauseTimeRemaining = Int16(data.subdata(in: 8..<10).to(type: Int16.self))
        event = Int8(data.subdata(in: 10..<11).to(type: Int8.self))
        amplitude = Int16(data.subdata(in: 11..<13).to(type: Int16.self))
        percentageEMGDetection = Int8(data.subdata(in: 13..<14).to(type: Int8.self))
        percentagePulsesEMGNoisy = Int8(data.subdata(in: 14..<15).to(type: Int8.self))
        emgDetected = Bool(data.subdata(in: 15..<16).to(type: Bool.self))
        emgTarget = Int32(data.subdata(in: 16..<20).to(type: Int32.self))
        pulseWidth = Int16(data.subdata(in: 20..<22).to(type: Int16.self))
        pulseWidthMax = Int16(data.subdata(in: 22..<24).to(type: Int16.self))
        pulseWidthMin = Int16(data.subdata(in: 24..<26).to(type: Int16.self))
        pulseWidthAvg = Int16(data.subdata(in: 26..<28).to(type: Int16.self))
        emgStrength = Int32(data.subdata(in: 28..<32).to(type: Int32.self))
        emgStrengthMax = Int32(data.subdata(in: 32..<36).to(type: Int32.self))
        emgStrengthMin = Int32(data.subdata(in: 36..<40).to(type: Int32.self))
        emgStrengthAvg = Int32(data.subdata(in: 40..<44).to(type: Int32.self))
        impedanceStim = Int32(data.subdata(in: 44..<48).to(type: Int32.self))
        impedanceStimMax = Int32(data.subdata(in: 48..<52).to(type: Int32.self))
        impedanceStimMin = Int32(data.subdata(in: 52..<56).to(type: Int32.self))
        impedanceStimAvg = Int32(data.subdata(in: 56..<60).to(type: Int32.self))
        mainState = StimStatusMainState(rawValue: Int8(data.subdata(in: 60..<61).to(type: Int8.self))) ?? .idle
        footConnectionADC = Int16(data.subdata(in: 61..<63).to(type: Int16.self))
        tempPainThreshold = Int32(data.subdata(in: 63..<67).to(type: Int32.self))
        errorCodes = Int32(data.subdata(in: 67..<71).to(type: Int32.self))
        temperature = Int8(data.subdata(in: 71..<72).to(type: Int8.self))
        rawADCAtStimPulse = Int16(data.subdata(in: 72..<74).to(type: Int16.self))
        currentTick = Int8(data.subdata(in: 74..<75).to(type: Int8.self))
        dailyTherapyTime = Int16(data.subdata(in: 75..<77).to(type: Int16.self))
        lastCompletedTime = Int32(data.subdata(in: 77..<81).to(type: Int32.self))
        
        //Slim.info("ble EMG Strength: \(emgStrength), ble EMG Target \(emgTarget)")      //emg strength used in getting emg strength target on portal
        return true
    }
    
    func getLogStr()-> String{
        var logStr = "state: \(state.getStr()),runningState: \(runningState.rawValue),deviceTime: \(deviceTime),timeRemaining: \(timeRemaining),pauseTimeRemaining: \(pauseTimeRemaining),event: \(event),amplitude: \(amplitude),percentageEMGDetection: \(percentageEMGDetection),percentagePulsesEMGNoisy: \(percentagePulsesEMGNoisy),emgDetected: \(emgDetected),emgTarget: \(emgTarget),pulseWidth: \(pulseWidth),pulseWidthMax: \(pulseWidthMax),pulseWidthMin: \(pulseWidthMin),pulseWidthAvg: \(pulseWidthAvg),emgStrength: \(emgStrength),emgStrengthMax: \(emgStrengthMax),emgStrengthMin: \(emgStrengthMin),emgStrengthAvg: \(emgStrengthAvg),impedanceStim: \(impedanceStim),impedanceStimMax: \(impedanceStimMax),impedanceStimMin: \(impedanceStimMin),impedanceStimAvg: \(impedanceStimAvg),mainState: \(mainState.rawValue),footConnectionADC: \(footConnectionADC),tempPainThreshold: \(tempPainThreshold),errorCodes: \(errorCodes),temperature: \(temperature),rawADCAtStimPulse: \(rawADCAtStimPulse),currentTick: \(currentTick),dailyTherapyTime: \(dailyTherapyTime), lastCompletedTime: \(lastCompletedTime)"
        return logStr
    }
}
