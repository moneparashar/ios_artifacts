//
//  PairedDevTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/15/23.
//

import UIKit

protocol PairedDevTableViewCellDelegate{
    func tappedUnpair()
}

class PairedDevTableViewCell: UITableViewCell {

    var allStack = UIStackView()
    
    var statusLabel = UILabel()
    
    var buttonStack = UIStackView()
    var unpairButton = ActionButton()
    
    var delegate: PairedDevTableViewCellDelegate?
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

    }

    private func configure(){
        therapyRunningCheck() // running ? can't unpair stim : can unpair
        
        contentView.backgroundColor = UIColor.lilyWhite
        contentView.layer.borderColor = UIColor.casperBlue?.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 15
        
        statusLabel.font = UIFont.h6
        statusLabel.textColor = UIColor.fontBlue
        statusLabel.textAlignment = .left
        statusLabel.numberOfLines = 0
        
        unpairButton.setTitle("Unpair", for: .normal)
        unpairButton.backgroundColor = UIColor.barleyWhite
        unpairButton.layer.borderColor = UIColor.macCheese?.cgColor
        unpairButton.setTitleColor(UIColor.fontBlue, for: .normal)
        
        let buttonView = UIView()
        unpairButton.translatesAutoresizingMaskIntoConstraints = false
        buttonView.addSubview(unpairButton)
        
        let buttonWidthMultiplier:CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.6 : 0.4
        
        NSLayoutConstraint.activate([
            unpairButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor),
            unpairButton.topAnchor.constraint(equalTo: buttonView.topAnchor),
            unpairButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
            unpairButton.leadingAnchor.constraint(greaterThanOrEqualTo: buttonView.leadingAnchor),
            unpairButton.widthAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: buttonWidthMultiplier)
        ])
        
        allStack = UIStackView(arrangedSubviews: [statusLabel, buttonView])
        allStack.axis = .vertical
        allStack.distribution = .equalSpacing
        allStack.spacing = 16
        allStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(allStack)
        
        NSLayoutConstraint.activate([
            allStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            allStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            allStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            allStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        unpairButton.addTarget(self, action: #selector(tapUnpair), for: .touchDown)
    }
    
    func setup(dev: BluetoothDeviceInfo, connected: Bool){
        statusLabel.text = ""
        let mac = dev.getMac()
        let deviceName = dev.deviceName
        statusLabel.text = connected ? "\(deviceName) \(mac) Controller (Connected)" : "\(deviceName) \(mac) Controller (Paired, Not connected)"
        unpairButton.isHidden = connected ? false : true
    }
    
    func therapyRunningCheck() {
        // therapy running ? disable unpair button
        if TherapyManager.sharedInstance.therapyRunning {
            unpairButton.isEnabled = false
          
        // enable
        } else {
            unpairButton.isEnabled = true
        }
    }
    
    @objc func tapUnpair(){
        delegate?.tappedUnpair()
    }
}
