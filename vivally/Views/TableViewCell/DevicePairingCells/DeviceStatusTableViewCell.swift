//
//  DeviceStatusTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/17/23.
//

import UIKit

class DeviceStatusTableViewCell: UITableViewCell {

    var allStack =  UIStackView()
    var leadingStack = UIStackView()
    var leadingLabel = UILabel()
    var ensureLabel = UILabel()
    
    var batteryImage = UIImage(named: "battery_led_green")?.withRenderingMode(.alwaysTemplate)
    
    var batteryStack = UIStackView()
    var batteryIcon = UIImageView()
    var connectedLabel = UILabel()
    
    
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
        leadingLabel.text = "Connectivity status"
        leadingLabel.textAlignment = .left
        leadingLabel.font = UIFont.bodyLarge
        leadingLabel.textColor = UIColor.navy
        
        ensureLabel.text = "Ensure your Controller is ON and in range"
        ensureLabel.textAlignment = .left
        ensureLabel.font = UIFont.bodyMed
        ensureLabel.textColor = UIColor.navy
        ensureLabel.numberOfLines = 0
        
        batteryIcon.image = batteryImage
        connectedLabel.text = "Connected"
        connectedLabel.textAlignment = .right
        connectedLabel.font = UIFont.h5
        connectedLabel.textColor = UIColor.wedgewoodBlue
        connectedLabel.numberOfLines = 0
        
        batteryIcon.tintColor = UIColor.darkGreen
        
        batteryStack = UIStackView(arrangedSubviews: [batteryIcon, connectedLabel])
        batteryStack.distribution = .equalSpacing
        batteryStack.alignment = .center
        batteryStack.spacing = 4
        
        leadingStack = UIStackView(arrangedSubviews: [leadingLabel, ensureLabel])
        leadingStack.distribution = .equalSpacing
        leadingStack.axis = .vertical
        
        allStack = UIStackView(arrangedSubviews: [leadingStack, batteryStack])
        allStack.distribution = .equalSpacing
        allStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(allStack)
        
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lineView)
        
        NSLayoutConstraint.activate([
            allStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            allStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            allStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            allStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            lineView.leadingAnchor.constraint(equalTo: allStack.leadingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lineView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func setupView(batteryVal: Int, notPaired: Bool = false, connected: Bool = false, otaConnected: Bool = false){
        
        // if paired but not connected, hide label
        if !notPaired && !connected{
            ensureLabel.isHidden = false
        } else {
            ensureLabel.isHidden = true
        }
        
        if connected && !otaConnected{
            connectedLabel.text = "Connected"
            batteryIcon.tintColor = UIColor.darkGreen
            if batteryVal < 50{
                batteryIcon.tintColor = UIColor.red
            }
            else if batteryVal > 50{
                batteryIcon.tintColor = UIColor.green
            }
            batteryIcon.isHidden = false
        }
        else{
            batteryIcon.isHidden = true
            if notPaired{
                connectedLabel.text = "Not Paired"
            }
            else if otaConnected && connected{
                connectedLabel.text = "Connected in OTA mode. Tap \"Recover firmware\" to perform a firmware recovery of the Controller."
            }
            else if !connected{
                connectedLabel.text = "Not Connected"
            }
        }
    }
}
