/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class StimData: BaseModel {
    var sessionGuid: UUID? = nil
    //var deviceConfigurationGuid: UUID? = nil
    var state: Int8? = StimStatusStates.idle.rawValue//StimStatus.STATE_IDLE,
    var runningState: Int8? = StimStatusRunningStates.idle.rawValue
    var deviceTime: Int32? = 0
    var timeRemaining: Int16? = 0
    var pauseTimeRemaining: Int16? = 0
    var event: Int8? = 0//StimStatus.EVENT_NONE,
    var currentAmplitude: Int16? = 0
    var percentEMGDetect: Int8? = 0
    var percentNoiseDetect: Int8? = 0
    var emgDetected: Int8? = 0
    var emgTarget: Int32? = 0
    var pulseWidth: Int16? = 0
    var pulseWidthMax: Int16? = 0
    var pulseWidthMin: Int16? = 0
    var pulseWidthAvg: Int16? = 0
    var emgStrength: Int32? = 0
    var emgStrengthMax: Int32? = 0
    var emgStrengthMin: Int32? = 0
    var emgStrengthAvg: Int32? = 0
    var impedanceStim: Int32? = 0
    var impedanceStimMax: Int32? = 0
    var impedanceStimMin: Int32? = 0
    var impedanceStimAvg: Int32? = 0
    var screeningGuid: UUID? = nil
    var mainState: Int8? = StimStatusMainState.idle.rawValue
    var footConnectionADC: Int16? = 0
    var tempPainThreshold: Int32? = 0
    var errorCodes:Int32? = 0
    var temperature:Int8? = 0
    var rawADCAtStimPulse: Int16? = 0
    
    override init() {
        sessionGuid = nil
        state = StimStatusStates.idle.rawValue//StimStatus.STATE_IDLE,
        runningState = StimStatusRunningStates.idle.rawValue//StimStatus.RUNNING_STATE_IDLE,
        deviceTime = 0
        timeRemaining = 0
        pauseTimeRemaining = 0
        event = 0//StimStatus.EVENT_NONE,
        currentAmplitude = 0
        percentEMGDetect = 0
        percentNoiseDetect = 0
        emgDetected = 0
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
        screeningGuid = nil
        mainState = StimStatusMainState.idle.rawValue
        footConnectionADC = 0
        tempPainThreshold = 0
        errorCodes = 0
        temperature = 0
        rawADCAtStimPulse = 0
        super.init()
    }
    enum CodingKeys: CodingKey{
        case sessionGuid
        case state
        case runningState
        case deviceTime
        case timeRemaining
        case pauseTimeRemaining
        case event
        case currentAmplitude
        case percentEMGDetect
        case percentNoiseDetect
        case emgDetected
        case emgTarget
        case pulseWidth
        case pulseWidthMax
        case pulseWidthMin
        case pulseWidthAvg
        case emgStrength
        case emgStrengthMax
        case emgStrengthMin
        case emgStrengthAvg
        case impedanceStim
        case impedanceStimMax
        case impedanceStimMin
        case impedanceStimAvg
        case screeningGuid
        case mainState
        case footConnectionADC
        case tempPainThreshold
        case errorCodes
        case temperature
        case rawADCAtStimPulse
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(sessionGuid, forKey:.sessionGuid)
        try container.encodeIfPresent(state, forKey:.state)
        try container.encodeIfPresent(runningState, forKey:.runningState)
        try container.encodeIfPresent(deviceTime, forKey:.deviceTime)
        try container.encodeIfPresent(timeRemaining, forKey: .timeRemaining)
        try container.encodeIfPresent(pauseTimeRemaining, forKey: .pauseTimeRemaining)
        try container.encodeIfPresent(event, forKey: .event)
        try container.encodeIfPresent(currentAmplitude, forKey: .currentAmplitude)
        try container.encodeIfPresent(percentEMGDetect, forKey: .percentEMGDetect)
        try container.encodeIfPresent(percentNoiseDetect, forKey: .percentNoiseDetect)
        try container.encodeIfPresent(emgDetected, forKey: .emgDetected)
        try container.encodeIfPresent(emgTarget, forKey: .emgTarget)
        try container.encodeIfPresent(pulseWidth, forKey: .pulseWidth)
        try container.encodeIfPresent(pulseWidthMax, forKey: .pulseWidthMax)
        try container.encodeIfPresent(pulseWidthMin, forKey: .pulseWidthMin)
        try container.encodeIfPresent(pulseWidthAvg, forKey: .pulseWidthAvg)
        try container.encodeIfPresent(emgStrength, forKey: .emgStrength)
        try container.encodeIfPresent(emgStrengthMax, forKey: .emgStrengthMax)
        try container.encodeIfPresent(emgStrengthMin, forKey: .emgStrengthMin)
        try container.encodeIfPresent(emgStrengthAvg, forKey: .emgStrengthAvg)
        try container.encodeIfPresent(impedanceStim, forKey: .impedanceStim)
        try container.encodeIfPresent(impedanceStimMax, forKey: .impedanceStimMax)
        try container.encodeIfPresent(impedanceStimMin, forKey: .impedanceStimMin)
        try container.encodeIfPresent(impedanceStimAvg, forKey: .impedanceStimAvg)
        try container.encodeIfPresent(screeningGuid, forKey: .screeningGuid)
        try container.encodeIfPresent(mainState, forKey: .mainState)
        try container.encodeIfPresent(footConnectionADC, forKey: .footConnectionADC)
        try container.encodeIfPresent(tempPainThreshold, forKey: .tempPainThreshold)
        try container.encodeIfPresent(errorCodes, forKey: .errorCodes)
        try container.encodeIfPresent(temperature, forKey: .temperature)
        try container.encodeIfPresent(rawADCAtStimPulse, forKey: .rawADCAtStimPulse)

        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        sessionGuid = try container.decodeIfPresent( UUID.self , forKey: .sessionGuid )
        state = try container.decodeIfPresent(Int8.self , forKey: .state ) ?? 0
        runningState = try container.decodeIfPresent(Int8.self , forKey: .runningState ) ?? 0
        deviceTime = try container.decodeIfPresent(Int32.self  , forKey: .deviceTime ) ?? 0
        timeRemaining = try container.decodeIfPresent(Int16.self  , forKey: .timeRemaining ) ?? 0
        pauseTimeRemaining = try container.decodeIfPresent(Int16.self , forKey: .pauseTimeRemaining ) ?? 0
        event = try container.decodeIfPresent(Int8.self  , forKey: .event ) ?? 0
        currentAmplitude = try container.decodeIfPresent(Int16.self  , forKey: .currentAmplitude ) ?? 0
        percentEMGDetect = try container.decodeIfPresent(Int8.self  , forKey: .percentEMGDetect ) ?? 0
        percentNoiseDetect = try container.decodeIfPresent(Int8.self  , forKey: .percentNoiseDetect ) ?? 0
        emgDetected = try container.decodeIfPresent(Int8.self  , forKey: .emgDetected ) ?? 0
        emgTarget = try container.decodeIfPresent(Int32.self  , forKey: .emgTarget ) ?? 0
        pulseWidth = try container.decodeIfPresent( Int16.self , forKey: .pulseWidth ) ?? 0
        pulseWidthMax = try container.decodeIfPresent(Int16.self  , forKey: .pulseWidthMax ) ?? 0
        pulseWidthMin = try container.decodeIfPresent(Int16.self , forKey: .pulseWidthMin ) ?? 0
        pulseWidthAvg = try container.decodeIfPresent( Int16.self , forKey: .pulseWidthAvg ) ?? 0
        emgStrength = try container.decodeIfPresent( Int32.self , forKey: .emgStrength ) ?? 0
        emgStrengthMax = try container.decodeIfPresent(Int32.self  , forKey: .emgStrengthMax ) ?? 0
        emgStrengthMin = try container.decodeIfPresent(Int32.self  , forKey: .emgStrengthMin ) ?? 0
        emgStrengthAvg = try container.decodeIfPresent(Int32.self  , forKey: .emgStrengthAvg ) ?? 0
        impedanceStim = try container.decodeIfPresent(Int32.self  , forKey: .impedanceStim ) ?? 0
        impedanceStimMax = try container.decodeIfPresent(Int32.self  , forKey: .impedanceStimMax ) ?? 0
        impedanceStimMin = try container.decodeIfPresent(Int32.self  , forKey: .impedanceStimMin ) ?? 0
        impedanceStimAvg = try container.decodeIfPresent(Int32.self  , forKey: .impedanceStimAvg ) ?? 0
        screeningGuid = try container.decodeIfPresent( UUID.self , forKey: .screeningGuid )
        mainState = try container.decodeIfPresent( Int8.self , forKey: .mainState ) ?? 0
        footConnectionADC = try container.decodeIfPresent( Int16.self , forKey: .footConnectionADC ) ?? 0
        tempPainThreshold = try container.decodeIfPresent( Int32.self , forKey: .tempPainThreshold ) ?? 0
        errorCodes = try container.decodeIfPresent( Int32.self , forKey: .errorCodes ) ?? 0
        temperature = try container.decodeIfPresent( Int8.self , forKey: .temperature ) ?? 0
        rawADCAtStimPulse = try container.decodeIfPresent( Int16.self , forKey: .rawADCAtStimPulse ) ?? 0
        
        try super.init(from: decoder)
    }

}
