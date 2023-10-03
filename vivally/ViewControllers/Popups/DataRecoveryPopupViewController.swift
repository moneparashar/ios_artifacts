//
//  DataRecoveryPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 4/5/23.
//

import UIKit
import CoreBluetooth

class DataRecoveryPopupViewController: BasePopupViewController {

    var rootStack = UIStackView()
    var allStack = UIStackView()
    
    var icon = UIImageView(image: PopupIcons.check.getIconImage())
    var titleLabel = UILabel()
    var messageLabel = UILabel()
    
    var progressStack = UIStackView()
    var progressBar = UIProgressView()
    var progressLabel = UILabel()
    
    var singleButtonStack = UIStackView()
    var stopButton = ActionButton()
    var okButton = ActionButton()
    
    var contentPadding:CGFloat = 24
    
    var progressStr = "0"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPopupStack()
        stopButton.addTarget(self, action: #selector(tappedStop), for: .touchUpInside)
        
        okButton.addTarget(self, action: #selector(tappedOK), for: .touchUpInside)
        okButton.isHidden = true
        
        DataRecoveryManager.sharedInstance.delegate = self
        if BluetoothManager.sharedInstance.isConnectedToDevice(){
            DataRecoveryManager.sharedInstance.recoverData()
            
            ActivityManager.sharedInstance.stopActivityTimers()
        }
        else{
            BluetoothManager.sharedInstance.delegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.badTimeNotify(notif:)), name: NSNotification.Name("badTimestamp"), object: nil)
    }
    
    @objc func badTimeNotify(notif:Notification){
        dismiss(animated: false)
    }
    
    @objc func tappedStop(_ sender: UIButton){
        BluetoothManager.sharedInstance.sendCommand(command: .clearDataRecovery, parameters: [])
        DataRecoveryManager.sharedInstance.removeRecovery()
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.interuptDataRecovery.rawValue), object: nil)
        dismiss(animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            NetworkManager.sharedInstance.sendBulkStimAndEMGData(){}
            NetworkManager.sharedInstance.sendTherapyOnlyData(){}
        }
    }
    
    @objc func tappedOK(_sender: UIButton){
        dismiss(animated: false)
    }

    func setupPopupStack(){
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
        titleLabel.text = "Transferring last session data"
        
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.bodyMed
        messageLabel.textColor = UIColor.fontBlue
        messageLabel.numberOfLines = 0
        messageLabel.text = "Controller disconnected in your last session. We are saving your data, please wait. If you would like to skip the transfer, press Stop."
        
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
        
        stopButton.setTitle("Stop", for: .normal)
        okButton.setTitle("Ok", for: .normal)
        
        singleButtonStack = UIStackView(arrangedSubviews: [stopButton, okButton])
        singleButtonStack.translatesAutoresizingMaskIntoConstraints = false
        singleButtonStack.arrangedSubviews[0].setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        singleButtonStack.arrangedSubviews[1].setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        allStack = UIStackView(arrangedSubviews: [iconParentView, titleLabel, messageLabel, progressStack, singleButtonStack])
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
    
    func updateProgress(){
        if DataRecoveryManager.sharedInstance.progress != nil{
            let progress = Float(DataRecoveryManager.sharedInstance.progress ?? 0)
            let progressText = String(format: "%.0f", progress)
            
            if progressText != progressStr && !progress.isNaN{
                progressStr = progressText
                progressLabel.text = progressText + "%"
                let progressPass = (progress / 100).isNaN ? 0 : progress / 100
                progressBar.progress = progressPass
            }
        }
    }
    
    func finished(success: Bool = true){
        if success{
            titleLabel.text = "Data Recovered"
            messageLabel.text = "Controller data recovered successfully. Please press the Controller's power button for 4 seconds to turn it OFF, then press again to turn it ON, and then tap OK"
            progressStack.isHidden = true
            okButton.isHidden = false
            stopButton.isHidden = true
            
            BluetoothManager.sharedInstance.sendCommand(command: .clearDataRecovery, parameters: [])
            DataRecoveryManager.sharedInstance.removeRecovery()
            DataRecoveryManager.sharedInstance.recoveryComplete = true
            
            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.finishTherapyRecovery.rawValue), object: nil)
            
            ActivityManager.sharedInstance.resetInactivityCount()
        }
        else{
            failedRecovery()
        }
    }
    
    func failedRecovery(){
        titleLabel.text = "Transferring last session data failed"
        messageLabel.text = "Last session data was not saved"
        progressStack.isHidden = true
        okButton.isHidden = false
        stopButton.isHidden = true
        
        BluetoothManager.sharedInstance.sendCommand(command: .clearDataRecovery, parameters: [])
        DataRecoveryManager.sharedInstance.removeRecovery()
        
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.interuptDataRecovery.rawValue), object: nil)
    }
}

extension DataRecoveryPopupViewController: DataRecoveryManagerDelegate{
    func dataRecoveryProgressUpdated() {
        updateProgress()
    }
    
    func dataRecoveryFinished(noError: Bool) {
        finished(success: noError)
    }
    
    
}
extension DataRecoveryPopupViewController: BluetoothManagerDelegate{
    func didDiscoverDevice(discoveredDevice: DiscoveredDevice) {}
    
    func didConnectToDevice(device: CBPeripheral) {
        DataRecoveryManager.sharedInstance.recoverData()
    }
    
    func didDisconnectFromDevice(device: CBPeripheral) {
        dismiss(animated: false)
        ActivityManager.sharedInstance.resetInactivityCount()
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
