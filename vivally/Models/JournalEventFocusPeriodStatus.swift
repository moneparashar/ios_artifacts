/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class JournalEventFocusPeriodStatus: Codable{
    var status:Int
    
    enum CodingKeys: CodingKey{
        case status
    }
}
