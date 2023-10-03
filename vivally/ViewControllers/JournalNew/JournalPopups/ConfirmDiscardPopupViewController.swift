//
//  ConfirmDiscardPopupViewController.swift
//  vivally
//
//  Created by Ryan Levels on 3/15/23.
//

import UIKit

class ConfirmDiscardPopupViewController: BasicPopupViewController {
        
    override func viewDidLoad() {
            
        baseContent = BasicPopupContent(title: "Discard eDiary entry", message: "Are you sure you want to discard this entry? All changes in this entry will be lost.", option1: "Continue", option2: "Discard", icon: .question)
        
        super.viewDidLoad()
    }
    
    override func tappedOption1(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    // close view controller, dismiss popup
    override func tappedOption2(_ sender: UIButton) {
        self.dismiss(animated: false)
        NavigationManager.sharedInstance.currentNav.popViewController(animated: true)
    }
    
    override func tappedClose(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
