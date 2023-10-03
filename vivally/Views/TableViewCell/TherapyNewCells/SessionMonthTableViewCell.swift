//
//  SessionMonthTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/3/23.
//

import UIKit

class SessionMonthTableViewCell: UITableViewCell {
    var borderView = UIView()
    var monthTitle = UILabel()
    
    var hideBottomView = UIView()
    
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
        borderView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        borderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(borderView)
        
        monthTitle.numberOfLines = 0
        monthTitle.font = UIFont.h4
        monthTitle.textColor = UIColor.fontBlue
        monthTitle.textAlignment = .left
        
        monthTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(monthTitle)
        
        hideBottomView.backgroundColor = UIColor.white
        hideBottomView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hideBottomView)
        
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            monthTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            monthTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            monthTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            monthTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            hideBottomView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor),
            hideBottomView.heightAnchor.constraint(equalToConstant: 1),
            hideBottomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hideBottomView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func setup(month: String){
        monthTitle.text = ""
        monthTitle.text = month
    }

}
