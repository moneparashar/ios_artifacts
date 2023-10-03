//
//  MDTextFieldView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 9/9/21.
//

import UIKit

import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class MDTextFieldView: UIView {

    let kCONTENT_XIB_NAME = "MDTextFieldView"
    @IBOutlet var contentView: UIView!
    
    var textLabel = "default text Label"
    var placeholder = "default placeholder"
    
    //var  tF = MDCFilledTextArea()
    var tF = MDCFilledTextField()         //old way
    
    fileprivate let eyeOpenedImage: UIImage
    fileprivate let eyeClosedImage: UIImage
    fileprivate let eyeButton: UIButton
    
    override init(frame: CGRect) {
        self.eyeOpenedImage = UIImage(systemName: "eye")!.withRenderingMode(.alwaysTemplate)
        self.eyeClosedImage = UIImage(systemName: "eye.slash")!.withRenderingMode(.alwaysTemplate)
        self.eyeButton = UIButton(type: .custom)
        
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder aDecoder: NSCoder) {
            self.eyeOpenedImage = UIImage(systemName: "eye")!.withRenderingMode(.alwaysTemplate)
            self.eyeClosedImage = UIImage(systemName: "eye.slash")!.withRenderingMode(.alwaysTemplate)
            self.eyeButton = UIButton(type: .custom)
            
            super.init(coder: aDecoder)
            commonInit()
        }
        
        func commonInit() {
            Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
            addMD()
            contentView.fixView(self)
        }
    
    func addMD(){
        tF.autocapitalizationType = UITextAutocapitalizationType.none
        tF.setFilledBackgroundColor(UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1), for: .normal)
        let underline = UIColor(named: "avationLtGreen")!
        tF.setUnderlineColor(underline, for: .normal)
        tF.setUnderlineColor(underline, for: .editing)
        
        
        tF.font = tF.font?.withSize(14)
        
        
        
        let labelColor = UIColor(named: "avationGrayFont")!
        tF.setNormalLabelColor(labelColor, for: .normal)
        tF.setFloatingLabelColor(labelColor, for: .normal)
        tF.setFloatingLabelColor(labelColor, for: .disabled)
        
        tF.setTextColor(labelColor, for: .disabled)
        tF.setUnderlineColor(labelColor, for: .disabled)
        //let bgColor = UIColor(named: "avationLtGray")!
        let bgColor = tF.filledBackgroundColor(for: .normal)
        tF.setFilledBackgroundColor(bgColor, for: .disabled)
        
        
        //testing eye
        //passwordToggle()
        //end of eye test
        
        tF.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tF)
        
        let margins = contentView.layoutMarginsGuide
        tF.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
        tF.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
        
        tF.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        tF.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
    }
    
    
    func setErrorMessage(message:String){
        let underline = UIColor(named: "avationError")!
        tF.setUnderlineColor(underline, for: .normal)
        tF.setUnderlineColor(underline, for: .editing)
        tF.setLeadingAssistiveLabelColor(underline, for: .normal)
        tF.setLeadingAssistiveLabelColor(underline, for: .editing)
        tF.leadingAssistiveLabel.text = message
    }
    
    func resetErrorMessage(){
        let underline = UIColor(named: "avationLtGreen")!
        tF.setUnderlineColor(underline, for: .normal)
        tF.setUnderlineColor(underline, for: .editing)
        tF.leadingAssistiveLabel.text = ""
    }
    

    //for secure toggle
    var secure = false
    let eyeIcon = UIImageView(image: UIImage(systemName: "eye"))
    
    func passwordToggle(){
        secure = true
        tF.isSecureTextEntry = secure
        
        eyeIcon.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedEye(_:)))
        eyeIcon.addGestureRecognizer(tap)
        
        eyeIcon.tintColor = UIColor(named: "avationMdGray")
        
        tF.trailingView = eyeIcon
        tF.trailingViewMode = .always
        
        
    }
    
    @objc func tappedEye(_ sender: UITapGestureRecognizer? = nil){
        secure = !secure
        tF.isSecureTextEntry = secure
        eyeIcon.image = secure ? eyeOpenedImage : eyeClosedImage
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
}


