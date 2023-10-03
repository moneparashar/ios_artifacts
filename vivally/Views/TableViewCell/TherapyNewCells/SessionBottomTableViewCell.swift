//
//  SessionBottomTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 4/6/23.
//

import UIKit

class SessionBottomTableViewCell: UITableViewCell {

    var borderView = UIView()
    
    var stack = UIStackView()
    var leftIcon = UIImageView()
    var dateLabel = UILabel()
    
    var passImage = UIImage(named: "therapyPass")
    var incompleteImage = UIImage(named: "incomplete")
    
    
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
        
        borderView.layer.borderColor = UIColor.casperBlue?.cgColor
        borderView.layer.borderWidth = 1
        
        borderView.clipsToBounds = true
        borderView.layer.cornerRadius = 15
        borderView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        borderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(borderView)
        
        dateLabel.numberOfLines = 0
        dateLabel.font = UIFont.bodyLarge
        dateLabel.textAlignment = .left
        dateLabel.textColor = UIColor.fontBlue
        
        stack = UIStackView(arrangedSubviews: [leftIcon, dateLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -5),
            borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView .centerYAnchor)
        ])
    }
    
    func setup(pass: Bool = true, datestr:String){
        leftIcon.image = UIImage()
        dateLabel.text = ""
        
        leftIcon.image = pass ? passImage : incompleteImage
        dateLabel.text = datestr
    }

}
