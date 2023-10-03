/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class Command: NSObject {
    var command:UInt16
    var parameters:[UInt8]
    
    override init(){
        command = 0
        parameters = []
    }
    
    func parse(data:Data) -> Bool{
        
        command = UInt16(data.subdata(in: 0..<2).to(type: UInt16.self))
        
        parameters = []
        for index in 2 ..< 20{
            parameters.append(data[index])
        }
        
        return true
    }
    
    func toDataModel(command:UInt16, parameter: [UInt8])-> Data{
        var data = Data()
        data.append(Data(from: command))
        let buffer:UInt8 = 0x00
        
        if parameter.isEmpty{
            for _ in 2 ..< 20{
                data.append(buffer)
            }
        }
        else{
            for bah in parameter{
                data.append(Data(from: bah))
            }
            let count = parameter.count
            for _ in (count + 2) ..< 20{
                data.append(buffer)
            }
        }
        return data
    }
    
}
