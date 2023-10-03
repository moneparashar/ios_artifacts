/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class HelpTimestamp: NSObject, Codable{
    var title: String = ""
    var type:Int = 0
    var sequence: Int = 0
    var seconds: Int = 0
    
    override init(){
        title = ""
        type = 0
        sequence = 0
        seconds = 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(type, forKey: .type)
        try container.encode(sequence, forKey: .sequence)
        try container.encode(seconds, forKey: .seconds)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        type = try container.decode(Int.self, forKey: .type)
        sequence = try container.decode(Int.self, forKey: .sequence)
        seconds = try container.decode(Int.self, forKey: .seconds)
        
        super.init()
    }
    
    enum CodingKeys: CodingKey{
        case title
        case type
        case sequence
        case seconds
    }
}
