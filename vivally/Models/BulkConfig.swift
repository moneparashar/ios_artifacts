/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class BulkConfig: NSObject, Codable {
    var recordCount:Int
    
    override init() {
        recordCount = 0
        super.init()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(recordCount, forKey:.recordCount)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        recordCount = try container.decode(Int.self, forKey: .recordCount)
        super.init()
   }
    
    enum CodingKeys: CodingKey{
        case recordCount
    }
}
