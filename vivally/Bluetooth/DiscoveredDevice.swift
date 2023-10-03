/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import CoreBluetooth

class DiscoveredDevice: NSObject {
    let name:String
    let peripheral:CBPeripheral?
    let mac:String
    
    func getMac() -> String{
        var minMac = ""
        if mac.count > 5{
            let bah = mac.filter{ $0.isLetter || $0.isNumber}
            minMac = String(bah.suffix(4)).uppercased()
        }
        return minMac
    }
    
    init(name:String,mac:String, peripheral:CBPeripheral){
        self.name = name
        self.peripheral = peripheral
        self.mac = mac
    }
    
    override init(){
        self.name = ""
        self.peripheral = nil
        self.mac = "unknown"
        super.init()
    }
}
