//
//  ChecksFailedPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/19/23.
//

import UIKit

class ChecksFailedPopupViewController: BasicPopupViewController {

    var checkError:TherapyImpError = .foot
    var isLeft = false
    
    override func viewDidLoad() {
        let screeningRunning = ScreeningProcessManager.sharedInstance.screeningRunning
        switch checkError {
        case .continuity:
            baseContent = BasicPopupContent(title: "Controller check failed", message: "Check that the controller is placed firmly in the garment and then tap Continue", option1: screeningRunning ? "Pause" : "Stop", option2: "Continue", xClose: false, icon: .warning, videoMesssage: "Need help? Watch a video about how to place the Gel Cushions")
        case .foot:
            let foot = isLeft ? "LEFT" : "RIGHT"
            baseContent = BasicPopupContent(title: "Foot check failed", message: "Check that the controller is in the inner ankle socket of the \(foot) foot and tap Continue", option1: screeningRunning ? "Pause" : "Stop", option2: "Continue", xClose: false, icon: .warning, videoMesssage: "Need help? Watch a video about how to place the Garment")
        case .impedance:
            baseContent = BasicPopupContent(title: "Garment check failed", message: "Check the gel cushions and garment position and then tap Continue", option1: screeningRunning ? "Pause" : "Stop", option2: "Continue", xClose: false, icon: .warning, videoMesssage: "Need help? Watch a video about how to place the Gel Cushions")
        }
                
        super.viewDidLoad()
    }

    override func tappedOption1(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.callSetupBatteryNotify.rawValue), object: nil)
        if TherapyManager.sharedInstance.therapyRunning{
            TherapyManager.sharedInstance.userStopTherapy()
        }
        else{
            if ScreeningProcessManager.sharedInstance.screeningRunning{
                let stim = BluetoothManager.sharedInstance.informationServiceData.stimStatus
                if stim.state == .running{
                    ScreeningProcessManager.sharedInstance.pauseScreening()
                }
                
                BluetoothManager.sharedInstance.informationServiceData.deviceData.clearErrorValue()
                DeviceErrorManager.sharedInstance.failedImpOverall = false
            }
        }
        dismiss(animated: false)
    }
    
    override func tappedOption2(_ sender: UIButton) {
        if TherapyManager.sharedInstance.therapyRunning{
            TherapyManager.sharedInstance.resumeTherapy()
        }
        else if ScreeningProcessManager.sharedInstance.screeningRunning{
            ScreeningProcessManager.sharedInstance.resumeScreening()
        }
        else{
            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.impNot.rawValue), object: nil)
        }
        
        // reset error value: error = 0
        BluetoothManager.sharedInstance.informationServiceData.deviceData.clearErrorValue()
        DeviceErrorManager.sharedInstance.failedImpOverall = false
        dismiss(animated: false)
    }
    
    override func tappedVideo(_ sender: UIButton) {
        HelpManager.sharedInstance.playSectionVideo(vc: self, helpInfo: .garment)
    }
    
    @objc func closeVC(notif: Notification) {
        self.dismiss(animated: false)
    }
}
