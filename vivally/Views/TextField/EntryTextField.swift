//
//  EntryTextField.swift
//  vivally
//
//  Created by Joe Sarkauskas on 4/23/21.
//

import UIKit

class EntryTextField: UITextField {
    
    struct Constants {
            static let sidePadding: CGFloat = 20
            static let topPadding: CGFloat = 8
        }
    var isSublayerAdded:Bool = false
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return CGRect(
                x: bounds.origin.x + Constants.sidePadding,
                y: bounds.origin.y + Constants.topPadding,
                width: bounds.size.width - Constants.sidePadding * 2,
                height: bounds.size.height - Constants.topPadding * 2
            )
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return self.textRect(forBounds: bounds)
        }
    
    override func layoutSubviews() {
         super.layoutSubviews()
         self.layer.cornerRadius = self.frame.size.height/2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.706, green: 0.706, blue: 0.706, alpha: 0.29).cgColor
        
        if !isSublayerAdded{
            self.addInnerShadow()
            self.addInnerLight()
            self.layer.backgroundColor = UIColor(red: 0.979, green: 0.975, blue: 0.975, alpha: 1.0).cgColor
        }
     }

    private func addInnerShadow() {
        
        isSublayerAdded = true
        
        let innerShadow = CALayer()
        innerShadow.frame = bounds
        
        // Shadow path (1pt ring around bounds)
        let radius = self.frame.size.height/2
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: -0.5, dy:-0.5), cornerRadius:radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius:radius).reversing()
        
        
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        // Shadow properties
        //innerShadow.shadowColor = UIColor(red: 0.77, green: 0.77, blue: 0.77, alpha: 1).cgColor
        //innerShadow.shadowColor = UIColor(red: 0.553, green: 0.772, blue: 0.551, alpha: 1).cgColor
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 3)
        innerShadow.shadowOpacity = 1.0
        innerShadow.shadowRadius = 3
        innerShadow.cornerRadius = self.frame.size.height/2
        layer.addSublayer(innerShadow)
    }
    
    private func addInnerLight(){
        
        isSublayerAdded = true
        
        let innerShadow = CALayer()
        innerShadow.frame = bounds
        
        let radius = self.frame.size.height/2
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: -1, dy:-1), cornerRadius:radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius:radius).reversing()
        
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        // Shadow properties
        innerShadow.shadowColor = UIColor.white.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: -3)
        innerShadow.shadowOpacity = 1.0
        innerShadow.shadowRadius = 4
        innerShadow.cornerRadius = self.frame.size.height/2
        layer.addSublayer(innerShadow)
    }
}
