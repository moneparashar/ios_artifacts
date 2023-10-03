/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class OTAAddress: NSObject{
    var action:OTAAddressActions
    var address1:UInt8?
    var address2:OTAAddress2?
    var address3:UInt8?
    
    override init(){
        action = .cancelUpload
        address1 = nil
        address2 = nil
        address3 = nil
    }
    
    func toDataModel() -> Data{
        var data = Data()
        data.append(Data(from: action))
        
        if address1 != nil && address2 != nil && address3 != nil {
            data.append(address1!)
            data.append(address2!.rawValue)
            data.append(address3!)
        }
        
        
        //let buffer:UInt8 = 0x00
        
        return data
    }
    
    func toDataStartModel() -> Data{
        var data = Data()
        
        data.append(0x02)
        data.append(0x00)
        data.append(0x70)
        data.append(0x00)
        
        return data
    }
    
    func toDataFinishModel() -> Data{
        var data = Data()
        
        data.append(0x07)
        return data
    }
    
    func startUserApplicationFileUpload(){
        action = .startUserApplicationFileUpload
        address1 = 0x00
        address2 = .userApplication
        address3 = 0x00
        
        
        //print("\(action.rawValue) \(address1.rawValue) \(address2?.rawValue ?? 0) \(address3.rawValue)")
    }
    
    func fileUploadFinish() {
        action = .fileUploadFinished
    }
}
