//
//  PrepTherapyDataRecoveryPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/27/23.
//

import UIKit

class PrepTherapyDataRecoveryPopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Last session data available", message: "Controller disconnected in your last session. You can save this session data from the status page or Ignore and continue to Therapy.", option1: "Ignore", option2: "Go to Status", icon: .exclamation)
        super.viewDidLoad()
    }
    
    override func tappedOption1(_ sender: UIButton) {
        BluetoothManager.sharedInstance.sendCommand(command: .clearDataRecovery, parameters: [])
        DataRecoveryManager.sharedInstance.removeRecovery()
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.checksGo.rawValue), object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            DataRecoveryManager.sharedInstance.showPopup = true
        }
        self.dismiss(animated: false)
    }
    
    override func tappedOption2(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.statusGo.rawValue), object: nil)
        self.dismiss(animated: false)
    }
    
    override func tappedClose(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.checksGo.rawValue), object: nil)
        self.dismiss(animated: false)
    }

}
