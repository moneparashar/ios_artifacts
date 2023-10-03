//
//  BannerView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/27/23.
//

import UIKit

protocol BannerViewDelegate{
    func tappedBanner(bannerType: BannerView)
}

class BannerView: UIView {
    var delegate:BannerViewDelegate?
    
    var textStack = UIStackView()
    var allStack = UIStackView()
    
    var iconView = UIImageView()
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()

    let warningImage = UIImage(named: "bannerWarning")   //triangle warning
    let infoImage = UIImage(named: "learnmore") // info button
    
    required init?(coder: NSCoder){
        super.init(coder: coder)
        configure()
    }
    
    private func configure(){
        backgroundColor = UIColor.barleyWhite
        
        titleLabel.font = UIFont.h4
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.regalBlue
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = UIFont.bodyMed
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = UIColor.regalBlue
        subtitleLabel.numberOfLines = 0
        
        textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.distribution = .equalSpacing
        
        iconView.image = warningImage
        
        allStack = UIStackView(arrangedSubviews: [iconView, textStack])
        allStack.alignment = .top
        allStack.spacing = 8
        
        allStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(allStack)
        
        allStack.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .vertical)
        allStack.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            allStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            allStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            allStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            allStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            allStack.arrangedSubviews[0].heightAnchor.constraint(equalTo: allStack.arrangedSubviews[0].widthAnchor, multiplier: 1)
        ])
        
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.macCheese?.cgColor
        layer.cornerRadius = 15
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapBanner))
        addGestureRecognizer(tap)
    }
    
    @objc func tapBanner(){
        delegate?.tappedBanner(bannerType:self)
    }
    
    func setup(title: String, sub: String, info: Bool = false){
        titleLabel.text = title
        subtitleLabel.text = sub
        iconView.isHidden = false
        if info{
            setToInfo()
        }
    }
    func setupForStatus(title: String, sub: String, info: Bool = false){
        titleLabel.text = title
        subtitleLabel.text = sub
        iconView.isHidden = true
        backgroundColor = UIColor.barleyWhite
        titleLabel.font = UIFont.h6
    }
    
    func setToInfo(){
        //blue
        iconView.image = infoImage
        layer.borderColor = UIColor.casperBlue?.cgColor
        backgroundColor = UIColor.lavendarMist
    }
    // add for getting device battery percent
    func getBatteryPercentage() -> Float? {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        
        if device.batteryState == .unplugged || device.batteryState == .charging || device.batteryState == .full{
            return device.batteryLevel * 100
        } else {
            // The device is plugged in, and the battery percentage may not be accurate in this state.
            // You can choose to handle this case differently, depending on your use case.
            return nil
        }
    }
}
