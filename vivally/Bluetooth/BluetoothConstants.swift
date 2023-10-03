/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class BluetoothConstants: NSObject {
    static let patientServiceString = "2d75c71d-1c34-409a-90ea-915333f45488"
    static let informationServiceString = "2d75c71d-1c34-409a-9554-f6566c8dde68"
    static let otaServiceString = "0000fe20-cc7a-482a-984a-7f2ed5b3e58f"
    
    /// Information Service Characteristics
    static let batteryStateOfChargeCharacteristicString = "2d75c71d-1c34-409a-9554-ef63dce41886"
    static let batteryLevelsCharacteristicString = "2d75c71d-1c34-409a-9554-235fb1be9a4a"
    static let signalCharacteristicString = "2d75c71d-1c34-409a-9554-c9339bb51d0a"
    static let stimulationStatusCharacteristicString = "2d75c71d-1c34-409a-9554-2b119f443bec"
    static let infoTherapySessionCharacteristicString =  "2d75c71d-1c34-409a-9554-9fda914cfcd6" //similar to stim status, use when session ends (so only send once)
    static let emgStatusCharacteristicString = "2d75c71d-1c34-409a-9554-44a3111ae86d"
    static let commandCharacteristicString = "2d75c71d-1c34-409a-9554-751aa4d0c93f"
    static let asciiCommandCharacteristicString = "2d75c71d-1c34-409a-9554-eebc8a461c8c"
    static let deviceCharacteristicString = "2d75c71d-1c34-409a-9554-18cb081d41dc"              //info_device_char vivally_info_device_char
    static let asciiCommandEchoCharacteristicString = "2d75c71d-1c34-409a-9554-2740a1d70228"
    static let timeCharacteristicString = "2d75c71d-1c34-409a-9554-dfdabe99965f"
    static let deviceParametersCharacteristicString = "2d75c71d-1c34-409a-9554-7c7fb6eb3c2e"
    static let revisionCharacteristicString = "2d75c71d-1c34-409a-9554-531ac23ab820"
    static let rebootRequestCharacteristicString = "0000fe11-8e22-4541-9d4c-21edae82ed19"
    static let serialNumberCharacteristicString = "2d75c71d-1c34-409a-9554-b90eed867dbb"
    static let deviceEventCharacteristicString = "2d75c71d-1c34-409a-9554-5d007d99f429"
    
    /// Patient Service Characteristics
    static let therapyScheduleCharacteristicString = "2d75c71d-1c34-409a-90ea-09585fa668f9"
    static let therapyLengthCharacteristicString = "2d75c71d-1c34-409a-90ea-39215ced2006"
    static let pulseWidthAtSkinParastheisaCharacteristicString = "2d75c71d-1c34-409a-90ea-f8fb7f134b79"
    static let pulseWidthAtComfortCharacteristicString = "2d75c71d-1c34-409a-90ea-0d2ecf902f2c"
    static let pulseWidthAtEMGCharacteristicString = "2d75c71d-1c34-409a-90ea-5e922c1b1fc1"         //used for EMG Detect
    static let emgStrengthMaxCharacteristicString = "2d75c71d-1c34-409a-90ea-d4fc85829606"
    static let readyToSendCharacteristicString = "2d75c71d-1c34-409a-90ea-dfd913bb6eb5"
    static let footCharacteristicString = "2d75c71d-1c34-409a-90ea-5b0a9d231ceb"
    static let targetEMGCharacteristicString = "2d75c71d-1c34-409a-90ea-037d8d350d9e"
    static let recoverCharacteristicString = "2d75c71d-1c34-409a-90ea-f32b0f5dda97"
    static let temporaryPainThresholdCharacteristicString = "2d75c71d-1c34-409a-90ea-b0ead998b103"
    static let currentTickCharacteristicString = "2d75c71d-1c34-409a-90ea-fc8772d15965"
    static let dailyTherapyTimeCharacteristicString = "2d75c71d-1c34-409a-90ea-0b9174e1c7cb"
    static let lastCompletedTimeCharacteristicString = "2d75c71d-1c34-409a-90ea-9bf383239a06"
    
    //put that under information service char
    
    /// OTA Service Characteristics
    static let baseAddressCharacteristicString = "0000fe22-8e22-4541-9d4c-21edae82ed19"
    static let fileUploadConfirmationRebootCharacteristicString = "0000fe23-8e22-4541-9d4c-21edae82ed19"
    static let rawDataCharacteristicString = "0000fe24-8e22-4541-9d4c-21edae82ed19"
    static let otaRevisionCharacteristicString = "4df38a8d-8230-4795-8b6f-f51ba63d522f"
    
    
    static let param_change_amplitude_decrement = 0
    static let param_change_amplitude_increment = 1
    
    static let PARAM_STIM_NOTIFY_FALSE = 0
    static let PARAM_STIM_NOTIFY_TRUE = 1
    
    static let PARAM_DEVICE_MODE_CLINICAL = 0
    static let PARAM_DEVICE_MODE_ENGINEERING = 1
    
    static let PARAM_DEVICE_MODE_NO_STIM = 2
    static let PARAM_DEVICE_MODE_LOW_STIM = 3
}
