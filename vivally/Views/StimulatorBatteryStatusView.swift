//
//  StimulatorBatteryStatusView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/15/22.
//

import UIKit

class StimulatorBatteryStatusView: UIView {

    var stimulatorStack = UIStackView() //holds two mini stacks and empty label but only shows one at a time
    var batteryStack = UIStackView()
    var disconnectstack = UIStackView()
    var emptyLabel = UILabel()
    
    var circleStatus = UIImageView()
    var batteryStatus = UILabel()
    
    var disconnectLabel = UILabel()
    var checkStatusButton = UIButton()
    
    var greenImage = UIImage(named: "battery_led_green")
    var yellowImage = UIImage(named: "battery_led_yellow")
    var redImage = UIImage(named: "battery_led_red")
    
    required init(){
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
      
    }
    
    private func configure() {
        emptyLabel.text = " "
        
        batteryStatus.font = UIFont.bodyMed
        batteryStatus.textColor = UIColor.fontBlue
        batteryStatus.textAlignment = .left
        batteryStatus.numberOfLines = 0
        
        batteryStack = UIStackView(arrangedSubviews: [circleStatus, batteryStatus])
        batteryStack.distribution = .equalSpacing
        batteryStack.alignment = .center
        
        batteryStack.arrangedSubviews[1].setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        NSLayoutConstraint.activate([
            batteryStack.arrangedSubviews[0].widthAnchor.constraint(equalTo: batteryStack.arrangedSubviews[0].heightAnchor),
            batteryStack.arrangedSubviews[0].widthAnchor.constraint(lessThanOrEqualToConstant: 30)
        ])
        
        disconnectLabel.text = "System not connected."
        disconnectLabel.font = UIFont.bodyMed
        disconnectLabel.textColor = UIColor.error
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bodyMed as Any,
            .foregroundColor: UIColor.darkGreen as Any,
            .underlineStyle: NSUnderlineStyle.single
        ]
        let attributeStr = NSMutableAttributedString(string: "Check Status", attributes: attributes)
        checkStatusButton.setAttributedTitle(attributeStr, for: .normal)
        
        disconnectstack = UIStackView(arrangedSubviews: [disconnectLabel, checkStatusButton])
        disconnectstack.axis = .vertical
        disconnectstack.distribution = .equalSpacing
        disconnectstack.alignment = .leading
        
        stimulatorStack = UIStackView(arrangedSubviews: [ batteryStack, disconnectstack, emptyLabel])
        stimulatorStack.axis = .vertical
        stimulatorStack.distribution = .equalSpacing
        stimulatorStack.alignment = .leading
        
        stimulatorStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stimulatorStack)
        
        NSLayoutConstraint.activate([
            stimulatorStack.topAnchor.constraint(equalTo: self.topAnchor),
            stimulatorStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stimulatorStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stimulatorStack.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        //set default value
        setupBattery(battery: 0)
    }
    
    
    func setupView(){
        if BluetoothManager.sharedInstance.isConnectedToDevice(){
            setupBattery(battery: BluetoothManager.sharedInstance.informationServiceData.batteryStateOfCharge.level)
        }
        else{
            showDisconnect()
        }
    }
    
    func setupBattery(battery: Int){
        if battery == 0{
            stimulatorStack.arrangedSubviews[0].isHidden = true
            stimulatorStack.arrangedSubviews[1].isHidden = true
            stimulatorStack.arrangedSubviews[2].isHidden = false
            return
        }
        stimulatorStack.arrangedSubviews[2].isHidden = true
        
        var stimBatteryText = "Controller battery: \(battery)%. "
        if battery >= 70{
            circleStatus.image = greenImage
            stimBatteryText.append("You are ready to start!")
        }
        else if battery > 50{
            circleStatus.image = yellowImage
            stimBatteryText.append("Think about charging")
        }
        else{
            circleStatus.image = redImage
            stimBatteryText.append("Controller needs to be charged")
        }
        
        batteryStatus.text = stimBatteryText
        stimulatorStack.arrangedSubviews[1].isHidden = true // disconnect stack
        stimulatorStack.arrangedSubviews[0].isHidden = false // empty label
    }
    
    func showDisconnect(){
        stimulatorStack.arrangedSubviews[0].isHidden = true // battery stack
        stimulatorStack.arrangedSubviews[2].isHidden = true // empty stack
        
        /* old implementation: no longer on figma
        // disconnect stack
        stimulatorStack.arrangedSubviews[1].isHidden = false
         */
    }
}
