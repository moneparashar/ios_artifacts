/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class AccountData: Codable {
    var token:String = ""
    var refreshToken:String = ""
    var acceptedEULA:Bool = false
    var pinValue:String = ""
    var username:String = ""
    var userModel:UserModel?
    var roles = [String]()
    
    
    enum CodingKeys: CodingKey{
        case token
        case refreshToken
        case acceptedEULA
        case pinValue
        case username
        case userModel
        case roles
    }
}
