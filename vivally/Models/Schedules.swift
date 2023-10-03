/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class Schedules: Codable{
    var schedules:[Int] = []
    
    /*
    init(){
        schedules = []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schedules, forKey: .schedules)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schedules = try container.decode([Int].self, forKey: .schedules)
    }
    */
    
    
    enum CodingKeys: CodingKey{
        case schedules
    }
}


