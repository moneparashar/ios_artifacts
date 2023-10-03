/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class UserLogConfiguration: NSObject, Codable{
    var userId: Int?
    var `default`: Int?
    var authentication: Int?
    var pairing: Int?
    var screening:Int?
    var therapy: Int?
    var journal: Int?
    var upload: Int?
    var deviceInfo: Int?
    var appInfo: Int?
    var appEvents: Int?
    
    override init() {
        userId = 0
        `default` = 0
        authentication = 0
        pairing = 0
        screening = 0
        therapy = 0
        journal = 0
        upload = 0
        deviceInfo = 0
        appInfo = 0
        appEvents = 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(userId, forKey:.userId)
        try container.encodeIfPresent(`default`, forKey: .default)
        try container.encodeIfPresent(authentication, forKey: .authentication)
        try container.encodeIfPresent(pairing, forKey: .pairing)
        try container.encodeIfPresent(screening, forKey: .screening)
        try container.encodeIfPresent(therapy, forKey: .therapy)
        try container.encodeIfPresent(pairing, forKey: .journal)
        try container.encodeIfPresent(screening, forKey: .upload)
        try container.encodeIfPresent(therapy, forKey: .deviceInfo)
        try container.encodeIfPresent(pairing, forKey: .appInfo)
        try container.encodeIfPresent(screening, forKey: .appEvents)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        `default` = try container.decodeIfPresent(Int.self, forKey: .default)
        authentication = try container.decodeIfPresent(Int.self, forKey: .authentication)
        pairing = try container.decodeIfPresent(Int.self, forKey: .pairing)
        screening = try container.decodeIfPresent(Int.self, forKey: .screening)
        therapy = try container.decodeIfPresent(Int.self, forKey: .therapy)
        userId = try container.decodeIfPresent(Int.self, forKey: .journal)
        authentication = try container.decodeIfPresent(Int.self, forKey: .upload)
        pairing = try container.decodeIfPresent(Int.self, forKey: .deviceInfo)
        screening = try container.decodeIfPresent(Int.self, forKey: .appInfo)
        therapy = try container.decodeIfPresent(Int.self, forKey: .appEvents)
        
        super.init()
   }
    
    enum CodingKeys: CodingKey{
        case userId
        case `default`
        case authentication
        case pairing
        case screening
        case therapy
        case journal
        case upload
        case deviceInfo
        case appInfo
        case appEvents
    }
    
}
