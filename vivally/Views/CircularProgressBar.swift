//
//  CircularProgressBar.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 8/4/21.
//

import UIKit

class CircularProgressBar: UIView {

    override func awakeFromNib() {
            super.awakeFromNib()
            
            updateView(currentPercent: 0.0)
        }
    
    public var lineWidth:CGFloat = 8
    public func updateView(currentPercent: Double, darkGreen: Bool = false){
        self.layer.sublayers = nil
        
        let convertPercent = CGFloat(currentPercent)
        let percentAngle = convertPercent * (2*CGFloat.pi)
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: 3*(CGFloat.pi)/2, endAngle: percentAngle + (3*(CGFloat.pi)/2), clockwise: true)
        self.progressLayer.lineCap = CAShapeLayerLineCap.round
        self.progressLayer.path = path.cgPath
        if darkGreen{
            self.progressLayer.strokeColor = UIColor(red: 0.25, green: 0.53, blue: 0.09, alpha: 1).cgColor
        }
        else{
            self.progressLayer.strokeColor = UIColor(red: 0.791, green: 0.913, blue: 0.631, alpha: 1).cgColor
        }
        self.progressLayer.lineWidth = lineWidth
        self.progressLayer.fillColor = UIColor.clear.cgColor

        self.layer.addSublayer(progressLayer)
    }
    
        //bar layer
        private let progressLayer = CAShapeLayer()
        private var radius: CGFloat {
            get{
                if self.frame.width < self.frame.height { return (self.frame.width - lineWidth)/2 }
                else { return (self.frame.height - lineWidth)/2 }
            }
        }
        
        private var pathCenter: CGPoint{ get{ return self.convert(self.center, from:self.superview) } }
        
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
