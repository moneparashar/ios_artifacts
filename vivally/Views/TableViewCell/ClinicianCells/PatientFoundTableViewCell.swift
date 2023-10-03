//
//  PatientFoundTableViewCell.swift
//  vivally
//
//  Created by Ryan Levels on 1/23/23.
//

import UIKit

class PatientFoundTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var patientInfoLabel: UILabel!
    
    //weak var delegate: PatientFoundTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView(rowName: String, info: String) {
        titleLabel.text = "\(rowName)"
        patientInfoLabel.text = "\(info)"
    }
}
