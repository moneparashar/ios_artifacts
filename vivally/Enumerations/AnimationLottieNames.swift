/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

enum AnimationLottieNames: String{
    //screening
    case screeningBackground = "ClinicianComp_Background"
    case screeningEMGLabel = "ClinicianComp_EMG_Label"
    case screeningFillActive = "ClinicianComp_Fill_Active"
    case screeningFillInactive = "ClinicianComp_Fill_Inactive"  //use active instead with different color
    case screeningEMGActive = "ClinicianComp_EMG_Active"
    
    //therapy
    case therapyBackground = "PatientComp_Background"
    case therapyFillActive = "PatientComp_Fill_Active"
    case therapyFillInactive = "PatientComp_Fill_Inactive"
    
    case therapySwirl = "StimAnimation_Loop1s"
    
}
