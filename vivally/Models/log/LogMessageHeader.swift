//
//  LogMessageHeader.swift
//  vivally
//
//  Created by Joe Sarkauskas on 4/16/21.
//

//no longer used, replaced by LogMetadata
import UIKit

class LogMessageHeader: Codable {
    var osVersion: String?
    var deviceModel: String?
    var appVersion: String?
    var userId: String?
    
    init() {
        osVersion = nil
        deviceModel = nil
        appVersion = nil
        userId = nil
    }
    
    enum CodingKeys: CodingKey{
        case osVersion
        case deviceModel
        case appVersion
        case userId
    }
}
