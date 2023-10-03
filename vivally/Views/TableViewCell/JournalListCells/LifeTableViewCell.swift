//
//  LifeTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 8/25/22.
//

import UIKit

protocol LifeTableViewCellDelegate{
    func entryButtonTapped(sect: Int, row: Int)
}

class LifeTableViewCell: UITableViewCell {

    var delegate: LifeTableViewCellDelegate?
    
    var section = 0
    var tableRow = 0
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(sect: Int, row: Int, gel: Bool, medication: Bool, exercise: Bool, diet: Bool, stress: Bool){
        section = sect
        tableRow = row
        
        let subs = stackView.arrangedSubviews
        for subV in subs{
            subV.isHidden = true
        }
        
        subs[0].isHidden = !gel
        subs[1].isHidden = !medication
        subs[2].isHidden = !exercise
        subs[3].isHidden = !diet
        subs[4].isHidden = !stress
        
    }

    @IBAction func entryTapped(_ sender: Any) {
        delegate?.entryButtonTapped(sect: section, row: tableRow)
    }
}
