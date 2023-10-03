/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

enum JournalDayEntryNavigationPages: Int, CaseIterable {
    case night = 0
    case morning = 6
    case afternoon = 12
    case evening = 18
    
    func getStr() -> String{
        switch self {
        case .night:
            return "Night"
        case .morning:
            return "Morning"
        case .afternoon:
            return "Afternoon"
        case .evening:
            return "Evening"
        }
    }
    
    func insideRange(hour: Int) -> Bool{
        switch self {
        case .night:
            return (hour >= JournalDayEntryNavigationPages.night.rawValue && hour < JournalDayEntryNavigationPages.morning.rawValue)
        case .morning:
            return (hour >= JournalDayEntryNavigationPages.morning.rawValue && hour < JournalDayEntryNavigationPages.afternoon.rawValue)
        case .afternoon:
            return (hour >= JournalDayEntryNavigationPages.afternoon.rawValue && hour < JournalDayEntryNavigationPages.evening.rawValue)
        case .evening:
            return (hour >= JournalDayEntryNavigationPages.evening.rawValue)
        }
    }
}
