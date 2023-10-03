/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class DeviceInfo: BaseModel {
    var voluntaryEMG: UInt8? = nil
    var impedance: UInt8? = nil
    var error: Int? = nil
    var charging: UInt8? = nil
    var level: Int? = nil
    var empty: Int? = nil
    var low: Int? = nil
    var half: Int? = nil
    var high: Int? = nil
    var full: Int? = nil
    var deviceConfigurationGuid: UUID? = nil
    var patientGuid: UUID? = nil
    
    enum CodingKeys: CodingKey{
        case voluntaryEMG
        case impedance
        case error
        case charging
        case level
        case empty
        case low
        case half
        case high
        case full
        case deviceConfigurationGuid
        case patientGuid
    }
    
    override init() {
        voluntaryEMG = nil
        impedance = nil
        error = nil
        charging = nil
        patientGuid = nil
        level = nil
        empty = nil
        low = nil
        half = nil
        high = nil
        full = nil
        deviceConfigurationGuid = nil
        patientGuid = nil
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(voluntaryEMG, forKey:.voluntaryEMG)
        try container.encodeIfPresent(impedance, forKey: .impedance)
        try container.encodeIfPresent(error, forKey:.error)
        try container.encodeIfPresent(charging, forKey:.charging)
        try container.encodeIfPresent(patientGuid, forKey:.patientGuid)
        try container.encodeIfPresent(level, forKey:.level)
        try container.encodeIfPresent(empty, forKey:.empty)
        try container.encodeIfPresent(low, forKey:.low)
        try container.encodeIfPresent(half, forKey:.half)
        try container.encodeIfPresent(high, forKey:.high)
        try container.encodeIfPresent(full, forKey:.full)
        try container.encodeIfPresent(deviceConfigurationGuid, forKey:.deviceConfigurationGuid)
        try container.encodeIfPresent(patientGuid, forKey:.patientGuid)
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        voluntaryEMG = try container.decodeIfPresent(UInt8.self, forKey: .voluntaryEMG)
        impedance = try container.decodeIfPresent(UInt8.self, forKey: .impedance)
        error = try container.decodeIfPresent(Int.self, forKey: .error)
        charging = try container.decodeIfPresent(UInt8.self, forKey: .charging)
        patientGuid = try container.decodeIfPresent(UUID.self, forKey: .patientGuid)
        level = try container.decodeIfPresent(Int.self, forKey: .level)
        empty = try container.decodeIfPresent(Int.self, forKey: .empty)
        low = try container.decodeIfPresent(Int.self, forKey: .low)
        half = try container.decodeIfPresent(Int.self, forKey: .half)
        high = try container.decodeIfPresent(Int.self, forKey: .high)
        full = try container.decodeIfPresent(Int.self, forKey: .full)
        patientGuid = try container.decodeIfPresent(UUID.self, forKey: .patientGuid)
        empty = try container.decodeIfPresent(Int.self, forKey: .empty)
        try super.init(from: decoder)
   }
    
}
