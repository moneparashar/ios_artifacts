//
//  RecoverFirmwarePopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 3/8/23.
//

import UIKit
import CoreBluetooth

class RecoverFirmwarePopupViewController: BasePopupViewController{
    var rootStack = UIStackView()
    var allStack = UIStackView()
    
    var icon = UIImageView()
    var titleLabel = UILabel()
    var messageLabel = UILabel()
    
    var progressStack = UIStackView()
    var progressBar = UIProgressView()
    var progressLabel = UILabel()
    
    var askButtonStack = UIStackView()
    var cancelButton = ActionButton()
    var confirmUpdateButton = ActionButton()
    
    var singleButtonStack = UIStackView()
    var okButton = ActionButton()           //update fails
    var continueButton = ActionButton()     //update succeeds
    
    var contentPadding:CGFloat = 24
    
    var currentState:FirmwareUpdateState = .askConfirmation
    var progressStr = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPopupStack()
        
        cancelButton.addTarget(self, action: #selector(tappedCancel(_:)), for: .touchUpInside)
        confirmUpdateButton.addTarget(self, action: #selector(tappedConfirm(_:)), for: .touchUpInside)
        okButton.addTarget(self, action: #selector(tappedOk(_:)), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(tappedContinue(_:)), for: .touchUpInside)
        
        
        changedState()
    }
    
    func testviews(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.currentState = .updateInProgress
            OTAManager.sharedInstance.progress = 75
            self.updateProgress()
            self.changedState()
            
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.currentState = .firmwareFailed
                self.changedState()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    self.currentState = .firmwareUpdated
                    self.changedState()
                }
            }
        }
    }
    
    @objc func tappedCancel(_ sender: UIButton){
        dismiss(animated: false)
    }
    
    @objc func tappedConfirm(_ sender: UIButton){
        confirmUpdateButton.isEnabled = false
        startOTA()
    }
    
    @objc func tappedOk(_ sender: UIButton){
        dismiss(animated: false)
    }
    
    @objc func tappedContinue(_ sender: UIButton){
        OTAManager.sharedInstance.updateAvailable = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNames.finishUpdate.rawValue), object: nil)
        dismiss(animated: false)
    }
    

    func setupPopupStack(){
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
        
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.h4
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.numberOfLines = 0
        
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.bodyMed
        messageLabel.textColor = UIColor.fontBlue
        messageLabel.numberOfLines = 0
        
        //progressStack
        progressBar.backgroundColor = UIColor.lavendarMist
        progressBar.progressTintColor = UIColor.androidGreen
        progressBar.layer.cornerRadius = 8
        
        progressLabel.font = UIFont.h4
        progressLabel.textAlignment = .center
        progressLabel.textColor = UIColor.fontBlue
        
        progressStack = UIStackView(arrangedSubviews: [progressBar, progressLabel])
        progressStack.axis = .vertical
        progressStack.distribution = .equalSpacing
        progressStack.spacing = 12
        progressStack.translatesAutoresizingMaskIntoConstraints = false
        
        progressStack.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .vertical)
        progressStack.arrangedSubviews[1].setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            progressStack.arrangedSubviews[0].heightAnchor.constraint(equalToConstant: 20)
        ])
        
        
        cancelButton.setTitle("Cancel", for: .normal)
        confirmUpdateButton.setTitle("Confirm", for: .normal)
        cancelButton.toSecondary()
        
        askButtonStack = UIStackView(arrangedSubviews: [cancelButton, confirmUpdateButton])
        askButtonStack.distribution = .fillEqually
        askButtonStack.spacing = 24
        
        okButton.setTitle("Ok", for: .normal)
        continueButton.setTitle("Continue", for: .normal)
        singleButtonStack = UIStackView(arrangedSubviews: [okButton, continueButton])
        singleButtonStack.translatesAutoresizingMaskIntoConstraints = false
        singleButtonStack.arrangedSubviews[0].setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        singleButtonStack.arrangedSubviews[1].setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        allStack = UIStackView(arrangedSubviews: [iconParentView, titleLabel, messageLabel, progressStack, askButtonStack, singleButtonStack])
        allStack.axis = .vertical
        allStack.alignment = .fill
        allStack.distribution = .fill
        allStack.spacing = 30
        
        UIDevice.current.userInterfaceIdiom == .phone ? setPhoneLayouts() : setTabletLayouts()
    }
    
    func setTabletLayouts(){
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        rootStack = UIStackView(arrangedSubviews: [leftSpacer, allStack, rightSpacer])
        rootStack.alignment = .top
        rootStack.distribution = .equalSpacing
        
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
            rootStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            rootStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentPadding),
            rootStack.arrangedSubviews[1].widthAnchor.constraint(equalToConstant: view.getWidthConstant())
        ])
    }
    
    func setPhoneLayouts(){
        allStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(allStack)
        
        NSLayoutConstraint.activate([
            allStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
            allStack.centerXAnchor.constraint(equalTo:  contentView.centerXAnchor),
            allStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            allStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentPadding),
        ])
    }
    
    func changedState(){
        askButtonStack.isHidden = true
        progressStack.isHidden = true
        singleButtonStack.isHidden = true
        
        switch currentState {
        case .askConfirmation:
            titleLabel.text = "Recover Firmware"
            icon.image = PopupIcons.question.getIconImage()
            messageLabel.text = "Updating the firmware will take a couple of minutes, please do not turn OFF the Controller or the App during the update"
            askButtonStack.isHidden = false
        case .updateInProgress:
            titleLabel.text = "Firmware Updating"
            icon.image = PopupIcons.exclamation.getIconImage()
            messageLabel.text = "Updating Controller firmware. Please wait...\nDo not turn OFF the Controller and do not close the App until firmware update has completed."
            progressStack.isHidden = false
        case .firmwareUpdated:
            titleLabel.text = "Firmware Updated"
            icon.image = PopupIcons.check.getIconImage()
            messageLabel.text = "Controller firmware updated successfully.\nPlease press the Controller's power button for 4 seconds to turn it OFF, then press and release the power button again. Once your Controller has powered back ON, click the Continue button below."
            okButton.isHidden = true
            continueButton.isHidden = false
            singleButtonStack.isHidden = false
        case .firmwareFailed:
            titleLabel.text = "Recover firmware failed"
            icon.image = PopupIcons.warning.getIconImage()
            messageLabel.text = "Please press the Controller's power button for 4 seconds to turn it OFF, then press again to turn it ON and then tap on Recovery button."
            continueButton.isHidden = true
            singleButtonStack.isHidden = false
        }
    }
    
    func startOTA(){
        if BluetoothManager.sharedInstance.isConnectedToDevice() && OTAManager.sharedInstance.OTAMode{
            OTAManager.sharedInstance.delegate = self
            BluetoothManager.sharedInstance.delegate = self
            
            BluetoothManager.sharedInstance.handleOTA()
            
            currentState = .updateInProgress
            progressLabel.text = "0%"
            changedState()
        }
    }
    
    func updateProgress(){
        if OTAManager.sharedInstance.progress != nil {
            let progress = Float(OTAManager.sharedInstance.progress ?? 0)
            let progressText = String(format: "%.0f", progress)
            
            if progressText != progressStr && !progress.isNaN{
                progressStr = progressText
                progressLabel.text = progressText + "%"
                let progressPass = (progress / 100).isNaN ? 0 : progress / 100
                progressBar.progress = progressPass
            }
        }
    }
}

extension RecoverFirmwarePopupViewController: BluetoothManagerDelegate{
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {
    }
    
    func didConnectToDevice(device: CBPeripheral) {
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        if currentState != .askConfirmation{
            if OTAManager.sharedInstance.progress != 100{
                currentState = .firmwareFailed
                changedState()
            }
            hideLoading()
        }
    }
    
    func didBLEChange(on: Bool) {}
    
    func didUpdateData() {}
    
    func didUpdateStimStatus() {}
    
    func didUpdateEMG() {}
    func didUpdateBattery(){}
    func didUpdateTherapySession() {}
    
    func didBondFail() {}
    
    func didUpdateDevice() {}
    
    func foundOngoingTherapy() {}
    func pairingTimeExpired() {}
}

extension RecoverFirmwarePopupViewController: OTAManagerDelegate{
    func stateUpdated() {
        if OTAManager.sharedInstance.state == .flashing{
            updateProgress()
        }
        else if OTAManager.sharedInstance.state == .completed{
            currentState = .firmwareUpdated
            changedState()
        }
    }
    
    
}
