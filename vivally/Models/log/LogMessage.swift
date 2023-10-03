//
//  LogMessage.swift
//  vivally
//
//  Created by Joe Sarkauskas on 4/16/21.
//

import UIKit

class LogMessage: NSObject, Codable {
    var guid:UUID
    var id:Int
    var timestamp:Date
    var modified:Date?
    var dirty:Bool
    var delete:Bool
    
        var level: Int
        var source: String
        var message: String
        var json: String?
    
    enum CodingKeys: CodingKey{
        case guid
        case id
        case timestamp
        case modified
        case dirty
        case delete
        
        case level
        case source
        case message
        case json
    }
    
    override init() {
        guid = UUID()
        id = 0
        timestamp = Date()
        modified = nil
        dirty = true
        delete = false
        
        level = 0
        source = ""
        message = ""
        json = nil
        super.init()
    }
    
     func encode(to encoder: Encoder) throws {
        //try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
         
         try container.encode(guid, forKey:.guid)
         try container.encode(id, forKey: .id)
         try container.encode(timestamp, forKey:.timestamp)
         try container.encodeIfPresent(modified, forKey:.modified)
         try container.encodeIfPresent(delete, forKey: .delete)
         try container.encodeIfPresent(dirty, forKey: .dirty)
        
        
        try container.encodeIfPresent(level, forKey:.level)
        try container.encodeIfPresent(source, forKey:.source)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(json, forKey: .json)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        
        guid = try container.decode(UUID.self, forKey: .guid)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        //print(timestamp)
        modified = try container.decodeIfPresent(Date.self, forKey: .modified)
        dirty = try container.decode(Bool.self, forKey: .dirty)
        delete = try container.decodeIfPresent(Bool.self, forKey: .delete) ?? false
        
        level = try container.decode(Int.self, forKey: .level)
        source = try container.decode(String.self, forKey: .source)
        message = try container.decode(String.self, forKey: .message)
        json = try container.decodeIfPresent(String.self, forKey: .json)
        
        //try super.init(from: decoder)
    }
}
