//
//  PairHomeTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/14/22.
//

import UIKit

protocol PairHomeTableViewCellDelegate{
    func tappedPair()
}

class PairHomeTableViewCell: UITableViewCell {

    var outerStack = UIStackView()
    var innerStack = UIStackView()
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()
    var pairButton = ActionButton()
    
    var delegate:PairHomeTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        contentView.backgroundColor = .lilyWhite ?? .white
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        
        titleLabel.text = "Controller not paired"
        titleLabel.font = UIFont.h4
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.black
        
        subtitleLabel.text = "Please pair with the Vivally Controller"
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = UIFont.bodyMed
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = UIColor.fontBlue
        
        innerStack = UIStackView(arrangedSubviews:  [titleLabel, subtitleLabel])
        innerStack.alignment = .leading
        innerStack.distribution = .equalSpacing
        innerStack.axis = .vertical
        
        let buttonView = UIView()
        pairButton.setTitle("Pair Controller", for: .normal)
        pairButton.translatesAutoresizingMaskIntoConstraints = false
        buttonView.addSubview(pairButton)
        
        let pairButtonWidthMultiplier:CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.6 : 0.4
        
        pairButton.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            pairButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor),
            pairButton.topAnchor.constraint(equalTo: buttonView.topAnchor),
            pairButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
            pairButton.leadingAnchor.constraint(greaterThanOrEqualTo: buttonView.leadingAnchor),
            pairButton.widthAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: pairButtonWidthMultiplier)
        ])
        
        outerStack = UIStackView(arrangedSubviews: [innerStack, buttonView])
        outerStack.alignment = .fill
        outerStack.distribution = .equalSpacing
        outerStack.spacing = 24
        outerStack.axis = .vertical
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(outerStack)
        
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            outerStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            outerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            outerStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        
        pairButton.addTarget(self, action: #selector(tapEvent), for: .touchDown)
    }
    
    @objc func tapEvent(){
        delegate?.tappedPair()
    }
    
    func addShadow(){
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.shadowOpacity = 1
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowColor = UIColor(red: 0.09, green: 0.255, blue: 0.431, alpha: 0.17).cgColor
        
        // add corner radius on `contentView`
    }
}
