/*
 * Copyright 2022, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

protocol DeviceErrorManagerDelegate{
    func dataRecoveryAvailable()
    func dailyLimitReachedError()
    func batteryLowError()
    
    func impedanceError(imp: TherapyImpError)
}
protocol DeviceErrorManagerNavDelegate{
    func dataRecoveryAvailable()
}

class DeviceErrorManager: NSObject {
    static let sharedInstance = DeviceErrorManager()
    
    var delegate:DeviceErrorManagerDelegate?
    var navDelegate: DeviceErrorManagerNavDelegate?
    
    var impedanceCheckRunning = false
    var checkDailyWeeklyLimits = false
    var didNotPairInTime = false
    
    var impedanceCheckImpedance:Bool? = nil
    var impedanceCheckContinuity:Bool? = nil
    var impedanceCheckFoot:Bool? = nil
    var impedanceCheck:UInt8? = nil
    //skipping voluntaryEMG for now
    var recoveryDataAvailable:Bool? = nil
    var insufficientBattery:Bool? = nil
    var doesNotMeetCriteria:Bool? = nil
    var meetsCriteria:Bool? = nil
    var pauselimitReached:Bool? = nil
    var dailyLimitReached:Bool? = nil
    var weeklyLimitReached:Bool? = nil
    var pauseTimeout:Bool? = nil
    var savePatientInfoSuccess:Bool? = nil
    var savePatientInfoFailure:Bool? = nil
    var loadPatientInfoSucces:Bool? = nil
    var loadPatientInfoFailure:Bool? = nil
    var wrongFoot:Bool? = nil
    var continuityBad:Bool? = nil
    var impedanceBad:Bool? = nil
    
 
    func resetAll(){
        impedanceCheckRunning = false
        checkDailyWeeklyLimits = false
        
        impedanceCheckImpedance = nil
        impedanceCheckContinuity = nil
        impedanceCheckFoot = nil
        impedanceCheck = nil
        recoveryDataAvailable = nil
        insufficientBattery = nil
        doesNotMeetCriteria = nil
        meetsCriteria = nil
        pauselimitReached = nil
        dailyLimitReached = nil
        weeklyLimitReached = nil
        pauseTimeout = nil
        savePatientInfoSuccess = nil
        savePatientInfoFailure = nil
        loadPatientInfoSucces = nil
        loadPatientInfoFailure = nil
        wrongFoot = nil
        continuityBad = nil
        impedanceBad = nil
        
        failedImpOverall = false
    }
    
    func finshImpChecks(){
        let current = impedanceCheck ?? 0
        impedanceCheck = (current & ImpedanceCheckValues.continuity.rawValue)
    }
    
    func setDataRecoveryAvailability(){
        if let avail = recoveryDataAvailable{
            if avail{
                if KeychainManager.sharedInstance.loadAccountData()?.roles.contains("Clinician") == true{
                    BluetoothManager.sharedInstance.sendCommand(command: .clearDataRecovery, parameters: [])
                    DataRecoveryManager.sharedInstance.removeRecovery()
                    return
                }
                
                DataRecoveryManager.sharedInstance.recoveryAvailable = DataRecoveryManager.sharedInstance.timeStampAvailable() != nil ? avail : false
                delegate?.dataRecoveryAvailable()
                navDelegate?.dataRecoveryAvailable()
            }
        }
    }
    
    func checkForDailyCheck(){
        if dailyLimitReached == true{
            delegate?.dailyLimitReachedError()
        }
    }
    
    func checkForBatteryCheck(){
        if insufficientBattery == true{
            delegate?.batteryLowError()
        }
    }
    
    var failedImpOverall = false
    func checkForImp(){
        if wrongFoot == false && continuityBad == false && impedanceBad == false && failedImpOverall{
            failedImpOverall = false
            return
        }
        else if continuityBad == true && !failedImpOverall{
            failedImpOverall = true
            delegate?.impedanceError(imp: .continuity)
            return
        }
        else if wrongFoot == true && !failedImpOverall{
            failedImpOverall = true
            delegate?.impedanceError(imp: .foot)
            return
        }
        else if impedanceBad == true && !failedImpOverall{
            failedImpOverall = true
            delegate?.impedanceError(imp: .impedance)
            return
        }
    }
    
    
    func isthereError(){
        var errorstr = ""
        
        errorstr = (impedanceCheckImpedance ?? false) ?  "impedanceCheckImpedance " : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = impedanceCheckContinuity ?? false ? "impedanceCheckContinuity " : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = impedanceCheckFoot ?? false ? "impedanceCheckFoot " : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = (impedanceCheck != 0 && impedanceCheck != nil) ? "impedanceCheck " : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = insufficientBattery ?? false ? "insufficientBattery fail" : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = recoveryDataAvailable ?? false ? "recovery data available" : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = doesNotMeetCriteria ?? false ? "doesNotMeetCriteria" : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = meetsCriteria ?? false ? "meetsCriteria" : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = pauselimitReached ?? false ? "pauselimitReached" : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = dailyLimitReached ?? false ? "dailyLimitReached" : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = weeklyLimitReached ?? false ? "weeklyLimitReached" : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = pauseTimeout ?? false ? "pauseTimeout " : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = savePatientInfoSuccess ?? false ? "savePatientInfoSuccess" : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = savePatientInfoFailure ?? false ? "savePatientInfoFailure" : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = loadPatientInfoSucces ?? false ? "loadPatientInfoSucces " : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = loadPatientInfoFailure ?? false ? "loadPatientInfoFailure " : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = wrongFoot ?? false ? "wrongFoot fail" : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = continuityBad ?? false ? "continuityBad fail" : ""
        errorstr != "" ? print(errorstr) : ()
        errorstr = impedanceBad ?? false ? "impedanceBad fail" : ""
        errorstr != "" ? print(errorstr) : ()
    }
}
