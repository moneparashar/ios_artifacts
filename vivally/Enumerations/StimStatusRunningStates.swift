/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum StimStatusRunningStates: Int8 {
    case idle = 0
    case paused = 1
    case resume = 2
    case openLoop = 3
    case closedLoop = 4
    case manualRampUp = 5
    case manualRampDown = 6
    case pausedError = 7
}
