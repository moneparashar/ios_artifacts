/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

extension String{
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .unicode) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    //still needs testing
    func convertToAttributedString() -> NSAttributedString? {
            let modifiedFontString = "<span style=\"font-family: Open-Sans; color: rgb(60, 60, 60)\">" + self + "</span>"
            return modifiedFontString.htmlToAttributedString
    }
    
    //timestamps changes
    func treatTimestampStrAsDate() -> Date?{
        let d = DateFormatter.iso8601WithOffset.date(from: self)
        return d
    }
    
    
    //EEEE d, h:mm a
    func getDateStrOfTime() -> String{
        let yearMonthDayStr = String(self.prefix(10))   //2023-08-17
        let timeStr = self.slice(from: "T", to: ".") ?? "" //14:23:48
        
        let yearStr = String(self.prefix(4))
        let monthStr = yearMonthDayStr.slice(from: "-", to: "-") ?? ""
        let dayStr = String(yearMonthDayStr.suffix(2))
        
        let hourStr = String(timeStr.prefix(2))
        let minStr = timeStr.slice(from: ":", to: ":") ?? ""
        
        var dComponents = DateComponents()
        dComponents.year = Int(yearStr)
        dComponents.month = Int(monthStr)
        dComponents.day = Int(dayStr)
        
        let dat = Calendar(identifier: .gregorian).date(from: dComponents) ?? Date()
        
        let df = DateFormatter()
        df.dateFormat = "EEEE d, "
        var tempDateStr = df.string(from: dat)
        
        let hour = Int(hourStr) ?? 0
        let end = hour - 12 > -1 ? "pm" : "am"
        let hrStr = hour - 12 > 0 ? String(hour - 12) : hourStr
        
        tempDateStr += "\(hrStr):\(minStr) \(end)"
        
        return tempDateStr
    }
    
    //EEEE, MMM d
    func getDateStrOfDay() -> String{
        let yearMonthDayStr = String(self.prefix(10))   //2023-08-17
        
        let yearStr = String(self.prefix(4))
        let monthStr = yearMonthDayStr.slice(from: "-", to: "-") ?? ""
        let dayStr = String(yearMonthDayStr.suffix(2))
        
        var dComponents = DateComponents()
        dComponents.year = Int(yearStr)
        dComponents.month = Int(monthStr)
        dComponents.day = Int(dayStr)
        
        let dat = Calendar(identifier: .gregorian).date(from: dComponents) ?? Date()
        
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMMM d"
        var tempDateStr = df.string(from: dat)
        
        return tempDateStr
    }
    
    
    
    func slice(from: String, to: String) -> String? {
            return (range(of: from)?.upperBound).flatMap { substringFrom in
                (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                    String(self[substringFrom..<substringTo])
                }
            }
        }
}
