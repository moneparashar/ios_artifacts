//
//  EventTableViewCell.swift
//  vivally
//
//  Created by Joe Sarkauskas on 5/9/21.
//

import UIKit

protocol EventTableViewCellDelegate{
    func eventTableViewCellChangeButtonTapped(sect: Int, row: Int)
    func entryButtonTapped(sect: Int, row: Int)
}

class EventTableViewCell: UITableViewCell {

    var delegate:EventTableViewCellDelegate?
    
    var section = 0
    var tableRow = 0
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var drinkWidth: NSLayoutConstraint!
    @IBOutlet weak var urgeWidth: NSLayoutConstraint!
    @IBOutlet weak var restroomWidth: NSLayoutConstraint!
    @IBOutlet weak var accidentsWidth: NSLayoutConstraint!
    @IBOutlet weak var lifeWidth: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var lifeImage: UIImageView!
    @IBOutlet weak var drinkImage: UIImageView!
    @IBOutlet weak var urgeImage: UIImageView!
    
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var entryButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(timestr: String, sect: Int, row: Int, urge: Bool, restroom: Bool, drinks: Bool, accidents: Bool, life: Bool){
        timeLabel.text = timestr
        section = sect
        tableRow = row
        
        let normalConstant = CGFloat(30)
        urgeWidth.constant = normalConstant
        restroomWidth.constant = normalConstant
        drinkWidth.constant = normalConstant
        accidentsWidth.constant = normalConstant
        lifeWidth.constant = normalConstant
        
        if !urge{
            urgeWidth.constant = 0
        }
        if !restroom{
            restroomWidth.constant = 0
        }
        if !drinks{
            drinkWidth.constant = 0
        }
        if !accidents{
            accidentsWidth.constant = 0
        }
        if !life{
            lifeWidth.constant = 0
        }
    }
    
    @IBAction func changeButtonTapped(_ sender: Any) {
    
        delegate?.eventTableViewCellChangeButtonTapped(sect: section, row: tableRow)
        
        /*
        let optionMenu = UIAlertController(title: nil, message: "Choose option", preferredStyle: .actionSheet)
        optionMenu.view.tintColor = UIColor(named: "avationFont")
        
        let editAction = UIAlertAction(title: "Edit Entry", style: .default){ action -> Void in
        //go to edit that entry
            
        }
        
        let deleteAction = UIAlertAction(title: "Delete Entry", style: .default){ action -> Void in
            //delete that entry
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        optionMenu.popoverPresentationController?.sourceView = self.changeButton
        
        optionMenu.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: contentView.bounds.midX, y: contentView.bounds.midY, width: 0, height: 0)
        
        contentView.present(optionMenu, animated: true, completion: nil)
        */
    }
    @IBAction func entryButtonTapped(_ sender: Any) {
        delegate?.entryButtonTapped(sect: section, row: tableRow)
    }
    
}
