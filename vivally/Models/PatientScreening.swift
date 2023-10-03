/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class PatientScreening: Codable {
    //var exists:Bool = false
    var user:PatientExists?
    var clinic:Clinic?
    
    enum CodingKeys: CodingKey{
        //case exists
        case user
        case clinic
    }
}
