//
//  NotificationTask.swift
//  vivally
//
//  Created by Joe Sarkauskas on 7/23/21.
//

import UIKit

struct Task: Identifiable, Codable {
  var id = UUID().uuidString
  var name: String
  var completed = false
  var reminderEnabled = false
  var reminder: Reminder
}

enum ReminderType: Int, CaseIterable, Identifiable, Codable {
  case time
  case calendar
  case location
  var id: Int { self.rawValue }
}

struct Reminder: Codable {
  var timeInterval: TimeInterval?
  var date: Date?
  var reminderType: ReminderType = .time
  var repeats = false
}
