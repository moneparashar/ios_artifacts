//
//  DeviceStatusTabletViewController.swift
//  vivally
//
//  Created by Ryan Levels on 2/14/23.
//

import UIKit
import CoreBluetooth

enum DeviceStatusState{
    case connected
    case notPaired
    case notConnected
    case otaOnConnected
}

class DeviceStatusTabletViewController: BaseNavViewController {

    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkAppStoreLinkView: UIView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var youMustPairControllerView: UIView!
    @IBOutlet weak var bleBanner: BannerView!
    
    @IBOutlet weak var recoverTherapy: ActionButton!
    @IBOutlet weak var recoverButton: UIButton!
    @IBOutlet weak var updatebutton: ActionButton!
    @IBOutlet weak var pairingButton: ActionButton!
    
    @IBOutlet weak var contentWidthConstant: NSLayoutConstraint!
    
    let connectCell = "connectCell"
    
    // tableView rows
    var tableRows:[DeviceStatusType] = [.connectivityStatus, .battery, .serNum, .firmwareVers, .bootloaderVers, .firmwareUpd]
    
    var connectionState:DeviceStatusState = .notPaired
    
    var observersSet = false
    
    var finishUpdate = false
    var dataUpdated = false
    
    var allowBannerRedirect = false

    override func viewDidLoad() {
        super.goBackEnabled = true
        super.statusPage = true
        super.showBleToast = false
        super.viewDidLoad()
        
       
        contentWidthConstant.constant = view.getWidthConstant()
        // Do any additional setup after loading the view.
        
        bleBanner.setup(title: "Bluetooth is off", sub: "Please turn ON Bluetooth")
        bleBanner.delegate = self
        
        initTableView()
        getState()
        setupView()
        
        tableContainerView.layer.cornerRadius = 15
        tableContainerView.layer.borderWidth = 1
        tableContainerView.layer.borderColor = UIColor.lavendarMist?.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "System Status"
        
        if TherapyManager.sharedInstance.therapyRunning{
            TherapyManager.sharedInstance.delegate = self
        }
        else if ScreeningProcessManager.sharedInstance.screeningRunning{
            ScreeningProcessManager.sharedInstance.delegate = self
        }
        else{
            BluetoothManager.sharedInstance.delegate = self
        }
        
        if !observersSet{
            addObservers()
        }
        
        getState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent{
            dismissObservers()
        }
        title = ""
    }
    
    override func viewWillLayoutSubviews() {
        self.tableViewHeight.constant = self.tableView.contentSize.height
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFinished(notif:)), name: NSNotification.Name(NotificationNames.finishUpdate.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAvailable(notif:)), name: NSNotification.Name(NotificationNames.updateAvailable.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideRecover), name: NSNotification.Name(NotificationNames.finishTherapyRecovery.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideRecover), name: NSNotification.Name(NotificationNames.interuptDataRecovery.rawValue), object: nil)
        observersSet = true
    }
    
    func dismissObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.finishUpdate.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.updateAvailable.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.finishTherapyRecovery.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.interuptDataRecovery.rawValue), object: nil)
        observersSet = false
    }
    
    @objc func hideRecover(){
        recoverTherapy.isHidden = true
        getState()
    }
    
    @objc func updateFinished(notif:Notification){
        OTAManager.sharedInstance.clearOTAData()
        NotificationManager.sharedInstance.removeOTAUpdateNotifications()
        finishUpdate = true
        getState()
        finishUpdate = false
    }
    
    @objc func updateAvailable(notif:Notification){
        getState()
    }
    
    @IBAction func tappedAppLink(_ sender: UIButton) {
        guard let settingsUrl = URL(string: "https://testflight.apple.com/a") else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Testflight opened: \(success)") // Prints true
            })
        }
    }
    
    @IBAction func pairingButtonTapped(_ sender: ActionButton) {
        let storyboard = UIStoryboard(name: "patientDevicePairing", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DevicePairingTabletViewController") as! DevicePairingTabletViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func initTableView() {
        tableView.register(DeviceStatusTableViewCell.self, forCellReuseIdentifier: connectCell)
        tableView.delegate = self
        tableView.dataSource = self
        if !BluetoothManager.sharedInstance.isBleAvailable() {
            tableContainerView.isHidden = true;
            pairingButton.isHidden = true;
        }else{
            tableContainerView.isHidden = false;
            pairingButton.isHidden = false;
        }
    }
    
    private func getState(){
        let oldState = connectionState
        let connected = BluetoothManager.sharedInstance.isConnectedToDevice()
        let paired = BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired()
        youMustPairControllerView.isHidden = paired
        
        let otaOn = OTAManager.sharedInstance.OTAMode
        
        if otaOn && connected{
            connectionState = .otaOnConnected
        }
        else if connected{
            connectionState = .connected
        }
        else if otaOn{
            connectionState = .notConnected
        }
        else{
            connectionState = paired ? .notConnected : .notPaired
        }
        
        if oldState != connectionState || finishUpdate || dataUpdated{
            dataUpdated = false
            setupView()
            tableView.reloadData(){
                self.tableViewHeight.constant = self.tableView.contentSize.height
            }
        }
        else if oldState == .connected{
            //just reload battery
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        }
    }
    
    func setupView(){
        recoverTherapy.isHidden = true
        recoverButton.isHidden = true
        updatebutton.isHidden = true
        
        if connectionState == .otaOnConnected{
            #if STAGING
            recoverButton.isHidden = false
            #endif
        }
        else if connectionState == .connected{
            if DataRecoveryManager.sharedInstance.recoveryAvailable && !TherapyManager.sharedInstance.therapyRunning{
                recoverTherapy.isHidden = false
            }
            else if OTAManager.sharedInstance.updateAvailable && !TherapyManager.sharedInstance.therapyRunning && !ScreeningProcessManager.sharedInstance.screeningRunning{
                updatebutton.isHidden = false
            }
        }
        
        if BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired(){
            pairingButton.toSecondary()
        }
        
        //topStackHideAllBut(cState: connectionState)
        switch connectionState {
        case .connected:
            // blue app?
            // YES: show bootloader vers.
            #if STAGING
            checkAppStoreLinkView.isHidden = false
            tableRows = [.connectivityStatus, .battery, .serNum, .firmwareVers, .bootloaderVers, .firmwareUpd, .appVers]
            
            // NO: don't show bootloader vers.
            #elseif PRODUCTION
            checkAppStoreLinkView.isHidden = true
            tableRows = [.connectivityStatus, .battery, .serNum, .firmwareVers, .firmwareUpd, .appVers]
            #endif
        
        case .notPaired, .notConnected, .otaOnConnected:
            tableRows = [.connectivityStatus,.appVers]
        }
        
        if BluetoothManager.sharedInstance.isBleAvailable(){
            allowBannerRedirect = false
            bleBanner.isHidden = true
            pairingButton.isHidden = false;
            tableView.isHidden = false
            tableContainerView.isHidden = false
            tableView.reloadData(){
                self.tableViewHeight.constant = self.tableView.contentSize.height
            }
            
            let isControllerConnected = BluetoothManager.sharedInstance.isConnectedToDevice()
            let controllerBattery = Float(BluetoothManager.sharedInstance.informationServiceData.batteryStateOfCharge.level)
            let phoneBattery = Float(bleBanner.getBatteryPercentage() ?? 0)
            
            if phoneBattery < 30{
                bleBanner.setupForStatus(title: "", sub:"Mobile device battery level \(String(describing: phoneBattery))%:\nBattery is insufficient for installing updates",info: false)
                bleBanner.isHidden = false
            }
            else if controllerBattery < 30 && isControllerConnected{
                bleBanner.setupForStatus(title: "", sub:"Controller battery level less than 30%: Battery is insufficient for installing updates or performing therapy",info: false)
                bleBanner.isHidden = false
            }
            else if controllerBattery < 50 && isControllerConnected{
                bleBanner.setupForStatus(title: "", sub:"Controller battery level less than 50%: Battery is insufficient for therapy",info: false)
                bleBanner.isHidden = false
            }
        }
        else {
            tableContainerView.isHidden = true
            tableView.isHidden = true
            pairingButton.isHidden = true;
            tableView.reloadData(){
                self.tableViewHeight.constant = 0
            }
            
            bleBanner.setup(title: "Bluetooth is off", sub: "Please turn ON Bluetooth")
            bleBanner.isHidden = false
            allowBannerRedirect = true
        }
        
    }
    
    @IBAction func recoverTherapyTapped(_ sender: UIButton) {
        let vc = DataRecoveryPopupViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    @IBAction func recoverFirmwareTapped(_ sender: UIButton) {
        let vc = RecoverFirmwarePopupViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    @IBAction func updateTapped(_ sender: UIButton) {
        let vc = FirmwareUpdatePopupViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    
    /*
    // when want to test recovery mode, send reboot but stop app
    func testReboot(){
        if !OTAManager.sharedInstance.OTAMode {
            BluetoothManager.sharedInstance.rebootRequest()
            exit(0)
        }
    }
    */
}

extension DeviceStatusTabletViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableRows[indexPath.row] == .connectivityStatus {
            let cell = tableView.dequeueReusableCell(withIdentifier: connectCell, for: indexPath) as! DeviceStatusTableViewCell
            
            let connected = BluetoothManager.sharedInstance.isConnectedToDevice()
            let paired = BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired()
            let otaOn = OTAManager.sharedInstance.OTAMode
            
            let bat = BluetoothManager.sharedInstance.informationServiceData.batteryStateOfCharge.level
            
            cell.setupView(batteryVal: bat, notPaired: !paired, connected: connected, otaConnected: otaOn)
            
            return cell
            
        
        } else if tableRows[indexPath.row] == .battery {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            let battery = BluetoothManager.sharedInstance.informationServiceData.batteryStateOfCharge.level
            let batteryStr = String(battery) + "%"
            cell.setupView(rowName: "Battery", info: batteryStr)
            
            return cell
            
        } else if tableRows[indexPath.row] == .serNum {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            let serial = BluetoothManager.sharedInstance.informationServiceData.serialNumber.serialNum
            let serialStr = String(format: "%06d", serial)
            cell.setupView(rowName: "Controller Serial #", info: serialStr)
            
            return cell
            
        } else if tableRows[indexPath.row] == .firmwareVers {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            let firm = BluetoothManager.sharedInstance.informationServiceData.revision.rev
            cell.setupView(rowName: "Controller Firmware version", info: firm)
            
            return cell
            
        }
        else if tableRows[indexPath.row] == .bootloaderVers{
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            let bootVersion = BluetoothManager.sharedInstance.informationServiceData.revision.bootRev
            cell.setupView(rowName: "Controller Bootloader version", info: bootVersion)
            return cell
        }
        else if tableRows[indexPath.row] == .firmwareUpd {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            let newFirmware = OTAManager.sharedInstance.ota?.firmwareVersion ?? ""
            let firmwareMessage = OTAManager.sharedInstance.updateAvailable ? "New version available \(newFirmware)" : "Up to date"
            cell.setupView(rowName: "Firmware update", info: firmwareMessage)
            
            return cell
        }
        else if tableRows[indexPath.row] == .appVers{
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            let appVersion = (UIApplication.appVersion ?? "") + "." + (UIApplication.build ?? "")
            cell.setupView(rowName: "App version", info: appVersion)
            
            return cell
        }
        
        return UITableViewCell()
    }
}

extension DeviceStatusTabletViewController: BluetoothManagerDelegate{
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {}
    
    func didConnectToDevice(device: CBPeripheral) {
        getState()
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        getState()
    }
    
    func didBLEChange(on: Bool) {
        getState()
    }
    
    func didUpdateData() {
        dataUpdated = true
        getState()
    }
    
    func didUpdateStimStatus() {}
    
    func didUpdateEMG() {}
    func didUpdateBattery(){
        getState()
    }
    func didUpdateTherapySession() {}
    
    func didBondFail() {}
    
    func didUpdateDevice() {
        getState()
    }
    
    func foundOngoingTherapy() {}
    func pairingTimeExpired() {}
}

extension DeviceStatusTabletViewController: TherapyManagerDelegate{
    func therapyFinished(state: therapyFinishStates) {
        BluetoothManager.sharedInstance.delegate = self
        getState()
    }
    
    func updateBLEData() {
        getState()
    }
    
    func didConnectToBLEDevice(device: CBPeripheral) {
        getState()
    }
    
    func didDisconnectFromBLEDevice(device: CBPeripheral) {
        getState()
    }
    
    func pauseLimitReached() {}
    
    func didUpdateStatus() {}
    
    func didUpdateDev() {
        getState()
    }
    func didUpdateTherapyBattery(){
        getState()
    }
    func pauseAboutToExpire() {}
    func pauseExpired() {}
}

extension DeviceStatusTabletViewController: ScreeningProcessManagerDelegate{
    func rampChange() {}
    
    func emgDetected() {}
    
    func metCriteria(pass: Bool) {}
    
    func evalErrorUpload(message: String) {}
    
    func updateStimStatus() {}
    func updateScreeningBattery(){
        getState()
    }
}
extension DeviceStatusTabletViewController: BannerViewDelegate{
    func tappedBanner(bannerType: BannerView){
        if allowBannerRedirect{
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
}
