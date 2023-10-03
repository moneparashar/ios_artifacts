//
//  ChangeStudyPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/23/23.
//

import UIKit

class ChangeStudyPopupViewController: BasicPopupViewController {

    var study = ""
    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Study Change", message: "Are you sure you want to select the \(study) study?", option1: "Cancel", option2: "Ok", xClose: false, icon: .question)
        super.viewDidLoad()
    }
    

    override func tappedOption1(_ sender: UIButton) {
        //cancel notif
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.cancelChangeStudy.rawValue), object: nil)
        
        dismiss(animated: false)
    }
    
    override func tappedOption2(_ sender: UIButton) {
        //change study
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.changeStudy.rawValue), object: nil)
        
        dismiss(animated: false)
    }
}
