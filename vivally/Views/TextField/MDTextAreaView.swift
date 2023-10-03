//
//  MDTextAreaView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 3/30/22.
//

import UIKit

import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields


class MDTextAreaView: UIView {

    var  tF = MDCFilledTextArea()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        
        
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder aDecoder: NSCoder) {
            
            
            super.init(coder: aDecoder)
            commonInit()
        }
        
        func commonInit() {
            
            addMD()
            //contentView.fixView(self)
        }
    
    func addMD(){
        //let textField = MDCFilledTextField()
        tF.textView.autocapitalizationType = UITextAutocapitalizationType.none
        tF.setFilledBackgroundColor(UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1), for: .normal)
        //tF.label.text = textLabel
        let underline = UIColor(named: "avationLtGreen")!
        tF.setUnderlineColor(underline, for: .normal)
        tF.setUnderlineColor(underline, for: .editing)
        
        tF.textView.font = tF.textView.font?.withSize(14)
        
        let labelColor = UIColor(named: "avationGrayFont")!
        tF.setNormalLabel(labelColor, for: .normal)
        tF.setFloatingLabel(labelColor, for: .normal)
        tF.setFloatingLabel(labelColor, for: .disabled)
        
        tF.setTextColor(labelColor, for: .disabled)
        tF.setUnderlineColor(labelColor, for: .disabled)
        //let bgColor = UIColor(named: "avationLtGray")!
        let bgColor = tF.filledBackgroundColor(for: .normal)
        tF.setFilledBackgroundColor(bgColor, for: .disabled)
        
        tF.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tF)
        
        let margins = self.layoutMarginsGuide
        tF.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
        tF.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
        
        tF.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        tF.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func setErrorMessage(message:String){
        let underline = UIColor(named: "avationError")!
        tF.setUnderlineColor(underline, for: .normal)
        tF.setUnderlineColor(underline, for: .editing)
        tF.setLeadingAssistiveLabel(underline, for: .normal)
        tF.setLeadingAssistiveLabel(underline, for: .editing)
        tF.leadingAssistiveLabel.text = message
    }
    
    func resetErrorMessage(){
        let underline = UIColor(named: "avationLtGreen")!
        tF.setUnderlineColor(underline, for: .normal)
        tF.setUnderlineColor(underline, for: .editing)
        tF.leadingAssistiveLabel.text = ""
    }
}
