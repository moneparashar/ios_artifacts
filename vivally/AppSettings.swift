/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation
class AppSettings: NSObject {
    
    //dev
    static let devrootUrl = "https://api.avaleecloudv2.sancsoft.dev"
    
    //staging
    //static let rootUrl = "https://api.staging.avation.com"
    
    #if STAGING
    //preprod
    static let rootUrl = debug ? devrootUrl : "https://api.preprod.avation.com"
    
    #elseif PRODUCTION
    //prod
    static let rootUrl = "https://api.vivally.com"
    #endif
        
    static let apiVersion = "v1"
    static let apiVersion2 = "v2"
    
    static let debug = false
    //static let rootUrl = debug ? devrootUrl : rootUrl
    static let phraseKey = "A#v!a$t@i%o^n@2023&*"
}
