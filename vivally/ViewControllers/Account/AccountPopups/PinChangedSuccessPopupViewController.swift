//
//  PinChangedSuccessPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 3/3/23.
//

import UIKit

class PinChangedSuccessPopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Change PIN", message: "PIN changed successfully", option1: "OK", xClose: false, icon: .check)
        super.viewDidLoad()

    }
    
    override func tappedOption1(_ sender: UIButton) {
        self.dismiss(animated: false)
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.setPin.rawValue), object: nil)
    }
}
