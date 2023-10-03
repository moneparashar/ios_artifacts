//
//  SettingsEnableStimRecoveryTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 10/12/21.
//

import UIKit

class SettingsEnableStimRecoveryTableViewCell: UITableViewCell {

    @IBOutlet weak var stimRecoveryModeToggle: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView(){
        stimRecoveryModeToggle.isOn = OTAManager.sharedInstance.OTAMode
        stimRecoveryModeToggle.isEnabled = !BluetoothManager.sharedInstance.isConnectedToDevice()
    }
    @IBAction func enableStimModeChanged(_ sender: Any) {
        OTAManager.sharedInstance.OTAMode = stimRecoveryModeToggle.isOn
        OTAManager.sharedInstance.recovery = OTAManager.sharedInstance.OTAMode
        UserDefaults.standard.set(OTAManager.sharedInstance.OTAMode, forKey: "otaMode")
        if !OTAManager.sharedInstance.OTAMode{
            BluetoothManager.sharedInstance.clearOTAPairing()
        }
    }
    
}
