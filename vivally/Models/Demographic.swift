/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class Demographic: BaseModel{
    var type: Int
    var displayName: String
    var sequence: Int
    
    override init(){
        type = 0
        displayName = ""
        sequence = 0
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(sequence, forKey: .sequence)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        type = try container.decode(Int.self, forKey: .type)
        displayName = try container.decode(String.self, forKey: .displayName)
        sequence = try container.decode(Int.self, forKey: .sequence)
        try super.init(from: decoder)
    }
    
    enum CodingKeys: CodingKey{
        case type
        case displayName
        case sequence
    }
}
