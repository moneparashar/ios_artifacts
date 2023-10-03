/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class Note: BaseModel {
    var deviceConfigurationGuid: UUID? = nil
    var patientGuid: UUID? = nil
    var note: String = ""
    var category: String? = nil
    
    enum CodingKeys: CodingKey{
        case deviceConfigurationGuid
        case patientGuid
        case note
        case category
    }
    
    override init() {
         deviceConfigurationGuid = nil
         patientGuid = nil
         note = ""
        category = nil
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(deviceConfigurationGuid, forKey:.deviceConfigurationGuid)
        try container.encodeIfPresent(patientGuid, forKey:.patientGuid)
        try container.encodeIfPresent(note, forKey: .note)
        try container.encodeIfPresent(category, forKey: .category)
        
        
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        deviceConfigurationGuid = try container.decodeIfPresent(UUID.self, forKey: .deviceConfigurationGuid)
        patientGuid = try container.decodeIfPresent(UUID.self, forKey: .patientGuid)
        note = try container.decode(String.self, forKey: .note)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        
        try super.init(from: decoder)
    }
}
