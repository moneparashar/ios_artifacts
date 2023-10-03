/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class EMGStatus: NSObject {
    var timestamp:UInt32
    var index:UInt8
    var theData:[Int32]
    
    override init(){
        timestamp = 0
        index = 0
        theData = []
    }
    
    func parse(data:Data) -> Bool{
        //print(data.hexEncodedString())
        
        timestamp = UInt32(data.subdata(in: 0..<4).to(type: UInt32.self))
        index = UInt8(UInt8(data.subdata(in: 4..<5).to(type: UInt8.self)))
        var count = 0
        var temp:[UInt8] = []
        //var tempindex = 0
        for index in 5..<133{
            temp.append(data[index])
            if count == 3{
                let subdata = Data(temp)
                let num = Int32(subdata.to(type: Int32.self))
                theData.append(num)
                temp = []
                count = 0
            }
            else{
                count += 1
            }
        }
        return true
    }
}
