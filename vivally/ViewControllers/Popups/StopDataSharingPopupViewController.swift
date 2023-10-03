//
//  StopDataSharingPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 3/1/23.
//

import UIKit

class StopDataSharingPopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "Data sharing", message: "Are you sure you want to stop sharing your data?", option1: "Don't share", option2: "Cancel", xClose: false, icon: .warning)
        super.viewDidLoad()
    }
    

    override func tappedOption1(_ sender: UIButton) {
        //don't share
        
        self.dismiss(animated: false)
    }
    
    override func tappedOption2(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
