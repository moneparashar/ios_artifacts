//
//  ActionButton.swift
//  vivally
//
//  Created by Joe Sarkauskas on 6/16/21.
//

import UIKit

class ActionButton: UIButton {
    
    var isSublayerAdded:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
        
    }
    
    func toSecondary(){
        backgroundColor = UIColor.white
        tintColor = UIColor.white
        self.setTitleColor(UIColor.regalBlue, for: .normal)
        self.setTitleColor(UIColor.regalBlue, for: .disabled)
        layer.borderColor = UIColor.regalBlue?.cgColor
        layer.borderWidth = 1
    }
    func toDisable(){
        backgroundColor = UIColor.white
        tintColor = UIColor.casperBlue
        self.setTitleColor(UIColor.casperBlue, for: .normal)
        self.setTitleColor(UIColor.casperBlue, for: .disabled)
        layer.borderColor = UIColor.casperBlue?.cgColor
        layer.borderWidth = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
       if !isSublayerAdded{
           layer.cornerRadius = self.frame.size.height/2
           //addDropShadow()
        }
        
        
        
        if imageView?.image != nil {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 40), bottom: 5, right: 10)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: (imageView?.frame.width)!)
            contentHorizontalAlignment = .left
        }
    }
    
    private func configure() {
        titleLabel?.font = UIFont.h5
        self.layer.cornerRadius = self.frame.size.height/2
        self.backgroundColor = isEnabled ? UIColor.regalBlue : UIColor.neutralGray
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.white, for: .disabled)
        self.titleLabel?.textAlignment = .center
        self.layer.borderColor = UIColor.regalBlue?.cgColor
        self.layer.borderWidth = isEnabled ? 1 : 0
        
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.cornerStyle = .capsule
            config.titleTextAttributesTransformer =
            UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.h5
                return outgoing
            }
            let padHeight = CGFloat(8)
            let padMinWidth = CGFloat(12)
            config.contentInsets = NSDirectionalEdgeInsets(top: padHeight, leading: padMinWidth, bottom: padHeight, trailing: padMinWidth)
            self.configuration = config
        }
        else{
            let padHeight = CGFloat(8)
            let padWidth = CGFloat(12)
            self.contentEdgeInsets = UIEdgeInsets(top: padHeight, left: padWidth, bottom: padHeight, right: padWidth)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled{
                self.backgroundColor = UIColor.regalBlue
                self.layer.borderWidth = 1
            }
            else{
                self.backgroundColor = UIColor.neutralGray
                self.layer.borderWidth = 0
            }
        }
    }
    
    private func addDropShadow()
    {
        
        //let topLayer = createShadowLayer(color: .white, offset: CGSize(width: 0, height: -10))
        let colorPass = UIColor(red: 0.77, green: 0.77, blue: 0.77, alpha: 1.0)
        let bottomLayer = createShadowLayer(color: colorPass, offset: CGSize(width: 0, height: 3))
        
        layer.cornerRadius = self.frame.size.height/2
        
        
        if let subLayers = layer.sublayers{
            for l in subLayers{
                if (l.name ?? "") == "Shadow"{
                    l.removeFromSuperlayer()
                }
            }
        }
        
        layer.insertSublayer(bottomLayer, at: 0)
        
        //layer.insertSublayer(topLayer, at: 0)
        
        
    }
    
    private func createShadowLayer(color: UIColor, offset: CGSize) -> CAShapeLayer {
        // Modified
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.frame.size.height/2).cgPath
        shadowLayer.fillColor = self.backgroundColor?.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = offset
        shadowLayer.shadowRadius = 4
        //shadowLayer.masksToBounds = false
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowOpacity = 1.0
        shadowLayer.name = "Shadow"
        
        
        
        return shadowLayer
    }
    
    
    
    
}
