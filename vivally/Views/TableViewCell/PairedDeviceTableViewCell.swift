//
//  PairedDeviceTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 10/12/21.
//

import UIKit

class PairedDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(device: BluetoothDeviceInfo, connected: Bool){
        if connected {
            //last 4
            let last = device.deviceMac.suffix(4).uppercased()
            deviceLabel.text = device.deviceName + " - " + last + " (Connected)"
        }
        else{
            let last = device.deviceMac.suffix(4).uppercased()
            deviceLabel.text = device.deviceName + " - " + last + " (Paired, Not Connected)\nTurn ON the Vivally Stimulator by pressing the button"
        }
    }

}
