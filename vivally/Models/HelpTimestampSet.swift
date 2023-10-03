/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class HelpTimestampSet: NSObject, Codable{
    var url: String = ""
    var timestamps: [HelpTimestamp] = []
    
    override init(){
        url = ""
        timestamps = []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(timestamps, forKey: .timestamps)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        timestamps = try container.decodeIfPresent([HelpTimestamp].self, forKey: .timestamps) ?? []
        
        super.init()
    }
    
    enum CodingKeys: CodingKey{
        case url
        case timestamps
    }
    
}
