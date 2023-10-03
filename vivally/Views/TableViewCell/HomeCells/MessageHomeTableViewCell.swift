//
//  MessageHomeTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 3/22/22.
//

import UIKit

class MessageHomeTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        messageLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(mes: String){
        messageLabel.isHidden = false
        messageLabel.font = messageLabel.font.withSize(14)
        messageLabel.textColor = UIColor.info
        messageLabel.text = mes
    }

}
