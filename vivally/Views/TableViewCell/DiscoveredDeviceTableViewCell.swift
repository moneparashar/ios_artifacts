//
//  DiscoveredDeviceTableViewCell.swift
//  vivally
//
//  Created by Joe Sarkauskas on 6/2/21.
//

import UIKit

protocol DiscoveredDeviceTableViewCellDelegate{
    func menuButtonClicked(device:DiscoveredDevice)
}

class DiscoveredDeviceTableViewCell: UITableViewCell {

    var delegate:DiscoveredDeviceTableViewCellDelegate?
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var macAddressLabel: UILabel!
    var device:DiscoveredDevice = DiscoveredDevice()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(device:DiscoveredDevice){
        /*
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerDown.direction = .left
        self.addGestureRecognizer(swipeGestureRecognizerDown)
        */
        
        self.device = device
        let last = device.mac.suffix(4).uppercased()
        deviceNameLabel.text = device.name + " - " + last + " (Not paired)"
        
        macAddressLabel.text = ""
        
        menuButton.isHidden = BluetoothManager.sharedInstance.isConnectedToDevice()
        
    }
    
    func setupConnectedView(paired:Bool){
        
    }

    @IBAction func menuButtonTapped(_ sender: Any) {
        delegate?.menuButtonClicked(device: device)
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer){
        menuButton.isHidden = false
        var frame = menuButton.frame
        frame.origin.x += 100.0
        UIView.animate(withDuration: 0.25){
            self.menuButton.frame = frame
        }
    }
}
