/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class BatteryLevels: NSObject {
    var empty:UInt32
    var low:UInt32
    var half:UInt32
    var high:UInt32
    var full:UInt32
    
    override init(){
        empty = 0
        low = 0
        half = 0
        high = 0
        full = 0
    }
    
    func parse(data:Data) -> Bool{
        if data.count != 20{
            return false
        }
        
        empty = UInt32(data.subdata(in: 0..<4).to(type: UInt32.self))
        low = UInt32(data.subdata(in: 4..<8).to(type: UInt32.self))
        half = UInt32(data.subdata(in: 8..<12).to(type: UInt32.self))
        high = UInt32(data.subdata(in: 12..<16).to(type: UInt32.self))
        full = UInt32(data.subdata(in: 16..<20).to(type: UInt32.self))
        
        /*
        print("Battery levels low to High: ")
        print(low)
        print(half)
        print(high)
        print(full)
        */
        return true
    }
}
