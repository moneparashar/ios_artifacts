//
//  TherapySessionFailedSavePopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 10/12/22.
//

import UIKit

class TherapySessionFailedSavePopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        let bpc = BasicPopupContent(title: "Device Error", message: "Saving the therapy session failed", option1: "OK")
        baseContent = bpc
        super.viewDidLoad()
    }
    
    override func tappedOption1(_ sender: UIButton) {
        self.dismiss(animated: false)
    }

}
extension TherapySessionFailedSavePopupViewController: BasicPopupDelegate{
    func option1Selected() {
        self.dismiss(animated: false)
    }
    
    func option2Selected() {
        
    }
    
    func closeSelected() {
        
    }
    
    func videoSelected() {
        
    }
    
    
}
