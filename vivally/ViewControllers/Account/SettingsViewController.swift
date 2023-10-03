//
//  SettingsViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 8/9/21.
//
// TODO: fix tableView header height issue (the word 'settings')

import UIKit
import CoreBluetooth

class SettingsViewController: BaseNavViewController {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    
    var tableRows:[SettingsViewControllerCells] = [.journalReminder, .enableStimRecoveryMode, .dataSharing, .account]
    var headerHeight = CGFloat(0.0)
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.showOnlyRightLogo = true
        super.viewDidLoad()
        
        contentWidth.constant = view.getWidthConstant()
        tableView.dataSource = self
        tableView.delegate = self
    
        getTableRows()
    }
    
    func getTableRows(){
        if let account = KeychainManager.sharedInstance.loadAccountData(){
            if account.roles.contains("Clinician"){
                tableRows = OTAManager.sharedInstance.checkForAllowRecoveryToggle() ? [.enableStimRecoveryMode, .account] : [.account]
                
            } else if account.roles.contains("Patient") {
                tableRows = OTAManager.sharedInstance.checkForAllowRecoveryToggle() ? [.journalReminder, .enableStimRecoveryMode, .account] : [.journalReminder, .account]
            }
        }

        tableView.reloadData()
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableRows.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableRows[indexPath.section] == .journalReminder {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JournalNotify", for: indexPath) as! SettingsJournalTableViewCell
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.casperBlue?.cgColor
            cell.layer.cornerRadius = 15
            cell.selectionStyle = .none
            
            cell.setupView()
            
            return cell
            
        } else if tableRows[indexPath.section] == .enableStimRecoveryMode {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FirmwareRecovery", for: indexPath) as! SettingsEnableStimRecoveryTableViewCell
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.casperBlue?.cgColor
            cell.layer.cornerRadius = 15
            cell.selectionStyle = .none
            
            cell.setupView()
            
            return cell
            
        } else if tableRows[indexPath.section] == .dataSharing {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DataSharing", for: indexPath) as! SettingsDataSharingTableViewCell
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.casperBlue?.cgColor
            cell.layer.cornerRadius = 15
            cell.selectionStyle = .none
            
            cell.delegate = self
            
            let isOn = true
            cell.setupView(toggleOn: isOn)
            
            return cell
        }
        else if tableRows[indexPath.section] == .account{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCloseAccountTableViewCell") as! SettingsCloseAccountTableViewCell
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.casperBlue?.cgColor
            cell.layer.cornerRadius = 15
            cell.selectionStyle = .none
            cell.deleteAccountBtn.toSecondary()
            cell.deleteAccountBtn.layer.borderWidth = 2
            cell.deleteAccountBtn.setTitleColor(UIColor.white, for: .normal)
            cell.deleteAccountBtn.backgroundColor =  UIColor.regalBlue
//            cell.deleteAccountBtn.layer.borderColor = UIColor.casperBlue?.cgColor
            cell.deleteAccountBtn.layer.cornerRadius = cell.deleteAccountBtn.frame.size.height/2
            cell.delegate = self
            
            return cell
        }
        
        return UITableViewCell()
    }
}

extension SettingsViewController: SettingsDataSharingTableViewCellDelegate{
    func dataSharing(isOn: Bool) {
        if !isOn{
            AccountManager.sharedInstance.disableDataSharing {}
        }
        else{
            AccountManager.sharedInstance.enableDataSharing{}
        }
    }
}

extension SettingsViewController: SettingsCloseAccountTableViewCellDelegate{
    func tappedStopAccount() {
        let vc = CloseAccountPoupViewController()
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
}

extension SettingsViewController: TherapyManagerDelegate{
    func therapyFinished(state: therapyFinishStates) {}
    
    func updateBLEData() {}
    
    func didConnectToBLEDevice(device: CBPeripheral) {
        getTableRows()
    }
    
    func didDisconnectFromBLEDevice(device: CBPeripheral) {
        getTableRows()
    }
    
    func pauseLimitReached() {}
    
    func didUpdateStatus() {}
    
    func didUpdateDev() {}
    
    func didUpdateTherapyBattery(){}
    
    func pauseAboutToExpire() {}
    func pauseExpired() {}
}

extension SettingsViewController: BluetoothManagerDelegate{
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {}
    
    func didConnectToDevice(device: CBPeripheral) {
        getTableRows()
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        getTableRows()
    }
    
    func didBLEChange(on: Bool) {}
    
    func didUpdateData() {}
    
    func didUpdateStimStatus() {}
    
    func didUpdateEMG() {}
    
    func didUpdateBattery() {}
    
    func didUpdateTherapySession() { }

    func didBondFail() {}
    
    func didUpdateDevice() {}
    
    func foundOngoingTherapy() {}
    func pairingTimeExpired() {}
}
