/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import CoreBluetooth

protocol PatientServiceDelegate{
    func PatientServiceDataUpdated(data:PatientServiceData)
}

class PatientService: NSObject {
    var delegate: PatientServiceDelegate?
    private var isEnabled = false
    var btPeripheral:CBPeripheral? = nil
    var patientServiceData:PatientServiceData = PatientServiceData()
    
    var therapyScheduleCharacteristic:CBCharacteristic? = nil
    var therapyScheduleCharacteristicUUID:CBUUID? = nil
    
    var therapyLengthCharacteristic:CBCharacteristic? = nil
    var therapyLengthCharacteristicUUID: CBUUID? = nil
    
    var pulseWidthAtSkinParastheisaCharacteristic:CBCharacteristic? = nil
    var pulseWidthAtSkinParastheisaCharacteristicUUID: CBUUID? = nil
    
    var pulseWidthAtComfortCharacteristic:CBCharacteristic? = nil
    var pulseWidthAtComfortCharacteristicUUID:CBUUID? = nil
    
    var pulseWidthAtEMGCharacteristic:CBCharacteristic? = nil
    var pulseWidthAtEMGCharacteristicUUID:CBUUID? = nil
    
    var emgStrengthMaxCharacteristic:CBCharacteristic? = nil
    var emgStrengthMaxCharacteristicUUID:CBUUID? = nil
    
    var footCharacteristic:CBCharacteristic? = nil
    var footCharacteristicUUID:CBUUID? = nil
    
    var targetEMGCharacteristic:CBCharacteristic? = nil
    var targetEMGCharacteristicUUID:CBUUID? = nil
    
    var recoverCharacteristic:CBCharacteristic? = nil
    var recoverCharacteristicUUID:CBUUID? = nil
    
    var readyToSendCharacteristic:CBCharacteristic? = nil
    var readyToSendCharacteristicUUID:CBUUID? = nil
    
    var temporaryPainThresholdCharacteristic:CBCharacteristic? = nil
    var temporaryPainThresholdCharacteristicUUID:CBUUID? = nil
    
    var currentTickCharacteristic:CBCharacteristic? = nil
    var currentTickCharacteristicUUID:CBUUID? = nil
    
    var dailyTherapyTimeCharacteristic:CBCharacteristic? = nil
    var dailyTherapyTimeCharacteristicUUID:CBUUID? = nil
    
    var lastCompletedTimeCharacterisitc:CBCharacteristic? = nil
    var lastCompletedTimeCharacterisiticUUID:CBUUID? = nil
    
    
    override init(){
        therapyScheduleCharacteristicUUID = CBUUID(string: BluetoothConstants.therapyScheduleCharacteristicString)
        therapyLengthCharacteristicUUID = CBUUID(string: BluetoothConstants.therapyLengthCharacteristicString)
        pulseWidthAtSkinParastheisaCharacteristicUUID = CBUUID(string: BluetoothConstants.pulseWidthAtSkinParastheisaCharacteristicString)
        pulseWidthAtComfortCharacteristicUUID = CBUUID(string: BluetoothConstants.pulseWidthAtComfortCharacteristicString)
        pulseWidthAtEMGCharacteristicUUID = CBUUID(string: BluetoothConstants.pulseWidthAtEMGCharacteristicString)
        emgStrengthMaxCharacteristicUUID = CBUUID(string: BluetoothConstants.emgStrengthMaxCharacteristicString)
        footCharacteristicUUID = CBUUID(string: BluetoothConstants.footCharacteristicString)
        targetEMGCharacteristicUUID = CBUUID(string: BluetoothConstants.targetEMGCharacteristicString)
        recoverCharacteristicUUID = CBUUID(string: BluetoothConstants.recoverCharacteristicString)
        readyToSendCharacteristicUUID = CBUUID(string: BluetoothConstants.readyToSendCharacteristicString)
        temporaryPainThresholdCharacteristicUUID = CBUUID(string: BluetoothConstants.temporaryPainThresholdCharacteristicString)
        currentTickCharacteristicUUID = CBUUID(string: BluetoothConstants.currentTickCharacteristicString)
        dailyTherapyTimeCharacteristicUUID = CBUUID(string: BluetoothConstants.dailyTherapyTimeCharacteristicString)
        lastCompletedTimeCharacterisiticUUID = CBUUID(string: BluetoothConstants.lastCompletedTimeCharacteristicString)
        super.init()
    }
    
    init(withPeripheral peripheral:CBPeripheral, _ delegate:PatientServiceDelegate){
        self.btPeripheral = peripheral
        self.delegate = delegate
        
        therapyScheduleCharacteristicUUID = CBUUID(string: BluetoothConstants.therapyScheduleCharacteristicString)
        therapyLengthCharacteristicUUID = CBUUID(string: BluetoothConstants.therapyLengthCharacteristicString)
        pulseWidthAtSkinParastheisaCharacteristicUUID = CBUUID(string: BluetoothConstants.pulseWidthAtSkinParastheisaCharacteristicString)
        pulseWidthAtComfortCharacteristicUUID = CBUUID(string: BluetoothConstants.pulseWidthAtComfortCharacteristicString)
        pulseWidthAtEMGCharacteristicUUID = CBUUID(string: BluetoothConstants.pulseWidthAtEMGCharacteristicString)
        emgStrengthMaxCharacteristicUUID = CBUUID(string: BluetoothConstants.emgStrengthMaxCharacteristicString)
        footCharacteristicUUID = CBUUID(string: BluetoothConstants.footCharacteristicString)
        targetEMGCharacteristicUUID = CBUUID(string: BluetoothConstants.targetEMGCharacteristicString)
        recoverCharacteristicUUID = CBUUID(string: BluetoothConstants.recoverCharacteristicString)
        readyToSendCharacteristicUUID = CBUUID(string: BluetoothConstants.readyToSendCharacteristicString)
        temporaryPainThresholdCharacteristicUUID = CBUUID(string: BluetoothConstants.temporaryPainThresholdCharacteristicString)
        currentTickCharacteristicUUID = CBUUID(string: BluetoothConstants.currentTickCharacteristicString)
        dailyTherapyTimeCharacteristicUUID = CBUUID(string: BluetoothConstants.dailyTherapyTimeCharacteristicString)
        lastCompletedTimeCharacterisiticUUID = CBUUID(string: BluetoothConstants.lastCompletedTimeCharacteristicString)
        
        super.init()
    }
    
    func isConfigured() -> Bool{
        if  therapyScheduleCharacteristic != nil && therapyLengthCharacteristic != nil && pulseWidthAtSkinParastheisaCharacteristic != nil && pulseWidthAtComfortCharacteristic != nil && pulseWidthAtEMGCharacteristic != nil &&  emgStrengthMaxCharacteristic != nil && footCharacteristic != nil && targetEMGCharacteristic != nil && recoverCharacteristic != nil && readyToSendCharacteristic != nil && temporaryPainThresholdCharacteristic != nil && currentTickCharacteristic != nil && dailyTherapyTimeCharacteristic  != nil && lastCompletedTimeCharacterisiticUUID != nil{
            return true
        }
        return false
    }
    
    func setEnabled(enabled:Bool){
        if enabled == true && isEnabled == false{
            isEnabled = true
            
            // This is where we want to do an initial read
            
            
        }
        else if enabled == false && isEnabled == true{
            isEnabled = false
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, characteristic:CBCharacteristic, error: Error?) {
        if service.uuid == CBUUID(string:BluetoothConstants.patientServiceString){
            if characteristic.uuid == therapyScheduleCharacteristicUUID{
                therapyScheduleCharacteristic = characteristic
                peripheral.readValue(for: therapyScheduleCharacteristic!)
            }
            else if characteristic.uuid == therapyLengthCharacteristicUUID{
                therapyLengthCharacteristic = characteristic
                peripheral.readValue(for: therapyLengthCharacteristic!)
            }
            else if characteristic.uuid == pulseWidthAtSkinParastheisaCharacteristicUUID{
                pulseWidthAtSkinParastheisaCharacteristic = characteristic
                peripheral.readValue(for: pulseWidthAtSkinParastheisaCharacteristic!)
            }
            else if characteristic.uuid == pulseWidthAtComfortCharacteristicUUID{
                pulseWidthAtComfortCharacteristic = characteristic
                peripheral.readValue(for: pulseWidthAtComfortCharacteristic!)
            }
            else if characteristic.uuid == pulseWidthAtEMGCharacteristicUUID{
                pulseWidthAtEMGCharacteristic = characteristic
                peripheral.readValue(for: pulseWidthAtEMGCharacteristic!)
            }
            else if characteristic.uuid == emgStrengthMaxCharacteristicUUID{
                emgStrengthMaxCharacteristic = characteristic
                peripheral.readValue(for: emgStrengthMaxCharacteristic!)
            }
            else if characteristic.uuid == footCharacteristicUUID{
                footCharacteristic = characteristic
                peripheral.readValue(for: footCharacteristic!)
            }
            else if characteristic.uuid == targetEMGCharacteristicUUID{
                targetEMGCharacteristic = characteristic
                peripheral.readValue(for: targetEMGCharacteristic!)
            }
            else if characteristic.uuid == recoverCharacteristicUUID{
                recoverCharacteristic = characteristic
                peripheral.readValue(for: recoverCharacteristic!)
            }
            else if characteristic.uuid == readyToSendCharacteristicUUID{
                readyToSendCharacteristic = characteristic
                peripheral.readValue(for: readyToSendCharacteristic!)
            }
            else if characteristic.uuid == temporaryPainThresholdCharacteristicUUID{
                temporaryPainThresholdCharacteristic = characteristic
                peripheral.readValue(for: temporaryPainThresholdCharacteristic!)
            }
            else if characteristic.uuid == currentTickCharacteristicUUID{
                currentTickCharacteristic = characteristic
                peripheral.readValue(for: currentTickCharacteristic!)
            }
            else if characteristic.uuid == dailyTherapyTimeCharacteristicUUID{
                dailyTherapyTimeCharacteristic = characteristic
                peripheral.readValue(for: dailyTherapyTimeCharacteristic!)
            }
            else if characteristic.uuid == lastCompletedTimeCharacterisiticUUID{
                lastCompletedTimeCharacterisitc = characteristic
                peripheral.readValue(for: lastCompletedTimeCharacterisitc!)
            }
        }
    }
    
    func setSchedule(schedule:TherapySchedules){
        let s = Int32(schedule.rawValue)
        
        if therapyScheduleCharacteristic != nil{
            let data = Data(from: s)
            btPeripheral?.writeValue(data, for: therapyScheduleCharacteristic!, type: .withResponse)
        }
    }
    
    func setTherapyLength(lengthInSeconds:Int32){
        if therapyLengthCharacteristic != nil{
            let data = Data(from:lengthInSeconds)
            btPeripheral?.writeValue(data, for: therapyLengthCharacteristic!, type: .withResponse)
        }
    }
    
    //previous was UInt16
    func setSkinSensation(sensation: Int32){
        if pulseWidthAtSkinParastheisaCharacteristic != nil {
            let data = Data(from: sensation)
            btPeripheral?.writeValue(data, for: pulseWidthAtSkinParastheisaCharacteristic!, type: .withResponse)
        }
    }
    
    func setPulseWidthAtComfort(pulseWidth:Int32){
        if pulseWidthAtComfortCharacteristic != nil{
            let data = Data(from:pulseWidth)
            btPeripheral?.writeValue(data, for: pulseWidthAtComfortCharacteristic!, type: .withResponse)
        }
    }
    
    func setPulseWidthAtEMG(pulseWidth:Int32){
        if pulseWidthAtEMGCharacteristic != nil{
            let data = Data(from:pulseWidth)
            btPeripheral?.writeValue(data, for: pulseWidthAtEMGCharacteristic!, type: .withResponse)
        }
    }
    
    func setFoot(foot:Feet){
        if footCharacteristic != nil{
            let data = Data(from:foot.rawValue)
            btPeripheral?.writeValue(data, for: footCharacteristic!, type: .withResponse)
        }
    }
    
    func setTargetEMG(targetEMG: Int32) {
        if targetEMGCharacteristic != nil{
            let data = Data(from:targetEMG)
            btPeripheral?.writeValue(data, for: targetEMGCharacteristic!, type: .withResponse)
        }
    }
    
    func setEMGStrengthMax(emgStrength: Int32){
        if emgStrengthMaxCharacteristic != nil{
            let data = Data(from: emgStrength)
            btPeripheral?.writeValue(data, for: emgStrengthMaxCharacteristic!, type: .withResponse)
        }
    }
    
    func setTemporaryPainThreshold(tempThreshold: Int32){
        if temporaryPainThresholdCharacteristic != nil{
            let data = Data(from: tempThreshold)
            btPeripheral?.writeValue(data, for: temporaryPainThresholdCharacteristic!, type: .withResponse)
        }
    }
    
    func setCurrentTick(tick: Int32){
        if currentTickCharacteristic != nil{
            let data = Data(from: tick)
            btPeripheral?.writeValue(data, for: currentTickCharacteristic!, type: .withResponse)
        }
    }
    
    func setDailyTherapyTime(dailyTime: Int32){
        if dailyTherapyTimeCharacteristic != nil{
            let data = Data(from: dailyTime)
            btPeripheral?.writeValue(data, for: dailyTherapyTimeCharacteristic!, type: .withResponse)
        }
    }
    
    func setLastCompletedTime(lastTime: Int32){
        if lastCompletedTimeCharacterisitc != nil{
            let data = Data(from: lastTime)
            Slim.debug("set lastCompletedTime: \(lastTime)")
            btPeripheral?.writeValue(data, for: lastCompletedTimeCharacterisitc!, type: .withResponse)
        }
    }
    
    func setReadyToSend(value: UInt8){
        if readyToSendCharacteristic != nil{
            let data = Data(from:value)
            btPeripheral?.writeValue(data, for: readyToSendCharacteristic!, type: .withResponse)
        }
    }
    
    func targetEMGSupported() -> Bool {
        if targetEMGCharacteristic != nil{
            //characteristicSupported(vivally_patient_target_emg)
            return true
        }
        return false
    }
    
    func readTargetEMG(){
        if targetEMGCharacteristic != nil{
            btPeripheral?.readValue(for: targetEMGCharacteristic!)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
        //print("\(Date()) - Did write value for \(characteristic.uuid.uuidString)")
        if (error == nil){
            if characteristic.uuid == readyToSendCharacteristicUUID{
                print("Wrote to readyToSendChar")
                //DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    //self.readStoredReadingValue()
                //}
                //readStoredReadingValue()
                if let characteristic = readyToSendCharacteristic {
                    peripheral.readValue(for: characteristic)
                }
            }
            if characteristic.uuid == therapyLengthCharacteristicUUID{
                if let characteristic = therapyLengthCharacteristic {
                    peripheral.readValue(for: characteristic)
                }
            }
            /*
            if characteristic.uuid == pulseWidthAtSkinParastheisaCharacteristicUUID {
                print("Successful Write to pulseWidthAtSkinParastheisa")
            }
            */
            
        }
        
        if let e = error{
            print("Error Writing Value: \(e.localizedDescription)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error == nil {
            if characteristic.uuid == therapyScheduleCharacteristicUUID{
                //print("Did Update Therapy Schedule")
                var schedule:Int32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                schedule = Int32(characteristic.value!.to(type: Int32.self))
                //print("Parsed Schedule - \(schedule)")
            }
            else if characteristic.uuid == therapyLengthCharacteristicUUID{
                //print("Did Update Therapy Length")
                var therapyLength:Int32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                therapyLength = Int32(characteristic.value!.to(type: Int32.self))
                //print("Parsed Therapy Length - \(therapyLength)")
            }
            else if characteristic.uuid == pulseWidthAtSkinParastheisaCharacteristicUUID{
                //print("Did Update Pulse Width At Skin Parastheisa")
                var pulse:Int32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                pulse = Int32(characteristic.value!.to(type: Int32.self))
                //print("Parsed Pulse Width At Skin Parastheisa - \(pulse)")
            }
            else if characteristic.uuid == pulseWidthAtComfortCharacteristicUUID{
                //print("Did Update pulseWidthAtComfortCharacteristicUUID")
                var pulse:Int32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                pulse = Int32(characteristic.value!.to(type: Int32.self))
                //print("Parsed pulseWidthAtComfortCharacteristicUUID - \(pulse)")
            }
            else if characteristic.uuid == pulseWidthAtEMGCharacteristicUUID{
                //print("Did Update pulseWidthAtEMGCharacteristicUUID")
                var pulse:Int32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                pulse = Int32(characteristic.value!.to(type: Int32.self))
                //print("Parsed pulseWidthAtEMGCharacteristicUUID - \(pulse)")
            }
            else if characteristic.uuid == emgStrengthMaxCharacteristicUUID{
                //print("Did Update emgStrengthCharacteristicUUID")
                var emg:Int32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                emg = Int32(characteristic.value!.to(type: Int32.self))
                //print("Parsed emgStrengthUUID - \(emg)")
            }
            else if characteristic.uuid == footCharacteristicUUID{
                //print("Did Update footCharacteristicUUID")
                var foot:Int32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                foot = Int32(characteristic.value!.to(type: Int32.self))
                //print("Parsed footCharacteristicUUID - \(foot)")
            }
            else if characteristic.uuid == targetEMGCharacteristicUUID{
                //print("Did Update targetEMGCharacteristicUUID")
                var emg:Int32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                emg = Int32(characteristic.value!.to(type: Int32.self))
                //print("Parsed targetEMGCharacteristicUUID - \(emg)")
            }
            else if characteristic.uuid == recoverCharacteristicUUID{
                //print("Did Update Recovery")
                let recovery = Recovery()
                if recovery.parse(data: characteristic.value!){
                    /*print("Parsed Recovery")
                    print("\(recovery.patientSchedule), \(recovery.foot), \(recovery.lastCompletedTime2)" )
                    print(recovery.subjectID)*/
                    patientServiceData.patientData = recovery
                    delegate?.PatientServiceDataUpdated(data: patientServiceData)
                }
                else{
                    print("Failed to Parse Recovery")
                }
            }
            else if characteristic.uuid == readyToSendCharacteristicUUID{
                //print("Did Update readyToSendCharacteristic")
                var rts:UInt8 = 0
                if characteristic.value!.count != 1{
                    return
                }
                rts = characteristic.value![0]
                //print("Parsed readyToSendCharacteristicUUID - \(rts)")
            }
            else if characteristic.uuid == temporaryPainThresholdCharacteristicUUID{
                //print("Did Update temporaryPainThreshold")
                var tempPain:Int32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                tempPain = Int32(characteristic.value!.to(type: Int32.self))
                //print(tempPain)
            }
            else if characteristic.uuid == currentTickCharacteristicUUID{
                print("Did Update Current Tick")
                var tick:Int32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                tick = Int32(characteristic.value!.to(type: Int32.self))
                print(tick)
            }
            else if characteristic.uuid == dailyTherapyTimeCharacteristicUUID{
                //print("Did Update Daily Time")
                var daily:Int32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                daily = Int32(characteristic.value!.to(type: Int32.self))
                //print(daily)
            }
            else if characteristic.uuid == lastCompletedTimeCharacterisiticUUID{
                //print("Did Update last Completed Time")
                var lastTime:Int32 = 0
                lastTime = Int32(characteristic.value!.to(type: Int32.self))
                //print(lastTime)
            }
            
        }
        else{
            //this never gets called
            print("An error occurred while Updating Value characteristic: Error = \(String(describing: error))")
        }
    }
    
    
   
}

