//
//  DevicePairingTabletViewController.swift
//  vivally
//
//  Created by Ryan Levels on 2/13/23.
//

import UIKit
import CoreBluetooth

enum DevicePairingStateViews{
    case noPair
    case pair
}

class DevicePairingTabletViewController: BaseNavViewController {
    
    @IBOutlet weak var pairingVivallyStack: UIStackView!
    
    @IBOutlet weak var headerVivallyStack: UIStackView!
    @IBOutlet weak var pairVivallyAppLabel: UILabel!
    @IBOutlet weak var informationButton: UIButton!
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // notification stack
    @IBOutlet weak var notificationStack: UIStackView!
    @IBOutlet weak var bleOffBanner: BannerView!
    @IBOutlet weak var recoveryModeBanner: BannerView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    
    private let refreshControl = UIRefreshControl()
    var discoveredDev:[DiscoveredDevice] = []
    
    let pairCell = "PairCell"
    let discoverCell = "DiscoverCell"
    
    var firstPair = false
    var deviceToPair:DiscoveredDevice? = nil
    var pairingExpiredTimer = Timer()

    override func viewDidLoad() {
        super.showOnlyRightLogo = true
        super.showBleToast = false
        super.viewDidLoad()

        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        stackWidth.constant = view.getWidthConstant()
        title = "Pairing"
        if TherapyManager.sharedInstance.therapyRunning || ScreeningProcessManager.sharedInstance.screeningRunning{
            TherapyManager.sharedInstance.delegate = self
        }
        else{
            BluetoothManager.sharedInstance.delegate = self
        }
        
        recoveryModeBanner.delegate = self
        setupView()
        createBanners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !TherapyManager.sharedInstance.therapyRunning && !ScreeningProcessManager.sharedInstance.screeningRunning{
            BluetoothManager.sharedInstance.restartScanning()
        }
        updateView()
        self.refreshControl.endRefreshing()
        addObserver() // view did disappear called when watching video which removes all observers
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        invalidatePairingTimer()
        self.removeObservers()
    }
    
    func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshDevices(_:)), name: NSNotification.Name(NotificationNames.unpair.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.pairController(_:)), name: NSNotification.Name(NotificationNames.pair.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToHome(_:)), name: NSNotification.Name(NotificationNames.firstPair.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.tryAgainTapped(_:)), name: NSNotification.Name(NotificationNames.tryAgainTapped.rawValue), object: nil)
    }
                                               
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func goToHome(_ sender: Any){
        //self.navigationController?.popToRootViewController(animated: true)
        
        if let navVc = navigationController?.viewControllers{
            var popTwice = false
            let count = navVc.count
            if count >= 2{
                if let prevVc = navigationController?.viewControllers[count - 2]{
                    if prevVc.isKind(of: DeviceStatusTabletViewController.self){
                        popTwice = true
                    }
                }
            }
            if popTwice{
                let vcToPopTo = navVc[count - 3]
                navigationController?.popToViewController(vcToPopTo, animated: true)
            }
            else {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if(keyPath == "contentSize"){
             if let newvalue = change?[.newKey]
             {
                 DispatchQueue.main.async {
                 let newsize  = newvalue as! CGSize
                 self.tableViewHeight.constant = newsize.height
                 }

             }
         }
     }
    
    @IBAction func informationButtonTapped(_ sender: UIButton) {
        HelpManager.sharedInstance.playSectionVideo(vc: self, helpInfo: .pair)
    }
    
    func createBanners(){
        bleOffBanner.isHidden = true
        recoveryModeBanner.isHidden = true
        
        bleOffBanner.setup(title: "Bluetooth is OFF", sub: "Please turn ON your mobile device Bluetooth")
        recoveryModeBanner.setup(title: "Controller recovery mode", sub: "Since Enable Controller Recovery Mode option in the app's setting is ON, only Vivally Controllers in OTA mode are currently displayed. Tap here to go to the settings page")
    }
    
    func setupView() {
        tableView.register(PairedDevTableViewCell.self, forCellReuseIdentifier: pairCell)
        tableView.register(DiscoveredUnpairedDeviceTableViewCell.self, forCellReuseIdentifier: discoverCell)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshDevices(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Devices ...", attributes: nil)
    }
    
    func setupNotificationStack(){
        bleOffBanner.isHidden =  BluetoothManager.sharedInstance.isBleAvailable()
        recoveryModeBanner.isHidden = (!BluetoothManager.sharedInstance.isBleAvailable()) || (!OTAManager.sharedInstance.OTAMode)
        notificationStack.isHidden = bleOffBanner.isHidden && recoveryModeBanner.isHidden
    }
    
    func updateView(){
        discoveredDev = BluetoothManager.sharedInstance.dicoveredDevices.values.map({$0})
        let isPaired = BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired()
        let isConnected = BluetoothManager.sharedInstance.isConnectedToDevice()
        let bleOn = BluetoothManager.sharedInstance.bleON
        
        if isPaired{
            discoveredDev.removeAll(where: {$0.mac == BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac})
        }
        if isConnected{
            discoveredDev = []
        }
        
        pairVivallyAppLabel.text = isPaired ? "Vivally App and Controller are paired" : "Pair the Vivally App and Controller"
        // instructionLabel.isHidden = isPaired
        
        tableView.isHidden = !bleOn
        tableView.reloadData {}
        setupNotificationStack()
    }
    
    func startPairingTimer() {
        pairingExpiredTimer = Timer.scheduledTimer(timeInterval: 28, target: self, selector: #selector(didNotPairInTime), userInfo: nil, repeats: false)
    }
    
    func invalidatePairingTimer() {
        pairingExpiredTimer.invalidate()
        DeviceErrorManager.sharedInstance.didNotPairInTime = false
    }
    
    @objc func didNotPairInTime() {
        DeviceErrorManager.sharedInstance.didNotPairInTime = true
    }
    
    @objc func refreshDevices(_ sender: Any){
        BluetoothManager.sharedInstance .restartScanning()
        updateView()
        refreshControl.endRefreshing()
    }
                                               
    @objc func pairController(_ sender: Any) {
        pair(device: deviceToPair!)
    }
    
    @objc func tryAgainTapped(_ sender: Any) {
        tappedPair(device: deviceToPair!)
    }
}

extension DevicePairingTabletViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        if OTAManager.sharedInstance.OTAMode{
            if BluetoothManager.sharedInstance.isConnectedToDevice(){
                return 1
            }
        }
        else if BluetoothManager.sharedInstance.isConnectedToDevice() || BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired(){
            return discoveredDev.count + 1
        }
        
        return discoveredDev.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.0
        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var connected = false
        var paired = false
        var otaON = false
        
        connected = BluetoothManager.sharedInstance.isConnectedToDevice()
        paired = BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired()
        otaON = OTAManager.sharedInstance.OTAMode
        instructionLabel.text = connected ? "" :"Turn ON the Vivally Controller by pressing and releasing the power button"
        if otaON{
            if indexPath.section == 0 && (connected){
                let devInfo = BluetoothDeviceInfoManager.sharedInstance.deviceInfo
                let cell = tableView.dequeueReusableCell(withIdentifier: pairCell, for: indexPath) as! PairedDevTableViewCell
                cell.setup(dev: devInfo ,connected: connected)
                cell.delegate = self
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: discoverCell, for: indexPath) as! DiscoveredUnpairedDeviceTableViewCell
                let passDev = connected ? discoveredDev[indexPath.section - 1] : discoveredDev[indexPath.section]
                cell.setupView(device: passDev)
                cell.delegate = self
                return cell
            }
        }
        else{
            if indexPath.section == 0 && (connected || paired){
                let devInfo = BluetoothDeviceInfoManager.sharedInstance.deviceInfo
                let cell = tableView.dequeueReusableCell(withIdentifier: pairCell, for: indexPath) as! PairedDevTableViewCell
                cell.setup(dev: devInfo, connected: connected)
                cell.delegate = self
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: discoverCell, for: indexPath) as! DiscoveredUnpairedDeviceTableViewCell
                let passDev = (connected || paired) ? discoveredDev[indexPath.section - 1] : discoveredDev[indexPath.section]
                cell.setupView(device: passDev)
                cell.delegate = self
                return cell
            }
        }
    }
    
}

extension DevicePairingTabletViewController: PairedDevTableViewCellDelegate{
    func tappedUnpair() {
        //ask to remove pairing popup
        let vc = RemovePairingPopupViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    
}

extension DevicePairingTabletViewController: DiscoveredUnpairedDeviceTableViewCellDelegate{
    func tappedPair(device: DiscoveredDevice) {
        startPairingTimer()
        deviceToPair = device
        
        let newDeviceMac = BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac
           
        // pairing second controller?
        if newDeviceMac != "" {
            
            // YES: show verification popup
            if newDeviceMac != device.mac {
                let vc = ConfirmPairNewControllerPopupViewController()
                
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: false)
            }
            
        // NO: connect controller
        } else {
            pair(device: device)
        }

    }
    
    func pair(device: DiscoveredDevice) {
        if BluetoothManager.sharedInstance.firstRead == false {
            firstPair = true
            BluetoothManager.sharedInstance.firstRead = true
            BluetoothManager.sharedInstance.attemptConnectToDeviceByDiscoveredDevice(ddevice: device)
        }

    }
}

extension DevicePairingTabletViewController:BluetoothManagerDelegate{
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {
        updateView()
    }
    
    func didConnectToDevice(device: CBPeripheral) {
        updateView()
        if firstPair{
            firstPair = false
            let vc = PairSuccessfulPopupViewController()
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: false)
        }
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        updateView()
    }
    
    func didBLEChange(on: Bool) {
        updateView()
    }
    
    func didUpdateData() {}
    
    func didUpdateStimStatus(){}
    
    func didUpdateEMG() {}
    func didUpdateBattery(){}
    func didUpdateTherapySession() {}
    
    func didBondFail() {
        invalidatePairingTimer()
        let vc = PairingFailedViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func pairingTimeExpired() {
        invalidatePairingTimer()
        let vc = PairingTimeExpiredViewController()
        
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func didUpdateDevice() {}
    
    func foundOngoingTherapy() {}
}

extension DevicePairingTabletViewController: TherapyManagerDelegate{
    func pauseExpired() {}
    
    func therapyFinished(state: therapyFinishStates) {
        BluetoothManager.sharedInstance.delegate = self
    }
    
    func updateBLEData() {}
    
    func didConnectToBLEDevice(device: CBPeripheral) {
        updateView()
    }
    
    func didDisconnectFromBLEDevice(device: CBPeripheral) {
        BluetoothManager.sharedInstance.restartScanning()
        updateView()
    }
    
    func pauseLimitReached() {}
    
    func didUpdateStatus() {}
    
    func didUpdateDev() {}
    func didUpdateTherapyBattery(){}
    func pauseAboutToExpire() {}
}

extension DevicePairingTabletViewController: BannerViewDelegate{
    
    func tappedBanner(bannerType: BannerView) {
        if bannerType == recoveryModeBanner {
            let storyboard = UIStoryboard(name: "account", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}
