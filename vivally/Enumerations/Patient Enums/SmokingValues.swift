/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

enum SmokingValues: Int, CaseIterable{
    case none = 0
    case yes = 1
    case no = 2
    
    func getStr() -> String{
        switch self {
        case .none:
            return ""
        case .yes:
            return "Yes"
        case .no:
            return "No"
        }
    }
    
    func getBool() -> Bool?{
        switch self {
        case .none:
            return nil
        case .yes:
            return true
        case .no:
            return false
        }
    }
}
