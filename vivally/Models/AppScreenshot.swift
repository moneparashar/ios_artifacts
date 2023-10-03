/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class AppScreenshot: BaseModel {
    var name:String?
    var fileName:String?
    var fileLength:Int?
    var evaluationCriteriaGuid:UUID?
    
    override init() {
        name = nil
        fileName = nil
        fileLength = nil
        evaluationCriteriaGuid = nil
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey:.name)
        try container.encodeIfPresent(fileName, forKey: .fileName)
        try container.encodeIfPresent(fileLength, forKey:.fileLength)
        try container.encodeIfPresent(evaluationCriteriaGuid, forKey:.evaluationCriteriaGuid)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decodeIfPresent(String.self, forKey: .name)
        fileName = try container.decodeIfPresent(String.self, forKey: .fileName)
        fileLength = try container.decodeIfPresent(Int.self, forKey: .fileLength)
        evaluationCriteriaGuid = try container.decodeIfPresent(UUID.self, forKey: .evaluationCriteriaGuid)
        try super.init(from: decoder)
   }
    
    enum CodingKeys: CodingKey{
        case name
        case fileName
        case fileLength
        case evaluationCriteriaGuid
    }
}
