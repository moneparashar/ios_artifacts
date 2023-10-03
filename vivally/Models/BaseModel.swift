/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit


class BaseModel: NSObject, Codable {
    var guid:UUID
    var id:Int
    var timestamp:Date
    var modified:Date?
    var dirty:Bool
    var deleted:Bool
    
    override init() {
        guid = UUID()
        id = 0
        timestamp = Date()
        modified = nil
        dirty = false
        deleted = false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(guid, forKey:.guid)
        try container.encode(id, forKey: .id)
        //encoder.dateEncodingStrategy = .iso8601
        
        try container.encode(timestamp, forKey:.timestamp)
        try container.encode(modified, forKey:.modified)
        try container.encodeIfPresent(deleted, forKey: .deleted)
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guid = try container.decode(UUID.self, forKey: .guid)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        //print(timestamp)
        modified = try container.decodeIfPresent(Date.self, forKey: .modified)
        dirty = false
        deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted) ?? false
        super.init()
   }
    
    enum CodingKeys: CodingKey{
        case guid
        case id
        case timestamp
        case modified
        case deleted
    }
    
    
}
