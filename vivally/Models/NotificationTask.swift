/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */
import UIKit

struct NotificationTask: Identifiable, Codable {
  var id = UUID().uuidString
  var name: String
  var completed = false
  var reminderEnabled = false
  var reminder: Reminder
}

enum ReminderType: Int, CaseIterable, Identifiable, Codable {
    case time
    case calendar
    var id: Int { self.rawValue }
}

struct Reminder: Codable {
  var timeInterval: TimeInterval?
  var date: Date?
  var reminderType: ReminderType = .time
  var repeats = false
}
