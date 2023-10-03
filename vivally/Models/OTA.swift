/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class OTA: Codable {
    var ready: Bool = false
        var guid: UUID?
        var timestamp: Date?
        var modified: Date?
        var name: String?
        var fileName: String?
        var fileLength: Int?
        var firmwareVersion: String?
        var firmwareVersionNumeric: Int?
        var createdByUserId: Int? = 0
    
    enum CodingKeys: CodingKey{
        case ready
        case guid
        case timestamp
        case modified
        case name
        case fileName
        case fileLength
        case firmwareVersion
        case firmwareVersionNumeric
        case createdByUserId
    }
}
