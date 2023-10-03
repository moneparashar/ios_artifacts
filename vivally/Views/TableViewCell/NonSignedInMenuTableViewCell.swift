//
//  NonSignedInMenuTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 10/20/21.
//

import UIKit

class NonSignedInMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView(page:NonSignedInSideMenuMainPages, isSubMenu:Bool){

        menuName.text = ""
        menuImageView.image = UIImage()
        //menuImageView.image = menuImageView.image?.withRenderingMode(.alwaysTemplate)
        menuImageView.tintColor = UIColor(named: "avationFont")
        
        switch page{
        case .bluetoothStatus:
            menuName.text = "Bluetooth Status"
            menuImageView.image = UIImage(named: "menu_bluetooth")!.withRenderingMode(.alwaysTemplate)
        case .wifiStatus:
            menuName.text = "Wi-Fi Status"
            menuImageView.image = UIImage(named: "menu_wifi")!.withRenderingMode(.alwaysTemplate)
        case .contactUs:
            menuName.text = "Contact & About"
            menuImageView.image = UIImage(named: "info_icon")!.withRenderingMode(.alwaysTemplate)
        }
    }
    
}
