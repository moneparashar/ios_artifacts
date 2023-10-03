//
//  ChangePinViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 5/18/21.
//

import UIKit

class ChangePinViewController: BaseNavViewController, UITextFieldDelegate  {

    @IBOutlet weak var oldPin: PinView!
    @IBOutlet weak var newPin: PinView!
    @IBOutlet weak var confrimPin: PinView!
    
    @IBOutlet weak var setPinButton: UIButton!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var errorMessageLabelTwo: UILabel!
    
    @IBOutlet weak var incorrectPinErrorLabel: UILabel!
    @IBOutlet weak var oldPinWidth: NSLayoutConstraint!
    @IBOutlet weak var newPinWidth: NSLayoutConstraint!
    @IBOutlet weak var confirmPinWidth: NSLayoutConstraint!
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    @IBOutlet weak var setPinButtonWidth: NSLayoutConstraint!
    
    var observerSet = false
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.clearRightBarItems = true
        super.viewDidLoad()

        setupPinFields()
        setupErrorMessages()
        // Do any additional setup after loading the view.
        
        contentWidth.constant = view.getWidthConstant()
        setPinButtonWidth.constant = UIDevice.current.userInterfaceIdiom == .phone ? view.getWidthConstant() : view.getWidthConstant(specificPercent: 26)
        
        let allPINWidths = [oldPinWidth, newPinWidth, confirmPinWidth]
        for wid in allPINWidths{
            wid?.constant = UIDevice.current.userInterfaceIdiom == .phone ? view.getWidthConstant(specificPercent: 56) : view.getWidthConstant(specificPercent: 26)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.successPIN(notif:)), name: NSNotification.Name("SetPINNotif"), object: nil)
        observerSet = true
    }
    
    @objc func successPIN(notif:Notification){
        
        self.navigationController?.popViewController(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !observerSet{
            NotificationCenter.default.addObserver(self, selector: #selector(self.successPIN(notif:)), name: NSNotification.Name("SetPINNotif"), object: nil)
            observerSet = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent{
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("SetPINNotif"), object: nil)
            observerSet = false
        }
    }
    
    // disable signin button and check for user input into pin fields
    func setupPinFields() {
        setPinButton.isEnabled = false
        oldPin.isUserInteractionEnabled = true
        newPin.isUserInteractionEnabled = true
        confrimPin.isUserInteractionEnabled = true
        
        oldPin.pinTextFieldsArray[3].addTarget(self, action: #selector(PINFieldsIsNotEmpty), for: .allEditingEvents)
        newPin.pinTextFieldsArray[3].addTarget(self, action: #selector(PINFieldsIsNotEmpty), for: .allEditingEvents)
        confrimPin.pinTextFieldsArray[3].addTarget(self, action: #selector(PINFieldsIsNotEmpty), for: .allEditingEvents)
    }
    
    func setupErrorMessages() {
        errorMessageLabel.isHidden = true
        incorrectPinErrorLabel.isHidden = true
        errorMessageLabelTwo.isHidden = true
        errorMessageLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
        errorMessageLabelTwo.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
    }
    
    func isValid() -> Bool {
        errorMessageLabel.text = ""
        var valid = true
        _ = KeychainManager.sharedInstance.loadAccountData()
        let oldPinVal = KeychainManager.sharedInstance.accountData!.pinValue
        
        if oldPin.getPIN() == ""{
            errorMessageLabel.isHidden = false
            incorrectPinErrorLabel.isHidden = true
            errorMessageLabel.text = "Old PIN required"

            
            valid = false
        }
        else if oldPin.getPIN() != oldPinVal{
            incorrectPinErrorLabel.isHidden = false
            errorMessageLabel.text =  "Incorrect old PIN"
            oldPinHighlightError()
            valid = false
        }
        
        else if newPin.getPIN() == ""{
            errorMessageLabelTwo.isHidden = false
            incorrectPinErrorLabel.isHidden = true
            errorMessageLabelTwo.text =  "New PIN required"
            
            valid = false
            
        } else if newPin.getPIN().count != 4 {
            errorMessageLabelTwo.isHidden = false
            incorrectPinErrorLabel.isHidden = true
            errorMessageLabelTwo.text = "Please enter a four digit PIN"
            
            valid = false
            
        } else if newPin.getPIN() == oldPin.getPIN() {
            errorMessageLabelTwo.isHidden = false
            incorrectPinErrorLabel.isHidden = true
            errorMessageLabelTwo.text = "New PIN matches old PIN"
            
            valid = false
        }
        else if confrimPin.getPIN() == "" {
            errorMessageLabelTwo.isHidden = false
            incorrectPinErrorLabel.isHidden = true
            errorMessageLabelTwo.text = "Confirm new PIN required"
            
            valid = false
            
        } else if newPin.getPIN() != confrimPin.getPIN() {
            errorMessageLabelTwo.isHidden = false
            incorrectPinErrorLabel.isHidden = true
            errorMessageLabelTwo.text = "New PINs do not match"
            
            valid = false
        }
        
        return valid
    }
    func oldPinHighlightError(){
        oldPin.pinTextFieldsArray[0].layer.borderColor = UIColor.red.cgColor
        oldPin.pinTextFieldsArray[1].layer.borderColor = UIColor.red.cgColor
        oldPin.pinTextFieldsArray[2].layer.borderColor = UIColor.red.cgColor
        oldPin.pinTextFieldsArray[3].layer.borderColor = UIColor.red.cgColor
    }
    
    func hideErrorMessages() {
        errorMessageLabel.isHidden = true
        errorMessageLabelTwo.isHidden = true
    }
    
    @IBAction func changePinButtonTapped(_ sender: Any) {
        if !isValid(){
            return
        }
        
        let accountData = KeychainManager.sharedInstance.accountData
        accountData?.pinValue = newPin.getPIN()
        KeychainManager.sharedInstance.saveAccountData(data: accountData!)
        
        let vc = PinChangedSuccessPopupViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // make sure the result is under 4 characters
        return updatedText.count <= 4
    }
    
    // no pin in fields? Pin button disabled
    @objc func PINFieldsIsNotEmpty(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        // last pin field isEmpty
        guard
            let oldPinCheck = oldPin.pinTextFieldsArray[3].text, !oldPinCheck.isEmpty,
            let newPinCheck = newPin.pinTextFieldsArray[3].text, !newPinCheck.isEmpty,
            let confirmPinCheck = confrimPin.pinTextFieldsArray[3].text, !confirmPinCheck.isEmpty
        
        
        else {
            hideErrorMessages()
            self.setPinButton.isEnabled = false
            return
        }
        
        // !isEmpty
        setPinButton.isEnabled = true
    }
}
