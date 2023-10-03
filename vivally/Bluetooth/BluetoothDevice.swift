/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import CoreBluetooth

protocol BluetoothDeviceDelegate{
    func bluetoothDeviceDidConnect(device:CBPeripheral)
    func deviceBatteryDidUpdate(informationServiceData:InformationServiceData, patientServiceData:PatientServiceData)
    func deviceGeneralDataDidUpdate(informationServiceData:InformationServiceData, patientServiceData:PatientServiceData)
    func deviceStimDataDidUpdate(informationServiceData: InformationServiceData, patientServiceData: PatientServiceData)
    func deviceEMGDataDidUpdate(informationServiceData: InformationServiceData, patientServiceData: PatientServiceData)
    func deviceDidUpdate(informationServiceData: InformationServiceData, patientServiceData: PatientServiceData)
    func deviceTherapySessionDidUpdate(informationServiceData: InformationServiceData, patientServiceData:PatientServiceData)
    
    func bondFail()
    func pairingTimeExpired()
    func bondSuccess(device:CBPeripheral)
    
    func deviceError()
}

class BluetoothDevice: NSObject {
    var delegate:BluetoothDeviceDelegate?
    
    var peripheral:CBPeripheral? = nil
    
    var patientService = PatientService()
    var informationService = InformationService()
    var otaService = OTAService()
    
    init(withPeripheral peripheral:CBPeripheral, andDelegate delegate:BluetoothDeviceDelegate){
        self.peripheral = peripheral
        self.delegate = delegate
        
        super.init()
        
        patientService = PatientService(withPeripheral: peripheral, self)
        informationService = InformationService(withPeripheral: peripheral, self)
        otaService = OTAService(withPeripheral: peripheral, self)
        
        self.informationService.delegate = self
        self.patientService.delegate = self
        self.otaService.delegate = self
        self.peripheral?.delegate = self
    }
    
    func discoverServices(){
        self.peripheral?.discoverServices(nil)
    }
    
    private func enableSensors(){
        patientService.setEnabled(enabled: true)
        informationService.setEnabled(enabled: true)
    }
    
    private func enableOTASensors(){
        otaService.setEnabled(enabled: true)
    }
    
    private func disableSensors(){
        patientService.setEnabled(enabled: false)
        informationService.setEnabled(enabled: false)
    }
    
    private func disableOTASensors(){
        otaService.setEnabled(enabled: false)
    }
    
    func disconnectFromDevice(){
        disableSensors()

        if OTAManager.sharedInstance.OTAMode{
            disableOTASensors()
        }
    }
    
    func sendCommand(command:DeviceCommands, parameters:[UInt8]){
        informationService.sendCommand(command: command, parameters: parameters)
    }
    
    func readBatteryStateCharge(){
        informationService.readBatteryStateCharge()
    }
    
    func readStimStatus(){
        informationService.readStimStatus()
    }
    
    func readEMGStatus(){
        informationService.readEMGStatus()
    }
    
    func readTherapySession(){
        informationService.readTherapySession()
    }
    
    func readDevice(){
        informationService.readDevice()
    }
    
    func setSchedule(schedule:TherapySchedules){
        patientService.setSchedule(schedule: schedule)
    }
    
    func setTherapyLength(lengthInSeconds:Int32){
        patientService.setTherapyLength(lengthInSeconds: lengthInSeconds)
    }
    
    func setSkinSensation(pulseWidth: Int32){
        patientService.setSkinSensation(sensation: pulseWidth)
    }
    
    func setPulseWidthAtComfort(pulseWidth:Int32){
        patientService.setPulseWidthAtComfort(pulseWidth: pulseWidth)
    }
    
    func setPulseWidthAtEMG(pulseWidth:Int32){
        patientService.setPulseWidthAtEMG(pulseWidth: pulseWidth)
    }
    
    func setFoot(foot:Feet){
        patientService.setFoot(foot: foot)
    }
    
    func setTargetEMG(targetEMG: Int32){
        patientService.setTargetEMG(targetEMG: targetEMG)
    }
    
    func setEMGStrengthMax(emgStrengthMax: Int32){
        patientService.setEMGStrengthMax(emgStrength: emgStrengthMax)
    }
    
    func setTemporaryPainThreshold(tempThreshold: Int32){
        patientService.setTemporaryPainThreshold(tempThreshold: tempThreshold)
    }
    
    func setCurrentTick(tick: Int32){
        patientService.setCurrentTick(tick: tick)
    }
    
    func setDailyTherapyTime(dailyTime: Int32){
        patientService.setDailyTherapyTime(dailyTime: dailyTime)
    }
    
    func setLastCompletedTime(lastTime: Int32){
        patientService.setLastCompletedTime(lastTime: lastTime)
    }
    
    func setReadyToSend(value: UInt8){
        patientService.setReadyToSend(value: value)
    }
    
    func targetEMGSupported() -> Bool{
        patientService.targetEMGSupported()
    }
    
    func readTargetEMG(){
        patientService.readTargetEMG()
    }
    
    func readDeviceEvent(){
        informationService.readDeviceEvent()
    }
    
    func rebootRequest() {
        informationService.rebootRequest()
    }
    
    func handleOTA(isRecovery: Bool){
        otaService.handleOTA2(recovery: isRecovery)
    }
}

extension BluetoothDevice: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if( error == nil){
            for service in peripheral.services!{
                print("Found Service \(service.uuid)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        else{
            print("An error occurred while discovering services: Error = \(String(describing: error))")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if( error == nil){
            for characteristic in service.characteristics!{
                //Logger.sharedInstance.log("Found Characteristic \(characteristic.uuid) For Service \(service.uuid)")
                
                patientService.peripheral(peripheral, didDiscoverCharacteristicsFor: service, characteristic: characteristic, error: error)
                informationService.peripheral(peripheral, didDiscoverCharacteristicsFor: service, characteristic: characteristic, error: error)
                otaService.peripheral(peripheral, didDiscoverCharacteristicsFor: service, characteristic: characteristic, error: error)
                
            }
            
            if patientService.isConfigured() && informationService.isConfigured(){
                enableSensors()
                
                print( "All services configured")
            }
            
            else if OTAManager.sharedInstance.OTAMode && otaService.isConfigured(){
                print("OTA services configured")
                enableOTASensors()
            }
        }
        else{
            print("An error occurred while discovering characteristic: Error = \(String(describing: error))")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("\(Date()) - Did write value for \(characteristic.uuid.uuidString)")
        if let e = error{
            print("Error Writing Value: \(e.localizedDescription)")
        }
        patientService.peripheral(peripheral, didWriteValueFor: characteristic, error: error)
        
        if OTAManager.sharedInstance.OTAMode{
            otaService.peripheral(peripheral, didWriteValueFor: characteristic, error: error)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error{
            print("Error Updating Value For Value: \(e.localizedDescription)  \(characteristic) \(characteristic.uuid.uuidString)")
            
            if characteristic.uuid == patientService.therapyScheduleCharacteristicUUID {
                print("fail to read therapySchedule aka first char")
                
                if BluetoothManager.sharedInstance.firstRead {
                    BluetoothManager.sharedInstance.clearPairing()
                    BluetoothDeviceInfoManager.sharedInstance.clearDevice()
                    
                    // user pairs before timer ends?
                    // YES: show pairing timeout pop up
                    let didNotPair = DeviceErrorManager.sharedInstance.didNotPairInTime
                    if didNotPair {
                        delegate?.pairingTimeExpired()
                        
                    // NO: show bond fail pop up
                    } else {
                        delegate?.bondFail()
                        Slim.log(level: LogLevel.error, category: [.pairing], "Bond did fail to: \(peripheral)")
                    }
                }
            }
            
            return
        }
        else{
            if characteristic.uuid == patientService.therapyScheduleCharacteristicUUID{
                BluetoothManager.sharedInstance.firstRead = false
                delegate?.bondSuccess(device: peripheral)
            }
            else if OTAManager.sharedInstance.OTAMode && characteristic.uuid == otaService.fileUploadConfirmationRebootCharacteristicUUID{
                OTAManager.sharedInstance.otaFileUploadFinishedReceived = true
            }
        }
        
        patientService.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        informationService.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        
        if OTAManager.sharedInstance.OTAMode{
            otaService.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        }
    }
}

extension BluetoothDevice:InformationServiceDelegate{
    func InformationServiceDeviceDataUpdated(data: InformationServiceData) {
        delegate?.deviceDidUpdate(informationServiceData: informationService.informationServiceData, patientServiceData: patientService.patientServiceData)
    }
    
    func InformationServiceBatteryUpdated(data: InformationServiceData){
        delegate?.deviceBatteryDidUpdate(informationServiceData:informationService.informationServiceData, patientServiceData: patientService.patientServiceData)
    }
    
    func InformationServiceDataUpdated(data: InformationServiceData) {
        delegate?.deviceGeneralDataDidUpdate(informationServiceData: informationService.informationServiceData, patientServiceData: patientService.patientServiceData)
    }
    func InformationServiceStimDataUpdated(data: InformationServiceData) {
        delegate?.deviceStimDataDidUpdate(informationServiceData: informationService.informationServiceData, patientServiceData: patientService.patientServiceData)
    }
    func InformationServiceEMGDataUpdated(data:InformationServiceData){
        delegate?.deviceEMGDataDidUpdate(informationServiceData: informationService.informationServiceData, patientServiceData: patientService.patientServiceData)
    }
    func InformationServiceTherapySessionUpdated(data: InformationServiceData) {
        delegate?.deviceTherapySessionDidUpdate(informationServiceData: informationService.informationServiceData, patientServiceData: patientService.patientServiceData)
    }
    
    func InformationServiceError(data: InformationServiceData) {
        delegate?.deviceError()
    }
}

extension BluetoothDevice:PatientServiceDelegate{
    func PatientServiceDataUpdated(data: PatientServiceData) {
        delegate?.deviceGeneralDataDidUpdate(informationServiceData: informationService.informationServiceData, patientServiceData: patientService.patientServiceData)
    }
}

extension BluetoothDevice:OTAServiceDelegate{
    
}
