/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class DeviceConfig: BaseModel {
    var appVersion:String? // Get app version from iOS
    var firmwareVersion:String? // Get When connected
    var appDeviceGuid:UUID?
    var stimDeviceGuid:UUID?
    var screeningGuid:UUID?
    //var recoveryVersion:Int?
    //var recovery:PatientRecovery?
    
    override init() {
        appVersion = nil
        firmwareVersion = nil
        appDeviceGuid = nil
        stimDeviceGuid = nil
        screeningGuid = nil
        //recoveryVersion = nil
        //recovery = nil
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(appVersion, forKey:.appVersion)
        try container.encodeIfPresent(firmwareVersion, forKey:.firmwareVersion)
        try container.encodeIfPresent(appDeviceGuid, forKey: .appDeviceGuid)
        try container.encodeIfPresent(stimDeviceGuid, forKey:.stimDeviceGuid)
        try container.encodeIfPresent(screeningGuid, forKey:.screeningGuid)
        //try container.encodeIfPresent(recoveryVersion, forKey:.recoveryVersion)
        //try container.encodeIfPresent(recovery, forKey:.recovery)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        appVersion = try container.decodeIfPresent(String.self, forKey: .appVersion)
        firmwareVersion = try container.decodeIfPresent(String.self, forKey: .firmwareVersion)
        appDeviceGuid = try container.decodeIfPresent(UUID.self, forKey: .appDeviceGuid)
        stimDeviceGuid = try container.decodeIfPresent(UUID.self, forKey: .stimDeviceGuid)
        screeningGuid = try container.decodeIfPresent(UUID.self, forKey: .screeningGuid)
        //recoveryVersion = try container.decodeIfPresent(Int.self, forKey: .recoveryVersion)
        //recovery = try container.decodeIfPresent(PatientRecovery.self, forKey: .recovery)
        try super.init(from: decoder)
   }
    
    enum CodingKeys: CodingKey{
        case appVersion
        case firmwareVersion
        case appDeviceGuid
        case stimDeviceGuid
        case screeningGuid
        //case recoveryVersion
        //case recovery
    }
}
