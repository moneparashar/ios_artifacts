//
//  ProfileTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/15/22.
//

//used in help video page and account menu
import UIKit

class ProfileTableViewCell: UITableViewCell {

    var leadButton = UIImageView()
    var titleLabel = UILabel()
    var arrowButton = UIButton()
    
    var stack = UIStackView()
    
    var backView = UIView()
    var actualContentView = UIView()
    
    var padding:CGFloat = 16
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure3()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure3()
    }
    
    var mainContent = UIView()
    var shadowView = ShadowView()
    private func configure3(){
        selectionStyle = .none
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
        
        leadButton.tintColor = UIColor.wedgewoodBlue
        
        titleLabel.font = UIFont.h5
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        
        arrowButton.tintColor = UIColor.wedgewoodBlue
        arrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        
        stack = UIStackView(arrangedSubviews: [leadButton, titleLabel, arrowButton])
        
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        stack.arrangedSubviews[1].setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .vertical)
        //stack.arrangedSubviews[1].setContentCompressionResistancePriority(.required, for: .horizontal)
        stack.arrangedSubviews[1].setContentCompressionResistancePriority(.required, for: .vertical)
        
        stack.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .horizontal)
        stack.arrangedSubviews[2].setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: mainContent.topAnchor, constant: padding),
            stack.leadingAnchor.constraint(equalTo: mainContent.leadingAnchor, constant: padding),
            stack.centerYAnchor.constraint(equalTo: mainContent.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: mainContent.centerXAnchor),
            
            stack.arrangedSubviews[0].heightAnchor.constraint(equalTo: stack.arrangedSubviews[0].widthAnchor, multiplier: 1),
            stack.arrangedSubviews[2].heightAnchor.constraint(equalTo: stack.arrangedSubviews[2].widthAnchor, multiplier: 1),
        ])
        
        contentView.layer.cornerRadius = 15
    }
    private func configure2(){
        selectionStyle = .none
        
        backView.layer.cornerRadius = 12
        backView.clipsToBounds = true
        backView.backgroundColor = UIColor(red: 0.09, green: 0.25, blue: 0.43, alpha: 0.17)
        backView.layer.opacity = 0.25
        backView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backView)
        
        actualContentView.backgroundColor = UIColor.lilyWhite
        actualContentView.layer.cornerRadius = 15
        actualContentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actualContentView)
        
        leadButton.tintColor = UIColor.wedgewoodBlue
        
        titleLabel.font = UIFont.h5
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        
        arrowButton.tintColor = UIColor.wedgewoodBlue
        arrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        
        stack = UIStackView(arrangedSubviews: [leadButton, titleLabel, arrowButton])
        
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        stack.arrangedSubviews[1].setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .vertical)
        stack.arrangedSubviews[1].setContentCompressionResistancePriority(.required, for: .horizontal)
        stack.arrangedSubviews[1].setContentCompressionResistancePriority(.required, for: .vertical)
        let lmg = actualContentView
        NSLayoutConstraint.activate([
            
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            actualContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            actualContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            actualContentView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actualContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            
            stack.topAnchor.constraint(equalTo: lmg.topAnchor, constant: padding),
            stack.leadingAnchor.constraint(equalTo: lmg.leadingAnchor, constant: padding),
            stack.centerYAnchor.constraint(equalTo: lmg.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: lmg.centerXAnchor),
            
            stack.arrangedSubviews[0].heightAnchor.constraint(equalTo: stack.arrangedSubviews[0].widthAnchor, multiplier: 1),
            stack.arrangedSubviews[2].heightAnchor.constraint(equalTo: stack.arrangedSubviews[2].widthAnchor, multiplier: 1),
        ])
    }
    
    private func configure() {
        contentView.backgroundColor = UIColor.lilyWhite
        selectionStyle = .none
        
        leadButton.tintColor = UIColor.wedgewoodBlue
        
        titleLabel.font = UIFont.h5
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        
        arrowButton.tintColor = UIColor.wedgewoodBlue
        arrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        
        stack = UIStackView(arrangedSubviews: [leadButton, titleLabel, arrowButton])
        
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        //stack.arrangedSubviews[1].setContentHuggingPriority(UILayoutPriority(rawValue: 5), for: .horizontal)
        stack.arrangedSubviews[1].setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .vertical)
        stack.arrangedSubviews[1].setContentCompressionResistancePriority(.required, for: .horizontal)
        stack.arrangedSubviews[1].setContentCompressionResistancePriority(.required, for: .vertical)
        let lmg = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: lmg.topAnchor, constant: padding),
            //stack.bottomAnchor.constraint(equalTo: lmg.bottomAnchor, constant: (-1) * (padding)),
            stack.leadingAnchor.constraint(equalTo: lmg.leadingAnchor, constant: padding),
            //stack.trailingAnchor.constraint(equalTo: lmg.trailingAnchor, constant: -padding),
            stack.centerYAnchor.constraint(equalTo: lmg.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: lmg.centerXAnchor),
            
            stack.arrangedSubviews[0].heightAnchor.constraint(equalTo: stack.arrangedSubviews[0].widthAnchor, multiplier: 1),
            stack.arrangedSubviews[2].heightAnchor.constraint(equalTo: stack.arrangedSubviews[2].widthAnchor, multiplier: 1),
        ])
        addShadow()
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
    
    func setup(title: String, icon: iconLIst = .video){
        titleLabel.text = title
        
        leadButton.image = icon.getImage()
    }
}
