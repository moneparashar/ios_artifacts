/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class StimDeviceAndDeviceConfig: Codable {
    var stimDevice: StimDevice = StimDevice()
    var deviceConfig: DeviceConfig? = nil
    
    enum CodingKeys: CodingKey{
        case stimDevice
        case deviceConfig
    }
}
