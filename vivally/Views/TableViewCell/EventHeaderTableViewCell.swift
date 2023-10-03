//
//  EventHeaderTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 9/13/21.
//

import UIKit

class EventHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var therapySessionImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView(datestr: String, therapyDone: Bool) {
        dateLabel.text = datestr
        therapySessionImageView.isHidden = true
        if therapyDone {
            therapySessionImageView.isHidden = false
        }
        /*
        else{
            therapySessionImageView.isHidden = true
        }
        */
    }
}
