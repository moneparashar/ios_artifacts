/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */
import UIKit

class SerialNumber: NSObject {
    var serialNum:UInt32
    
    override init(){
        serialNum = 0
    }
    
    func parse(data:Data) -> Bool{
        if data.count != 4{
            return false
        }
        
        serialNum = UInt32(data.to(type: UInt32.self))
        return true
    }
}
