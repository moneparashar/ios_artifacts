/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class JournalEventFocusPeriod: BaseModel{
    var userId:Int
    var startedDateUtc:Date
    var startedDateOffset:String
    var status: Int?
    var acknowledged:Date?
    var postponedCount:Int
    
    override init(){
        userId = 0
        startedDateUtc = Date()
        startedDateOffset = ""
        status = nil
        acknowledged = nil
        postponedCount = 0
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(startedDateUtc, forKey: .startedDateUtc)
        try container.encode(startedDateOffset, forKey: .startedDateOffset)
        try container.encode(status, forKey: .status)
        try container.encode(acknowledged, forKey: .acknowledged)
        try container.encode(postponedCount, forKey: .postponedCount)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userId = try container.decode(Int.self, forKey: .userId)
        startedDateUtc = try container.decode(Date.self, forKey: .startedDateUtc)
        startedDateOffset = try container.decode(String.self, forKey: .startedDateOffset)
        status = try container.decodeIfPresent(Int.self, forKey: .status)
        acknowledged = try container.decodeIfPresent(Date.self, forKey: .acknowledged)
        postponedCount = try container.decode(Int.self, forKey: .postponedCount)
        try super.init(from: decoder)
    }
    
    enum CodingKeys: CodingKey{
        case userId
        case startedDateUtc
        case startedDateOffset
        case status
        case acknowledged
        case postponedCount
    }
}
