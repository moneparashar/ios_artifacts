/*
 * Copyright 2022, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
class LogMetadata:  NSObject, Codable{
    var user_id:String
    var app_ver:String
    var os: String
    var model: String
    var env: String
    
    override init() {
        user_id = ""
        app_ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        os = "ios"
        model = UIDevice.current.model
        
        #if STAGING
        env = "Pre-Prod"     //dev/staging/production
        #elseif PRODUCTION
        env = "production"
        #endif
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(user_id, forKey:.user_id)
        try container.encodeIfPresent(app_ver, forKey: .app_ver)
        try container.encodeIfPresent(os, forKey: .os)
        try container.encodeIfPresent(model, forKey: .model)
        try container.encodeIfPresent(env, forKey: .env)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        user_id = try container.decode(String.self, forKey: .user_id)
        app_ver = try container.decode(String.self, forKey: .app_ver)
        os = try container.decode(String.self, forKey: .os)
        model = try container.decode(String.self, forKey: .model)
        env = try container.decode(String.self, forKey: .env)
        super.init()
   }
    
    enum CodingKeys: CodingKey{
        case user_id
        case app_ver
        case os
        case model
        case env
    }
    
}
