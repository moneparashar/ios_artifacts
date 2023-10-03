//
//  ExistingPatientTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 7/26/21.
//

import UIKit
import PhoneNumberKit

protocol ExistingPatientTableViewCellDelegate{
    func findPatientButtonTapped(email:String, name: String)
}

class ExistingPatientTableViewCell: ShadowTableViewCell {

    var delegate:ExistingPatientTableViewCellDelegate?
    @IBOutlet weak var nameTextField: EntryTextField!
    @IBOutlet weak var emailTextField: EntryTextField!
    
    @IBOutlet weak var nameMD: MDTextFieldView!
    @IBOutlet weak var emailMD: MDTextFieldView!
    
    @IBOutlet weak var findPatientButton: ActionButton!
    
    @IBOutlet weak var patientNotFound: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func validateEmailPhone() -> Bool{
        let emailPattern = #"^\S+@\S+\.\S+$"#
        //let phonePattern = #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#
        
        //var phoneValid = true
        
        if let email = emailMD.tF.text{
            if email.isEmpty && !nameMD.tF.text!.isEmpty{
                return true
            }
            
            let resultEmail = email.range(
                of: emailPattern,
                options: .regularExpression
            )
            /*
            let resultPhone = email.range(
                of: phonePattern,
                options: .regularExpression
            )
            
            do{
                let phoneNumberKit = PhoneNumberKit()
                _ = try phoneNumberKit.parse(emailMD.tF.text!, withRegion: "US", ignoreType: true)
                
            }catch{
                print("Failed Phone Parse")
                phoneValid = false
            }
            */
            return resultEmail != nil
            //return (resultEmail != nil || resultPhone != nil || phoneValid)
        }
        else{
            return false
        }
    }
    
    @IBAction func findPatientButtonTapped(_ sender: ActionButton) {
        patientNotFound.isHidden = true
        
        emailMD.resetErrorMessage()
        
        checkAllFieldsForWhitespace()
        
        if !validateEmailPhone(){
            emailMD.setErrorMessage(message: "Invalid Email")
            return
        }
        
        if emailMD.tF.text != nil || nameMD.tF.text != nil {
            var name = ""
            var email = ""
            if emailMD.tF.text != nil{
                email = emailMD.tF.text!
            }
            if nameMD.tF.text != nil{
                name = nameMD.tF.text!
            }
            delegate?.findPatientButtonTapped(email:email, name: name)
        }
        
    }
    
    func checkAllFieldsForWhitespace(){
        emailMD.tF.text = removeExcessWhitespace(text: emailMD.tF.text!)
        
        nameMD.tF.text = removeExcessWhitespace(text: nameMD.tF.text!, multiple: true)
    }
    
    func removeExcessWhitespace(text: String, multiple: Bool = false) -> String{
        if multiple{
            var fullname = text.trimmingCharacters(in: .whitespaces)
            
            if let firstCommaIndex = fullname.firstIndex(of: ","){
                var last = String(fullname[..<firstCommaIndex])
                last = last.trimmingCharacters(in: .whitespaces)
                
                let afterCommaIndex = fullname.index(after: firstCommaIndex)
                var first = String(fullname[afterCommaIndex...])
                first = first.trimmingCharacters(in: .whitespaces)
                
                let trimmedStr = last + ", " + first
                return trimmedStr
            }
            return text
        }
        return text.trimmingCharacters(in: .whitespaces)
    }
    
    func setupView(hidePatientFoundError: Bool, enableFind: Bool) {
        findPatientButton.isEnabled = enableFind
        nameMD.tF.label.text = "Last Name, First Name"
        emailMD.tF.label.text = "Email Address"
        findPatientButton.layer.cornerRadius = findPatientButton.frame.size.height / 2
        self.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.layer.cornerRadius = 15
        
        //emailMD.tF.text = "vivally.test01@gmail.com"  //staging
        //emailMD.tF.text = "abarker@sancsoft.com"
        //emailMD.tF.text = "nkcamachocabrera@gmail.com"
        //nameMD.tF.text = "la, fifth"
        patientNotFound.isHidden = hidePatientFoundError
        
        addShadow()
    }
    
    func addShadow(){
        findPatientButton.layer.masksToBounds = false
        findPatientButton.layer.shadowColor = UIColor(named: "avationShadow")?.cgColor
        findPatientButton.layer.shadowOpacity = 1
        findPatientButton.layer.shadowOffset = CGSize.init(width: 0, height: 4)
        findPatientButton.layer.shadowRadius = 4
    }
}
