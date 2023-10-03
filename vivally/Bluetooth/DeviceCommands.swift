/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum DeviceCommands: UInt16 {
    case stopStim = 0x0000
    case startStim = 0x0001
    case startStimEval = 0x0002         //clicking play
    case startEmgTest = 0x0003          //unused
    case pauseStim = 0x0004
    case resumeStim = 0x0005
    case startStimImpedance = 0x0006        //run before screening screen; wait for 7 seconds
    case startStimEMG = 0x0007             //unused
    case restartStimEval = 0x0008           //rescreen
    case discontinueStimEval = 0x0009       //maybe when going back/out of screening
    case startStimImpedanceRunTherapy = 0x0010
    case startStimTest = 0x0011                 //on test therapy screen instead of startStim
    case startDataRecovery = 0x0012
    case clearDataRecovery = 0x0013
    case sessionStatusAck = 0x0014
    case bondedAck = 0x0015
    
    case changeAmplitude = 0x0100
    case stimNotify = 0x0101
    
    case deviceMode = 0x0200                    
}


