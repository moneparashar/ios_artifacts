//
//  ConfirmPairNewControllerPopupViewController.swift
//  vivally
//
//  Created by Ryan Levels on 5/12/23.
//

import UIKit

class ConfirmPairNewControllerPopupViewController: BasicPopupViewController {
    
    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Pairing Confirmation", message: "Pairing a new device will unpair the currently paired controller.", option1: "Pair", option2: "Cancel", icon: .warning)
        
        super.viewDidLoad()
    }
    
    // pair
    override func tappedOption1(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("PairController"), object:  nil)
        self.dismiss(animated: false)
    }
    
    // cancel
    override func tappedOption2(_ sender: UIButton) {
        self.dismiss(animated: false)
        
    }
    
    override func tappedClose(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
