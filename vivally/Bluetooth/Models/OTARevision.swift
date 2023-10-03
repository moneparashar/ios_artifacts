/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class OTARevision: NSObject {
    var major:UInt8
    var minor:UInt8
    var patch:UInt8
    var rev:String
    
    override init(){
        major = 0
        minor = 0
        patch = 0
        rev = ""
    }
    
    func parse(data:Data) -> Bool{
        if data.count != 3{
            return false
        }
        
        major = data[0]
        minor = data[1]
        patch = data[2]
        
        return true
    }
    
    func revisionStr(data: Data) {
        if let str = String(data: data, encoding: .utf8){
            rev = str
        }
    }
}
