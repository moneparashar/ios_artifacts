//
//  SignUpViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 6/18/21.
//

import UIKit

class SignUpViewController: BaseNavViewController {
    
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var pinContainerView: UIView!
    @IBOutlet weak var invalidAccessLabel: UILabel!
    
    
    @IBOutlet weak var passwordTextStack: TextFieldStackView!
    @IBOutlet weak var confirmTextStack: TextFieldStackView!
    
    @IBOutlet weak var actionButton: ActionButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    
    @IBOutlet weak var formWidth: NSLayoutConstraint!
    
    
    let passedUsername = AccountManager.sharedInstance.username
    
    var observerSet = false
    
    let accessPINView = PinView(fieldNum: 6)
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.clearRightBarItems = true
        super.viewDidLoad()

        contentWidth.constant = view.getWidthConstant()
        if UIDevice.current.userInterfaceIdiom == .phone{
            buttonStackView.arrangedSubviews[0].isHidden = true
            buttonStackView.arrangedSubviews[2].isHidden = true
            
            formWidth.constant = contentWidth.constant
        }else {
            formWidth.priority = UILayoutPriority(rawValue: 1000)
            formWidth.constant = view.getWidthConstant(specificPercent: 40)
        }
        
        accessPINView.translatesAutoresizingMaskIntoConstraints = false
        pinContainerView.addSubview(accessPINView)
        
        NSLayoutConstraint.activate([
            accessPINView.topAnchor.constraint(equalTo: pinContainerView.topAnchor),
            accessPINView.centerYAnchor.constraint(equalTo: pinContainerView.centerYAnchor),
            accessPINView.leadingAnchor.constraint(equalTo: pinContainerView.leadingAnchor),
            accessPINView.centerXAnchor.constraint(equalTo: pinContainerView.centerXAnchor)
        ])
        setEyeIcon()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.successPassword(notif:)), name: NSNotification.Name("SetPasswordNotif"), object: nil)
        observerSet = true
    }
    
    func setEyeIcon()  {
        passwordTextStack.setup(title: "Password", toggle: true)
        confirmTextStack.setup(title: "Confirm Password", toggle: true)
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
    
    @objc func successPassword(notif: Notification){
        let initialViewController = NonSignedInMainViewController()
        NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
    }
    
    func setupView(){
        
    }
    
    func isValid() -> Bool{
        invalidAccessLabel.text = " "
        passwordTextStack.resetErrorMessage()
        confirmTextStack.resetErrorMessage()
        var valid = true
        if accessPINView.getPIN() == ""{
            invalidAccessLabel.text = "Access code required"
            
            valid = false
        }
        if passwordTextStack.tf.text == ""{
            passwordTextStack.setErrorMessage(message: "Password required")
            errorMessageLabel.text = "One or more required fields were not filled"
            valid = false
        }
        else if !isValidPassword(passedPswd: passwordTextStack.tf.text ?? ""){
            passwordTextStack.setErrorMessage(message: "")
            confirmTextStack.setErrorMessage(message: "")
            errorMessageLabel.text = "Password does not meet the complexity requirements"
            valid = false
            errorMessageLabel.isHidden = false
        }
        if confirmTextStack.tf.text == ""{
            confirmTextStack.setErrorMessage(message: "Confirm password required")
            errorMessageLabel.text = "One or more required fields were not filled"
            valid = false
        }
        else if passwordTextStack.tf.text != confirmTextStack.tf.text {
            errorMessageLabel.text = "Passwords do not match"
            passwordTextStack.setErrorMessage(message: "")
            confirmTextStack.setErrorMessage(message: "")
            valid = false
            errorMessageLabel.isHidden = false
        }
        setEyeIcon()
        return valid
    }
    
    func isValidPassword(passedPswd: String) -> Bool{
        let password = passedPswd.trimmingCharacters(in: .whitespaces)
        let passwordRegx = "^(?=.*[!@#$&*])(?=.*?[0-9]).{8,}$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@", passwordRegx)
        return passwordCheck.evaluate(with: password)
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        errorMessageLabel.isHidden = true
        if !isValid(){
            return
        }
        showLoading()
        attemptConfirmForgotPassword()
    }
    
    func attemptConfirmForgotPassword() {
        AccountManager.sharedInstance.confirmForgotPassword(username: passedUsername, newPassword: passwordTextStack.tf.text!, confirmationCode: accessPINView.getPIN()) { success, didSend, errorMessage in
            self.hideLoading()
            if success{
                
                Slim.info("Clear Account Data Being Called")
                KeychainManager.sharedInstance.clearAccountData()
                let vc = PasswordChangedSuccessPopupViewController()
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: false)
            }
            else{
                self.errorMessageLabel.text = errorMessage
                self.errorMessageLabel.isHidden = false
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SetPinViewController{
            let vc = segue.destination as? SetPinViewController
            vc?.pw = passwordTextStack.tf.text!
            vc?.username = passedUsername
        }
    }
    

}
