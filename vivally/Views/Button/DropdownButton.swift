//
//  DropdownButton.swift
//  vivally
//
//  Created by Joe Sarkauskas on 6/24/21.
//

import UIKit

class DropdownButton: UIButton {

    var isSublayerAdded:Bool = false
    let cornerRadius:CGFloat = 10
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
       if !isSublayerAdded{
            isSublayerAdded = true
            addDropShadow()
        }
        
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 20), bottom: 5, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: (imageView?.frame.width)!)
            contentHorizontalAlignment = .left
        }
    }
    
    private func configure() {
        self.layer.cornerRadius = cornerRadius
        self.tintColor = UIColor(named: "avationLtGreen")
        self.backgroundColor = UIColor(named: "avationBackground")
    }
    
    private func addDropShadow()
    {
        
        let topLayer = createShadowLayer(color: .white, offset: CGSize(width: 0, height: -10))
        let bottomLayer = createShadowLayer(color: .darkGray, offset: CGSize(width: 0, height: 1))
        
        layer.cornerRadius = cornerRadius
        // Modified
        layer.insertSublayer(bottomLayer, at: 0)
        layer.insertSublayer(topLayer, at: 0)
        
        
    }
    
    private func createShadowLayer(color: UIColor, offset: CGSize) -> CAShapeLayer {
        // Modified
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        shadowLayer.fillColor = self.backgroundColor?.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = offset
        shadowLayer.shadowRadius = 3
        //shadowLayer.masksToBounds = false
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowOpacity = 0.5
        
        
        
        return shadowLayer
    }

}
