/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import CoreBluetooth

protocol InformationServiceDelegate{
    func InformationServiceDataUpdated(data:InformationServiceData)
    func InformationServiceBatteryUpdated(data: InformationServiceData)
    func InformationServiceTherapySessionUpdated(data:InformationServiceData)
    func InformationServiceStimDataUpdated(data:InformationServiceData)
    func InformationServiceEMGDataUpdated(data:InformationServiceData)
    func InformationServiceDeviceDataUpdated(data:InformationServiceData)
    func InformationServiceError(data: InformationServiceData)
}

class InformationService: NSObject {
    var delegate: InformationServiceDelegate?
    private var isEnabled = false
    var btPeripheral:CBPeripheral? = nil
    
    var previousDevice: Device? = nil
    var impedanceCheckTimer:Timer?
    
    var informationServiceData:InformationServiceData = InformationServiceData()
    
    var batteryStateOfChargeCharacteristic:CBCharacteristic? = nil
    var batteryStateOfChargeCharacteristicUUID:CBUUID? = nil
    
    var batteryLevelsCharacteristic:CBCharacteristic? = nil
    var batteryLevelsCharacteristicUUID:CBUUID? = nil
    
    var signalCharacteristic:CBCharacteristic? = nil
    var signalCharacteristicUUID: CBUUID? = nil
    
    var stimulationStatusCharacteristic:CBCharacteristic? = nil
    var stimulationStatusCharacteristicUUID: CBUUID? = nil
    
    var infoTherapySessionCharateristic:CBCharacteristic? = nil
    var infoTherapySessionCharateristicUUID:CBUUID? = nil
    
    var emgStatusCharacteristic:CBCharacteristic? = nil
    var emgStatusCharacteristicUUID:CBUUID? = nil
    
    var commandCharacteristic:CBCharacteristic? = nil
    var commandCharacteristicUUID:CBUUID? = nil
    
    var asciiCommandCharacteristic:CBCharacteristic? = nil
    var asciiCommandCharacteristicUUID:CBUUID? = nil
    
    var deviceCharacteristic:CBCharacteristic? = nil
    var deviceCharacteristicUUID:CBUUID? = nil
    
    var asciiCommandEchoCharacteristic:CBCharacteristic? = nil
    var asciiCommandEchoCharacteristicUUID:CBUUID? = nil
    
    var timeCharacteristic:CBCharacteristic? = nil
    var timeCharacteristicUUID:CBUUID? = nil
    
    var timeTimer:Timer?
    
    var deviceParametersCharacteristic:CBCharacteristic? = nil
    var deviceParametersCharacteristicUUID:CBUUID? = nil
    
    var revisionCharacteristic:CBCharacteristic? = nil
    var revisionCharacteristicUUID:CBUUID? = nil
    
    var rebootRequestCharacteristic:CBCharacteristic? = nil
    var rebootRequestCharacteristicUUID:CBUUID? = nil
    
    var serialNumberCharacteristic:CBCharacteristic? = nil
    var serialNumberCharacteristicUUID:CBUUID? = nil
    
    var deviceEventCharacteristic:CBCharacteristic? = nil
    var deviceEventCharacteristicUUID:CBUUID? = nil

    func enbableSensors(){
        
    }
    func disableSensors(){
        if timeTimer != nil{
            timeTimer?.invalidate()
            timeTimer = nil
        }
        if impedanceCheckTimer != nil{
            impedanceCheckTimer?.invalidate()
            impedanceCheckTimer = nil
        }
    }

    override init(){
        batteryStateOfChargeCharacteristicUUID = CBUUID(string: BluetoothConstants.batteryStateOfChargeCharacteristicString)
        batteryLevelsCharacteristicUUID = CBUUID(string: BluetoothConstants.batteryLevelsCharacteristicString)
        signalCharacteristicUUID = CBUUID(string: BluetoothConstants.signalCharacteristicString)
        stimulationStatusCharacteristicUUID = CBUUID(string: BluetoothConstants.stimulationStatusCharacteristicString)
        infoTherapySessionCharateristicUUID = CBUUID(string: BluetoothConstants.infoTherapySessionCharacteristicString)
        emgStatusCharacteristicUUID = CBUUID(string: BluetoothConstants.emgStatusCharacteristicString)
        commandCharacteristicUUID = CBUUID(string: BluetoothConstants.commandCharacteristicString)
        asciiCommandCharacteristicUUID = CBUUID(string: BluetoothConstants.asciiCommandCharacteristicString)
        deviceCharacteristicUUID = CBUUID(string: BluetoothConstants.deviceCharacteristicString)
        asciiCommandEchoCharacteristicUUID = CBUUID(string: BluetoothConstants.asciiCommandEchoCharacteristicString)
        timeCharacteristicUUID = CBUUID(string: BluetoothConstants.timeCharacteristicString)
        deviceParametersCharacteristicUUID = CBUUID(string: BluetoothConstants.deviceParametersCharacteristicString)
        revisionCharacteristicUUID = CBUUID(string: BluetoothConstants.revisionCharacteristicString)
        rebootRequestCharacteristicUUID = CBUUID(string: BluetoothConstants.rebootRequestCharacteristicString)
        serialNumberCharacteristicUUID = CBUUID(string: BluetoothConstants.serialNumberCharacteristicString)
        
        deviceEventCharacteristicUUID = CBUUID(string: BluetoothConstants.deviceEventCharacteristicString)
        
        super.init()
    }
    
    init(withPeripheral peripheral:CBPeripheral, _ delegate:InformationServiceDelegate){
        self.btPeripheral = peripheral
        self.delegate = delegate
        
        batteryStateOfChargeCharacteristicUUID = CBUUID(string: BluetoothConstants.batteryStateOfChargeCharacteristicString)
        batteryLevelsCharacteristicUUID = CBUUID(string: BluetoothConstants.batteryLevelsCharacteristicString)
        signalCharacteristicUUID = CBUUID(string: BluetoothConstants.signalCharacteristicString)
        stimulationStatusCharacteristicUUID = CBUUID(string: BluetoothConstants.stimulationStatusCharacteristicString)
        infoTherapySessionCharateristicUUID = CBUUID(string: BluetoothConstants.infoTherapySessionCharacteristicString)
        emgStatusCharacteristicUUID = CBUUID(string: BluetoothConstants.emgStatusCharacteristicString)
        commandCharacteristicUUID = CBUUID(string: BluetoothConstants.commandCharacteristicString)
        asciiCommandCharacteristicUUID = CBUUID(string: BluetoothConstants.asciiCommandCharacteristicString)
        deviceCharacteristicUUID = CBUUID(string: BluetoothConstants.deviceCharacteristicString)
        asciiCommandEchoCharacteristicUUID = CBUUID(string: BluetoothConstants.asciiCommandEchoCharacteristicString)
        timeCharacteristicUUID = CBUUID(string: BluetoothConstants.timeCharacteristicString)
        deviceParametersCharacteristicUUID = CBUUID(string: BluetoothConstants.deviceParametersCharacteristicString)
        revisionCharacteristicUUID = CBUUID(string: BluetoothConstants.revisionCharacteristicString)
        rebootRequestCharacteristicUUID = CBUUID(string: BluetoothConstants.rebootRequestCharacteristicString)
        serialNumberCharacteristicUUID = CBUUID(string: BluetoothConstants.serialNumberCharacteristicString)
        deviceEventCharacteristicUUID = CBUUID(string: BluetoothConstants.deviceEventCharacteristicString)
        
        super.init()
    }
    
    func isConfigured() -> Bool{
        if batteryStateOfChargeCharacteristic != nil && batteryLevelsCharacteristic != nil && signalCharacteristic != nil && stimulationStatusCharacteristic != nil && infoTherapySessionCharateristic != nil && emgStatusCharacteristic != nil && commandCharacteristic != nil && asciiCommandCharacteristic != nil && deviceCharacteristic != nil && asciiCommandEchoCharacteristic != nil && timeCharacteristic != nil && deviceParametersCharacteristic != nil && revisionCharacteristic != nil && rebootRequestCharacteristic != nil && serialNumberCharacteristic != nil{
            return true
        }
        return false
    }
    
    func setEnabled(enabled:Bool){
        if enabled == true && isEnabled == false{
            isEnabled = true
            
            // This is where we want to do an initial read
            btPeripheral?.setNotifyValue(true, for: batteryStateOfChargeCharacteristic!)
            btPeripheral?.setNotifyValue(true, for: signalCharacteristic!)
            btPeripheral?.setNotifyValue(true, for: stimulationStatusCharacteristic!)
            btPeripheral?.setNotifyValue(true, for: emgStatusCharacteristic!)
            btPeripheral?.setNotifyValue(true, for: deviceCharacteristic!)
            btPeripheral?.setNotifyValue(true, for: asciiCommandEchoCharacteristic!)
            
            btPeripheral?.setNotifyValue(true, for: infoTherapySessionCharateristic!)
            
        }
        else if enabled == false && isEnabled == true{
            isEnabled = false
        }
        if enabled == false{
            disableSensors()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, characteristic:CBCharacteristic, error: Error?) {
        if service.uuid == CBUUID(string:BluetoothConstants.informationServiceString){
            //print(service.uuid)
            if characteristic.uuid == batteryStateOfChargeCharacteristicUUID{
                batteryStateOfChargeCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: batteryStateOfChargeCharacteristic!)
                peripheral.readValue(for: batteryStateOfChargeCharacteristic!)
            }
            else if characteristic.uuid == batteryLevelsCharacteristicUUID{
                batteryLevelsCharacteristic = characteristic
                peripheral.readValue(for: batteryLevelsCharacteristic!)
            }
            else if characteristic.uuid == signalCharacteristicUUID{
                signalCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: signalCharacteristic!)
                peripheral.readValue(for: signalCharacteristic!)
            }
            else if characteristic.uuid == stimulationStatusCharacteristicUUID{
                stimulationStatusCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: stimulationStatusCharacteristic!)
                peripheral.readValue(for: stimulationStatusCharacteristic!)
            }
            else if characteristic.uuid == infoTherapySessionCharateristicUUID{
                //print("discovered infotherapySession")
                infoTherapySessionCharateristic = characteristic
                peripheral.setNotifyValue(true, for: infoTherapySessionCharateristic!)
                peripheral.readValue(for: infoTherapySessionCharateristic!)
            }
            else if characteristic.uuid == emgStatusCharacteristicUUID{
                emgStatusCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: emgStatusCharacteristic!)
                peripheral.readValue(for: emgStatusCharacteristic!)
            }
            else if characteristic.uuid == commandCharacteristicUUID{
                commandCharacteristic = characteristic
                
                BluetoothManager.sharedInstance.setMode2()
            }
            else if characteristic.uuid == asciiCommandCharacteristicUUID{
                asciiCommandCharacteristic = characteristic
            }
            else if characteristic.uuid == deviceCharacteristicUUID{
                deviceCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: deviceCharacteristic!)
                peripheral.readValue(for: deviceCharacteristic!)
            }
            else if characteristic.uuid == asciiCommandEchoCharacteristicUUID{
                asciiCommandEchoCharacteristic = characteristic
            }
            else if characteristic.uuid == timeCharacteristicUUID{
                
                timeCharacteristic = characteristic
                
                if timeTimer != nil{
                    timeTimer?.invalidate()
                    timeTimer = nil
                }
                timeTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(sendTime), userInfo: nil, repeats: true)
                
                peripheral.readValue(for: timeCharacteristic!)
                
                //writeTime()
            }
            else if characteristic.uuid == deviceParametersCharacteristicUUID{
                deviceParametersCharacteristic = characteristic
                peripheral.readValue(for: deviceParametersCharacteristic!)
            }
            else if characteristic.uuid == revisionCharacteristicUUID{
                revisionCharacteristic = characteristic
                peripheral.readValue(for: revisionCharacteristic!)
            }
            else if characteristic.uuid == rebootRequestCharacteristicUUID{
                rebootRequestCharacteristic = characteristic
            }
            else if characteristic.uuid == serialNumberCharacteristicUUID{
                serialNumberCharacteristic = characteristic
                peripheral.readValue(for: serialNumberCharacteristic!)
            }
            else if characteristic.uuid == deviceEventCharacteristicUUID{
                deviceEventCharacteristic = characteristic
                peripheral.readValue(for: deviceEventCharacteristic!)
            }
        }
    }
    /*
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
        print("Did write value for \(characteristic.uuid.uuidString)")
        if (error == nil) {
            if characteristic.uuid == rebootRequestCharacteristicUUID {
                print("Wrote to reboot char")
            }
        }
    }
    */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error == nil {
            if characteristic.uuid == batteryStateOfChargeCharacteristicUUID{
                //print("Did Update Battery State of Charge")
                let bsoc = BatteryStateOfCharge()
                if bsoc.parse(data: characteristic.value!){
                    bsoc.calcLevel()
                    informationServiceData.batteryStateOfCharge = bsoc
                    delegate?.InformationServiceDataUpdated(data: informationServiceData)
                    delegate?.InformationServiceBatteryUpdated(data: informationServiceData)
                }
                else{
                    print("Failed to parse Battery State of charge")
                }
            }
            else if characteristic.uuid == batteryLevelsCharacteristicUUID{
                //print("Did Update Battery Levels")
                let batteryLevels = BatteryLevels()
                if batteryLevels.parse(data: characteristic.value!){
                    //print("Parsed Battery Levels")
                    informationServiceData.batteryLevels = batteryLevels
                    delegate?.InformationServiceDataUpdated(data: informationServiceData)
                    delegate?.InformationServiceBatteryUpdated(data: informationServiceData)
                }
                else{
                    print("Failed to Parse Battery Levels")
                }
            }
            else if characteristic.uuid == signalCharacteristicUUID{
                //print("Did Update Battery Levels")
                var signal:UInt8 = 0
                if characteristic.value!.count != 1{
                    return
                }
                signal = characteristic.value![0]
                //print("Parsed Signal - \(signal)")
            }
            else if characteristic.uuid == stimulationStatusCharacteristicUUID{
                //print("Did Update Stimulation Status")
                let stimStatus = StimulationStatus()
                if stimStatus.parse(data: characteristic.value!){
                    informationServiceData.stimStatus = stimStatus
                    delegate?.InformationServiceDataUpdated(data: informationServiceData)
                    delegate?.InformationServiceStimDataUpdated(data: informationServiceData)
                }
                else{
                    print("Failed to Parse Stimulation Status")
                }
            }
            else if characteristic.uuid == infoTherapySessionCharateristicUUID{
                //print("Did Update infoTherapy")
                //once new device fix this
                let therapySession = TherapySession()
                if therapySession.parse(data: characteristic.value!){
                    informationServiceData.therapySession = therapySession
                    //check for logged in
                    Slim.log(level: .info, category: [.therapy], therapySession.getSessionStr())
                    if UserDefaults.standard.bool(forKey: "loggedIn") && !DataRecoveryManager.sharedInstance.startedDataRecovery{
                        
                        TherapyManager.sharedInstance.handleTherapySession(session: therapySession)
                    }
                    
                    delegate?.InformationServiceTherapySessionUpdated(data: informationServiceData)
                    
                }
                else{
                    print("Failed to Parse Therapy Session")
                }
                
            }
            else if characteristic.uuid == emgStatusCharacteristicUUID{
                //print("Did update emg status")
               let emgStatus = EMGStatus()
                if emgStatus.parse(data: characteristic.value!){
                    //print("Parsed EMG Status")
                    informationServiceData.emgStatus = emgStatus
                    //delegate?.InformationServiceDataUpdated(data: informationServiceData)
                    delegate?.InformationServiceEMGDataUpdated(data: informationServiceData)
                }
                else{
                    print("Failed to parse EMG Status")
                }
            }
            else if characteristic.uuid == commandCharacteristicUUID{
                
            }
            else if characteristic.uuid == asciiCommandCharacteristicUUID{
                
            }
            else if characteristic.uuid == deviceCharacteristicUUID{
                //print("Did Update Device Status")
                let device = Device()
                if device.parse(data: characteristic.value!){
                    //print("Parsed Device \(device.error)")
                    informationServiceData.deviceData = device
                    
                    DeviceErrorManager.sharedInstance.dailyLimitReached = device.isDailyLimitReached(prevDevice: previousDevice) == true
                    DeviceErrorManager.sharedInstance.weeklyLimitReached = device.isWeeklyLimitReached(prevDevice: previousDevice) == true
                    DeviceErrorManager.sharedInstance.checkForDailyCheck()
                    
                    if DeviceErrorManager.sharedInstance.impedanceCheckRunning {
                       let impedance = device.isImpedancePassed(prevDevice: previousDevice) == true
                       let continuity = device.isContinuityPassed(prevDevice: previousDevice) == true
                       let footCheck = device.isFootCheckPassed(prevDevice: previousDevice) == true
                    
                       if (previousDevice != nil){
                           DeviceErrorManager.sharedInstance.impedanceCheckImpedance = impedance
                           DeviceErrorManager.sharedInstance.impedanceCheckContinuity = continuity
                           DeviceErrorManager.sharedInstance.impedanceCheckFoot = footCheck
                           if impedance{
                               
                               DeviceErrorManager.sharedInstance.impedanceCheckRunning = false
                               DeviceErrorManager.sharedInstance.impedanceCheck = device.impedance
                           }
                       }
                    }
                    
                    DeviceErrorManager.sharedInstance.recoveryDataAvailable = device.isRecoveryDataAvailable(prevDevice: previousDevice) == true
                    DeviceErrorManager.sharedInstance.setDataRecoveryAvailability()
                    
                    DeviceErrorManager.sharedInstance.insufficientBattery = device.isErrorInsufficientBattery(prevDevice: previousDevice) == true
                    DeviceErrorManager.sharedInstance.doesNotMeetCriteria = device.doesPatientNotMeetCriteria(prevDevice: previousDevice) == true
                    DeviceErrorManager.sharedInstance.meetsCriteria = device.doesPatientMeetCriteria(prevDevice: previousDevice) == true
                    DeviceErrorManager.sharedInstance.pauselimitReached = device.isPauseLimitReached(prevDevice: previousDevice) == true
                    DeviceErrorManager.sharedInstance.pauseTimeout = device.isPauseTimeout(prevDevice: previousDevice) == true
                    DeviceErrorManager.sharedInstance.savePatientInfoSuccess = device.didSavePatientInfoSuceed(prevDevice: previousDevice) == true
                    DeviceErrorManager.sharedInstance.savePatientInfoFailure = device.didSavePatientInfoFail(prevDevice: previousDevice) == true
                    DeviceErrorManager.sharedInstance.loadPatientInfoSucces = device.didLoadPatientInfoSucced(prevDevice: previousDevice) == true
                    DeviceErrorManager.sharedInstance.loadPatientInfoFailure = device.didLoadPatientInfoFail(prevDevice: previousDevice) == true
                    
                    DeviceErrorManager.sharedInstance.checkForBatteryCheck()
                    
                    DeviceErrorManager.sharedInstance.wrongFoot = device.isWrongFoot() == true
                    DeviceErrorManager.sharedInstance.continuityBad = device.isContinuityBad() == true
                    DeviceErrorManager.sharedInstance.impedanceBad = device.isImpedanceBad() == true
                    
                    if DeviceErrorManager.sharedInstance.impedanceCheckRunning {
                        DeviceErrorManager.sharedInstance.checkForImp()
                    }
                    
                    if device.error != 0{
                        DeviceErrorManager.sharedInstance.isthereError()
                        delegate?.InformationServiceError(data: informationServiceData)
                    }
                    previousDevice = device
                    
                    delegate?.InformationServiceDeviceDataUpdated(data: informationServiceData)
                    //delegate?.InformationServiceDataUpdated(data: informationServiceData)
                }
                else{
                    print("Failed to Parse Device")
                }
            }
            else if characteristic.uuid == asciiCommandEchoCharacteristicUUID{
                
            }
            else if characteristic.uuid == timeCharacteristicUUID{
                //print("Did Update Time")
                var time:UInt32 = 0
                if characteristic.value!.count != 4{
                    return
                }
                time = UInt32(characteristic.value!.to(type: UInt32.self))
                informationServiceData.time = time
            }
            else if characteristic.uuid == deviceParametersCharacteristicUUID{
                //print("Did Update Device Parameters")
                let deviceP = DeviceParameters()
                if deviceP.parse(data: characteristic.value!){
                    //print("Parsed Device Parameters")
                }
                else{
                    print("Failed to Parse Parameters")
                }
            }
            else if characteristic.uuid == revisionCharacteristicUUID{
                //print("Did Update Revision")
                let revision = Revision()
                if revision.parse(data: characteristic.value!){
                    //print("Parsed Revision")
                    //print("Revision pieces: \(revision.major) \(revision.minor) \(revision.patch)")
                    revision.revisionStr(data: characteristic.value!)
                    //print(revision.rev)
                    //print(revision.bootRev)
                    informationServiceData.revision = revision
                    delegate?.InformationServiceDataUpdated(data: informationServiceData)
                }
                else{
                    print("Failed to Parse Revision")
                }
            }
            
            else if characteristic.uuid == serialNumberCharacteristicUUID{
                //print("Did update Serial Num")
                let serialNum = SerialNumber()
                if serialNum.parse(data: characteristic.value!){
                    //print("Parsed Serial Num")
                    informationServiceData.serialNumber = serialNum
                    delegate?.InformationServiceDataUpdated(data: informationServiceData)
                    
                    DeviceConfigManager.sharedInstance.checkForNewDeviceConfig2()
                    OTAManager.sharedInstance.calcOTAMac()
                }
            }
            else if characteristic.uuid == deviceEventCharacteristicUUID{
                //print("Did update Device Event")
                let deviceEvent = DeviceEvent()
                if deviceEvent.parse(data: characteristic.value!){
                    //print("parsed deviceevent")
                    informationServiceData.deviceEvent = deviceEvent
                    DeviceEventManager.sharedInstance.handleDeviceEvent(devEvent: deviceEvent)
                    DeviceEventManager.sharedInstance.deviceEvent = deviceEvent
                    delegate?.InformationServiceDataUpdated(data: informationServiceData)
                }
                else{
                    print("failed to parse device event")
                }
            }
            
        }
        else{
            Slim.error("An error occurred while Updating Value characteristic: Error = \(String(describing: error))")
        }
    }
    
    func readDeviceEvent(){
        
    }
    
    func rebootRequest(){
        print("Requesting Reboot")
        
        let request = RebootRequest()
        request.getOTAReboot(sizeInBytes: 0)
        let data = request.toDataModel()
        
        if rebootRequestCharacteristic != nil {
            btPeripheral?.writeValue(data, for: rebootRequestCharacteristic!, type: .withoutResponse)
        }
    }
    
    func rebootNormal(){
        let request = RebootRequest()
        let data = request.toDataModel()
        
        if rebootRequestCharacteristic != nil {
            btPeripheral?.writeValue(data, for: rebootRequestCharacteristic!, type: .withoutResponse)
        }
    }
    
    func readBatteryStateCharge(){
        if batteryStateOfChargeCharacteristic != nil{
            btPeripheral?.readValue(for: batteryStateOfChargeCharacteristic!)
        }
    }
    
    func readStimStatus(){
        if stimulationStatusCharacteristic != nil{
            btPeripheral?.readValue(for: stimulationStatusCharacteristic!)
        }
    }
    
    func readEMGStatus(){
        if emgStatusCharacteristic != nil{
            btPeripheral?.readValue(for: emgStatusCharacteristic!)
        }
    }
    
    func readTherapySession(){
        if infoTherapySessionCharateristic != nil {
            btPeripheral?.readValue(for: infoTherapySessionCharateristic!)
        }
    }
    
    func readDevice(){
        if deviceCharacteristic != nil {
            btPeripheral?.readValue(for: deviceCharacteristic!)
        }
    }
    
    func sendCommand(command:DeviceCommands, parameters:[UInt8]){
        let c = Command()
        let data = c.toDataModel(command: command.rawValue, parameter: parameters)
        
        if commandCharacteristic != nil{
            btPeripheral?.writeValue(data, for: commandCharacteristic!, type: .withResponse)
        }
    }
    
    
    func writeTime(){
        let appTime =  UInt32(Date().timeIntervalSince1970)
        let data = Data(from: appTime)
        btPeripheral?.writeValue(data, for: timeCharacteristic!, type: .withResponse)
    }
   
}

extension InformationService{
    
    
    @objc func readTime(){
        if let characteristic = timeCharacteristic{
            btPeripheral?.readValue(for: characteristic)
        }
    }
 
    
    @objc func sendTime(){
        writeTime()
        
        readTime()
        
    }
    
    
    @objc func imp(){
        
    }
}

