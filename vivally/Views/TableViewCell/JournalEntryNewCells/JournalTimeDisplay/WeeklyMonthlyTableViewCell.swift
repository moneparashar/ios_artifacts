//
//  WeeklyMonthlyTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/4/23.
//

import UIKit

class WeeklyMonthlyTableViewCell: UITableViewCell {

    var stack = UIStackView()
    var textStack = UIStackView()
    var titleLabel = UILabel()
    var cellLabel = UILabel()
    var rightImage = UIImageView(image: UIImage(named: "Right"))
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure2()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure2()
    }
    
    var mainContent = UIView()
    var shadowView = ShadowView()
    private func configure2(){
        contentView.backgroundColor = UIColor.clear
        mainContent.backgroundColor = UIColor.lilyWhite
        mainContent.layer.cornerRadius = 15
        mainContent.translatesAutoresizingMaskIntoConstraints = false
        
        shadowView.backgroundColor = UIColor.lilyWhite
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(shadowView)
        contentView.addSubview(mainContent)
        
        NSLayoutConstraint.activate([
            mainContent.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            mainContent.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mainContent.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            mainContent.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            
            shadowView.leadingAnchor.constraint(equalTo: mainContent.leadingAnchor),
            shadowView.centerXAnchor.constraint(equalTo: mainContent.centerXAnchor),
            shadowView.topAnchor.constraint(equalTo: mainContent.topAnchor),
            shadowView.centerYAnchor.constraint(equalTo: mainContent.centerYAnchor)
        ])
        
        
        titleLabel.font = UIFont.h5
        titleLabel.textColor = UIColor.wedgewoodBlue
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        
        cellLabel.font = UIFont.bodyLarge
        cellLabel.textColor = UIColor.regalBlue
        cellLabel.textAlignment = .left
        cellLabel.numberOfLines = 0
        
        textStack = UIStackView(arrangedSubviews: [titleLabel, cellLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.distribution = .fill
        
        stack = UIStackView(arrangedSubviews: [textStack, rightImage])
        stack.alignment = .center
        stack.distribution = .fill
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: mainContent.leadingAnchor, constant: 12),
            stack.centerXAnchor.constraint(equalTo: mainContent.centerXAnchor),
            stack.topAnchor.constraint(equalTo: mainContent.topAnchor, constant: 12),
            stack.centerYAnchor.constraint(equalTo: mainContent.centerYAnchor)
        ])
        
        contentView.layer.cornerRadius = 15
    }
    
    private func configure(){
        titleLabel.font = UIFont.h5
        titleLabel.textColor = UIColor.wedgewoodBlue
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        
        cellLabel.font = UIFont.bodyLarge
        cellLabel.textColor = UIColor.regalBlue
        cellLabel.textAlignment = .left
        cellLabel.numberOfLines = 0
        
        textStack = UIStackView(arrangedSubviews: [titleLabel, cellLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.distribution = .fill
        
        stack = UIStackView(arrangedSubviews: [textStack, rightImage])
        stack.alignment = .center
        stack.distribution = .fill
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        addShadow()
    }

    func setup(titleStr: String, journalStr: String){
        titleLabel.text = ""
        cellLabel.text = ""
        
        titleLabel.text = titleStr
        cellLabel.text = journalStr
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
