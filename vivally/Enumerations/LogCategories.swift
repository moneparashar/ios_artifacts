/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

public enum LogCategories: String{
    case `default` = "Default"
    case authentication = "Authentication"
    case pairing = "Pairing"
    case screening = "Screenig"
    case therapy = "Therapy"
    case journal = "Journal"
    case upload = "Upload"
    case deviceInfo = "Device Info"
    case appInfo = "AppInfo"
    case appEvents = "AppEvents"
}
