//
//  JournalHomeTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 8/27/21.
//

import UIKit
import Lottie

protocol JournalHomeTableViewCellDelegate {
    func enterEventButtonTapped()
    func journalButtonTapped()
}

class JournalHomeTableViewCell: ShadowTableViewCell {

    @IBOutlet weak var backView: UIView!
    var delegate:JournalHomeTableViewCellDelegate?
    
    @IBOutlet weak var journalImageView: UIImageView!
    @IBOutlet weak var enterEventButton: UIButton!
    @IBOutlet weak var lastJournalEntryLabel: UILabel!
    
    @IBOutlet weak var lastJournalTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backView.layer.borderWidth = 1
        backView.layer.cornerRadius = 15
        backView.layer.borderColor = UIColor.clear.cgColor
        backView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView(lastJournal: String) {
        journalImageView.image = UIImage(named: "journal_calendar")!.withRenderingMode(.alwaysTemplate)
        
        enterEventButton.layer.cornerRadius = enterEventButton.bounds.size.height / 2
        addShadow()
        
        lastJournalEntryLabel.text = lastJournal
        lastJournalTitleLabel.isHidden = false
        if lastJournal.isEmpty{
            lastJournalTitleLabel.isHidden = true
        }
        
        enterEventButton.titleLabel?.textAlignment = .center
    }
    
    func addShadow(){
        enterEventButton.layer.masksToBounds = false
        enterEventButton.layer.shadowColor = UIColor(named: "avationShadow")?.cgColor
        enterEventButton.layer.shadowOpacity = 1
        enterEventButton.layer.shadowOffset = CGSize.init(width: 0, height: 4)
        enterEventButton.layer.shadowRadius = 4
    }
    
    @IBAction func journalButtonTapped(_ sender: Any) {
        delegate?.journalButtonTapped()
    }
    @IBAction func enterEventButtonTapped(_ sender: Any) {
        delegate?.enterEventButtonTapped()
    }
    
}
