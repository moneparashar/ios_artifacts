/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

enum GarmentSizes: Int, CaseIterable{
    case none = 0
    case small = 1
    case medium = 2

    func getStr() -> String{
        switch self {
        case .small:
            return "Small"
        case .medium:
            return "Medium"
        default:
            return ""
        }
    }
}
