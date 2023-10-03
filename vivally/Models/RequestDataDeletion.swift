/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class RequestDataDeletion: NSObject, Codable{
    var requestedDataDeletionReason: Int
    var requestedDataDeletionReasonText: String
    
    override init() {
        requestedDataDeletionReason = 0
        requestedDataDeletionReasonText = ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(requestedDataDeletionReason, forKey: .requestedDataDeletionReason)
        try container.encode(requestedDataDeletionReasonText, forKey: .requestedDataDeletionReasonText)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        requestedDataDeletionReason = try container.decode(Int.self, forKey: .requestedDataDeletionReason)
        requestedDataDeletionReasonText = try container.decode(String.self, forKey: .requestedDataDeletionReasonText)
        super.init()
    }
    
    enum CodingKeys: CodingKey{
        case requestedDataDeletionReason
        case requestedDataDeletionReasonText
    }
}
