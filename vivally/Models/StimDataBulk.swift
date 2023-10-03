/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class StimDataBulk: Codable {
    var bulk: [StimData] = []
    
    init() {
        bulk = []
    }
    
    func encode(to encoder: Encoder) throws {
        /*
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bulk, forKey: .bulk)
        */
        //try container.encode(bulk)
        
        //try this if top fails
        var container = encoder.unkeyedContainer()
        try container.encode(bulk)
    }
    
    required init(from decoder: Decoder) throws {
        /*
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //bulk = try container.decode([StimData].self, forKey: .bulk)
        bulk = try container.decode([StimData].self, forKey: .bulk)
        */
        var container2 = try decoder.unkeyedContainer()
        bulk = try container2.decode([StimData].self)
    }
    
    
    enum CodingKeys: CodingKey{
        case bulk
    }
    
}
