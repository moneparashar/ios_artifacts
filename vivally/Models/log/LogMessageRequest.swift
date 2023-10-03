//
//  LogMessageRequest.swift
//  vivally
//
//  Created by Joe Sarkauskas on 4/16/21.
//

import UIKit

class LogMessageRequest: /*BaseModel*/ NSObject, Codable {
    var metadata: LogMetadata
    var data: String //String from LogMessage decoded
    
    enum CodingKeys: CodingKey{
        case metadata
        case data
    }
    
    override init() {
        metadata = LogMetadata()
        data = ""
        super.init()
    }
    
    func encode(to encoder: Encoder) throws {
        //try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(metadata, forKey:.metadata)
        try container.encodeIfPresent(data, forKey: .data)
        
        
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        metadata = try container.decode(LogMetadata.self, forKey: .metadata)
        data = try container.decode(String.self, forKey: .data)
        
        //try super.init(from: decoder)
    }
}
