//
//  TherapyHistoryTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 8/3/21.
//

import UIKit

class TherapyHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var statusComplete: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stoppedLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //also pass in a string or time
    func setupView(status:Bool, datestr: String, therapyRunning: Bool = false) {
        
        //else
        //timestamp shenanigans
        dateLabel.text = datestr
        //if not complete (i.e. empty circle) display stopped
        if therapyRunning{
            statusComplete.image = UIImage(named: "circletoggle_off")
            stoppedLabel.isHidden = true
        }
        
        else if status {
            statusComplete.image = UIImage(named: "circletoggle_on")
            stoppedLabel.isHidden = true
        }
        else{
            stoppedLabel.isHidden = false
            statusComplete.image = UIImage(named: "circletoggle_off")
        }
    }
}
