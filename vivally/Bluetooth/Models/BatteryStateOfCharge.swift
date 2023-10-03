/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class BatteryStateOfCharge:NSObject {
    var charging:Bool
    var voltage:Int32
    var level:Int
    
    let batteryLowLevelMax = 3750000
    let batteryHighLevelMax = 4300000
    
    
    override init(){
        charging = false
        voltage = 0
        level = 0
    }
    
     func parse(data:Data) -> Bool{
        if data.count != 5{
            return false
        }
        
        charging = Bool(data.subdata(in: 0..<1).to(type: Bool.self))
        voltage = Int32(data.subdata(in: 1..<4).to(type: Int32.self))
        /*
        print("voltage: ")
        print(voltage)
        */
        return true
    }
    
    func isBatteryGreen() -> Bool{
        if voltage > batteryLowLevelMax{
            return true
        }
        return false
    }
    
    func minBatteryRequired() -> Bool{
        return level > 50
    }
    
    
    func calcLevel() {
        let full = 4100000
        let empty = 3400000
        let tempLevel = ((Int(voltage) - empty) * 100) / (full - empty)
        
        if tempLevel < 0 {
            level = 0
        }
        else if tempLevel > 100{
            level = 100
        }
        else{
            level = tempLevel
        }
    }
}
