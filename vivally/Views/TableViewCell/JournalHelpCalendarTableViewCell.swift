//
//  JournalHelpCalendarTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 11/4/21.
//

import UIKit

class JournalHelpCalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var currentDayCircleView: UIView!
    @IBOutlet weak var selectedDayCircleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView(){
        //circles
        currentDayCircleView.layer.cornerRadius = currentDayCircleView.frame.size.width/2
        selectedDayCircleView.layer.cornerRadius = currentDayCircleView.frame.size.width/2
        
    }
}
