/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class EMGData: BaseModel {
    var dataTimestamp: Int? = 0
    var index: UInt8? = 0
    var data: [Int]? = nil
    var deviceConfigurationGuid: UUID? = nil
    var screeningGuid: UUID? = nil
    var sessionGuid: UUID? = nil
    
    override init() {
        dataTimestamp = 0
        index = 0
        data = nil
        deviceConfigurationGuid = nil
        screeningGuid = nil
        sessionGuid = nil
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(dataTimestamp, forKey:.dataTimestamp)
        try container.encodeIfPresent(index, forKey: .index)
        try container.encodeIfPresent(data, forKey: .data)
        try container.encodeIfPresent(deviceConfigurationGuid, forKey:.deviceConfigurationGuid)
        try container.encodeIfPresent(screeningGuid, forKey:.screeningGuid)
        try container.encodeIfPresent(sessionGuid, forKey:.sessionGuid)
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        dataTimestamp = try container.decodeIfPresent(Int.self, forKey: .dataTimestamp)
        index = try container.decodeIfPresent(UInt8.self, forKey: .index)
        data = try container.decodeIfPresent([Int].self, forKey: .data)
        deviceConfigurationGuid = try container.decodeIfPresent(UUID.self, forKey: .deviceConfigurationGuid)
        screeningGuid = try container.decodeIfPresent(UUID.self, forKey: .screeningGuid)
        sessionGuid = try container.decodeIfPresent( UUID.self, forKey: .sessionGuid )
        
        try super.init(from: decoder)
   }
    
    enum CodingKeys: CodingKey{
        case dataTimestamp
        case index
        case data
        case deviceConfigurationGuid
        case screeningGuid
        case sessionGuid
    }
}
