//
//  SettingsCloseAccountTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 5/16/23.
//

import UIKit

protocol SettingsCloseAccountTableViewCellDelegate{
    func tappedStopAccount()
}
class SettingsCloseAccountTableViewCell: UITableViewCell {

    @IBOutlet weak var deleteAccountBtn: ActionButton!
    var delegate:SettingsCloseAccountTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func stopAccountTapped(_ sender: Any) {
        delegate?.tappedStopAccount()
    }
    
}
