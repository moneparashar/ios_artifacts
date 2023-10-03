//
//  SignOutConfirmationViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 2/10/22.
//

import UIKit

class SignOutConfirmationViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var signOutButton: ActionButton!
    @IBOutlet weak var cancelButton: ActionButton!
    @IBOutlet weak var okButton: ActionButton!
    
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.layer.cornerRadius = 10
        signOutButton.toSecondary()
        
        
        checkUpload()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkUpload), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if timer != nil {
            timer?.invalidate()
        }
        timer = nil
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        Slim.info("Clear Account Data Being Called")
        BluetoothManager.sharedInstance.sendCommand(command: .stopStim, parameters: [])
        KeychainManager.sharedInstance.clearAccountData()
        
        //new attempt with login
        let appData = AppManager.sharedInstance.loadAppDeviceData()
        let appId = appData!.appIdentifier
        if NetworkManager.sharedInstance.connected{
            NotificationManager.sharedInstance.postPushNotificationUnRegister(appId: appId) { success, errorMessage in
                if !success{
                    Slim.error(errorMessage)
                }
            }
        }
        let initialViewController = NonSignedInMainViewController()
        NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
        
        NetworkManager.sharedInstance.logoutClear()
        
        ActivityManager.sharedInstance.loggedOut()
        
        Slim.info("logged out")
    }
        
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func checkUpload(){
        if NetworkManager.sharedInstance.checkIfStillSending(){
            messageLabel.text = "Data is still being processed. Please try to sign out again later."
            
            cancelButton.isHidden = true
            signOutButton.isHidden = true
            okButton.isHidden = false
        }
        else{
            messageLabel.text = "Are you sure you want to Sign out?"
            
            okButton.isHidden = true
            cancelButton.isHidden = false
            signOutButton.isHidden = false
        }
    }
}
