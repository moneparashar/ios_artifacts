//
//  WrongFootSelectedPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 7/3/23.
//

import UIKit

class WrongFootSelectedPopupViewController: BasicPopupViewController {

    var currentAllowedFoot = Feet.left
    
    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Foot Not Available", message: "You are only set up for therapy on \(currentAllowedFoot.getAllCapsStr()) foot. Please see your clinician to set up your \(currentAllowedFoot.getOtherFoot().getAllCapsStr()) foot", option1: "OK", xClose: false)
        super.viewDidLoad()
    }
    
    override func tappedOption1(_ sender: UIButton) {
        self.dismiss(animated: false)
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.prepWrongFootDismissed.rawValue), object: nil)
    }
    
}
