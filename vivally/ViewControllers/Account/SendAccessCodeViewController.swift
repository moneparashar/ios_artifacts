//
//  SendAccessCodeViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 6/15/21.
//

import UIKit

class SendAccessCodeViewController: BaseNavViewController,UITextFieldDelegate {
    @IBOutlet weak var actionButton: ActionButton!
    @IBOutlet weak var errorEmailRegisterLabel: UILabel!
    @IBOutlet weak var emailTextStackView: TextFieldStackView!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    var signup = false
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.clearRightBarItems = true
        super.viewDidLoad()
        
        
        actionButton.isEnabled = false
        actionButton.backgroundColor = UIColor.casperBlue
        emailTextStackView.tf.delegate = self
        emailTextStackView.tf.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)

        contentWidth.constant = view.getWidthConstant()
        if UIDevice.current.userInterfaceIdiom == .phone{
            buttonStackView.arrangedSubviews[0].isHidden = true
            buttonStackView.arrangedSubviews[2].isHidden = true
        }
        
        emailTextStackView.setup(title: "Email", placeholder: "Somebody@email.com")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendAccessCodeTapped(_ sender: Any) {
        if signup{
            attemptSignUp()
        }
        else{
            attemptForgetPassword()
        }
    }
    
    func validateEmailPhone() -> Bool{
        let emailPattern = #"^\S+@\S+\.\S+$"#
        //let phonePattern = #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#
        
        if let email = emailTextStackView.tf.text{
            /*
            let resultPhone = email.range(
                of: phonePattern,
                options: .regularExpression
            )
            
            return (resultEmail != nil || resultPhone != nil)
            */
            
            let resultEmail = email.range(
                of: emailPattern,
                options: .regularExpression
            )

            return resultEmail != nil
        }
        else{
            return false
        }
    }
    
    
    func attemptForgetPassword(){
        emailTextStackView.resetErrorMessage()
        if !validateEmailPhone(){
            emailTextStackView.setErrorMessage(message: "Invalid email address")
            return
        }
        self.showLoading()
        AccountManager.sharedInstance.forgetPassword(username: emailTextStackView.tf.text!) { success, didSend, errorMessage in
            self.hideLoading()
            
            if success{
                AccountManager.sharedInstance.username = self.emailTextStackView.tf.text!
                //AccountManager.sharedInstance.dob = self.DobTextField.text!
                self.performSegue(withIdentifier: "GoToSignUp", sender: self)
            }
            else{
                self.errorEmailRegisterLabel.text = errorMessage
                self.errorEmailRegisterLabel.isHidden = false
            }
        }
    }
    
    func attemptSignUp(){
        self.errorEmailRegisterLabel.isHidden = true
        emailTextStackView.resetErrorMessage()
        
        if !validateEmailPhone(){
//            self.errorEmailRegisterLabel.text = "Invalid Email Address"
//            self.errorEmailRegisterLabel.isHidden = false
//            return
            
            self.errorEmailRegisterLabel.isHidden = true
            self.emailTextStackView.setErrorMessage(message: "Invalid Email Address")
            return
        }
        
        self.showLoading()
        AccountManager.sharedInstance.signup(username: emailTextStackView.tf.text!) { success, didSend, errorMessage in
            self.hideLoading()
            
            if success{
                AccountManager.sharedInstance.username = self.emailTextStackView.tf.text!
                self.performSegue(withIdentifier: "GoToSignUp", sender: self)
            }
            else{
                if errorMessage != ""
                {
                    self.errorEmailRegisterLabel.text = errorMessage
                }else
                {
                    self.errorEmailRegisterLabel.text = "An error occurred while trying to request an access code"
                }
                    
                self.errorEmailRegisterLabel.isHidden = false
                
            }
        }

        
    }
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
               // Enable the button if the text field has text, disable it otherwise
        actionButton.isEnabled = !textField.text!.isEmpty
        if !actionButton.isEnabled
        {
            actionButton.backgroundColor = UIColor.casperBlue
        }
        
    }
}
