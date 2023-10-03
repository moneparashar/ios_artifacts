/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

enum TherapySchedules:Int, CaseIterable{
    case none = 0
    case oneTimes = 1
    case threeTimes = 3
    case twoTimes = 2
    case fourTimes = 4
    case fiveTimes = 5
    case sixTimes = 6
    case sevenTimes = 7
    
    case oncePer2Weeks = 14
    case oncePer4Weeks = 28
    
    case unknownSchedule = -1
    
    init(rawValue: Int) {
        switch rawValue{
        case 1:
            self = .oneTimes
        case 2:
            self = .twoTimes
        case 3:
            self = .threeTimes
        case 4:
            self = .fourTimes
        case 5:
            self = .fiveTimes
        case 6:
            self = .sixTimes
        case 7:
            self = .sevenTimes
        
        //1 per every (x / 7) weeks
        case 14:
            self = .oncePer2Weeks
        case 28:
            self = .oncePer4Weeks
            
        case 0:
            self = .none
        default:
            self = .unknownSchedule
        }
    }
    
    func getStr() -> String{
        if rawValue <= 7{
            let valStr = String(self.rawValue)
            return valStr + " / week"
        }
        else{
            let actualVal = self.rawValue / 7
            return "1 / " + String(actualVal) + "-weeks"
        }
    }
}
