//
//  TherapyDisconnectViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/26/23.
//

import UIKit
import CoreBluetooth

class TherapyDisconnectViewController: BaseNavViewController {

    override func viewDidLoad() {
        super.goBackEnabled = true
        super.goBackPrompt = true
        super.viewDidLoad()
        
        super.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        BluetoothManager.sharedInstance.delegate = self
        TherapyManager.sharedInstance.delegate = self
        
        super.viewDidAppear(false)
    }
    
    func stimStatusUpdated(){
        let stim = BluetoothManager.sharedInstance.informationServiceData.stimStatus
        // therapy running?
        // YES: pop vc
        if stim.mainState == .therapy {
            self.navigationController?.popViewController(animated: false)
            
            // NO: check if clinician or patient
        } else {
            if let accountData = KeychainManager.sharedInstance.loadAccountData(){
                
                // clinician, sign out
                if accountData.roles.contains("Clinician"){
                    let initialViewController = NonSignedInMainViewController()
                    NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
                    
                    NetworkManager.sharedInstance.logoutClear()
                    DataRecoveryManager.sharedInstance.removeRecovery()
                    // patient, pop to home
                } else {
                    self.navigationController?.popToRootViewController(animated: false)
                }
                
                // account data error, pop to home
            } else {
                self.navigationController?.popToRootViewController(animated: false)
            }
        }
    }
}

extension TherapyDisconnectViewController: BluetoothManagerDelegate{
    func didUpdateDevice() {}
    
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {    }
    
    func didConnectToDevice(device: CBPeripheral) {
        //self.navigationController?.popViewController(animated: false)
        BluetoothManager.sharedInstance.readStimStatus()
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {}
    
    func didBLEChange(on: Bool) {}
    
    func didUpdateData() {}
    
    func didUpdateStimStatus() {
        stimStatusUpdated()
    }
    
    func didUpdateEMG() {}
    func didUpdateBattery(){}
    func didUpdateTherapySession() {}
    
    func didBondFail() {}
    
    func foundOngoingTherapy() {}
    func pairingTimeExpired() {}
}

extension TherapyDisconnectViewController:TherapyManagerDelegate{
    func therapyFinished(state: therapyFinishStates) {
    }
    
    func updateBLEData() {}
    
    func didConnectToBLEDevice(device: CBPeripheral) {}
    
    func didDisconnectFromBLEDevice(device: CBPeripheral) {}
    
    func pauseLimitReached() {}
    
    func didUpdateStatus() {
        stimStatusUpdated()
    }
    
    func didUpdateDev() {}
    
    func didUpdateTherapyBattery() {}
    
    func pauseAboutToExpire() {}
    
    func pauseExpired() {}
    
}

extension TherapyDisconnectViewController: BackPromptDelegate{
    func goBackSelected() {
        self.navigationController?.popToRootViewController(animated: false)
    }
}
