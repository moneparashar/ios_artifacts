//
//  AccountTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 7/11/22.
//

import UIKit

enum AccountPages: Int{
    case name
    case system
    case help
    case privacy
    case contactAbout
    case settings
    case changePassword
    case changePIN
    case signOut
}
class AccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    /*
    var icon = UIImageView()
    var label = UILabel()
    var exitButton = UIButton()
    */
    
    let accountImage = UIImage(named: "ic_account")
    let systemManualImage = UIImage(named: "menu_manual")
    let helpImage = UIImage(systemName: "play.circle")
    let privacyImage = UIImage(named: "menu_privacy")
    let contactImage = UIImage(named: "contact")
    let settingsImage = UIImage(systemName: "gearshape")
    let changePasswordImage = UIImage(named: "change_password")
    let changePinImage = UIImage(named: "change_pin")
    let logoutImage = UIImage(named: "sign_out")

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //commonInit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //commonInit()
    }
    
    /*
    func commonInit() {
        icon.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(icon)
        
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 2),
            icon.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            exitButton.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 0),
            exitButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -17),
            exitButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
    */
    
    func commonInit(){
        //home, help, settings
    }
    
    func setupView(page: AccountPages){    //need to add specific type
        iconImageView.image = UIImage()
        
        switch page {
        case .system:
            iconImageView.image = systemManualImage
            label.text = "System Manual"
        case .help:
            iconImageView.image = helpImage?.withRenderingMode(.alwaysOriginal)
            label.text = "Help"
        case .privacy:
            iconImageView.image = privacyImage
            label.text = "Privacy"
        case .contactAbout:
            iconImageView.image = contactImage
            label.text = "Contact & About"
        case .settings:
            iconImageView.image = settingsImage?.withRenderingMode(.alwaysOriginal)
            label.text = "Settings"
        case .changePassword:
            iconImageView.image = changePasswordImage
            label.text = "Change Password"
        case .changePIN:
            iconImageView.image = changePinImage
            label.text = "Change PIN"
        case .signOut:
            iconImageView.image = logoutImage
            label.text = "Sign out"
        default:
            return
        }
    }
}
