//
//  PairConfirmationPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/15/23.
//

import UIKit

class PairSuccessfulPopupViewController: BasicPopupViewController {
    
    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Pairing Confirmation", message: "Your controller is now paired with your mobile device", option1: "OK", xClose: false, icon: .check)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tappedOption1(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.firstPair.rawValue), object:  nil)
        self.dismiss(animated: false)
    }
}
