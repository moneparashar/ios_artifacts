/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum StimStatusStates: Int8 {
    case idle = 0
    case running = 1
    case paused = 2
    case competed = 3
    case stopped = 4
    
    func getStr() -> String{
        switch self {
        case .idle:
            return "idle"
        case .running:
            return "running"
        case .paused:
            return "paused"
        case .competed:
            return "completed"
        case .stopped:
            return "stopped"
        }
    }
}
