/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class LoginResult: Codable {
    var authenticationResult:AuthenticationResult
    //var challengeName:
    //var challengeParameters
    var session:String?
    //var responseMetaData:
    var contentLength:Int
    var httpStatusCode:Int
    
    enum CodingKeys: CodingKey{
        case authenticationResult
        case session
        case contentLength
        case httpStatusCode
       
    }
}
