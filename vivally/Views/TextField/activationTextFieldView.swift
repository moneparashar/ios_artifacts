//
//  activationTextFieldView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 8/10/21.
//

import UIKit

import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class activationTextFieldView: UIView {

    var textLabel = ""
    var textPlaceholder = ""
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't use init with coder.")
    }
    
    fileprivate func setupViews(){
        let estimatedFrame = self.frame
        
        let textField = MDCFilledTextField(frame: estimatedFrame)
        textField.label.text = "Phone number"
        textField.placeholder = "555-555-5555"
        textField.sizeToFit()
        self.addSubview(textField)
    }
    
    func changeText(textLabel: String, textPlaceholder: String) {
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
