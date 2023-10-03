//
//  DiscoveredUnpairedDeviceTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/15/23.
//

import UIKit

protocol DiscoveredUnpairedDeviceTableViewCellDelegate{
    func tappedPair(device: DiscoveredDevice)
}

class DiscoveredUnpairedDeviceTableViewCell: UITableViewCell {

    var allStack = UIStackView()
    
    var instructionLabel = UILabel()
    var statusLabel = UILabel()
    
    var buttonStack = UIStackView()
    var spaceView = UIView()
    var pairButton = ActionButton()
    
    var delegate: DiscoveredUnpairedDeviceTableViewCellDelegate?
    var dev:DiscoveredDevice?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func configure(){
        contentView.backgroundColor = UIColor.lilyWhite
        contentView.layer.borderColor = UIColor.casperBlue?.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 15
        
        statusLabel.font = UIFont.bodyMed
        statusLabel.textColor = UIColor.fontBlue
        statusLabel.textAlignment = .left
        statusLabel.numberOfLines = 0
        
        instructionLabel.font = UIFont.h5
        instructionLabel.textColor = UIColor.fontBlue
        instructionLabel.textAlignment = .left
        instructionLabel.numberOfLines = 0
        instructionLabel.text = "Vivally Controller (Not Paired)"
        
        pairButton.setTitle("Pair", for: .normal)
        
        let buttonView = UIView()
        pairButton.translatesAutoresizingMaskIntoConstraints = false
        buttonView.addSubview(pairButton)
        
        let buttonWidthMultiplier:CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.6 : 0.4
        NSLayoutConstraint.activate([
            pairButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor),
            pairButton.topAnchor.constraint(equalTo: buttonView.topAnchor),
            pairButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
            pairButton.leadingAnchor.constraint(greaterThanOrEqualTo: buttonView.leadingAnchor),
            pairButton.widthAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: buttonWidthMultiplier)
        ])
        
        allStack = UIStackView(arrangedSubviews: [instructionLabel, statusLabel, buttonView])
        allStack.axis = .vertical
        allStack.distribution = .equalSpacing
        allStack.spacing = 16
        allStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(allStack)
        
        //allStack.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            allStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            allStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            allStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            allStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        pairButton.addTarget(self, action: #selector(tapPair), for: .touchDown)
    }
    
    func setupView(device: DiscoveredDevice){
        dev = device
        let deviceName = dev?.name ?? ""
        let mac = device.getMac()
        statusLabel.text = "Locate your 6-digit pairing code on your Quick Start Guide that was provided with your System.\nTap Pair button below and enter your pairing code when prompted."
        instructionLabel.text = "Vivally Controller (Not Paired)"
        instructionLabel.text = "\(deviceName) \(mac) Controller (Not Paired)"
    }
    
    @objc func tapPair(){
        if dev != nil{
            delegate?.tappedPair(device: dev!)
        }
    }
}
