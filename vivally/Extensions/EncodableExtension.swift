/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        /*
         encoder.dateEncodingStrategy = JSONEncoder.customDate({(key ) -> DateFormatter? in
         switch key{
         case SessionData.CodingKeys.eventTimestamp, JournalEvents.CodingKeys.eventTimestamp, EvaluationCriteria.CodingKeys.eventTimestamp:
         return DateFormatter.iso8601WithOffset
         default:
         return .iso8601Full
         }
         })
         */
        
        let data = try encoder.encode(self)
        
        //let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
    
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

extension JSONDecoder{
    static func customDates(_ formatterForKey: @escaping (CodingKey) throws -> DateFormatter?) -> JSONDecoder.DateDecodingStrategy{
        return .custom({ (decoder) -> Date in
            guard let codingKey = decoder.codingPath.last else{
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No Coding Path Found"))
            }
            guard let container = try? decoder.singleValueContainer(), let text = try? container.decode(String.self) else{
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode date text"))
            }
            guard let dateFormatter = try formatterForKey(codingKey) else{
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "No date formatter for date text")
            }
            if let date = dateFormatter.date(from: text){
                return date
            } else{
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(text)")
            }
        })
    }
}

extension JSONEncoder{
    static func customDate(_ formatterForKey: @escaping (CodingKey) throws -> DateFormatter?) -> JSONEncoder.DateEncodingStrategy{
        return .custom({ (date, encoder) in
            guard let codingKey = encoder.codingPath.last else{
                throw EncodingError.invalidValue(0, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "No Coding Path"))
            }
            
            guard let dateFormatter = try formatterForKey(codingKey) else{
                throw EncodingError.invalidValue(0, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "No date formatter"))
            }
            
            let dateStr = dateFormatter.string(from: date)
            var container = encoder.singleValueContainer()
            try container.encode(dateStr)
            /*
             var dateFormatUsed = DateFormatter()
             switch codingKey{
             case JournalEvents.CodingKeys.eventTimestamp:
             dateFormatUsed = DateFormatter.iso8601WithOffset
             default:
             dateFormatUsed = DateFormatter.iso8601Full
             }
             let dateStr = dateFormatUsed.string(from: date)
             var container = encoder.singleValueContainer()
             try container.encode(dateStr)
             */
        })
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let iso8601WithOffset: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
