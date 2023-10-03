//
//  FirmwareUpdateHomeTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 4/27/22.
//

import UIKit

protocol FirmwareUpdateHomeTableViewCellDelegate{
    func firmwareCheckStatusTapped()
}

class FirmwareUpdateHomeTableViewCell: UITableViewCell {

    var delegate:FirmwareUpdateHomeTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func firmwareCheckStatusTapped(_ sender: Any) {
        delegate?.firmwareCheckStatusTapped()
    }
}
