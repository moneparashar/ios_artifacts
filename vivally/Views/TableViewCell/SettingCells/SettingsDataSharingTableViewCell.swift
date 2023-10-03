//
//  SettingsDataSharingTableViewCell.swift
//  vivally
//
//  Created by Ryan Levels on 2/27/23.
//

import UIKit

protocol SettingsDataSharingTableViewCellDelegate{
    func dataSharing(isOn: Bool)
}

class SettingsDataSharingTableViewCell: UITableViewCell {
    
    var delegate: SettingsDataSharingTableViewCellDelegate?

    @IBOutlet weak var dataSharingToggle: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupView(toggleOn: Bool){
        dataSharingToggle.isOn = toggleOn
    }
    @IBAction func enableDataSharingChanged(_ sender: Any) {
        delegate?.dataSharing(isOn: dataSharingToggle.isOn)
    }
    
}
