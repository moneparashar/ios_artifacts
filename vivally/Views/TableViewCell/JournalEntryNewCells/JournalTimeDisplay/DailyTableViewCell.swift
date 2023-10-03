//
//  DailyTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/4/23.
//

import UIKit

class DailyTableViewCell: UITableViewCell {
    
    var fullStack = UIStackView()
    var textStack = UIStackView()
    
    var rangeTitle = UILabel()
    var dayText = UILabel()
    
    var morningIcon = UIImage(named: "morningDark")
    var afternoonIcon = UIImage(named: "noonDark")
    var eveningIcon = UIImage(named: "eveningDark")
    var nightIcon = UIImage(named: "nightDark")
    
    var iconImage = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure(){
        selectionStyle = .none
        
        rangeTitle.font = UIFont.h5
        rangeTitle.textColor = UIColor.wedgewoodBlue
        
        dayText.font = UIFont.bodyLarge
        dayText.textColor = UIColor.regalBlue
        dayText.numberOfLines = 0
        
        textStack = UIStackView(arrangedSubviews: [rangeTitle, dayText])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.distribution = .fill
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.setContentCompressionResistancePriority(.required, for: .vertical)
        
        fullStack = UIStackView(arrangedSubviews: [iconImage, textStack])
        fullStack.alignment = .center
        fullStack.spacing = 12
        fullStack.distribution = .fill
        fullStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fullStack)
        
        NSLayoutConstraint.activate([
            fullStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            fullStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            fullStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            fullStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            fullStack.arrangedSubviews[0].widthAnchor.constraint(equalTo: fullStack.arrangedSubviews[0].heightAnchor)
        ])
        //addShadow()
    }

    func setup(dayrange: JournalDayEntryNavigationPages, journalText: String = " "){
        rangeTitle.text = ""
        dayText.text = " "
        switch dayrange {
        case .night:
            rangeTitle.text = "Night"
            iconImage.image = nightIcon
        case .morning:
            rangeTitle.text = "Morning"
            iconImage.image = morningIcon
        case .afternoon:
            rangeTitle.text = "Afternoon"
            iconImage.image = afternoonIcon
        case .evening:
            rangeTitle.text = "Evening"
            iconImage.image = eveningIcon
        }
        
        dayText.text = journalText
    }
    
    func addShadow(){
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.shadowOpacity = 1
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowColor = UIColor(red: 0.09, green: 0.255, blue: 0.431, alpha: 0.17).cgColor
        
        // add corner radius on `contentView`
        contentView.backgroundColor = .lilyWhite ?? .white
        contentView.layer.cornerRadius = 15
    }
}
