//
//  PairingFailedViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/15/23.
//

import UIKit

class PairingFailedViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Pairing failed", message: "Make sure you have the correct 6-digit pairing code from the Quick Start Guide and enter it when prompted", option1: "OK", xClose: false, icon: .warning, videoMesssage: "Need help? Watch a video about pairing")
        super.viewDidLoad()
    }
    

    override func tappedOption1(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    override func tappedVideo(_ sender: UIButton) {
        HelpManager.sharedInstance.playSectionVideo(vc: self, helpInfo: .pair)
    }
}
