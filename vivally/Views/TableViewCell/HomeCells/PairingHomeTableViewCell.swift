//
//  PairingHomeTableViewCell.swift
//  vivally
//
//  Created by Joe Sarkauskas on 6/15/21.
//

import UIKit

protocol PairingHomeTableViewCellDelegate{
    func pairingHomePairingDidTap()
    func statusLinkDidTap()
}

class PairingHomeTableViewCell: ShadowTableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lastCompleteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pairingButton: UIButton!
    var delegate:PairingHomeTableViewCellDelegate?
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
    
    func setupView(lastSession: String = ""){
        pairingButton.titleLabel?.textAlignment = .center
        pairingButton.layer.cornerRadius = pairingButton.bounds.size.height / 2
        addShadow()
        
        lastCompleteLabel.isHidden = true
        dateLabel.isHidden = true
        if lastSession != ""{
            dateLabel.text = lastSession
            lastCompleteLabel.isHidden = false
            dateLabel.isHidden = false
        }
    }
    
    func addShadow(){
        pairingButton.layer.masksToBounds = false
        pairingButton.layer.shadowColor = UIColor(named: "avationShadow")?.cgColor
        pairingButton.layer.shadowOpacity = 1
        pairingButton.layer.shadowOffset = CGSize.init(width: 0, height: 4)
        pairingButton.layer.shadowRadius = 4
    }
    
    @IBAction func statusLinkTapped(_ sender: Any) {
        delegate?.statusLinkDidTap()
    }
    
    @IBAction func pairingButtonTapped(_ sender: Any) {
        delegate?.pairingHomePairingDidTap()
    }
}
