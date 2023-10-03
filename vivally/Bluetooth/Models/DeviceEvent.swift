/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class DeviceEvent: NSObject {
    var eventId: Int16
    var parameters:[Int8]
    
    let DeviceEventBadTimestamp: Int16 = 0x0001
    
    override init(){
        eventId = 0
        parameters = []
    }
    
    func parse(data: Data) -> Bool{
        eventId = Int16(data.subdata(in: 0..<2).to(type: Int16.self))
        for index in 2 ..< 20{
            parameters.append(Int8(data[index]))
        }
        return true
    }
    
    func toDataModel(deviceEvent:Int16, parameter:Int8) -> Data{
        var data = Data()
        data.append(Data(from: deviceEvent))
        data.append(Data(from: parameter))
        let buffer:UInt8 = 0x00
        for _ in 3..<20{
            data.append(buffer)
        }
        return data
    }
}
