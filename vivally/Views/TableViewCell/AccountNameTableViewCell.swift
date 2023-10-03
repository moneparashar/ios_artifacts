//
//  AccountNameTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 7/20/22.
//

import UIKit

protocol AccountNameTableViewCellDelegate{
    func closeTap()
}

class AccountNameTableViewCell: UITableViewCell {

    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var delegate:AccountNameTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commonInit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(){
        accountImageView.image = accountImageView.image?.withRenderingMode(.alwaysTemplate)
        accountImageView.tintColor = UIColor(named: "avationDkGray")
    }

    func setupView(fullname: String){
        name.text = fullname
    }
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.closeTap()
    }
}
