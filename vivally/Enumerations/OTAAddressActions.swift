/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum OTAAddressActions: UInt8 {
    case stopAllUpload = 0
    case startWirelessFileUpload = 1
    case startUserApplicationFileUpload = 2
    case fileUploadFinished = 7
    case cancelUpload = 8
}

enum OTAAddress2: UInt8{
    case wirelessApplication = 0x00
    case userApplication = 0x70                 //112       or b1110000
}
