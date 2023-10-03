/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum iconLIst{
    case manual
    case help
    case privacy
    case contact
    case settings
    case password
    case pin
    case signOut
    case video
    
    func getImage() -> UIImage?{
        switch self {
        case .manual:
            return UIImage(named: "systemManual")?.withRenderingMode(.alwaysTemplate)
        case .help:
            return UIImage(named: "Video")?.withRenderingMode(.alwaysTemplate)
        case .privacy:
            return UIImage(named: "privacy")?.withRenderingMode(.alwaysTemplate)
        case .contact:
            return UIImage(named: "faq")?.withRenderingMode(.alwaysTemplate)
        case .settings:
            return UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate)
        case .password:
            return UIImage(named: "password")?.withRenderingMode(.alwaysTemplate)
        case .pin:
            return UIImage(named: "pin")?.withRenderingMode(.alwaysTemplate)
        case .signOut:
            return UIImage(named: "logout")?.withRenderingMode(.alwaysTemplate)
        case .video:
            return UIImage(named: "Video")?.withRenderingMode(.alwaysTemplate)
        }
    }
}

