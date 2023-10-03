//
//  TherapyHistoryWeekViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/19/23.
//

import UIKit
import CoreBluetooth

class TherapyHistoryWeekViewController: BaseNavViewController {

    @IBOutlet weak var disconnectBannerView: BannerView!
    
    @IBOutlet weak var leftDateButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rightDateButton: UIButton!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var sessionCompletedLabel: UILabel!
    @IBOutlet weak var sessionProgressView: UIProgressView!
    @IBOutlet weak var scheduleLabel: UILabel!
    
    @IBOutlet weak var historySwitch: UISwitch!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var batteryView: StimulatorBatteryStatusView!
    @IBOutlet weak var noTherapyLabel: UILabel!
    
    @IBOutlet weak var startTherapyButton: UIButton!
    
    
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    
    var selectedDate = Date()
    var therapySessions:[[SessionData]] = []
    
    let sessionCell = "SessionCell"
    let sessionBottomCell = "SessionBottomCell"
    let monthCell = "monthCell"
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.viewDidLoad()
        
        title = "My Therapy history"

        stackWidth.constant = view.getWidthConstant()
        setup()
        
        disconnectBannerView.setup(title: "Controller not connected", sub: "Tap here to check Controller status")
        disconnectBannerView.delegate = self
        historyLabel.text = "Also show partial sessions"
        
        batteryView.setupView()
        if BluetoothManager.sharedInstance.isConnectedToDevice(){
            disconnectBannerView.isHidden = true
        }else{
            disconnectBannerView.isHidden = false
        }
        
        getTherapyList() {
            //tableview update
            self.tableView.dataSource = self
            self.tableView.delegate = self
        }
        
        if let schedle = KeychainManager.sharedInstance.accountData?.userModel?.therapySchedule{
            if schedle > 7{
                bannerView.isHidden = true
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
        
        // therapy running? YES: title = therapy running; NO: title = start therapy
        checkIfTherapyRunningAndConnected() ? startTherapyButton.setTitle("Therapy in progress", for: .normal) : startTherapyButton.setTitle("Start Therapy", for: .normal)
    }
    
    func setup(){
        tableView.register(SessionTableViewCell.self, forCellReuseIdentifier: sessionCell)
        tableView.register(SessionBottomTableViewCell.self, forCellReuseIdentifier: sessionBottomCell)
        tableView.register(SessionMonthTableViewCell.self, forCellReuseIdentifier: monthCell)
        
        //tableView.alwaysBounceVertical = false
        tableView.showsHorizontalScrollIndicator = false
        
        bannerView.layer.cornerRadius = 15
        bannerView.layer.borderWidth = 1
        
        historySwitch.layer.cornerRadius = historySwitch.frame.height / 2
        
        let today = Calendar.current.startOfDay(for: Date().startOfWeek())
        selectedDate = today
        setDateLabel()
        checkDateButtonEnabling()
        
        getBanner()
    }
    
    
    func getBanner(){
        let dayToStartFind = selectedDate
        
        if let account = KeychainManager.sharedInstance.loadAccountData(){
            do{
                if let schedule = account.userModel?.therapySchedule{
                    let user = account.username
                    let sessionsCompleted = try SessionDataDataHelper.getCompletedSessionsInWeek(passDate: dayToStartFind, name: user) ?? 0
                    
                    let eval = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
                    var sessionTime = 0
                    var feet:[Feet] = []
                    if eval?.left != nil{
                        sessionTime = eval?.left?.therapyLength ?? 0
                        feet.append(.left)
                    }
                    if eval?.right != nil{
                        sessionTime = eval?.right?.therapyLength ?? 0
                        feet.append(.right)
                    }
                    sessionTime = sessionTime / 60
                    setBanner(numSession: sessionsCompleted, denomSession: schedule, feet: feet, length: sessionTime)
                }
            } catch{
                print("failure with get Completed Session in Week")
            }
        }
    }
    
    func setBanner(numSession: Int, denomSession: Int, feet: [Feet], length: Int = 30){
        // hide history banner label if patient schedule = 0 sessions/week
        bannerView.isHidden = denomSession == 0
        
        // show no therapy label if no therapies have been done this week
        noTherapyLabel.isHidden = numSession > 0

        // if number of sessions is not 0 and equals the number of possible sessions, show green background. If not, show blue background
        bannerView.layer.borderColor = numSession >= denomSession && numSession != 0 ? UIColor.androidGreen?.cgColor : UIColor.casperBlue?.cgColor
        bannerView.backgroundColor = numSession >= denomSession && numSession != 0 ? UIColor.springSun : UIColor.lavendarMist
        sessionCompletedLabel.text = "\(numSession)/\(denomSession) sessions completed this week"
        if numSession <= denomSession && denomSession != 0{
            sessionProgressView.setProgress(Float(numSession)/Float(denomSession), animated: true)
        }
        else if numSession > denomSession{
            sessionProgressView.setProgress(1, animated: true)
        }
        
        var footStr = ""
        if feet.count > 1{
            footStr = "LEFT/RIGHT"
        }
        else if feet.count == 1{
            footStr = feet[0] == .left ? "LEFT" : "RIGHT"
        }
        scheduleLabel.text = "\(length) min sessions - \(denomSession) times per week - " + footStr + " foot"
    }
    
    func getTherapyList(completion:@escaping () -> ()){
        SessionDataManager.sharedInstance.getLocalTherapyList(date: selectedDate, onlyComplete: !historySwitch.isOn){ tlist in
            self.therapySessions = tlist
            completion()
        }
    }
    
    func getDateStr(tStamp: Date, eventDate: Date, month: Bool = false) -> String{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = month ? "MMMM YYYY" : "EEEE d, h:mm a"
        
        return dateFormat.string(from: eventDate)
    }
    
    func dateChange(forward: Bool){
        selectedDate = forward ? selectedDate.addWeek() : selectedDate.prevWeek()
        setDateLabel()
        checkDateButtonEnabling()
        getTherapyList {
            self.getBanner()
            self.tableView.reloadData()
            self.tableView.showsHorizontalScrollIndicator = false
        }
    }
    
    func setDateLabel(){
        let firstdateFormat = DateFormatter()
        firstdateFormat.dateFormat = "MMM d"
        let firstHalf = "Week of " + firstdateFormat.string(from: selectedDate)
        
        let secondDateFormat = DateFormatter()
        secondDateFormat.dateFormat = "MMM d, YYYY"
        let endWeek = selectedDate.endOfWeek()
        
        dateLabel.text = firstHalf + " to " + secondDateFormat.string(from: endWeek)
    }
    
    func checkDateButtonEnabling(){
        let nextWeek = selectedDate.addWeek()
        rightDateButton.isEnabled = Date() >= nextWeek
    }
    
    // Check if therapy is running and stim connected
    func checkIfTherapyRunningAndConnected() -> Bool {
        let running = TherapyManager.sharedInstance.therapyRunning
        let connected = BluetoothManager.sharedInstance.isConnectedToDevice()
        
        if running && connected {
            return true
        }
        
        return false
    }
   
    @IBAction func tappedLeft(_ sender: UIButton) {
        dateChange(forward: false)
    }
    
    @IBAction func tappedRight(_ sender: UIButton) {
        dateChange(forward: true)
    }
    
    @IBAction func historyChanged(_ sender: UISwitch) {
        getTherapyList {
            self.tableView.reloadData()
            self.tableView.showsHorizontalScrollIndicator = false
        }
    }
    
    @IBAction func startTherapyTapped(_ sender: ActionButton) {
        // therapy running? YES: goto therapy;
        if checkIfTherapyRunningAndConnected() {
            let storyboard = UIStoryboard(name: "therapyNew", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TherapyViewController") as! TherapyViewController
            navigationController?.pushViewController(vc, animated: true)
            
        // NO: goto therapy prep
        } else {
            let storyboard = UIStoryboard(name: "therapyNew", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TherapyPrepViewController") as! TherapyPrepViewController
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension TherapyHistoryWeekViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        therapySessions[section].count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        therapySessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: monthCell, for: indexPath) as! SessionMonthTableViewCell
            let sess = therapySessions[indexPath.section][0]
            let sTmstmp = sess.eventTimestamp?.treatTimestampStrAsDate() ?? Date()
            let datestr = getDateStr(tStamp: sess.timestamp, eventDate: sTmstmp, month: true)
            cell.setup(month: datestr)
            return cell
        }
        else{
            let sess = therapySessions[indexPath.section][indexPath.row - 1]
            let displayDateStr = sess.eventTimestamp?.getDateStrOfTime() ?? ""
            
            if indexPath.row == therapySessions[indexPath.section].count{
                let cell = tableView.dequeueReusableCell(withIdentifier: sessionBottomCell, for: indexPath) as! SessionBottomTableViewCell
                cell.setup(pass: sess.isComplete, datestr: displayDateStr)
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: sessionCell, for: indexPath) as! SessionTableViewCell
                cell.setup(pass: sess.isComplete, datestr: displayDateStr)
                return cell
            }
        }
    }
}

extension TherapyHistoryWeekViewController: BluetoothManagerDelegate{
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {}
    
    func didConnectToDevice(device: CBPeripheral) {
        disconnectBannerView.isHidden = true
        batteryView.setupView()
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        disconnectBannerView.isHidden = false
        batteryView.setupView()
    }
    
    func didBLEChange(on: Bool) {}
    
    func didUpdateData() {
        batteryView.setupView()
    }
    
    func didUpdateStimStatus() {}
    
    func didUpdateEMG() {}
    func didUpdateBattery(){}
    func didUpdateTherapySession() {}
    
    func didBondFail() {}
    
    func didUpdateDevice() {}
    
    func foundOngoingTherapy(){}
    func pairingTimeExpired() {}
}

extension TherapyHistoryWeekViewController: TherapyManagerDelegate{
    func therapyFinished(state: therapyFinishStates) {}
    
    func updateBLEData() {
        batteryView.setupView()
    }
    
    func didConnectToBLEDevice(device: CBPeripheral) {
        batteryView.setupView()
    }
    
    func didDisconnectFromBLEDevice(device: CBPeripheral) {
        batteryView.setupView()
    }
    
    func pauseLimitReached() {}
    
    func didUpdateStatus() {}
    
    func didUpdateDev() {}
    func didUpdateTherapyBattery(){
        batteryView.setupView()
    }
    func pauseAboutToExpire() {}
    func pauseExpired() {}
}

extension TherapyHistoryWeekViewController: BannerViewDelegate{
    func tappedBanner(bannerType: BannerView) {
        if bannerType == disconnectBannerView {
            let storyboard = UIStoryboard(name: "patientDevicePairing", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "DeviceStatusTabletViewController") as! DeviceStatusTabletViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

