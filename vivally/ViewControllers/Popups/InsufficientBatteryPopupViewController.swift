//
//  InsufficientBatteryPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 3/14/23.
//

import UIKit

class InsufficientBatteryPopupViewController: BasicPopupViewController {

    var attemptTherapy = true
    override func viewDidLoad() {
        var stimOperation = attemptTherapy ? "therapy" : "screening"
        baseContent = BasicPopupContent(title: "Insufficient battery", message: "Please charge the controller to start \(stimOperation)", option1: "OK")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tappedOption1(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
