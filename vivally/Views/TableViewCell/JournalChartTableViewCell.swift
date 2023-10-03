//
//  JournalChartTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 8/23/21.
//

import UIKit

//don't need this
protocol JournalChartTableViewCellDelegate {
    func optionButtonTapped(optionType: String)
}


//var drinkBar = [water, caffeineFree, caffeinated, alcohol]
//var bottomBar = [urges, restroom, accidents]

class JournalChartTableViewCell: UITableViewCell {

    var delegate:JournalChartTableViewCellDelegate?
    @IBOutlet weak var dateLabel: UILabel!

    /*
    var water = true
    var caffeineFree = true
    var caffeinated = true
    var alcohol = true
    var urges = true
    var restroom = true
    var accidents = true
    */
    
    @IBOutlet weak var barHolderView: UIView!
    
    @IBOutlet weak var waterBarWidth: NSLayoutConstraint!
    @IBOutlet weak var caffeineFreeBarWidth: NSLayoutConstraint!
    @IBOutlet weak var caffeinatedBarWidth: NSLayoutConstraint!
    @IBOutlet weak var alcoholBarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var urgesBarWidth: NSLayoutConstraint!
    @IBOutlet weak var restroomBarWidth: NSLayoutConstraint!
    @IBOutlet weak var accidentsBarWidth: NSLayoutConstraint!
    
    var water = 4
    var caffeineFree = 4
    var caffeinated = 4
    var alcohol = 4
    
    var urges = 6
    var restroom = 7
    var accidents = 3
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //willl probably also neeed to pass all the other values as well
    
    func setupView(waterAct: Bool,  caffeineFreeAct: Bool, caffeinatedAct: Bool, alcoholAct: Bool, urgesAct: Bool, restroomAct: Bool, accidentsAct: Bool) {
        //top bar
        
        /*
        //these turn out zero probably because not yet loaded
        let leftValue = Double(barHolderView.bounds.minY)
        print(leftValue)
        let rightValue = Double(barHolderView.bounds.minX)
        print(rightValue)
        */
        
        //let bWidth = Double(barHolderView.frame.size.width)
        
        
        let bWidth = Double(UIScreen.main.bounds.width) - 140
        
        if waterAct{
            let percent = Double(water) / 16
            let right = bWidth * percent
            waterBarWidth.constant = CGFloat(right)
        }
        else{
            waterBarWidth.constant = 0
        }
        if caffeineFreeAct{
            let percent = Double(caffeineFree) / 16
            let right = bWidth * percent
            caffeineFreeBarWidth.constant = CGFloat(right)
        }
        else{
            caffeineFreeBarWidth.constant = 0
        }
        if caffeinatedAct{
            let percent = Double(caffeinated) / 16
            let right = bWidth * percent
            caffeinatedBarWidth.constant = CGFloat(right)
        }
        else{
            caffeinatedBarWidth.constant = 0
        }
        if alcoholAct{
            let percent = Double(alcohol) / 16
            let right = bWidth * percent
            alcoholBarWidth.constant = CGFloat(right)
        }
        else{
            alcoholBarWidth.constant = 0
        }
        
        
        
        //bottom bar
        if urgesAct {
            let percent = Double(urges) / 16
            let right = bWidth * percent
            urgesBarWidth.constant = CGFloat(right)
        }
        else{
            urgesBarWidth.constant = 0
        }
        if restroomAct {
            let percent = Double(restroom) / 16
            let right = bWidth * percent
            restroomBarWidth.constant = CGFloat(right)
        }
        else{
            restroomBarWidth.constant = 0
        }
        if accidentsAct {
            let percent = Double(accidents) / 16
            let right = bWidth * percent
            accidentsBarWidth.constant = CGFloat(right)
        }
        else{
            accidentsBarWidth.constant = 0
        }
        
        
        //draw
        //self.contentView.layoutIfNeeded()
    }

    
}
