//
//  JournalEntrySlider.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 7/2/21.
//

import UIKit
import MaterialComponents.MaterialSlider

class JournalEntrySlider: UISlider {
   
    var stepValue:Float = 1.0
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        if stepValue > 0{
            let noOfStep = (value/stepValue).rounded(.toNearestOrEven)
            value = noOfStep * stepValue
        }
        
        if !isContinuous{
            sendActions(for: .valueChanged)
        }
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
