/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class Patient: BaseModel {
    var screeningId: String = ""
    var subjectId: String? = nil
    var token: String? = nil
    
    enum CodingKeys: CodingKey{
        case screeningId
        case subjectId
        case token
    }
    
    override init() {
         screeningId = ""
         subjectId = nil
         token = ""
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(screeningId, forKey:.screeningId)
        try container.encodeIfPresent(subjectId, forKey:.subjectId)
        try container.encodeIfPresent(token, forKey: .token)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        screeningId = try container.decode(String.self, forKey: .screeningId)
        subjectId = try container.decodeIfPresent(String.self, forKey: .subjectId)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        
        try super.init(from: decoder)
    }
}
