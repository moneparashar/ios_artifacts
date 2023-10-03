//
//  ChangePasswordViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 5/18/21.
//

import UIKit

class ChangePasswordViewController: BaseNavViewController {

    @IBOutlet weak var oldTextStack: TextFieldStackView!
    @IBOutlet weak var newTextStack: TextFieldStackView!
    @IBOutlet weak var confirmTextStack: TextFieldStackView!
    
    @IBOutlet weak var setPasswordButton: ActionButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var errorOldPasswordLabel: UILabel!
    @IBOutlet weak var errorNewPasswordLabel: UILabel!
    @IBOutlet weak var errorNewMatchesOldPasswordLabel: UILabel!
    @IBOutlet weak var errorConfirmPasswordLabel: UILabel!
    
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    @IBOutlet weak var setPasswordButtonWidth: NSLayoutConstraint!
    
    var observerSet = false
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.clearRightBarItems = true
        super.viewDidLoad()

        errorOldPasswordLabel.isHidden = true
        
        contentWidth.constant = view.getWidthConstant()
        setPasswordButtonWidth.constant = UIDevice.current.userInterfaceIdiom == .phone ? view.getWidthConstant() : view.getWidthConstant(specificPercent: 26)
        
        setEyeIcon()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.successPassword(notif:)), name: NSNotification.Name("SetPasswordNotif"), object: nil)
        observerSet = true
        
        setupTextFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !observerSet{
            NotificationCenter.default.addObserver(self, selector: #selector(self.successPassword(notif:)), name: NSNotification.Name("SetPasswordNotif"), object: nil)
            observerSet = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent{
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("SetPasswordNotif"), object: nil)
            observerSet = false
        }
    }
    
    @IBAction func changePasswordTapped(_ sender: Any) {
        if !isValid(){
            return
        }
        attemptConfirmChangePassword()
    }
    
    // disable signin button and check for user input into text fields
    func setupTextFields() {
        setPasswordButton.isEnabled = false
        
        oldTextStack.tf.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                        for: .editingChanged)
        newTextStack.tf.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                        for: .editingChanged)
        confirmTextStack.tf.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                        for: .editingChanged)
    }
    
    func hideErrorMessages() {
        errorOldPasswordLabel.isHidden = true
        errorNewPasswordLabel.isHidden = true
        errorNewMatchesOldPasswordLabel.isHidden = true
        errorConfirmPasswordLabel.isHidden = true
        confirmTextStack.allowErrorImage = false
        newTextStack.allowErrorImage = false
        newTextStack.resetErrorMessage()
        confirmTextStack.resetErrorMessage()
    }
    func inputHiglightError()  {
        confirmTextStack.allowErrorImage = true
        newTextStack.allowErrorImage = true
        confirmTextStack.setErrorMessage(message: "")
        newTextStack.setErrorMessage(message: "")
    }
    func setEyeIcon()  {
        oldTextStack.setup(title: "Old Password", toggle: true)
        newTextStack.setup(title: "New Password", toggle: true)
        confirmTextStack.setup(title: "Confirm New Password", toggle: true)
    }
    
    func isValid() -> Bool {
        hideErrorMessages()
        
        oldTextStack.resetErrorMessage()
        newTextStack.resetErrorMessage()
        confirmTextStack.resetErrorMessage()
        
        var valid = true
        
        // blank password
        if oldTextStack.tf.text == "" {
            self.errorOldPasswordLabel.text = "Incorrect old password"
            self.errorOldPasswordLabel.isHidden = false
            
            //oldTextStack.setErrorMessage(message: "Incorrect old password") MARK: former implementation
            
            valid = false
        }
        
        // old password == new password
       else if oldTextStack.tf.text == newTextStack.tf.text{
            self.errorNewMatchesOldPasswordLabel.text = "New password matches old password"
            self.errorNewMatchesOldPasswordLabel.isHidden = false
            
            valid = false
        }
        
        // new password != new password
        else if confirmTextStack.tf.text != newTextStack.tf.text {
            self.errorConfirmPasswordLabel.text = "New passwords do not match"
            self.errorConfirmPasswordLabel.isHidden = false
            inputHiglightError()
            valid = false
        }
        
        // not complex enough
        else if !isValidPassword(passedPswd: newTextStack.tf.text ?? ""){
            self.errorNewPasswordLabel.text = "Password does not meet the complexity requirements"
            self.errorNewPasswordLabel.isHidden = false
            inputHiglightError()
            
            valid = false
        }
        
        return valid
    }
    
    func isValidPassword(passedPswd: String) -> Bool{
        let password = passedPswd.trimmingCharacters(in: .whitespaces)
        let passwordRegx = "^(?=.*[!@#$&*%])(?=.*?[0-9]).{8,}$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@", passwordRegx)
        return passwordCheck.evaluate(with: password)
    }
    
    func attemptConfirmChangePassword(){
        AccountManager.sharedInstance.confirmChangePassword(oldPassword: oldTextStack.tf.text!, newPassword: newTextStack   .tf.text!) { success, errorMessage in
            if success{
                let vc = PasswordChangedSuccessPopupViewController()
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: false)
            }
            else{
                self.errorOldPasswordLabel.text = errorMessage
                self.errorOldPasswordLabel.isHidden = false
            }
                
        }
    }
    
    @objc func successPassword(notif:Notification){
        self.navigationController?.popViewController(animated: true)
    }
    
    // no text in email and password fields? Sign in button disabled
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
      sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        setEyeIcon()
        // new, old, & confirm password isEmpty
        guard
            let newPassword = newTextStack.tf.text, !newPassword.isEmpty,
            let oldPassword = oldTextStack.tf.text, !oldPassword.isEmpty,
            let confirmPassword = confirmTextStack.tf.text, !confirmPassword.isEmpty
        
        else {
            hideErrorMessages()
            setEyeIcon()
            self.setPasswordButton.isEnabled = false
            return
        }
        
        // !isEmpty
        setPasswordButton.isEnabled = true
    }
}
