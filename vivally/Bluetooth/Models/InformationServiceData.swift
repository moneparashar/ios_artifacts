/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class InformationServiceData: NSObject {
    var batteryLevels = BatteryLevels()
    var batteryStateOfCharge = BatteryStateOfCharge()
    var stimStatus = StimulationStatus()
    var deviceData = Device()
    var revision = Revision()
    var serialNumber = SerialNumber()
    var emgStatus = EMGStatus()
    var therapySession = TherapySession()
    var deviceEvent = DeviceEvent()
    var time = UInt32(0)
}
