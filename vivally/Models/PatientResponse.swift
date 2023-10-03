/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class PatientResponse: Codable {
    var patient: Patient = Patient()
    var token: String = ""
    
    enum CodingKeys: CodingKey{
        case patient
        case token
    }
}
