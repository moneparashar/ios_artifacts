//
//  ForgetPasswordViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 5/18/21.
//

import UIKit

class ForgetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: EntryTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        
        //activityIndicator.isHidden = false
        //activityIndicator.startAnimating()
        showLoading()
        
        AccountManager.sharedInstance.forgetPassword(username: emailTextField.text!) { success, didSend, errorMessage in
            //self.activityIndicator.isHidden = true
            //self.activityIndicator.stopAnimating()
            self.hideLoading()
            if success{
                self.sendSuccessMessage()
            }
            else{
                self.errorMessageLabel.text = errorMessage
                self.errorMessageLabel.isHidden = false
            }
        }
    }
    
    func sendSuccessMessage(){
        let message = NSLocalizedString("An email has been sent to update your password.", comment: "")
        let alertController = UIAlertController(title: NSLocalizedString("Alert", comment: ""), message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default) { uiaa in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
