/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class Study: Codable{
    var totalCount:Int
    var filteredCount:Int
    var records:[Clinic]
    
    init() {
        totalCount = 0
        filteredCount = 0
        records = []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalCount, forKey: .totalCount)
        try container.encode(filteredCount, forKey: .filteredCount)
        try container.encode(records, forKey: .records)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        totalCount = try container.decode(Int.self, forKey: .totalCount)
        filteredCount = try container.decode(Int.self, forKey: .filteredCount)
        records = try container.decode([Clinic].self, forKey: .records)
    }
    
    enum CodingKeys: CodingKey{
        case totalCount
        case filteredCount
        case records
    }
}
