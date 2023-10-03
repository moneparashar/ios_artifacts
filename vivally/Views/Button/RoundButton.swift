//
//  RoundButton.swift
//  vivally
//
//  Created by Joe Sarkauskas on 3/10/22.
//

import UIKit

class RoundButton: UIButton {

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
        self.backgroundColor = UIColor(named: "avationPaleGreen")
        self.setTitleColor(UIColor(named: "avationMdGreen"), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
       if !isSublayerAdded{
            //isSublayerAdded = true
            addDropShadow()
        }
        
        
        
        if imageView?.image != nil {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 40), bottom: 5, right: 10)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: (imageView?.frame.width)!)
            contentHorizontalAlignment = .left
        }
    }
    
    private func configure() {
        
        self.layer.cornerRadius = self.frame.size.height/2
        self.backgroundColor = UIColor(named: "avationLtGreen")
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.white, for: .disabled)
        self.titleLabel?.textAlignment = .center
        
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled{
                self.backgroundColor = UIColor(named: "avationLtGreen")
            }
            else{
                self.backgroundColor = UIColor(named: "avationLtGray")
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
