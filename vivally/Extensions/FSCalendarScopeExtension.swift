/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation
import FSCalendar

extension FSCalendarScope {
    func asCalendarComponent() -> Calendar.Component {
        switch (self) {
        case .month: return .month
        case .week: return .weekOfYear
        @unknown default:
            return .month
        }
     }
}
