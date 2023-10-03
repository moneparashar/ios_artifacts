//
// ClinicianHomePageTabletViewController.swift
// vivally
//
// Created by Ryan Levels on 1/31/23.
//

import UIKit
import CoreBluetooth

class ClinicianHomePageTabletViewController: BaseNavViewController, UITextFieldDelegate {
    //@IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var viewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var searchBarTextField: UITextField!
    @IBOutlet weak var searchBarButton: UIButton!
    
    @IBOutlet weak var allNotificationsStackView: UIStackView!
    @IBOutlet weak var notificationOne: UIView!
    @IBOutlet weak var noPatientMessage: UIView!
    @IBOutlet weak var appUpdateBanner: BannerView!
    @IBOutlet weak var firmwareUpdateBanner: BannerView!
    @IBOutlet weak var noControllerBanner: BannerView!
    
    
    @IBOutlet weak var addPatientButton: ActionButton!
    @IBOutlet weak var bottomButtonStack: UIStackView!
    let mainViewWidth = UIScreen.main.bounds.width // get width of screen
    
    var searchResults: [PatientExists] = []
    let cellSpacingHeight: CGFloat = 3.0
    let headerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewWidth.constant = view.getWidthConstant()
        
        title = "Clinician Portal"
        // Do any additional setup after loading the view.
        setupSearchBar()
        setupTableView()
        setupNotifications()
        addNotifications()
        
        //searchBarTextField.text = "nkcamachocabrera@gmail.com"
        
        addPatientButton.toSecondary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setOtherBanners()
        //checkForAppUpdate() MARK: uncomment to check for app update
        checkForAppUpdate()
        BluetoothManager.sharedInstance.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // reset search results & notifs when view disappears
        resetSearchResults()
        resetNotifications()
        removeNotifications()
    }
    
    @IBAction func tappedAddPatient(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "clinician", bundle: Bundle.main)
        let viewController = UIDevice.current.userInterfaceIdiom == .phone ? storyboard.instantiateViewController(withIdentifier: "NewPatientPhoneViewController") as! NewPatientPhoneViewController : storyboard.instantiateViewController(withIdentifier: "NewPatientTabletViewController") as! NewPatientTabletViewController
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Search for patients
    @IBAction func tappedSearchBarButton(_ sender: UIButton) {
        print("\nSearch Button Test") // MARK: for testing
        
        noPatientMessage.isHidden = true
        notificationOne.isHidden = true
        
        let searchPass = searchBarTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if searchPass.count < 3{
            notificationOne.isHidden = false
            return
        }
        else{
            //add check for wifi
            showLoading()
            
            //new attempt with proper query
            AccountManager.sharedInstance.confirmFindPatientQuery(searchText: searchPass){ success, result, errorMessage in
                if success{
                    self.searchResults = result
                    if result.isEmpty{
                        self.searchResults = []
                        self.noPatientMessage.isHidden = false
                    }
                }
                else{
                    self.searchResults = []
                    self.noPatientMessage.isHidden = false

                }
                self.tableView.reloadData()
                self.hideLoading()
            }
        }
        
    }
    
    func checkForAppUpdate() {
        let appBuildVersion = UIApplication.build ?? ""
        //let appData = AppManager.sharedInstance.loadAppDeviceData()
        let preProdAppId = "6451394364" // MARK: taken from the app store url
        let appId = "1585689224"
        
        AppUpdateManager.sharedInstance.isAppStoreUpdateAvailable(appId: appId, currentVersion: appBuildVersion) { [self] updateIsAvailable, error in
            // Update available
            if updateIsAvailable {
                print("Update available on the App Store.")
                //print("Update available on Testflight.")
                DispatchQueue.main.async { [self] in
                    appUpdateBanner.isHidden = false
                }

            // Error
            } else if let error = error {
                print("Error: \(error)")

            // No update available
            } else {
                print("No update available on the App Store.")
                //print("No update available on Testflight.")
                DispatchQueue.main.async { [self] in
                    appUpdateBanner.isHidden = true
                }
            }
        }
    }
    
    // Don't allow text field to add characters past maxLength
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 35
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= maxLength
    }
    
    
    func setupView() {
        self.viewWidth.constant = UIDevice.current.userInterfaceIdiom == .phone ? (mainViewWidth - 48) : (mainViewWidth - 308)
    }
    
    func setOtherBanners(){
        let connected = BluetoothManager.sharedInstance.isConnectedToDevice()
        noControllerBanner.isHidden = connected
        if connected{
            firmwareUpdateBanner.isHidden = !OTAManager.sharedInstance.updateAvailable
        }
        else{
            firmwareUpdateBanner.isHidden = true
        }
    }
    
    func setupSearchBar(){
        searchBarTextField.delegate = self
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func setupNotifications() {
        notificationOne.layer.borderWidth = 1
        notificationOne.layer.borderColor = UIColor.macCheese?.cgColor
        notificationOne.layer.cornerRadius = 15
        
        noPatientMessage.layer.borderWidth = 1
        noPatientMessage.layer.borderColor = UIColor.macCheese?.cgColor
        noPatientMessage.layer.cornerRadius = 15
        
        notificationOne.isHidden = true
        noPatientMessage.isHidden = true
        
        appUpdateBanner.isHidden = true
        firmwareUpdateBanner.isHidden = true
        noControllerBanner.isHidden = true
        
        
        appUpdateBanner.setup(title: "App update available", sub: "Tap here to open App store and update your app", info: true)
        firmwareUpdateBanner.setup(title: "Firmware update available", sub: "Tap here to go to status page and update the Vivally Controller", info: true)
        noControllerBanner.setup(title: "Controller not connected", sub: "Tap here to check Controller status")
        
        appUpdateBanner.delegate = self
        firmwareUpdateBanner.delegate = self
        noControllerBanner.delegate = self
    }
    
    func resetSearchResults() {
        searchBarTextField.text = ""
        searchResults.removeAll()
        tableView.reloadData()
    }
    
    func resetNotifications() {
        notificationOne.isHidden = true
        noPatientMessage.isHidden = true
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.otaUpdateAvailable(notif:)), name: NSNotification.Name(NotificationNames.otaUpdateAvailable.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.otaUpdateUnavailable(notif:)), name: NSNotification.Name(NotificationNames.otaUpdateUnavailable.rawValue), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func otaUpdateAvailable(notif: Notification) {
        firmwareUpdateBanner.isHidden = false
    }
    
    @objc func otaUpdateUnavailable(notif: Notification) {
        if !firmwareUpdateBanner.isHidden { // prevents double hide
            firmwareUpdateBanner.isHidden = true
        }
    }
}

extension ClinicianHomePageTabletViewController:UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.backgroundColor = .clear
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClinicianHomePageTableViewCell", for: indexPath) as! ClinicianHomePageTableViewCell
        cell.setupView(patient: searchResults[indexPath.section])
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cGuid = searchResults[indexPath.section].cognitoGuid{
            if !cGuid.isEmpty{
                showLoading()
                AccountManager.sharedInstance.confirmFindPatient(email: "", name: "", user: "", cogGuid: cGuid){ success, result, errorMessage in
                    if success{
                        if let patientData = result{
                            ScreeningManager.sharedInstance.saveAccountData(data: patientData)
                            let storyboard = UIStoryboard(name: "clinician", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "PatientFoundTabletViewController") as! PatientFoundTabletViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                            self.hideLoading()
                            
                        }
                    }
                }
            }
        }
    }
}

extension ClinicianHomePageTabletViewController: BannerViewDelegate{
    func tappedBanner(bannerType: BannerView) {
        if bannerType == firmwareUpdateBanner || bannerType == noControllerBanner{
            let storyboard = UIStoryboard(name: "patientDevicePairing", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "DeviceStatusTabletViewController") as! DeviceStatusTabletViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else if bannerType == appUpdateBanner{
            guard let settingsUrl = URL(string: "https://testflight.apple.com/a") else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Testflight opened: \(success)")
                })
            }
        }
    }
}

extension ClinicianHomePageTabletViewController: BluetoothManagerDelegate{
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {}
    
    func didConnectToDevice(device: CBPeripheral) {
        setOtherBanners()
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        setOtherBanners()
    }
    
    func didBLEChange(on: Bool) {}
    
    func didUpdateData() {}
    
    func didUpdateStimStatus() {}
    
    func didUpdateEMG() {}
    
    func didUpdateBattery() {}
    
    func didUpdateTherapySession() {}
    
    func didBondFail() {}
    
    func pairingTimeExpired() {}
    
    func didUpdateDevice() {
        setOtherBanners()
    }
    
    func foundOngoingTherapy() {}
}
