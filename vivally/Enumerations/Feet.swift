/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum Feet: Int32 {
    case left = 0
    case right = 1

    func getIntVal() -> Int{
        return Int(self.rawValue)
    }
    
    func getAllCapsStr() -> String{
        switch self {
        case .left:
            return "LEFT"
        case .right:
            return "RIGHT"
        }
    }
    
    func getOtherFoot() -> Feet{
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        }
    }
}
