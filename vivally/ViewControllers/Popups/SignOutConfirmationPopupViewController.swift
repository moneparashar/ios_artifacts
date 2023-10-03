//
//  SignOutConfirmationPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 4/18/23.
//

import UIKit

class SignOutConfirmationPopupViewController: BasePopupViewController {

    var popStack = UIStackView()
    
    var icon = UIImageView()
    var titleLabel = UILabel()
    var messageLabel = UILabel()
    
    var signOutAskStack = UIStackView()
    var signOutButton = ActionButton()
    var cancelButton = ActionButton()
    
    var okView = UIView()
    var okButton = ActionButton()
    
    var contentPadding:CGFloat = 24
    
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPopup()
        checkUpload()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkUpload), userInfo: nil, repeats: true)
    }
    

    func setupPopup(){
        icon = UIImageView(image: PopupIcons.question.getIconImage())
        let iconParentView = UIView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconParentView.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: iconParentView.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconParentView.centerYAnchor),
            icon.leadingAnchor.constraint(greaterThanOrEqualTo: iconParentView.leadingAnchor),
            icon.topAnchor.constraint(equalTo: iconParentView.topAnchor),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1)
        ])
        
        titleLabel.text = "Sign Out"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.h4
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.numberOfLines = 0
        
        messageLabel.text = "Are you sure you want to Sign out?"
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.bodyMed
        messageLabel.textColor = UIColor.fontBlue
        messageLabel.numberOfLines = 0
        
        signOutButton.setTitle("Sign out", for: .normal)
        signOutButton.toSecondary()
        cancelButton.setTitle("Cancel", for: .normal)
        signOutAskStack = UIStackView(arrangedSubviews: [signOutButton, cancelButton])
        signOutAskStack.distribution = .fillEqually
        signOutAskStack.spacing = 24
        
        okButton.setTitle("OK", for: .normal)
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            popStack = UIStackView(arrangedSubviews: [iconParentView, titleLabel, messageLabel, signOutAskStack, okView])
        }
        else{
            okButton.translatesAutoresizingMaskIntoConstraints = false
            okView.addSubview(okButton)
            NSLayoutConstraint.activate([
                okButton.centerXAnchor.constraint(equalTo: okView.centerXAnchor),
                okButton.centerYAnchor.constraint(equalTo: okView.centerYAnchor),
                okButton.leadingAnchor.constraint(greaterThanOrEqualTo: okView.leadingAnchor),
                okButton.topAnchor.constraint(equalTo: okView.topAnchor)
            ])
            
            popStack = UIStackView(arrangedSubviews: [iconParentView, titleLabel, messageLabel, signOutAskStack, okView])
        }
        
        popStack.axis = .vertical
        popStack.alignment = .fill
        popStack.distribution = .fill
        popStack.spacing = 24
        
        UIDevice.current.userInterfaceIdiom == .phone ? setPhoneLayouts() : setTabletLayouts()
        
        okButton.isHidden = true
        
        signOutButton.addTarget(self, action: #selector(signoutTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        okButton.addTarget(self, action: #selector(okTapped), for: .touchUpInside)
    }
    
    var rootStack = UIStackView()
    func setTabletLayouts(){
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        
        rootStack = UIStackView(arrangedSubviews: [leftSpacer, popStack, rightSpacer])
        rootStack.alignment = .top
        rootStack.distribution = .equalSpacing
        
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
            rootStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            //rootStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentPadding),
            rootStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            rootStack.arrangedSubviews[1].widthAnchor.constraint(equalToConstant: view.getWidthConstant())
        ])
    }
    
    func setPhoneLayouts(){
        popStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(popStack)
        NSLayoutConstraint.activate([
            popStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
            popStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            //popStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            popStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentPadding),
            popStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }
   
    @objc func signoutTapped(){
        let appData = AppManager.sharedInstance.loadAppDeviceData()
        let appId = appData!.appIdentifier
        if NetworkManager.sharedInstance.connected{
            NotificationManager.sharedInstance.postPushNotificationUnRegister(appId: appId) { success, errorMessage in
                if !success{
                    Slim.error(errorMessage)
                }
            }
        }
        
        
        // Access AppDelegate and call the showSplashScreen method for animation
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.SplashScreenTiming()
        }
        
        BluetoothManager.sharedInstance.stopAllStimulation()
        NetworkManager.sharedInstance.logoutClear()
        DataRecoveryManager.sharedInstance.removeRecovery()
    }
    
    @objc func cancelTapped(){
        dismiss(animated: false)
    }
    
    @objc func okTapped(){
        dismiss(animated: false)
    }
    
    
    @objc func checkUpload(){
        if NetworkManager.sharedInstance.checkIfStillSending(){
            messageLabel.text = "Data is still being processed. Please try to sign out again later."
            if !signOutAskStack.isHidden{
                signOutAskStack.isHidden = true
                okButton.isHidden = false
            }
        }
        else{
            messageLabel.text = "Are you sure you want to Sign out?"
            if signOutAskStack.isHidden{
                okButton.isHidden = true
                signOutAskStack.isHidden = false
            }
        }
    }

}
