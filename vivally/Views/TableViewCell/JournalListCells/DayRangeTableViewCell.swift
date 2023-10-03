//
//  DayRangeTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 8/25/22.
//

import UIKit

class DayRangeTableViewCell: UITableViewCell {

    var delegate: LifeTableViewCellDelegate?
    
    let morning = UIImage(named: "morning")
    let afternoon = UIImage(named: "afternoon")
    let evening = UIImage(named: "evening")
    let night = UIImage(named: "night")
    
    var section = 0
    var tableRow = 0
    
    @IBOutlet weak var rangeIcon: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView(sect: Int, row: Int, range: JournalDayEntryNavigationPages, drinks: Bool, restroom: Bool, accidents: Bool, urges: Bool){
        section = sect
        tableRow = row
        
        rangeIcon.image = morning
        if range == .night{
            rangeIcon.image = night
        }
        else if range == .afternoon{
            rangeIcon.image = afternoon
        }
        else if range == .evening{
            rangeIcon.image = evening
        }
        
        let subs = stackView.arrangedSubviews
        for subV in subs{
            subV.isHidden = true
        }
        subs[0].isHidden = !drinks
        subs[1].isHidden = !restroom
        subs[2].isHidden = !accidents
        subs[3].isHidden = !urges
    }
    
    @IBAction func entryTapped(_ sender: Any) {
        delegate?.entryButtonTapped(sect: section, row: tableRow)
    }
    
}
