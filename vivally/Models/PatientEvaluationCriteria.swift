/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */
import UIKit

class PatientEvaluationCriteria: NSObject, Codable{
    var screeningGuid:UUID
    var isValid:Bool?
    var left:EvaluationCriteria?
    var right:EvaluationCriteria?
    
    override init() {
        screeningGuid = UUID()
        isValid = nil
        left = nil
        right = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(screeningGuid, forKey: .screeningGuid)
        try container.encodeIfPresent(isValid, forKey: .isValid)
        try container.encodeIfPresent(left, forKey: .left)
        try container.encodeIfPresent(right, forKey: .right)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        screeningGuid = try container.decode(UUID.self, forKey: .screeningGuid)
        isValid = try container.decodeIfPresent(Bool.self, forKey: .isValid) ?? false
        left = try container.decodeIfPresent(EvaluationCriteria.self, forKey: .left)
        right = try container.decodeIfPresent(EvaluationCriteria.self, forKey: .right)
        
        super.init()
    }
    
    enum CodingKeys: CodingKey {
        case screeningGuid
        case isValid
        case left
        case right
    }
}
