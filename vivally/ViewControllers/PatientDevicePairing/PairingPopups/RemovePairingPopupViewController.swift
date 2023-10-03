//
//  RemovePairingPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/15/23.
//

import UIKit

class RemovePairingPopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Unpair Controller", message: "You will no longer be able to use this Controller unless you pair it again.\nAre you sure you want to unpair your Controller?", option1: "Unpair", option2: "Cancel", xClose: false, icon: .question)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tappedOption1(_ sender: UIButton) {
        BluetoothManager.sharedInstance.clearPairing()
        BluetoothDeviceInfoManager.sharedInstance.clearDevice()
        //
        self.dismiss(animated: false, completion: nil)
    }
    
    override func tappedOption2(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
