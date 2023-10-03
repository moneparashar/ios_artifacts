/*
 * Copyright 2022, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class LogAWS:  NSObject, Codable{
    var metadata:LogMetadata
    var data:String?
    
    override init() {
        metadata = LogMetadata()
        data = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(metadata, forKey:.metadata)
        try container.encodeIfPresent(data, forKey: .data)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        metadata = try container.decode(LogMetadata.self, forKey: .metadata)
        data = try container.decodeIfPresent(String.self, forKey: .data)
        super.init()
   }
    
    enum CodingKeys: CodingKey{
        case metadata
        case data
    }
    
}
