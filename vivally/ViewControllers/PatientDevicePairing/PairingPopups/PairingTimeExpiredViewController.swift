//
//  PairingTimeExpiredViewController.swift
//  vivally
//
//  Created by Ryan Levels on 8/10/23.
//

import UIKit

class PairingTimeExpiredViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Pairing Timed Out", message: "Pairing timed out. Please try again.", option1: "Cancel", option2: "Try Again", xClose: false, icon: .warning, videoMesssage: "Need help? Watch a video about pairing")
        super.viewDidLoad()
    }
    

    override func tappedOption1(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    override func tappedOption2(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNames.tryAgainTapped.rawValue), object: nil)
        
        self.dismiss(animated: false)
    }
    
    override func tappedVideo(_ sender: UIButton) {
        HelpManager.sharedInstance.playSectionVideo(vc: self, helpInfo: .pair)
    }
}
