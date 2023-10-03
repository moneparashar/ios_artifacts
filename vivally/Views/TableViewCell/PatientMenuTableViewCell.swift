//
//  PatientMenuTableViewCell.swift
//  vivally
//
//  Created by Joe Sarkauskas on 5/10/21.
//

import UIKit

class PatientMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuName: UILabel!
    @IBOutlet weak var menuSeparator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView(page:PatientSideMenuMainPages, isSubMenu:Bool){
        menuName.text = ""
        menuImageView.image = UIImage()
        //menuImageView.image = menuImageView.image?.withRenderingMode(.alwaysTemplate)
        menuImageView.tintColor = UIColor(named: "avationFont")
        
        switch page{
        case .home:
            menuName.text = "Home"
            menuImageView.image = UIImage(named: "ic_home_off")!.withRenderingMode(.alwaysTemplate)
        case .homeSeparator:
            menuName.isHidden = true
            menuImageView.isHidden = true
            menuSeparator.isHidden = false
        case .therapy:
            menuName.text = "Therapy"
            menuImageView.image = UIImage(named: "ic_sessions_off")!.withRenderingMode(.alwaysTemplate)
        case .journal:
            menuName.text = "Journal"
            menuImageView.image = UIImage(named: "ic_diary_off")!.withRenderingMode(.alwaysTemplate)
        case .journalSeparator:
            menuName.isHidden = true
            menuImageView.isHidden = true
            menuSeparator.isHidden = false
        case .bluetoothStatus:
            menuName.text = "Bluetooth Status"
            menuImageView.image = UIImage(named: "menu_bluetooth")!.withRenderingMode(.alwaysTemplate)
        case .wifiStatus:
            menuName.text = "Wi-Fi Status"
            menuImageView.image = UIImage(named: "menu_wifi")!.withRenderingMode(.alwaysTemplate)
        case .devicePairing:
            menuName.text = "System Pairing"
            menuImageView.image = UIImage(named: "menu_system_pairing")!.withRenderingMode(.alwaysTemplate)
        case .deviceStatus:
            menuName.text = "System Status"
            menuImageView.image = UIImage(named: "nav_stimulator")!.withRenderingMode(.alwaysTemplate)
        case .subjectManual:
            menuName.text = "System Manual"
            menuImageView.image = UIImage(named: "menu_manual")!.withRenderingMode(.alwaysTemplate)
        case .help:
            menuName.text = "Help"
            menuImageView.image = UIImage(systemName: "play.circle")!.withRenderingMode(.alwaysTemplate)
        case .settings:
        menuName.text = "Settings"
        menuImageView.image = UIImage(systemName: "gearshape")
        case .privacy:
            menuName.text = "Privacy"
            menuImageView.image = UIImage(named: "menu_privacy")!.withRenderingMode(.alwaysTemplate)
        case .contactUs:
            menuName.text = "Contact & About"
            menuImageView.image = UIImage(named: "info_icon")!.withRenderingMode(.alwaysTemplate)
        }
    }
}
