//
//  PauseLimitPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/27/23.
//

import UIKit

class PauseLimitPopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Pause Not Allowed", message: "Number of Pauses exeeded. If you need to terminate session, press \"Stop\"", option1: "OK", xClose: false)
        
        addObserver()
        
        super.viewDidLoad()
    }
    
    override func tappedOption1(_ sender: UIButton) {
        removeObserver()
        self.dismiss(animated: false)
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeVC(notif:)), name: NSNotification.Name(NotificationNames.closePopup.rawValue), object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func closeVC(notif: Notification) {
        removeObserver()
        self.dismiss(animated: false)
    }
}
