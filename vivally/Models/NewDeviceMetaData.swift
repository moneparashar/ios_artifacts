/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class NewDeviceMetaData: Codable {
    var deviceGroupKey:String
    var deviceKey:String
    
    enum CodingKeys: CodingKey{
        case deviceGroupKey
        case deviceKey
    }
}
