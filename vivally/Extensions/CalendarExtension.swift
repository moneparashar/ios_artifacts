/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

extension Calendar{
    static let utcCal: Calendar = {
        let utc = TimeZone(identifier: "UTC")
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = utc ?? .current
        return cal
    }()
}

extension Date{
    static func nextYear() -> [Date]{
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        let startDate = cal.startOfDay(for: Date())
        return Date.next(numberOfDays: 365, from: startDate)
    }
    
    static func lastYear() -> [Date]{
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        let startDate = cal.startOfDay(for: Date())
        return Date.next(numberOfDays: 366, from: cal.date(byAdding: .year, value: -1, to: startDate)!)
    }
    
    static func next(numberOfDays: Int, from startDate: Date) -> [Date]{
        var oneDayBeforeStartDate = Calendar.current.date(byAdding: .day, value: -1, to: startDate) ?? Date()
        var dates = [Date]()
        var cal = Calendar(identifier: .gregorian)
        
        cal.timeZone = .current
        
        for index in 0..<numberOfDays{
            if let date = cal.date(byAdding: .day, value: index, to: oneDayBeforeStartDate){
                dates.append(date)
            }
        }
        
        return dates
    }
    
    
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    func endOfWeek(using calendar: Calendar = .current) -> Date{
        let start = startOfWeek()
        var end = start.addWeek()
        end = calendar.date(byAdding: .day, value: -1, to: end) ?? Date()
        return end
    }
    
    
    func addWeek(using calendar: Calendar = .current) -> Date{
        return calendar.date(byAdding: .weekOfYear, value: 1, to: self) ?? Date()
    }
    
    func prevWeek(using calendar: Calendar = .current) -> Date{
        return calendar.date(byAdding: .weekOfYear, value: -1, to: self) ?? Date()
    }
    
    func startOfMonth(using calendar: Calendar = .current) -> Date {
        calendar.dateComponents([.calendar, .year, .month], from: self).date!
    }
    
    
    //timestamps fixes
    func convertDateToOffsetStr() -> String{
        let d = DateFormatter.iso8601WithOffset.string(from: self)
        return d
    }
}

