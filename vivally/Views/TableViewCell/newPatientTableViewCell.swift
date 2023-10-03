//
//  newPatientTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 7/26/21.
//

import UIKit

protocol newPatientTableViewCellDelegate{
    func addPatientButtonTapped()
}

class newPatientTableViewCell: ShadowTableViewCell {
    var delegate:newPatientTableViewCellDelegate?
    
    @IBOutlet weak var addPatientButton: ActionButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView() {
        addPatientButton.layer.cornerRadius = addPatientButton.frame.size.height / 2
        self.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.layer.cornerRadius = 15
        addShadow()
    }

    func addShadow(){
        addPatientButton.layer.masksToBounds = false
        addPatientButton.layer.shadowColor = UIColor(named: "avationShadow")?.cgColor
        addPatientButton.layer.shadowOpacity = 1
        addPatientButton.layer.shadowOffset = CGSize.init(width: 0, height: 4)
        addPatientButton.layer.shadowRadius = 4
    }
    
    @IBAction func addPatientButtonTapped(_ sender: ActionButton) {
        delegate?.addPatientButtonTapped()
    }
}
