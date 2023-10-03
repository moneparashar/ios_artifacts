//
//  SetPinViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 5/18/21.
//

import UIKit

class SetPinViewController: BaseNavViewController, UITextFieldDelegate {

    @IBOutlet weak var pinMD: MDTextFieldView!
    @IBOutlet weak var pinConfirmMD: MDTextFieldView!
    
    @IBOutlet weak var newPinView: PinView!
    @IBOutlet weak var confirmPinView: PinView!
    
    @IBOutlet weak var setPinButton: UIButton!
    
    @IBOutlet weak var errorPINdigitLabel: UILabel!
    
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    @IBOutlet weak var newPinWidth: NSLayoutConstraint!
    @IBOutlet weak var confirmPinWidth: NSLayoutConstraint!
    @IBOutlet weak var setPinWidth: NSLayoutConstraint!
    
    var pw = ""
    var username = ""
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.clearRightBarItems = true
        super.goBackPrompt = true
        super.viewDidLoad()
        
        super.delegate = self

        
        contentWidth.constant = view.getWidthConstant()
        if UIDevice.current.userInterfaceIdiom == .phone{
            newPinWidth.constant = view.getWidthConstant(specificPercent: 56)
            confirmPinWidth.constant = view.getWidthConstant(specificPercent: 56)
            setPinWidth.constant = view.getWidthConstant()
        }
        else{
            newPinWidth.constant = view.getWidthConstant(specificPercent: 26)
            confirmPinWidth.constant = view.getWidthConstant(specificPercent: 26)
            setPinWidth.constant = view.getWidthConstant(specificPercent: 26)
        }
        
        errorPINdigitLabel.text = " "
        setupPinFields()
    }
    

    @IBAction func setPinButtonTapped(_ sender: Any) {
        if isPinValid(){
            var accountData = KeychainManager.sharedInstance.loadAccountData()
            if accountData == nil{
                accountData = AccountData()
            }
            accountData?.pinValue = newPinView.getPIN()
            KeychainManager.sharedInstance.saveAccountData(data: accountData!)
            
            /* eula is accepted by then
            //check if eula was accepted
            if ((accountData?.userModel?.acceptedEULA) != nil){
                print(accountData?.userModel?.acceptedEULA)
                if accountData!.userModel!.acceptedEULA! == true{
                    
                    //should probably go straight to
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = mainStoryboard.instantiateViewController(withIdentifier: "PatientMainViewController")
                    //let vc = mainStoryboard.instantiateViewController(withIdentifier: "StartNav")
                    NavigationManager.sharedInstance.setRootViewController(viewController: vc)
                }
                else{
                    self.performSegue(withIdentifier: "GoEula", sender: self)
                }
            }
            else{
                self.performSegue(withIdentifier: "GoEula", sender: self)
            }
            
            */
            
            let vc = PatientMainViewController()
            NavigationManager.sharedInstance.setRootViewController(viewController: vc)
 
        }
    }
    
    // disable signin button and check for user input into pin fields
    func setupPinFields() {
        setPinButton.isEnabled = false
        
        newPinView.pinTextFieldsArray[3].addTarget(self, action: #selector(PINFieldsIsNotEmpty), for: .allEditingEvents)
        confirmPinView.pinTextFieldsArray[3].addTarget(self, action: #selector(PINFieldsIsNotEmpty), for: .allEditingEvents)
    }
    
    func isPinValid() -> Bool{
        errorPINdigitLabel.text = " "
        
        let pin = newPinView.getPIN()
        let pinConfirm = confirmPinView.getPIN()
        
        // Check how many values we need
        if pin.count != 4 {
            errorPINdigitLabel.text = "Please enter a four digit PIN"
            return false
        }
        else if pin != pinConfirm{
            errorPINdigitLabel.text = "PINs do not match"
            confirmPinHighlightError()

            return false
        }
        
        
        return true
    }
    func confirmPinHighlightError(){
        confirmPinView.pinTextFieldsArray[0].layer.borderColor = UIColor.red.cgColor
        confirmPinView.pinTextFieldsArray[1].layer.borderColor = UIColor.red.cgColor
        confirmPinView.pinTextFieldsArray[2].layer.borderColor = UIColor.red.cgColor
        confirmPinView.pinTextFieldsArray[3].layer.borderColor = UIColor.red.cgColor
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
    
    // no pin in fields? Set pin button disabled
    @objc func PINFieldsIsNotEmpty(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        // last pin field isEmpty
        guard
            let newPin = newPinView.pinTextFieldsArray[3].text, !newPin.isEmpty,
            let confirmPin = confirmPinView.pinTextFieldsArray[3].text, !confirmPin.isEmpty
        
        else {
            self.errorPINdigitLabel.text = " "
            self.setPinButton.isEnabled = false
            return
        }
        
        // !isEmpty
        setPinButton.isEnabled = true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.destination is EulaViewController{
            let vc = segue.destination as? EulaViewController
            vc?.pw = pw
            vc?.username = username
            vc?.loggedIn = false
        }
    }
    

}

extension SetPinViewController: BackPromptDelegate{
    func goBackSelected() {
        if let accountData = KeychainManager.sharedInstance.accountData{
            accountData.roles = []
            KeychainManager.sharedInstance.saveAccountData(data: accountData)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
