//
//  PauseExpiredPopupViewController.swift
//  vivally
//
//  Created by Ryan Levels on 6/30/23.
//

import UIKit

class PauseExpiredPopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Pause time exceeded", message: "Therapy Stopped due to Pause Time exceeded", option1: "OK", icon: .exclamation)
        super.viewDidLoad()
    }
    
    override func tappedOption1(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    override func tappedClose(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
