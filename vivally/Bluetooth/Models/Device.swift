/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class Device: NSObject, ReflectedStringConvertible {
    static let sharedInstance = Device()
    
    var voluntaryEMG:UInt8
    var impedance:UInt8
    var error:UInt32
    var numberOfTicks:UInt8
    var originalStrengthTick:UInt8
    var currentStrengthTick:UInt8
    var recoveryDataAvailable: UInt8
    var errorUserDefaults: UInt32 = 0
    
    override init(){
        voluntaryEMG = 0
        impedance = 0
        error = 0
        numberOfTicks = 0
        originalStrengthTick = 0
        currentStrengthTick = 0
        recoveryDataAvailable = 0
    }
    
    func parse(data:Data) -> Bool{
        if data.count < 9 || data.count > 10 {        //would normally just check count for 10, but older devs should have 9
            return false
        }
        
        voluntaryEMG = data[0]
        impedance = data[1]
        error = UInt32(data.subdata(in: 2..<6).to(type: UInt32.self))
        saveErrorValue(value: error)
        numberOfTicks = data[6]
        originalStrengthTick = data[7]
        currentStrengthTick = data[8]
        
        if data.count > 9{
            recoveryDataAvailable = data[9]
        }
        
        if error != 0{
            print(data.hexEncodedString())
        }
        return true
    }
    
    func getErrorValue(bit: DeviceError) -> Bool {
        let deviceError = (error & bit.rawValue)
        if deviceError == bit.rawValue {
            return true
        }
        return false
    }
    
    func saveErrorValue(value: UInt32){
        errorUserDefaults = value
        UserDefaults.standard.set(errorUserDefaults, forKey: "errorUserDefaults")
    }
    
    func loadErrorValue(){
        let userDefaults = UserDefaults.standard
        errorUserDefaults =  UInt32(userDefaults.integer(forKey: "errorUserDefaults"))
    }
    
    func clearErrorValue(){
        error = UInt32(0)
        UserDefaults.standard.removeObject(forKey: "errorUserDefaults")
    }
    


    //check later
    func impedanceCheck(bit: ImpedanceCheckValues) -> Bool {
        
        return (impedance & bit.rawValue) == bit.rawValue
    }
    
    func voluntaryEMGCheckValue(bit: UInt8) -> Bool{
        let emg = (voluntaryEMG & bit)
        if emg == bit{
            return true
        }
        return false
    }
    
    func recoveryDataAvailable(bit: UInt8) -> Bool{
        let recovery = (recoveryDataAvailable & bit)
        if recovery == bit{
            return true
        }
        return false
    }
    
    func isErrorInsufficientBattery(prevDevice: Device?) -> Bool {
        let currentValue = getErrorValue(bit: .insufficientBattery)
        
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.getErrorValue(bit: .insufficientBattery) {
            return false
        }
        return currentValue
    }
    
    func doesPatientNotMeetCriteria(prevDevice: Device?) -> Bool {
        let currentValue = getErrorValue(bit: .patientDoesNotMeetCriteria)
        
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.getErrorValue(bit: .patientDoesNotMeetCriteria) {
            return false
        }
        return currentValue
    }
    
    func doesPatientMeetCriteria(prevDevice: Device?) -> Bool {
        let currentValue = getErrorValue(bit: .patientMeetsCriteria)
        
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.getErrorValue(bit: .patientMeetsCriteria) {
            return false
        }
        return currentValue
    }
    
    func isPauseLimitReached(prevDevice: Device?) -> Bool {
        let currentValue = getErrorValue(bit: .pauseLimitReached)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.getErrorValue(bit: .pauseLimitReached) {
            return false
        }
        return currentValue
    }
    
    func isDailyLimitReached(prevDevice: Device?) -> Bool {
        let currentValue = getErrorValue(bit: .dailyLimitReached)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.getErrorValue(bit: .dailyLimitReached) {
            return false
        }
        return currentValue
    }
    
    func isWeeklyLimitReached(prevDevice: Device?) -> Bool {
        let currentValue = getErrorValue(bit: .weeklyLimitReached)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.getErrorValue(bit: .weeklyLimitReached) {
            return false
        }
        return currentValue
    }
    
    
    func isImpedanceBad() -> Bool{
        return getErrorValue(bit: .impedanceBad)
    }
    
    func isContinuityBad() -> Bool{
        return getErrorValue(bit: .continuityBad)
    }

    func isWrongFoot() -> Bool{
        return getErrorValue(bit: .wrongFoot)
    }
    
    func isPauseTimeout(prevDevice: Device?) -> Bool {
        let currentValue = getErrorValue(bit: .pauseTimeout)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.getErrorValue(bit: .pauseTimeout) {
            return false
        }
        return currentValue
    }
    
    func didSavePatientInfoSuceed(prevDevice: Device?) -> Bool {
        let currentValue = getErrorValue(bit: .savePatientInfoSuccessful)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.getErrorValue(bit: .savePatientInfoSuccessful) {
            return false
        }
        return currentValue
    }
    
    func didSavePatientInfoFail(prevDevice: Device?) -> Bool {
        let currentValue = getErrorValue(bit: .savePatientInfoFailed)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.getErrorValue(bit: .savePatientInfoFailed) {
            return false
        }
        return currentValue
    }
    
    func didLoadPatientInfoSucced(prevDevice: Device?) -> Bool {
        let currentValue = getErrorValue(bit: .loadPatientInfoSuccessful)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.getErrorValue(bit: .loadPatientInfoSuccessful) {
            return false
        }
        return currentValue
    }
    
    func didLoadPatientInfoFail(prevDevice: Device?) -> Bool {
        let currentValue = getErrorValue(bit: .loadPatientInfoFailed)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.getErrorValue(bit: .loadPatientInfoFailed) {
            return false
        }
        return currentValue
    }
    
    //checks for impedance, continuity, foot check already done
    //old
    /*
    func isImpedancePassed(prevDevice: Device?) -> Bool{
        let currentValue = impedanceCheck(bit: .impedance)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == impedanceCheck(bit: .impedance) {
            return false
        }
        return currentValue
    }
    */
    func isImpedancePassed(prevDevice: Device?) -> Bool{
        let currentValue = impedanceCheck(bit: .impedance)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice!.impedanceCheck(bit: .impedance) {
            return false
        }
        return currentValue
    }
    
    func isContinuityPassed(prevDevice: Device?) -> Bool{
        let currentValue = impedanceCheck(bit: .continuity)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice!.impedanceCheck(bit: .continuity) {
            return false
        }
        return currentValue
    }
    
    func isFootCheckPassed(prevDevice: Device?) -> Bool{
        let currentValue = impedanceCheck(bit: .foot)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice!.impedanceCheck(bit: .foot) {
            return false
        }
        return currentValue
    }
    
    func isVoluntaryEMGPassed(prevDevice: Device?) -> Bool{
        let volEMGCheck = UInt8(0b00000001)
        let currentValue = voluntaryEMGCheckValue(bit: volEMGCheck)
        if prevDevice == nil {
            return currentValue
        }
        if currentValue == prevDevice?.voluntaryEMGCheckValue(bit: volEMGCheck){
            return false
        }
        return currentValue
    }
    
    func isRecoveryDataAvailable(prevDevice: Device?) -> Bool{
        let maskDataRecoveryCheck = UInt8(0b00000001)
        let currentValue = recoveryDataAvailable(bit: maskDataRecoveryCheck)
        if prevDevice == nil{
            return currentValue
        }
        if currentValue == prevDevice?.recoveryDataAvailable(bit: maskDataRecoveryCheck){
            return false
        }
        return currentValue
    }
}
