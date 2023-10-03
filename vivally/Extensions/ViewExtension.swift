/*
 * Copyright 2022, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation
import UIKit

extension UIView{
    func getSpacingConstant(percent: Double = 60) -> CGFloat{
        var sp = CGFloat(0)
        let largeWidth = self.bounds.width
        
        sp = largeWidth * (100 - percent) / 200
        return sp
    }
    
    func getWidthConstant(specificPercent: Double? = nil) -> CGFloat{
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        var wid = CGFloat(0)
        let viewWidth = self.bounds.width
        
        if specificPercent != nil{
            wid = viewWidth * (specificPercent!)  / 100
        }
        else{
            let per = isPhone ? 0.86 : 0.6
            wid = viewWidth * per
        }
        return wid
    }
    
    func fixView(_ container: UIView!) -> Void{
            self.translatesAutoresizingMaskIntoConstraints = false;
            self.frame = container.frame;
            container.addSubview(self);
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
