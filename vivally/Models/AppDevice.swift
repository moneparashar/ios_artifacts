/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class AppDevice: BaseModel {
    var appIdentifier:String
    var deviceToken:String?
    var awsEndpointarn:String?
    var awsSubscriptionArnList:String?
    
    override init() {
        appIdentifier = ""
        deviceToken = nil
        awsEndpointarn = nil
        awsSubscriptionArnList = nil
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(appIdentifier, forKey:.appIdentifier)
        try container.encodeIfPresent(deviceToken, forKey: .deviceToken)
        try container.encodeIfPresent(awsEndpointarn, forKey:.awsEndpointarn)
        try container.encodeIfPresent(awsSubscriptionArnList, forKey:.awsSubscriptionArnList)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        appIdentifier = try container.decode(String.self, forKey: .appIdentifier)
        awsSubscriptionArnList = try container.decodeIfPresent(String.self, forKey: .awsSubscriptionArnList)
        deviceToken = try container.decodeIfPresent(String.self, forKey: .deviceToken)
        awsEndpointarn = try container.decodeIfPresent(String.self, forKey: .awsEndpointarn)
        try super.init(from: decoder)
   }
    
    enum CodingKeys: CodingKey{
        case appIdentifier
        case deviceToken
        case awsEndpointarn
        case awsSubscriptionArnList
    }
    
}
