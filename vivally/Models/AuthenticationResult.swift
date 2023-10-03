/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class AuthenticationResult: Codable {
    var accessToken:String = ""
    var expiresIn:Int = 0
    var idToken:String
    var newDeviceMetadata:NewDeviceMetaData?
    var refreshToken:String? = nil
    var tokenType:String
    
    enum CodingKeys: CodingKey{
        case accessToken
        case expiresIn
        case idToken
        case newDeviceMetadata
        case refreshToken
        case tokenType
    }
}
