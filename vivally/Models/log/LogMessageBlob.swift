//
//  LogMessageBlob.swift
//  vivally
//
//  Created by Joe Sarkauskas on 4/16/21.
//

import UIKit

class LogMessageBlob: Codable {
    var extra: String?
    
    enum CodingKeys: CodingKey{
        case extra
    }
}
