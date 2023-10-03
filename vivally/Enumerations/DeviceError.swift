/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum DeviceError: UInt32 {
    case insufficientBattery            = 0b00000000000000000000000000000001
    case patientDoesNotMeetCriteria     = 0b00000000000000000000000000000010
    case patientMeetsCriteria           = 0b00000000000000000000000000000100
    case pauseLimitReached              = 0b00000000000000000000000000001000
    case dailyLimitReached              = 0b00000000000000000000000000010000
    case weeklyLimitReached             = 0b00000000000000000000000000100000
    case impedanceBad                   = 0b00000000000000000000000001000000
    case pauseTimeout                   = 0b00000000000000000000000010000000
    case savePatientInfoSuccessful      = 0b00000000000000000000000100000000
    case savePatientInfoFailed          = 0b00000000000000000000001000000000
    case loadPatientInfoSuccessful      = 0b00000000000000000000010000000000
    case loadPatientInfoFailed          = 0b00000000000000000000100000000000
    case continuityBad                  = 0b00000000000000000001000000000000
    case wrongFoot                      = 0b00000000000000000010000000000000
}
