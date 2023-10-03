/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

enum SuffixType: Int, CaseIterable {
    case none = 0
    case sr = 1
    case jr = 2
    case second = 3
    case third = 4
    case fourth = 5
    case fifth = 6
    
    func getStr() -> String{
        switch self {
        case .none:
            return ""
        case .jr:
            return "Jr."
        case .sr:
            return "Sr."
        case .second:
            return "II"
        case .third:
            return "III"
        case .fourth:
            return "IV"
        case .fifth:
            return "V"
        }
    }
    
    func getSuffixFromString(suf: String) -> SuffixType{
        switch suf{
        case "Jr.":
            return .jr
        case "Sr.":
            return .sr
        case "II":
            return .second
        case "III":
            return .third
        case "IV":
            return .fourth
        case "V":
            return .fifth
        default:
            return .none
        }
    }
}
