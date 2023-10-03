/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import CoreBluetooth

protocol OTAServiceDelegate {
    //func OTAServiceConfirmationRebootUpdated()
}

class OTAService: NSObject{
    var delegate: OTAServiceDelegate?
    private var isEnabled = false
    var btPeripheral:CBPeripheral? = nil
    
    var baseAddressCharacteristic:CBCharacteristic? = nil
    var baseAddressCharacteristicUUID:CBUUID? = nil
    
    var fileUploadConfirmationRebootCharacteristic:CBCharacteristic? = nil
    var fileUploadConfirmationRebootCharacteristicUUID:CBUUID? = nil
    
    var rawDataCharacteristic:CBCharacteristic? = nil
    var rawDataCharacteristicUUID:CBUUID? = nil
    
    var otaRevisionCharacteristic:CBCharacteristic? = nil
    var otaRevisionCharacteristicUUID:CBUUID? = nil


    override init() {
        baseAddressCharacteristicUUID = CBUUID(string: BluetoothConstants.baseAddressCharacteristicString)
        fileUploadConfirmationRebootCharacteristicUUID = CBUUID(string: BluetoothConstants.fileUploadConfirmationRebootCharacteristicString)
        rawDataCharacteristicUUID = CBUUID(string: BluetoothConstants.rawDataCharacteristicString)
        otaRevisionCharacteristicUUID = CBUUID(string: BluetoothConstants.otaRevisionCharacteristicString)
        
        super.init()
    }
    
    init(withPeripheral peripheral:CBPeripheral, _ delegate:OTAServiceDelegate) {
        self.btPeripheral = peripheral
        self.delegate = delegate
        
        baseAddressCharacteristicUUID = CBUUID(string: BluetoothConstants.baseAddressCharacteristicString)
        fileUploadConfirmationRebootCharacteristicUUID = CBUUID(string: BluetoothConstants.fileUploadConfirmationRebootCharacteristicString)
        rawDataCharacteristicUUID = CBUUID(string: BluetoothConstants.rawDataCharacteristicString)
        otaRevisionCharacteristicUUID = CBUUID(string: BluetoothConstants.otaRevisionCharacteristicString)
        
        super.init()
    }
    
    func isConfigured() -> Bool{
        if baseAddressCharacteristic != nil && fileUploadConfirmationRebootCharacteristic != nil && rawDataCharacteristic != nil && otaRevisionCharacteristic != nil {
            return true
        }
        return false
    }
    
    func setEnabled(enabled:Bool){
        if enabled == true && isEnabled == false{
            isEnabled = true
            
            // This is where we want to do an initial read
            btPeripheral?.setNotifyValue(true, for: fileUploadConfirmationRebootCharacteristic!)
            
        }
        else if enabled == false && isEnabled == true{
            isEnabled = false
        }
        if enabled == false{
            //disableSensors()
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, characteristic:CBCharacteristic, error: Error?) {
        if service.uuid == CBUUID(string: BluetoothConstants.otaServiceString){
            //print("found ota")
            if characteristic.uuid == baseAddressCharacteristicUUID {
                baseAddressCharacteristic = characteristic
                print("found base address")
            }
            if characteristic.uuid == fileUploadConfirmationRebootCharacteristicUUID {
                fileUploadConfirmationRebootCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: fileUploadConfirmationRebootCharacteristic!)
                print("found fileUpload")
            }
            if characteristic.uuid == rawDataCharacteristicUUID{
                rawDataCharacteristic = characteristic
                print("found rawData")
            }
            if characteristic.uuid == otaRevisionCharacteristicUUID {
                otaRevisionCharacteristic = characteristic
                print("found revision char")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            if characteristic.uuid == fileUploadConfirmationRebootCharacteristicUUID {
                //file upload confirmed
                OTAManager.sharedInstance.otaFileUploadFinishedReceived = true
            }
            else if characteristic.uuid == rawDataCharacteristicUUID{
                //raw data change confirmed
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
        if (error == nil){
            
        }
        if let e = error{
            print("Error Writing Value: \(e.localizedDescription)")
        }
    }
    
    func writeBaseAddress(start: Bool){
        let address = OTAAddress()
        var data = Data()
        
        if start {
            address.startUserApplicationFileUpload()
            data = address.toDataStartModel()
        }
        else{
            address.fileUploadFinish()
            data = address.toDataFinishModel()
        }
        //let data = address.toDataStartModel()
        
        if baseAddressCharacteristic != nil {
            btPeripheral?.writeValue(data, for: baseAddressCharacteristic!, type: .withoutResponse)
        }
    }
    
    func writeRawData(rawdata: Data){
        if rawDataCharacteristic != nil {
            btPeripheral?.writeValue(rawdata, for: rawDataCharacteristic!, type: .withoutResponse)
        }
    }
    
    var packetCount = 0
    //trying with dispatch queue
    func handleOTA2(recovery: Bool){
        ActivityManager.sharedInstance.stopActivityTimers()
        
        OTAManager.sharedInstance.state = .connected
        OTAManager.sharedInstance.updateState()
        
        //check device and delay
        if(!checkDeviceAndDelay()){
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            self.writeBaseAddress(start: true)
            
            self.rawData = Data.init()
            //read file first
            do{
                //new
                if recovery{
                    if let path = Bundle.main.path(forResource: "Vivally_OTA_1_9_18", ofType: "bin"){
                    //if let path = Bundle.main.path(forResource: "Touch_OTA_1_7_4", ofType: "bin"){
                        let url = URL(fileURLWithPath: path)
                        self.rawData = try Data(contentsOf: url)
                    }
                }
                else{
                    let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = docsUrl.appendingPathComponent("updateFile.bin")
                    self.rawData = try Data(contentsOf: fileURL)
                }
            }
            catch{
                print("Couldn't read file")
                return
            }
            
            self.size = self.max
            self.leftRange = 0
            self.rightRange = self.leftRange + (self.size - 1)
           
           
            if self.writeTimer != nil {
                self.writeTimer?.invalidate()
            }
            self.writeTimer = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                if self.writeTimer != nil {
                    self.writeTimer?.invalidate()
                }
                self.writeTimer = nil
                self.writeTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.writeCheck), userInfo: nil, repeats: true)
            }
        }
    }
    
    var writeTimer:Timer?
    var rawData = Data()
    let max = 20
    var size = 0 // should be set to max
    var leftRange = 0
    var rightRange = 0 // should be set to leftRange + (size - 1)
    
    
    
    @objc func writeCheck(){
        if size > 0 {
            
            checkDeviceAndDelay()
            
            let tempByte = rawData[leftRange...rightRange]
            self.writeRawData(rawdata: tempByte)
            
            OTAManager.sharedInstance.state = .flashing
            
            var percent = 0.0
            percent = Double(rightRange + 1) / Double(rawData.count) * 100
            OTAManager.sharedInstance.progress = percent
            print("\(leftRange)-\(rightRange) & \(percent)%")
            print(tempByte as NSData)
            OTAManager.sharedInstance.updateState()
            
            leftRange = rightRange + 1
            if leftRange + size > rawData.count {
                size = rawData.count - leftRange
            }
            rightRange = leftRange + (size - 1)
            
            packetCount += 1
        }
        else{
            //disable timers
            if writeTimer != nil {
                writeTimer?.invalidate()
            }
            writeTimer = nil
            print(packetCount)
            finishWriting()
        }
        
    }
    
    func finishWriting(){
        if !self.checkDeviceAndDelay() {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            let otaFinishDelayMs = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                //delay ota finish ml
                print("wrote base address finish")
                self.writeBaseAddress(start: false)
                
                //delay ota finish check delay previous was 3.0
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                    let wasRecovery = OTAManager.sharedInstance.recovery
                //check if otaFileUploadFinishedReceived //set true from read
                    if OTAManager.sharedInstance.otaFileUploadFinishedReceived {
                        //ota clear available
                        if !wasRecovery{
                            OTAManager.sharedInstance.clearAvailable()
                        }
                        OTAManager.sharedInstance.state = .completed
                        print("upload finish received")
                        Slim.log(level: LogLevel.info, category: [.appEvents], "OTA upload complete")

                    }
                    else{
                        OTAManager.sharedInstance.state = .failed
                        print("no upload finish received")
                        Slim.log(level: LogLevel.error, category: [.appEvents], "OTA upload failed")

                    }
                    
                    if OTAManager.sharedInstance.OTAMode{
                        if !wasRecovery{
                            OTAManager.sharedInstance.OTAMode = false
                            //UserDefaults.standard.set(OTAManager.sharedInstance.OTAMode, forKey: "otaMode")
                        }
                        
                        
                        /*
                        if BluetoothManager.sharedInstance.isConnectedToDevice(){
                            wasRecovery ? BluetoothManager.sharedInstance.clearPairingOnly() : BluetoothManager.sharedInstance.disconnectDevices()
                        }
                        else{
                            OTAManager.sharedInstance.otaFileUploadFinishedReceived = false
                        }
                        */
                    }
                    
                    BluetoothManager.sharedInstance.clearPairingOnly()
                    OTAManager.sharedInstance.otaFileUploadFinishedReceived = false
                    
                    if !wasRecovery{
                        self.reconnectDeviceAfterOTA2()
                    }
                    else{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                            OTAManager.sharedInstance.otaIgnoreBLEChanges = false
                        }
                    }
                    
                    OTAManager.sharedInstance.updateState()
                    OTAManager.sharedInstance.updateRunning = false
                    
                    ActivityManager.sharedInstance.resetInactivityCount()
                }
            }
        }
    }
    
    var reconnectTimer:Timer?
    func reconnectDeviceAfterOTA2(){
        if OTAManager.sharedInstance.oldDevice != nil{
            BluetoothManager.sharedInstance.savePairing(bleInfo: OTAManager.sharedInstance.oldDevice!)
        }
        
        BluetoothManager.sharedInstance.restartScanning()
        
        /*
        reconnectAttempts = 0
        stopReconnectTimer()
        reconnectTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(attemptReconnect), userInfo: nil, repeats: true)
        */
    }
    
    var reconnectAttempts = 0
    @objc func attemptReconnect(){
        
        if reconnectAttempts < 3{
            let discoveredDevices = BluetoothManager.sharedInstance.dicoveredDevices.values.map({$0})
            for dev in discoveredDevices{
                if dev.mac == OTAManager.sharedInstance.oldMac{
                    stopReconnectTimer()
                    BluetoothManager.sharedInstance.attemptConnectToDeviceByDiscoveredDevice(ddevice: dev)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                        OTAManager.sharedInstance.otaIgnoreBLEChanges = false
                    }
                    return
                }
            }
            BluetoothManager.sharedInstance.restartScanning()
            reconnectAttempts += 1
        }
        else{
            stopReconnectTimer()
        }
    }
    
    func stopReconnectTimer(){
        if reconnectTimer != nil {
            reconnectTimer?.invalidate()
        }
        reconnectTimer = nil
    }
    
    
    
    //delay done outside
    func checkDeviceAndDelay() -> Bool{
        if !BluetoothManager.sharedInstance.isConnectedToDevice() {
            OTAManager.sharedInstance.state = .failed
            OTAManager.sharedInstance.updateState()
            print("check device fail")
            return false
        }
        return true
    }
}

