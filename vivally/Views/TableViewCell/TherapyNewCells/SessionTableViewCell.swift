//
//  SessionTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/19/23.
//

import UIKit

class SessionTableViewCell: UITableViewCell {

    var leftborderView = UIView()
    var rightBorderView = UIView()
    
    var stack = UIStackView()
    var leftIcon = UIImageView()
    var dateLabel = UILabel()
    
    var passImage = UIImage(named: "therapyPass")
    var incompleteImage = UIImage(named: "incomplete")
    
    var line = UIView()
    
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
        
        leftborderView.backgroundColor = UIColor.casperBlue
        rightBorderView.backgroundColor = leftborderView.backgroundColor
        
        leftborderView.translatesAutoresizingMaskIntoConstraints = false
        rightBorderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(leftborderView)
        contentView.addSubview(rightBorderView)
        
        dateLabel.numberOfLines = 0
        dateLabel.font = UIFont.bodyLarge
        dateLabel.textAlignment = .left
        dateLabel.textColor = UIColor.fontBlue
        
        stack = UIStackView(arrangedSubviews: [leftIcon, dateLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        line.backgroundColor = UIColor.casperBlue
        line.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(line)
        
        NSLayoutConstraint.activate([
            leftborderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            leftborderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            leftborderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftborderView.widthAnchor.constraint(equalToConstant: 1),
            
            rightBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rightBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rightBorderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightBorderView.widthAnchor.constraint(equalToConstant: 1),
            
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView .centerYAnchor),
            
            line.heightAnchor.constraint(equalToConstant: 1),
            line.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            line.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            line.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func setup(pass: Bool = true, datestr:String){
        leftIcon.image = UIImage()
        dateLabel.text = ""
        
        leftIcon.image = pass ? passImage : incompleteImage
        dateLabel.text = datestr
    }

}
