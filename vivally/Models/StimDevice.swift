/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class StimDevice: BaseModel {
    var address:String = ""
    var serialNumber: String = ""
    
    enum CodingKeys: CodingKey{
        case address
        case serialNumber
    }
    
    override init() {
        address = ""
        serialNumber = ""
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(address, forKey:.address)
        try container.encodeIfPresent(serialNumber, forKey: .serialNumber)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        address = try container.decode(String.self, forKey: .address)
        serialNumber = try container.decode(String.self, forKey: .serialNumber)
        
        try super.init(from: decoder)
    }
}
