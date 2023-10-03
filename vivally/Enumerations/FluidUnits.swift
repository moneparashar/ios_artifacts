/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

enum FluidUnits: Int, CaseIterable{
    case ounces = 1
    case cups  = 2
    case milliliters = 3
    
    
    func getStr() -> String{
        switch self {
        case .ounces:
            return "oz"
        case .cups:
            return "cups"
        case .milliliters:
            return "ml"
        }
    }
}
