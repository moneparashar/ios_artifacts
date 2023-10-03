/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class AppEvent: BaseModel {
    var type:Int
    var deviceConfigurationGuid:UUID?
    var screeningGuid:UUID?
    
    override init() {
        type = 0
        deviceConfigurationGuid = nil
        screeningGuid = nil
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(type, forKey:.type)
        try container.encodeIfPresent(deviceConfigurationGuid, forKey: .deviceConfigurationGuid)
        try container.encodeIfPresent(screeningGuid, forKey:.screeningGuid)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        type = try container.decode(Int.self, forKey: .type)
        deviceConfigurationGuid = try container.decodeIfPresent(UUID.self, forKey: .deviceConfigurationGuid)
        screeningGuid = try container.decodeIfPresent(UUID.self, forKey: .screeningGuid)
        try super.init(from: decoder)
   }
    
    enum CodingKeys: CodingKey{
        case type
        case deviceConfigurationGuid
        case screeningGuid
    }
}
