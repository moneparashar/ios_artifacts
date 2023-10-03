//
//  ExitScreeningPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/13/23.
//

import UIKit

class ExitScreeningPopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Exit Therapy Personalization", message: "Are you sure you want to exit Therapy Personalizaiton?", option1: "No", option2: "Exit", xClose: true, icon: .question)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tappedClose(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    override func tappedOption1(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    override func tappedOption2(_ sender: UIButton) {
        ScreeningProcessManager.sharedInstance.stopScreeningInvalid()
        self.dismiss(animated: true){
            NavigationManager.sharedInstance.currentNav.popViewController(animated: true)
        }
    }

}
