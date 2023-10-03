/*
 * Copyright 2022, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum Modes: CaseIterable{
    case clinical
    case noStim
    case lowStim

    
    func getModeCommandValue() -> Int{
        switch self {
        case .clinical:
            return BluetoothConstants.PARAM_DEVICE_MODE_CLINICAL
        case .noStim:
            return BluetoothConstants.PARAM_DEVICE_MODE_NO_STIM
        case .lowStim:
            return BluetoothConstants.PARAM_DEVICE_MODE_LOW_STIM
        }
    }
    
    func getDeviceModeEquivalent() -> Int{
        switch self {
        case .clinical:
            return 1
        case .noStim:
            return 4
        case .lowStim:
            return 2
        }
    }
}

