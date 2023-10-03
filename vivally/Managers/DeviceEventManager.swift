/*
 * Copyright 2022, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class DeviceEventManager: NSObject{
    static let sharedInstance = DeviceEventManager()
    
    var deviceEvent = DeviceEvent()
    
    func handleDeviceEvent(devEvent: DeviceEvent){
        if devEvent.eventId == DeviceEvent().DeviceEventBadTimestamp{
            DataRecoveryManager.sharedInstance.deleteTimestamp()
            print("bad Timestamp")
            //set datarecoverybadtimestamp to true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "badTimestamp"), object: nil)
        }
    }
}
