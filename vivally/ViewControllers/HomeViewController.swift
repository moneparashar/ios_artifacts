//
//  HomeViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 4/22/21.
//

import UIKit
import CoreBluetooth
import Alamofire
import Charts

class HomeViewController: BaseNavViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // for calculating screen size
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var updateAvailableBannerView: BannerView!
    @IBOutlet weak var diaryBannerView: BannerView!
    @IBOutlet weak var firmwareBannerView: BannerView!
    @IBOutlet weak var disconnectBannerView: BannerView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    
    var message: HomeViewControllerMessages = .none
    var tableRows:[HomeViewControllerCells] = [.devicePair, .therapy, .journal, .message]
    var hasEval = false
    var lastJournal = ""
    var lastTherapy = ""
    var hasAttemptedTherapy = false
    var completedTherapies = 1
    var scheduleTotal = 3    //need to calc these from session
    var headerHeight = CGFloat(0.0)
    
    var observerSet = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        title = "Vivally Home page"
        
        stackWidth.constant = view.getWidthConstant()
        
        let eval = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
        if (eval?.left != nil || eval?.right != nil) && eval?.isValid == true {
            if !EvaluationCriteriaManager.sharedInstance.checkEvalCritLastTimeOver(){
                hasEval = true
            }
            else if TherapyManager.sharedInstance.therapyRunning{
                hasEval = true
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.journalGoAddEntry(notif:)), name: NSNotification.Name("JournalEntryAddNotification"), object: nil)
        
        updateAvailableBannerView.isHidden = true
        updateAvailableBannerView.setup(title: "App update available", sub: "Tap here to open App store and update your app", info: true)
        diaryBannerView.setup(title: "3 Day Diary in Progress", sub: "Please document your activities in your diary as accurately as possible during your 3-Day Bladder Diary event.", info: true)
        firmwareBannerView.setup(title: "Firmware update available", sub: "Tap here to go to status page and update the Vivally Controller", info: true)
        disconnectBannerView.setup(title: "Controller not connected", sub: "Tap here to check Controller status")
        
        // delegates
        updateAvailableBannerView.delegate = self
        firmwareBannerView.delegate = self
        disconnectBannerView.delegate = self
        DatabaseManager.sharedInstance.delegate = self
        
        setupView()
        
        checkforDiary()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if TherapyManager.sharedInstance.therapyRunning {
            TherapyManager.sharedInstance.delegate = self
        }
        else{
            BluetoothManager.sharedInstance.delegate = self
        }
        
        //repository check
        checkLastJournal()
        checkIfTherapyAttempted()
        
        setCardDisplay()
        setupNavView()
        
        if !observerSet{
            addObservers()
            observerSet = true
        }
        
        setBannerDisplay()
        // if update is available, unhide update banner
        updateAvailableBannerView.isHidden = !AppUpdateManager.sharedInstance.updateAvailable
        
        getTherapyList() {
            self.tableView.reloadData(){
                self.tableViewHeight.constant = self.tableView.contentSize.height
            }
        }
    }
    
    func checkLastJournal(){
        do{
            let latestJournalDate = try JournalEventsDataHelper.getLatest(name: KeychainManager.sharedInstance.accountData!.username)
            if latestJournalDate != nil {
                let last = latestJournalDate!.eventTimestamp.treatTimestampStrAsDate() ?? Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yyyy"
                lastJournal = dateFormatter.string(from: last)
            }
        } catch{
            print("failure with get latest journal events")
        }
    }
    
    func checkIfTherapyAttempted(){
        do{
            hasAttemptedTherapy = try SessionDataDataHelper.hasAttemptedSession(name: KeychainManager.sharedInstance.accountData!.username)
        } catch{
            Slim.error("failure with checking for attempt session")
        }
    }
    
    func getDateStr(tStamp: Date, eventDate: Date, month: Bool = false) -> String{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd MMM yyyy"
    
        
        return dateFormat.string(from: eventDate)
    }
    
    func setCardDisplay(){
        tableRows = [.journal, .message]
        
        var validEval = false
        if hasEval{
            validEval = checkValidEval()
            if validEval{
                tableRows = (BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired() || hasAttemptedTherapy) ? [.therapy, .journal] : [.devicePair, .journal]
            }
        }
        
        if OTAManager.sharedInstance.OTAMode{
            tableRows = [.journal]
        }
    }
    
    func checkValidEval() -> Bool{
        if let studyID = KeychainManager.sharedInstance.accountData?.userModel?.studyId{
            if studyID <= 0{
                return false
            }
            //check if eval hasn't been retrieved in last 31 days
        }
        else{
            return false
        }
        
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent{
            dismissObservers()
        }
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.journalFocusNotify(notif:)), name: NSNotification.Name(NotificationNames.diaryEventConfirm.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.journalFocusRequest(notif:)), name: NSNotification.Name(NotificationNames.diaryRequest.rawValue), object: nil)
    }
    
    @objc func journalFocusRequest(notif: Notification){
        checkforDiary()
    }
    
    @objc func journalFocusNotify(notif:Notification){
        setBannerDisplay()
    }
    
    func dismissObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.diaryEventConfirm.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.diaryRequest.rawValue), object: nil)
        observerSet = false
    }
    
    func setupView(){
        tableView.reloadData(){
            self.tableViewHeight.constant = self.tableView.contentSize.height
        }
        
        setupNavView()
        setBannerDisplay()
    }
    
    func setupTable(){
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tableView.register(JournalHomeNewTableViewCell.self, forCellReuseIdentifier: "journalCell")
        tableView.register(TherapyHomeNewTableViewCell.self, forCellReuseIdentifier: "therapyCell")
        tableView.register(PairHomeTableViewCell.self.self, forCellReuseIdentifier: "pairNewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        tableView.clipsToBounds = false
    }

    func setBannerDisplay(){
        let focus = JournalEventFocusPeriodManager.sharedInstance.loadFocus()
        diaryBannerView.isHidden = !JournalEventFocusPeriodManager.sharedInstance.checkForFocus(focus: focus)
        
        firmwareBannerView.isHidden = !OTAManager.sharedInstance.updateAvailable
        
        let paired = BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired()
        let connected = BluetoothManager.sharedInstance.isConnectedToDevice()
        
        // start therapy row available?
        // YES: check if disconnect banner should be shown
        if tableRows.contains(.therapy){
            disconnectBannerView.isHidden = paired ? (connected) : false
            if !disconnectBannerView.isHidden{ // keep track of when disconnect banner is showing
                firmwareBannerView.isHidden = !disconnectBannerView.isHidden // if controller is disconnected don't show the firmware banner
            }
            
        // NO: don't show disconnect banner
        } else {
            disconnectBannerView.isHidden = true
        }
    }
    
    func checkforDiary(){
        _ = JournalEventFocusPeriodManager.sharedInstance.loadFocus()
        if JournalEventFocusPeriodManager.sharedInstance.askToBeginFocus(){
            let vc = DiaryDayPopupViewController()
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: false)
        }
    }
    
    func selectMessage() -> HomeViewControllerMessages{
        return .therapyWithPrescription
    }
    
    func goToJournal(home: Bool = true){
        let storyboard = UIStoryboard(name: "journalNew", bundle: nil)
        let vc = home ? storyboard.instantiateViewController(withIdentifier: "JournalHomeViewController") as! JournalHomeViewController : storyboard.instantiateViewController(withIdentifier: "JournalEntryMainViewController") as! JournalEntryMainViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func journalGoAddEntry(notif:Notification){
        JournalEventsManager.sharedInstance.comingFromHomeVc = true
        goToJournal(home: false)
    }
    
    func getTherapyList(completion:@escaping () -> ()){
        lastTherapy = ""
        do{
            let latestTherapyDate = try SessionDataDataHelper.getLatest(name: KeychainManager.sharedInstance.accountData!.username)
            if latestTherapyDate != nil {
                let last = latestTherapyDate!.eventTimestamp?.treatTimestampStrAsDate() ?? Date()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yyyy"
                lastTherapy = dateFormatter.string(from: last)
            }
            completion()
        } catch{
            print("failure with get latest therapy event")
            completion()
        }
    }
    
    func getSessionData() {
        getTherapyList() {
            self.tableView.reloadData(){
                self.tableViewHeight.constant = self.tableView.contentSize.height
            }
        }
    }
    
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableRows.count
    }
    
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //headerHeight = tableView.bounds.height * 0.012
        headerHeight = 24
        if section == 0{
            return 0.0
        }
        return headerHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableRows[indexPath.section] == .therapy{
            let cell = tableView.dequeueReusableCell(withIdentifier: "therapyCell", for: indexPath) as! TherapyHomeNewTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            
            let isConnected = BluetoothManager.sharedInstance.isConnectedToDevice()
            let isPaired = BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired()
            
            let running = TherapyManager.sharedInstance.therapyRunning
            let batteryLevel = BluetoothManager.sharedInstance.informationServiceData.batteryStateOfCharge.level
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.casperBlue?.cgColor
            
            cell.setupView(lastTherapy: lastTherapy, progressNum: completedTherapies, progressDenom: scheduleTotal, battery: batteryLevel, connected: isConnected, therapyRunning: running , paired: isPaired)
            cell.viewHistoryButton.isHidden = !hasAttemptedTherapy
        
            cell.layer.cornerRadius = 15
            
            return cell
        }
        
        else if tableRows[indexPath.section] == .journal{
            let cell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath) as! JournalHomeNewTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.setupView(lastJournal: lastJournal)
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.casperBlue?.cgColor
            cell.layer.cornerRadius = 15

            return cell
        }
        
        else if tableRows[indexPath.section] == .devicePair{
            let cell = tableView.dequeueReusableCell(withIdentifier: "pairNewCell", for: indexPath) as! PairHomeTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            //cell.setupView(lastSession: lastTherapy)
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.casperBlue?.cgColor
            cell.layer.cornerRadius = 15
            
            return cell
        }
        
        else if tableRows[indexPath.section] == .message{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageHomeTableViewCell
            cell.selectionStyle = .none
            cell.setupView(mes: selectMessage().rawValue)
            return cell
        }
        return UITableViewCell()
    }
}

extension HomeViewController: BluetoothManagerDelegate{
    func didUpdateDevice() {
        setupView()
    }
    
    func didUpdateData() {
        setupView()
    }
    
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {}
    
    func didConnectToDevice(device: CBPeripheral) {
        setupView()
        print("didConnect Called")
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        setupView()
    }
    func didBLEChange(on: Bool){}
    func didUpdateStimStatus(){}
    func didUpdateEMG() {}
    func didUpdateBattery(){}
    func didUpdateTherapySession(){}
    func didBondFail(){}
    func pairingTimeExpired() {}
    func foundOngoingTherapy(){
        TherapyManager.sharedInstance.delegate = self
        setupView()
    }
}

extension HomeViewController: TherapyManagerDelegate{
    func didUpdateDev() {}
    
    func therapyFinished(state: therapyFinishStates) {
        BluetoothManager.sharedInstance.delegate = self
    }
    
    func updateBLEData() {
        setupView()
    }
    
    func didConnectToBLEDevice(device: CBPeripheral) {
        setupView()
    }
    
    func didDisconnectFromBLEDevice(device: CBPeripheral) {
        setupView()
    }
    
    func pauseLimitReached() {}
    func didUpdateStatus() {}
    func didUpdateTherapyBattery(){}
    func pauseAboutToExpire() {}
    func pauseExpired() {}
}

//new cell delegates
extension HomeViewController: TherapyHomeNewTableViewCellDelegate{
    func tappedTherapyButton() {
        let therapyRun = TherapyManager.sharedInstance.therapyRunning
        let connected = BluetoothManager.sharedInstance.isConnectedToDevice()
        let isPaired = BluetoothDeviceInfoManager.sharedInstance.isDevicedPaired()
        
        if isPaired{
            let storyboard = UIStoryboard(name: "therapyNew", bundle: nil)
            let vc = (therapyRun && connected) ? storyboard.instantiateViewController(withIdentifier: "TherapyViewController") as! TherapyViewController : storyboard.instantiateViewController(withIdentifier: "TherapyPrepViewController") as! TherapyPrepViewController
            navigationController?.pushViewController(vc, animated: true)
        }
        else{
            let storyboard = UIStoryboard(name: "patientDevicePairing", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DevicePairingTabletViewController") as! DevicePairingTabletViewController
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tappedViewHistoryButton() {
        let storyboard = UIStoryboard(name: "therapyNew", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TherapyHistoryWeekViewController") as! TherapyHistoryWeekViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: JournalHomeNewTableViewCellDelegate{
    func tappedEvent() {
        let vc = DayNewPickViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.enterViaHome = true
        self.present(vc, animated: false)
    }
    
    func tappedViewDiaryButton() {
        JournalEventsManager.sharedInstance.comingFromHomeVc = false
        goToJournal()
    }
}

extension HomeViewController:PairHomeTableViewCellDelegate{
    func tappedPair() {
        let storyboard = UIStoryboard(name: "patientDevicePairing", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DevicePairingTabletViewController") as! DevicePairingTabletViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: BannerViewDelegate{
    func tappedBanner(bannerType: BannerView) {
        if bannerType == firmwareBannerView || bannerType == disconnectBannerView {
            let storyboard = UIStoryboard(name: "patientDevicePairing", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "DeviceStatusTabletViewController") as! DeviceStatusTabletViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else if bannerType == updateAvailableBannerView{
            //TODO change to app release url
            guard let settingsUrl = URL(string: "https://testflight.apple.com/a") else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Testflight opened: \(success)") // Prints true
                })
            }

        }
    }
}

extension HomeViewController: DatabaseManagerDelegate {
    func sessionDBFinishedLoading() {
        getSessionData()
        checkLastJournal()
        tableView.reloadData()
    }
}
