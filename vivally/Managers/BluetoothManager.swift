/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import CoreBluetooth

protocol BluetoothManagerDelegate{
    func didDiscoverDevice(discoveredDevice:DiscoveredDevice)
    func didConnectToDevice(device:CBPeripheral)
    func didDisconnectFromDevice(device:CBPeripheral)
    func didBLEChange(on: Bool)
    func didUpdateData()
    func didUpdateStimStatus()
    func didUpdateEMG()
    func didUpdateBattery()
    func didUpdateTherapySession()
    func didBondFail()
    func pairingTimeExpired()
    
    func didUpdateDevice()
    //triggered from TherapyManager
    func foundOngoingTherapy()
}

protocol BluetoothManagerNavDelegate{
    func deviceConnection(connection: Bool)
    func bleChange(on: Bool)
}

protocol BluetoothManagerToastDelegate {
    func deviceConnection(connection: Bool)
}

protocol BluetoothManagerBondDelegate{
    func attemptBond()      //read something
    func failedBond()       //
}

protocol BluetoothManagerErrorDelegate{
    func deviceError()
}

class BluetoothManager: NSObject {
    
    var isSham:Bool?
    
    var navDelegate:BluetoothManagerNavDelegate? = nil
    var toastDelegate: BluetoothManagerToastDelegate? = nil
    
    var errorDelegate: BluetoothManagerErrorDelegate? = nil
    
    var centralManager:CBCentralManager? = nil
    var dicoveredDevices:[String:DiscoveredDevice] = [:]
    var delegate:BluetoothManagerDelegate? = nil
    var connectedPeripheral:CBPeripheral? = nil
    var connectedDevice:BluetoothDevice? = nil
    var deviceMACAttemptingToConnect = ""
    
    var bleON = false
    var bonded = true
    var firstRead = false
    
    var patientServiceData:PatientServiceData = PatientServiceData()
    var informationServiceData:InformationServiceData = InformationServiceData()
    
    var connectingPeripheral:CBPeripheral? = nil
    
    static let sharedInstance = BluetoothManager()
    
    override init(){
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [ CBCentralManagerOptionRestoreIdentifierKey: "vivallybluetoothmanager"] )
    }
    
    func logout(){
        disconnectDevices()
    }
    
    func isConnectedToDevice() -> Bool{
        return (connectedDevice != nil)
    }
    
    func isBleAvailable() -> Bool{
        if !bleON{
            Slim.log(level: LogLevel.error, category: [.deviceInfo], "Bluetooth is not detected")
        }
        return bleON
    }
    
    func isPairedWithMAC(mac:String) -> Bool{
        if mac == deviceMACAttemptingToConnect && mac != ""{
            return true
        }
        return false
    }
    
    func savePairing(bleInfo:BluetoothDeviceInfo){
        BluetoothDeviceInfoManager.sharedInstance.deviceInfo = bleInfo
        deviceMACAttemptingToConnect = bleInfo.deviceMac
        BluetoothDeviceInfoManager.sharedInstance.saveData()
    }
    
    func clearPairing(){
        BluetoothDeviceInfoManager.sharedInstance.clearDevice()
        deviceMACAttemptingToConnect = ""
        connectedPeripheral = nil
        disconnectDevices()
        restartScanning()
    }
    
    func clearPairingOnly(){
        BluetoothDeviceInfoManager.sharedInstance.clearDevice()
        deviceMACAttemptingToConnect = ""
        disconnectDevices()
    }
    
    func clearOTAPairing(){
        if BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired(){
            let deviceName = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceName
            if deviceName.contains("ota") || deviceName.contains("OTA"){
                clearPairingOnly()
            }
        }
    }
    
    func setupManager(){
        deviceMACAttemptingToConnect = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac
    }
    
    func restartScanning(){
        dicoveredDevices = [:]
        stopScanning()
        startScanning()
    }
    
    func startScanning(){
        /*let servicesArray:Array = Array(arrayLiteral: CBUUID(string: BluetoothConstants.))*/
        centralManager?.scanForPeripherals(withServices: nil , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
    }
    
    func stopScanning(){
        if (centralManager?.isScanning)!{
            centralManager?.stopScan()
        }
    }
    
    func attemptConnectToDeviceByDiscoveredDevice(ddevice:DiscoveredDevice){
        deviceMACAttemptingToConnect = ddevice.mac
        if connectedDevice != nil{
            print("connectDevice != nil")
            connectedDevice?.disconnectFromDevice()
            connectedDevice = nil
        }
        if connectedPeripheral != nil{
            print("connectedPeripheral != nil")
            centralManager?.cancelPeripheralConnection(connectedPeripheral!)
        }
        
        BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceName = ddevice.name
        BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac = ddevice.mac
        BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceID = ddevice.peripheral!.identifier.uuidString
        BluetoothDeviceInfoManager.sharedInstance.saveData()
        
        connectToDevice(peripheral: ddevice.peripheral!)
    }
    
    private func connectToDevice(peripheral:CBPeripheral){
        
//        let options = [CBConnectPeripheralOptionNotifyOnConnectionKey: false as AnyObject,
//                       CBConnectPeripheralOptionNotifyOnDisconnectionKey: false as AnyObject,
//                       CBConnectPeripheralOptionNotifyOnNotificationKey: false as AnyObject,
//                       CBCentralManagerRestoredStatePeripheralsKey: true as AnyObject,
//                       CBCentralManagerRestoredStateScanServicesKey : true as AnyObject]
        stopScanning()
        print("centralManager.connect")
        centralManager?.connect(peripheral, options: nil)
    }
    
    
    
    func disconnectDevices(){
        
        print("DisconnectDevice Called")
        if let cd = connectedDevice{
            print("disconnectDevices = cancel peripheral")
            centralManager?.cancelPeripheralConnection(cd.peripheral!)
        }
        deviceMACAttemptingToConnect = ""
    }
    
    func disconnectFromDevice(device:DiscoveredDevice){
       
        print( "disconnectFromDevices called")
        if let cd = connectedDevice{
            if cd.peripheral?.identifier.uuidString == device.peripheral?.identifier.uuidString{
                centralManager?.cancelPeripheralConnection(cd.peripheral!)
            }
        }
        deviceMACAttemptingToConnect = ""
    }
    
    func stopAllStimulation(){
        if isConnectedToDevice(){
            let stimState = informationServiceData.stimStatus.state
            if stimState == .paused{
                sendCommand(command: .resumeStim, parameters: [])
            }
            sendCommand(command: .stopStim, parameters: [])
        }
    }
    
    func setMode(){
        if let setSham = isSham {
            if setSham{
                sendCommand(command: .deviceMode, parameters:  [UInt8(BluetoothConstants.PARAM_DEVICE_MODE_NO_STIM)])
                Slim.info("Stim connected: loading \(BluetoothConstants.PARAM_DEVICE_MODE_NO_STIM) mode")
            }
            else{
                sendCommand(command: .deviceMode, parameters:  [UInt8(BluetoothConstants.PARAM_DEVICE_MODE_CLINICAL)])
                Slim.info("Stim connected: loading \(BluetoothConstants.PARAM_DEVICE_MODE_CLINICAL) mode")
            }
        }
    }
    
    func setMode2(){
        var deviceMode: Int? = nil
        if KeychainManager.sharedInstance.loadAccountData()?.roles.contains("Patient") == true{
            deviceMode = KeychainManager.sharedInstance.accountData?.userModel?.deviceMode
        }
        else if KeychainManager.sharedInstance.accountData?.userModel?.roles?.contains("Clinician") == true{
            deviceMode = ScreeningManager.sharedInstance.patientData?.deviceMode
        }
        
        var modeList:[Int] = []
        for mod in Modes.allCases{
            let num = mod.getDeviceModeEquivalent()
            if isDeviceModeActive(devMode: deviceMode, bit: num) == true{
                modeList.append(num)
                let modeCommand = mod.getModeCommandValue()
                sendCommand(command: .deviceMode, parameters: [UInt8(modeCommand)])
            }
        }
        
        if modeList.isEmpty{
            sendCommand(command: .deviceMode, parameters: [UInt8(BluetoothConstants.PARAM_DEVICE_MODE_CLINICAL)])
        }
    }
    
    func isDeviceModeActive(devMode: Int?, bit: Int) -> Bool?{
        if devMode != nil{
            return (devMode! & bit) == bit
        }
        return nil
    }
    
    func sendCommand(command:DeviceCommands, parameters:[UInt8]){
        if let cd = connectedDevice{
            cd.sendCommand(command: command, parameters: parameters)
        }
    }
    
    func readBatteryStateCharge(){
        if let cd = connectedDevice{
            cd.readBatteryStateCharge()
        }
    }
    
    func readStimStatus(){
        if let cd = connectedDevice{
            cd.readStimStatus()
        }
    }
    
    func readEMGStatus(){
        if let cd = connectedDevice{
            cd.readEMGStatus()
        }
    }
    
    func readTherapySession(){
        if let cd = connectedDevice {
            cd.readTherapySession()
        }
    }
    
    func readDevice(){
        if let cd = connectedDevice {
            cd.readDevice()
        }
    }
    
    func setSchedule(schedule:TherapySchedules){
        if let cd = connectedDevice{
            cd.setSchedule(schedule: schedule)
        }
    }
    
    func setTherapyLength(lengthInSeconds:Int32){
        if let cd = connectedDevice{
            cd.setTherapyLength(lengthInSeconds: lengthInSeconds)
        }
    }
    
    func setPulseWidthAtComfort(pulseWidth:Int32){
        if let cd = connectedDevice{
            cd.setPulseWidthAtComfort(pulseWidth: pulseWidth)
        }
    }
    
    func setPulseWidthAtEMG(pulseWidth:Int32){
        if let cd = connectedDevice{
            cd.setPulseWidthAtEMG(pulseWidth: pulseWidth)
        }
    }
    
    func setFoot(foot:Feet){
        if let cd = connectedDevice{
            cd.setFoot(foot: foot)
        }
    }
    
    func setSkinSensation(pulseWidth: Int32){
        if let cd = connectedDevice{
            cd.setSkinSensation(pulseWidth: pulseWidth)
        }
    }
    
    func setTargetEMG(targetEMG: Int32){
        if let cd = connectedDevice{
            cd.setTargetEMG(targetEMG: targetEMG)
        }
    }
    
    func setEMGMax(emgStrength: Int32){
        if let cd = connectedDevice{
            cd.setEMGStrengthMax(emgStrengthMax: emgStrength)
        }
    }
    
    func setTemporaryPainThreshold(tempThreshold: Int32){
        if let cd = connectedDevice{
            cd.setTemporaryPainThreshold(tempThreshold: tempThreshold)
        }
    }
    
    func setCurrentTick(tick: Int32){
        if let cd = connectedDevice{
            cd.setCurrentTick(tick: tick)
        }
    }
    
    func setDailyTherapyTime(dailyTime: Int32){
        if let cd = connectedDevice{
            cd.setDailyTherapyTime(dailyTime: dailyTime)
        }
    }
    
    func setLastCompletedTime(lastTime: Int32){
        if let cd = connectedDevice{
            cd.setLastCompletedTime(lastTime: lastTime)
        }
    }
    
    func setReadyToSend(value: UInt8){
        if let cd = connectedDevice{
            cd.setReadyToSend(value: value)
        }
    }
    
    func readTargetEMG(){
        if let cd = connectedDevice{
            cd.readTargetEMG()
        }
    }
    
    func readDeviceEvent(){
        if let cd = connectedDevice{
            cd.readDeviceEvent()
        }
    }
    
    func rebootRequest(){
        if let cd = connectedDevice{
            cd.rebootRequest()
        }
        
        OTAManager.sharedInstance.state = .requestingReboot
    }
    
    func handleOTA(){
        if let cd = connectedDevice{
            let _isRecovery = OTAManager.sharedInstance.recovery
            cd.handleOTA(isRecovery: _isRecovery)
        }
    }
    
    func updateScreeningCriteria(){
        let patientEvalCrit = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
        let leftCrit = patientEvalCrit?.left
        let rightCrit = patientEvalCrit?.right
        
        if(leftCrit != nil && rightCrit != nil){
            setEvaluationCriteria(criteria: leftCrit!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                self.setEvaluationCriteria(criteria: rightCrit!)
            }
        }
        else if leftCrit != nil{
            setEvaluationCriteria(criteria: leftCrit!)
        }
        else if rightCrit != nil{
            setEvaluationCriteria(criteria: rightCrit!)
        }
    }
    
    func updateScreeningCriteria(foot: Feet){
        let patientEvalCrit = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
        if foot == .left{
            if let leftCrit = patientEvalCrit?.left{
                setEvaluationCriteria(criteria: leftCrit)
            }
        }
        else if foot == .right{
            if let rightCrit = patientEvalCrit?.right{
                setEvaluationCriteria(criteria: rightCrit)
            }
        }
    }
    
    func setEvaluationCriteria(criteria: EvaluationCriteria){
        setSchedule(schedule: TherapySchedules(rawValue: (criteria.therapySchedule)) )
        //setTherapyLength(lengthInSeconds: Int32(120))                       //for testing short therapies
        setTherapyLength(lengthInSeconds: Int32(criteria.therapyLength))
        setSkinSensation(pulseWidth: Int32(criteria.skinParesthesiaPulseWidth))
        setPulseWidthAtComfort(pulseWidth: Int32(criteria.comfortLevelPulseWidth))
        setPulseWidthAtEMG(pulseWidth: Int32(criteria.emgDetectionPointPulseWidth))
        let foot = Feet(rawValue: Int32(criteria.foot))
        setFoot(foot: foot!)
        setTargetEMG(targetEMG: Int32(criteria.targetEMGStrength))
        setEMGMax(emgStrength: Int32(criteria.emgStrengthMax))
        setTemporaryPainThreshold(tempThreshold: Int32(criteria.tempPainThreshold))
        setCurrentTick(tick: Int32(criteria.currentTick))
        setDailyTherapyTime(dailyTime: Int32(criteria.dailyTherapyTime))
        setLastCompletedTime(lastTime: Int32(criteria.lastCompletedTime))
        
        Slim.log(level: LogLevel.info, category: [.appEvents], "Data: \(criteria), sent to the controller")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            self.setReadyToSend(value: 1)
        }
    }
    
    func resetScreeningInfo(){
        setSkinSensation(pulseWidth: 0)
        setPulseWidthAtComfort(pulseWidth: 0)
        setPulseWidthAtEMG(pulseWidth: 0)
        
        setTargetEMG(targetEMG: 0)
        setEMGMax(emgStrength: 0)
        setTemporaryPainThreshold(tempThreshold: 0)
        
        BluetoothManager.sharedInstance.informationServiceData.stimStatus = StimulationStatus()
    }
    
    func handleDeviceEvent(event: DeviceEvent){
        
        
    }
}

extension BluetoothManager:  CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            print("Did Update State: Powered On")
            if !OTAManager.sharedInstance.otaIgnoreBLEChanges{
                bleON = true
                delegate?.didBLEChange(on: true)
                navDelegate?.bleChange(on: true)
            }
            if connectedPeripheral != nil && connectedDevice != nil{  //for already connected dev when openning app
                connectedDevice?.discoverServices()
                break
            }
            
            startScanning()
            if connectingPeripheral != nil {
                self.connectToDevice(peripheral: connectingPeripheral!)
            }
            
            break
        case .unknown:
            print("Did Update State: Unknown")
            break
        case .resetting:
            print("Did Update State: Resetting")
            break
        case .unsupported:
            print("Did Update State: Unsupported")
            break
        case .unauthorized:
            print("Did Update State: Unauthorized")
            break
        case .poweredOff:
            print("Did Update State: Powered Off")
            if !OTAManager.sharedInstance.otaIgnoreBLEChanges{
            bleON = false
            dicoveredDevices = [:]
            delegate?.didBLEChange(on: true)
            navDelegate?.bleChange(on: false)
            
                navDelegate?.deviceConnection(connection: false)
                toastDelegate?.deviceConnection(connection: false)
            }
                
            let oldConnectedPeri = connectedPeripheral
            if connectedDevice != nil{
                connectedDevice?.disconnectFromDevice()
                connectedDevice = nil
                connectedPeripheral = nil
            }
            if oldConnectedPeri != nil{
            delegate?.didDisconnectFromDevice(device: oldConnectedPeri!)
            }
            
            //
            break
        @unknown default:
            print("Uknown state change")
        }
    }
    
    func getState(_ state: CBPeripheralState) -> String {
        if state == .connected {
            return "connected"
        }
        if state == .connecting {
            return "connecting"
        }
        if state == .disconnected {
            return "disconnected"
        }
        if state == .disconnecting {
            return "disconnecting"
        }
        return ""
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        Slim.info("View Will Restore State Called")
        
        if let peripheralsObject = dict[CBCentralManagerRestoredStatePeripheralsKey] {
            let peripherals = peripheralsObject as! Array<CBPeripheral>
            if peripherals.count > 0 {
                Slim.info("Peripheral found.  Count is =  \(peripherals.count)")
                
                let peripheral = peripherals[0]
                
                //Slim.info("Peripheral state - \(getState(peripheral.state))")
                if getState(peripheral.state) == "connected" {
                    // At this point we need to check to see if we are in the window and should start a sync process
                    print("Did connect to device after restore state")
                    
                    // set peripheral to connected peripheral
                    connectedPeripheral = peripheral
                    
                    // Find the device that was connected in
                    connectedDevice = BluetoothDevice(withPeripheral: peripheral, andDelegate: self)
                    connectedDevice?.discoverServices()
                }
                else if getState(peripheral.state) == "connecting"{
                    // hold onto the connecting peripheral
                    print("connecting to device")
                    connectingPeripheral = peripheral
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = advertisementData["kCBAdvDataLocalName"] as! String? {
            //print( "Found \(name)")
            
            if OTAManager.sharedInstance.OTAMode{
                if !(name.contains("AT_OTA") || name.contains("Vivally_OTA") || name.contains("Viva_OTA")){
                    return
                }
                print("Discovered AT_OTA Device")
            }
            else{
                if !(name.contains("AT") || name.contains("Vivally")){
                    return
                }
                if name == "AT_OTA" || name == "Vivally_OTA" || name == "Viva_OTA"{
                    return
                }
                print("Discovered AT Device")
            }
            
            print( "Found \(name)")
            
            var mac = "unknown"
            if let mfgData = advertisementData["kCBAdvDataManufacturerData"] as? Data{
                if mfgData.count >= 12{
                    print("ManufacturerData \(mfgData.subdata(in: 6..<12).hexEncodedMACString())")
                    mac = mfgData.subdata(in: 6..<12).hexEncodedMACString()
                }
                else{
                    return
                }
            }
            
            let device = DiscoveredDevice(name: name, mac: mac, peripheral: peripheral)
            dicoveredDevices[peripheral.identifier.uuidString] = device
            delegate?.didDiscoverDevice(discoveredDevice: device)
            
            //attemptConnectToDeviceByDiscoveredDevice(ddevice: device)
            if mac == deviceMACAttemptingToConnect && deviceMACAttemptingToConnect != ""{
                print("calling attemptConnectToDeviceByMAC \(device.mac)")
                attemptConnectToDeviceByDiscoveredDevice(ddevice: device)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Did connect to device")
        Slim.log(level: LogLevel.info, category: [.pairing], "Did connect to peripheral: \(peripheral)")

        // set peripheral to connected peripheral
        connectedPeripheral = peripheral
        
        // Find the device that was connected in
        connectedDevice = BluetoothDevice(withPeripheral: peripheral, andDelegate: self)
        connectedDevice?.discoverServices()
        
        /*
        print("before did Connect to Device in didConnect")
        delegate?.didConnectToDevice(device: peripheral)
        navDelegate?.deviceConnection(connection: true)
        toastDelegate?.deviceConnection(connection: true)
        */
        
        if OTAManager.sharedInstance.OTAMode{
            delegate?.didConnectToDevice(device: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // if disconnecting through unpair or bluetooth settings, clear data
        if error == nil {
            clearPairing()
        }
        
        print("Did Disconnect Peripheral")
        Slim.log(level: LogLevel.info, category: [.pairing], "Did disconnect peripheral: \(peripheral)")
        
        // clean up data
        if connectedDevice != nil{
            connectedDevice?.disconnectFromDevice()
            connectedDevice = nil
            connectedPeripheral = nil
        }
        
        
        
        delegate?.didDisconnectFromDevice(device: peripheral)
        
        if !OTAManager.sharedInstance.otaIgnoreBLEChanges && !BluetoothManager.sharedInstance.firstRead{
            navDelegate?.deviceConnection(connection: false)
            toastDelegate?.deviceConnection(connection: false)
        }
        else if BluetoothManager.sharedInstance.firstRead{
            BluetoothManager.sharedInstance.firstRead = false
        }
        self.restartScanning()
        
        if BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired(){
            //call reconnect
            connectToDevice(peripheral: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Did fail to connect")
        print(error)
        Slim.log(level: LogLevel.warning, category: [.pairing], "Did fail to connect to peripheral: \(peripheral)")
        
        //instead of rescanning maybe tell user to disconnect from device
        //this error has come up if bonding was setup but then was removed but not anymore
        
        self.restartScanning()
    }
}

extension BluetoothManager:BluetoothDeviceDelegate{
    func deviceDidUpdate(informationServiceData: InformationServiceData, patientServiceData: PatientServiceData) {
        self.patientServiceData = patientServiceData
        self.informationServiceData = informationServiceData
        delegate?.didUpdateDevice()
    }
    
    func deviceTherapySessionDidUpdate(informationServiceData: InformationServiceData, patientServiceData: PatientServiceData) {
        self.patientServiceData = patientServiceData
        self.informationServiceData = informationServiceData
        delegate?.didUpdateTherapySession()
    }
    
    func deviceGeneralDataDidUpdate(informationServiceData: InformationServiceData, patientServiceData: PatientServiceData) {
        self.patientServiceData = patientServiceData
        self.informationServiceData = informationServiceData
        delegate?.didUpdateData()
    }
    
    func deviceStimDataDidUpdate(informationServiceData: InformationServiceData, patientServiceData: PatientServiceData){
        self.patientServiceData = patientServiceData
        self.informationServiceData = informationServiceData
        delegate?.didUpdateStimStatus()
    }
    
    func deviceEMGDataDidUpdate(informationServiceData: InformationServiceData, patientServiceData: PatientServiceData){
        self.patientServiceData = patientServiceData
        self.informationServiceData = informationServiceData
        delegate?.didUpdateEMG()
    }
    
    func deviceBatteryDidUpdate(informationServiceData: InformationServiceData, patientServiceData: PatientServiceData){
        self.patientServiceData = patientServiceData
        self.informationServiceData = informationServiceData
        delegate?.didUpdateBattery()
    }
    
    //doesn't get called anymore, now wait for bond success first
    func bluetoothDeviceDidConnect(device:CBPeripheral) {
        print("before didConnect in bleDeviceDidConnect")
        delegate?.didConnectToDevice(device: device)
        navDelegate?.deviceConnection(connection: true)
        toastDelegate?.deviceConnection(connection: true)
    }
    
    func bondFail() {
        delegate?.didBondFail()
    }
    
    func pairingTimeExpired() {
        delegate?.pairingTimeExpired()
    }
    
    func bondSuccess(device: CBPeripheral) {
        sendCommand(command: .bondedAck, parameters: [])
        delegate?.didConnectToDevice(device: device)
        if !OTAManager.sharedInstance.otaIgnoreBLEChanges{
            KeychainManager.sharedInstance.loadAccountData()
            if KeychainManager.sharedInstance.accountData?.userModel?.roles?.contains("Patient") == true{
                TherapyManager.sharedInstance.checkIfTherapyInProgress()
            }
            navDelegate?.deviceConnection(connection: true)
            toastDelegate?.deviceConnection(connection: true)
        }
    }
    
    func deviceError() {
        errorDelegate?.deviceError()
    }
   
}
