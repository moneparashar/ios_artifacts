/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum ImpedanceCheckValues: UInt8 {
    case impedanceInvalid   = 0b00000000
    case impedance          = 0b00000001
    case continuity         = 0b00000010
    case foot               = 0b00000100
}
