//
//  ContactUsTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/13/22.
//

import UIKit

class ContactUsTableViewCell: UITableViewCell {

    var leadingLabel = UILabel()
    var endLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        leadingLabel.font  = UIFont.bodyLarge
        leadingLabel.textColor = UIColor.fontBlue
        leadingLabel.numberOfLines = 0
        leadingLabel.textAlignment = .left
        
        endLabel.font = UIFont.h5
        endLabel.textColor = UIColor.wedgewoodBlue
        endLabel.numberOfLines = 0
        endLabel.textAlignment = .right
        
        let stack = UIStackView(arrangedSubviews: [leadingLabel, endLabel])
        
        stack.alignment = .center
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 15
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        stack.arrangedSubviews[0].setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func setupView(leadText: String, trailText: String){
        leadingLabel.text = leadText
        endLabel.text = trailText
    }
}
