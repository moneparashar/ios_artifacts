/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit


class Clinic: NSObject, Codable {
    var name:String
    var groupName:String?
    var studySchedules:Schedules?
    var id:Int
    var timestamp:Date
    var modified:Date?
    
    override init() {
        name = ""
        groupName = nil
        studySchedules = nil
        id = 0
        timestamp = Date()
        modified = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey:.name)
        try container.encodeIfPresent(groupName, forKey: .groupName)
        try container.encodeIfPresent(studySchedules, forKey: .studySchedules)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey:.timestamp)
        try container.encodeIfPresent(modified, forKey:.modified)
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        groupName = try container.decodeIfPresent(String.self, forKey: .groupName)
        studySchedules = try container.decodeIfPresent(Schedules.self, forKey: .studySchedules)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        modified = try container.decodeIfPresent(Date.self, forKey: .modified)
        
        super.init()
   }
    
    enum CodingKeys: CodingKey{
        case name
        case groupName
        case studySchedules
        case id
        case timestamp
        case modified
    }
    
    
}
