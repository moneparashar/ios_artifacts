/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class DeviceParameters: NSObject {
    var manualRampUp:UInt16
    var screenStartPW:UInt16
    var manualRampDown:UInt16
    var patientStimRange:UInt16
    var emgDetectTh:UInt16
    var emgDetectTw:UInt16
    var stimTargetRange:UInt16
    var minimumBattery:UInt16
    var minimumPercent:UInt16
    var initialRampingStepSize:UInt16
    var emgRecordTw:UInt16
    var sigStart:UInt16
    var sigEnd :UInt16
    var detectStart :UInt16
    var detectEnd :UInt16
    var emgPrescreenRMSFactor1 :UInt16
    var emgPrescreenPeakToPeak1 :UInt16
    var maWinRemoveLow :UInt16
    var maWinRemoveHigh :UInt16
    var emgPrescreenRMSFactor2 :UInt16
    var emgPrescreenPeakToPeak2 :UInt16
    var emgScreen2Conti :UInt16
    var emgPrescreenPeakToPeakAdjustAmp:UInt16
    var rPeakMa :UInt16
    var rPeakRMSFactor1 :UInt16
    var rPeakConti :UInt16
    var peakToPeakThreshold :UInt16
    var noiseRMSFactor1 :UInt16
    var noiseRMSFactor2 :UInt16
    var noiseRecordTw :UInt16
    var emgStrengthTw1 :UInt16
    var emgStrengthTw2 :UInt16
    var emgAvgNum :UInt16
    var lambda :UInt16
    var driftFactor :UInt16
    var strengthThFactor :UInt16
    var posChangeFactor :UInt16
    var negChangeFactor :UInt16
    var decPwStep :UInt16
    var incPwStep :UInt16
    var emgClosedLoopForgetTw :UInt16
    var emgClosedLoopForgetPercent :UInt16
    var feedbackDisplayTw:UInt16
    var feedbackDisplayTh :UInt16
    var noiseCheckTw :UInt16
    var noiseCheckTh:UInt16
    var rampDownRefractory :UInt16
    var rampDownAmount :UInt16
    var rampDownTime :UInt16
    var toeWiggleTw :UInt16
    var volunCheckTw :UInt16
    var volunSubTw :UInt16
    var volunCheckTh :UInt16
    var maxImpedanceAllow :UInt16
    var maxStimPause :UInt16
    
    override init(){
        manualRampUp = 0
        screenStartPW = 0
        manualRampDown = 0
        patientStimRange = 0
        emgDetectTh = 0
        emgDetectTw = 0
        stimTargetRange = 0
        minimumBattery = 0
        minimumPercent = 0
        initialRampingStepSize = 0
        emgRecordTw = 0
        sigStart = 0
        sigEnd  = 0
        detectStart  = 0
        detectEnd  = 0
        emgPrescreenRMSFactor1  = 0
        emgPrescreenPeakToPeak1  = 0
        maWinRemoveLow  = 0
        maWinRemoveHigh  = 0
        emgPrescreenRMSFactor2  = 0
        emgPrescreenPeakToPeak2  = 0
        emgScreen2Conti  = 0
        emgPrescreenPeakToPeakAdjustAmp = 0
        rPeakMa  = 0
        rPeakRMSFactor1  = 0
         rPeakConti  = 0
         peakToPeakThreshold  = 0
         noiseRMSFactor1  = 0
         noiseRMSFactor2  = 0
         noiseRecordTw  = 0
         emgStrengthTw1  = 0
         emgStrengthTw2  = 0
         emgAvgNum  = 0
         lambda  = 0
         driftFactor = 0
         strengthThFactor  = 0
         posChangeFactor  = 0
         negChangeFactor  = 0
         decPwStep  = 0
         incPwStep  = 0
         emgClosedLoopForgetTw = 0
         emgClosedLoopForgetPercent  = 0
         feedbackDisplayTw = 0
         feedbackDisplayTh  = 0
         noiseCheckTw  = 0
         noiseCheckTh = 0
         rampDownRefractory  = 0
         rampDownAmount  = 0
         rampDownTime  = 0
         toeWiggleTw  = 0
         volunCheckTw  = 0
         volunSubTw  = 0
         volunCheckTh  = 0
         maxImpedanceAllow  = 0
         maxStimPause  = 0
    }
    
    func parse(data:Data) -> Bool{
        
        /*timestamp = UInt32(data.subdata(in: 0..<4).to(type: UInt32.self))
        index = UInt8(UInt8(data.subdata(in: 4..<5).to(type: UInt8.self)))
        theData = []*/
        
        
        return true
    }
}
