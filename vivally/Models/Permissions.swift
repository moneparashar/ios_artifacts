/*
 * Copyright 2022, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class Permissions: NSObject, Codable {
    var userId:Int
    var viewTherapy:Bool
    var viewJournal:Bool
    
    enum CodingKeys: CodingKey{
        case userId
        case viewTherapy
        case viewJournal
    }
    
    override init() {
        userId = 0
        viewTherapy = false
        viewJournal = false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(userId, forKey:.userId)
        try container.encodeIfPresent(viewTherapy, forKey:.viewTherapy)
        try container.encodeIfPresent(viewJournal, forKey: .viewJournal)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userId = try container.decode(Int.self, forKey: .userId)
        viewTherapy = try container.decode(Bool.self, forKey: .viewTherapy)
        viewJournal = try container.decode(Bool.self, forKey: .viewJournal)
    }
}
