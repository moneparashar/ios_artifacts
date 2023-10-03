//
//  PauseAboutToExpirePopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 6/26/23.
//

import UIKit

class PauseAboutToExpirePopupViewController: BasicPopupViewController {

    var timer = Timer()
    
    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Pause time about to Expire", message: "Resume within 2 minutes or the session will terminate", option1: "OK", icon: .warning)
        
        startDismissTimer()
        
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        invalidateDismissTimer()
    }
    
    @objc func dismissPauseAboutToExpirePopup() {
        self.dismiss(animated: false)
    }

    override func tappedOption1(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    override func tappedClose(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    func startDismissTimer() {
        timer = Timer.scheduledTimer(timeInterval: 118.5, target: self, selector: #selector(dismissPauseAboutToExpirePopup), userInfo: nil, repeats: false)
    }
    
    func invalidateDismissTimer() {
        timer.invalidate()
    }

}
