/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class EulaHTML: NSObject, Codable{
    var html: String = ""
    
    override init(){
        html = ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(html, forKey: .html)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        html = try container.decode(String.self, forKey: .html)
        super.init()
    }
    
    enum CodingKeys: CodingKey{
        case html
    }
}
