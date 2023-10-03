/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation
import UserNotifications
import SwiftKeychainWrapper

enum NotificationManagerConstants {
  static let timeBasedNotificationThreadId =
    "TimeBasedNotificationThreadId"
  static let calendarBasedNotificationThreadId =
    "CalendarBasedNotificationThreadId"
}
enum TherapyRemindTimes{
    case once       //M
    case twice      //M W
    case thrice     //M W F
    case four       //M W F S
    case five       //M-F
    case six        //M-S
    case seven
}

enum JournalRemindTimes:Int, CaseIterable{
    case daily = 7
    case once = 1      //M
    case thrice = 3     //M W F
    case never = 0
    
    func getStr() -> String{
        switch self {
        case .daily:
            return "DAILY"
        case .once:
            return "1 / WEEK"
        case .thrice:
            return "3 / WEEK"
        case .never:
            return "NEVER"
        }
    }
}

enum NotficationStimulatorStates {
    case therapyRunning
    case therapyRunningNoPausesLeft
    case therapyPaused
    case screeningRunning
    case screeningPaused
    case none
}

class NotificationManager: NSObject {
    static let sharedInstance = NotificationManager()
    
    //new attempt with notification center
    var journalChangeNotify = NotificationCenter()
    
    func setupNotifyCenters(){
        journalChangeNotify = NotificationCenter()
    }
    //end of attempt
 
    var journalReminder:Int?
    var therapyReminder:Int?
    var settings: UNNotificationSettings?
    
    var journalReminderHour = 13
    
    var firebaseToken:String?
    
    func setupPushNotifcations(){
        if let ft = firebaseToken{
            if ft.isEmpty{
                Slim.info("Setup Push notifications Failed with empty firebase token")
            }
            else{
                let appData = AppManager.sharedInstance.loadAppDeviceData()
                let appId = appData!.appIdentifier
                postPushNotificationRegister(appId: appId, deviceToken: ft){ success, errorMessage in
                    if success{
                        //Slim.info("successful push notification post from setup Push Notification: appID: \(appId), deviceToken: \(ft)")
                    }
                    else{
                        //Slim.info("unsuccessful push notification post from setup Push Notification: appID: \(appId), deviceToken: \(ft)")
                    }
                }
            }
        }
        else{
            Slim.info("Setup Push notifications Failed with nil firebase token")
        }
    }
    
    func postPushNotificationRegister(appId: String, deviceToken: String, completion:@escaping (Bool, String) -> ()){
        APIClient.postPushNotificationRegister(appId: appId, deviceToken: deviceToken){ success, errorMessage, authorized in
            if success{
                completion(true, errorMessage)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, errorMessage)
            }
        }
    }
    
    func postPushNotificationUnRegister(appId: String, completion:@escaping (Bool, String) -> ()){
        APIClient.postPushNotificationUnRegister(appId: appId){ success, errorMessage, authorized in
            if success{
                completion(true, errorMessage)
            }
            else{
                if !authorized{
                    //RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, errorMessage)
            }
        }
    }
    
    func setupManager(){
        
    }
    
    var journalNotifySet = false
    var therapyNotifySet = false
    var gelNotifySet = false
    
    func loadNotifyData(){
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "journalNotifySet") {
            userDefaults.set(true, forKey: "journalNotifySet")
            journalNotifySet = true
        }
        if userDefaults.bool(forKey: "therapyNotifySet") {
            userDefaults.set(true, forKey: "therapyNotifySet")
            therapyNotifySet = true
        }
        if userDefaults.bool(forKey: "gelNotifySet") {
            userDefaults.set(true, forKey: "gelNotifySet")
            gelNotifySet = true
        }
    }
    
    //call these whenever therapy/journal/gel is done
    func resetJournalNotify(){
        UserDefaults.standard.set(false, forKey: "journalNotifySet")
        journalNotifySet = false
        removeCalendarNotifications(journal: true)
    }
    
    func resetTherapyNotify(){
        UserDefaults.standard.set(false, forKey: "therapyNotifySet")
        therapyNotifySet = false
        removeCalendarNotifications(journal: false)
    }
    func resetGelNotify(){
        UserDefaults.standard.set(false, forKey: "gelNotifySet")
        gelNotifySet = false
        removeGelCalendarNotifications()
    }
    
    func requestAuthorization(completion: @escaping  (Bool) -> Void) {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
        self.fetchNotificationSettings()
          completion(granted)
        }
    }
    
    func fetchNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        DispatchQueue.main.async {
          self.settings = settings
        }
      }
    }
    
    func removeScheduledNotification(task: NotificationTask) {
      UNUserNotificationCenter.current()
        .removePendingNotificationRequests(withIdentifiers: [task.id])
    }
    
    //MARK: Local Notifications while running app
    func removeTherapyTimeNotifications(isRunning: Bool, isPaused: Bool){
        if isRunning {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["TherapyRun"])
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["TherapyRun"])
            
        }
        if isPaused{
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["TherapyPause"])
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["TherapyPause"])
        }
    }
    
    func removeScreeningTimeNotifications(isRunning: Bool, isPaused: Bool){
        if isRunning {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["ScreeningRun"])
        }
        if isPaused {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["ScreeningPause"])
        }
    }
    
    func removeOTAUpdateNotifications(){
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["FirmwareUpdate"])
    }
    
    
    func scheduleNotification(task: NotificationTask, kind: NotficationStimulatorStates, gel: Bool = false) {
      // 2
      let content = UNMutableNotificationContent()
        var isCategory = true
        
        switch kind {
        case .screeningPaused:
            //content.body = "Screening paused. Hold for Actions"
            content.categoryIdentifier = "PauseCategory"
        case .screeningRunning:
            //content.body = "Screening in progress. Hold for Actions"
            content.categoryIdentifier = "ScreeningRunCategory"
        case .therapyPaused:
            //content.body = "Therapy paused. Hold for Actions"
            content.categoryIdentifier = "PauseCategory"
        case .therapyRunning:
            //content.body = "Therapy in progress. Hold for Actions"
            content.categoryIdentifier = "RunningCategory"
        case .none:
            isCategory = false
        case .therapyRunningNoPausesLeft:
            content.categoryIdentifier = "RunningMaxPauseCategory"
        }
        if gel {
            content.categoryIdentifier = "GelCategory"
        }
        
        content.title = task.name
        if isCategory{
            content.body = "Press and Hold for Actions"
        }
      //content.categoryIdentifier = "TherapyCategory"
      let taskData = try? JSONEncoder().encode(task)
      if let taskData = taskData {
        content.userInfo = ["Task": taskData]
      }

      // 3
      var trigger: UNNotificationTrigger?
      switch task.reminder.reminderType {
      case .time:
        if let timeInterval = task.reminder.timeInterval {
          trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: task.reminder.repeats)
        }
        content.threadIdentifier =
          NotificationManagerConstants.timeBasedNotificationThreadId
      case .calendar:
        if let date = task.reminder.date {
          trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
              [.day, .month, .year, .hour, .minute],
              from: date),
            repeats: task.reminder.repeats)
        }
        content.threadIdentifier =
          NotificationManagerConstants.calendarBasedNotificationThreadId
      }

      if let trigger = trigger {
        let request = UNNotificationRequest(
          identifier: task.id,
          content: content,
          trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
          if let error = error {
            print(error)
          }
        }
      }
    }
    
    //MARK: Day Reminders
    func clearJournalReminder(){
        journalReminder = 0
        UserDefaults.standard.removeObject(forKey: "journalReminder")
    }
    
    func saveJournalReminder(data: Int){
        self.journalReminder = data
        UserDefaults.standard.set(data, forKey: "journalReminder")
    }
    
    //save date of last missed journal date to schedule off of
    func clearMissJournal(){
        UserDefaults.standard.removeObject(forKey: "missedJournal")
    }
    
    func saveMissJournal(jDate: Date){
        UserDefaults.standard.set(jDate.timeIntervalSince1970, forKey: "missedJournal")
    }
    
    func loadMissJournal() -> Date?{
        let missD = UserDefaults.standard.double(forKey: "missedJournal")
        if missD != 0{
            return Date(timeIntervalSince1970: missD)
        }
        return nil
    }
    
    func loadJournalNotificationData() -> Int{
        var data = 1
        let journalNotifyDataObject = UserDefaults.standard.integer(forKey: "journalReminder")
        if journalNotifyDataObject <= 7 && journalNotifyDataObject > -1{
            data = journalNotifyDataObject
        }
        return data
    }
    
    func checkIfTherapyDone(){
        var schedule = 0
        let eval = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
        if eval?.left != nil {
            schedule = (eval?.left!.therapySchedule)!
        }
        else if eval?.right != nil {
            schedule = (eval?.right!.therapySchedule)!
        }
        
        do{
            let latestTherapy = try SessionDataDataHelper.getLatest(name: KeychainManager.sharedInstance.accountData!.username)
        
            if latestTherapy != nil {
                let lastTherapyDate = latestTherapy!.timestamp
                let today = Date()
            
                let differenceDays = Calendar.current.dateComponents([.day], from: lastTherapyDate, to: today).day
                
                if differenceDays != nil || differenceDays != 0 {
                    loadJournalRemindUnits()
                    let remindHour = journalReminderHour - 1
                    
                    switch schedule {
                    case 1:
                        if differenceDays! >= 8 {
                            //schedule notify
                            let noon = Calendar.current.date(bySettingHour: remindHour, minute: 0, second: 0, of: today)!
                            let therapyN = createTherapyNotifcation(date: noon)
                            scheduleCalendarNotification(task: therapyN, daily: true)
                        }
                    case 2:
                        if differenceDays! >= 4{
                            let noon = Calendar.current.date(bySettingHour: remindHour, minute: 0, second: 0, of: today)!
                            let therapyN = createTherapyNotifcation(date: noon)
                            scheduleCalendarNotification(task: therapyN, daily: true)
                        }
                    case 3, 4:
                        if differenceDays! >= 3 {
                            let noon = Calendar.current.date(bySettingHour: remindHour, minute: 0, second: 0, of: today)!
                            let therapyN = createTherapyNotifcation(date: noon)
                            scheduleCalendarNotification(task: therapyN, daily: true)
                        }
                    case 5...7:
                        if differenceDays! >= 2 {
                            let noon = Calendar.current.date(bySettingHour: remindHour, minute: 0, second: 0, of: today)!
                            let therapyN = createTherapyNotifcation(date: noon)
                            scheduleCalendarNotification(task: therapyN, daily: true)
                        }
                    default:()
                    }
                }
            }
        } catch{
            print("failure with get latest therapy events")
        }
    }
    
    func checkIfJournalDone(){
        let journalRemind = loadJournalNotificationData()
        if journalRemind == 0 {
            return
        }
        do{
            loadJournalRemindUnits()
            let remindHour = journalReminderHour - 1
            
            let latestJournal = try JournalEventsDataHelper.getLatest(name: KeychainManager.sharedInstance.accountData!.username)
            if  latestJournal != nil {
                let lastJournalDate = latestJournal!.eventTimestamp.treatTimestampStrAsDate() ?? Date()
                var today = Date()
                let differenceDays = Calendar.current.dateComponents([.day], from: lastJournalDate, to: today).day
                
                if differenceDays != nil || differenceDays != 0 {
                    var shouldSchedule = false
                    let miss = loadMissJournal()
                    
                    if let remindTime = JournalRemindTimes(rawValue: journalRemind){
                        switch remindTime {
                        case .daily:
                            if differenceDays! >= 2{
                                if miss == nil{
                                    today = Calendar.current.date(byAdding: .day, value: 2, to: lastJournalDate) ?? Date()
                                }
                                else{
                                    today = Calendar.current.date(byAdding: .day, value: 1, to: miss!) ?? Date()
                                }
                                saveMissJournal(jDate: today)
                                shouldSchedule = true
                            }
                            else{
                                clearMissJournal()
                            }
                        case .once:
                            if differenceDays! >= 8{
                                if miss == nil{
                                    today = Calendar.current.date(byAdding: .day, value: 8, to: lastJournalDate) ?? Date()
                                }
                                else{
                                    today = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: miss!) ?? Date()
                                }
                                saveMissJournal(jDate: today)
                                shouldSchedule = true
                            }
                            else{
                                clearMissJournal()
                            }
                        case .thrice:
                            if differenceDays! >= 3{
                                if miss == nil{
                                    today = Calendar.current.date(byAdding: .day, value: 3, to: lastJournalDate) ?? Date()
                                }
                                else{
                                    today = Calendar.current.date(byAdding: .day, value: 2, to: miss!) ?? Date()
                                }
                                saveMissJournal(jDate: today)
                                shouldSchedule = true
                            }
                        case .never:
                            break
                        }
                    }
                    
                    if shouldSchedule{
                        let timeSet = Calendar.current.date(bySettingHour: remindHour, minute: 0, second: 0, of: today)!
                        let journalN = createJournalNotification(date: timeSet)
                        scheduleCalendarNotification(task: journalN, daily: false, exact: true)
                    }
                }
            }
        } catch{
            print("failure with get latest journal event")
        }
    }
    
    func checkIfGelDone(){
        do{
            let latestGel = try JournalEventsDataHelper.getLastGel()
            if latestGel != nil {
                let lastGelDate = latestGel!.eventTimestamp.treatTimestampStrAsDate() ?? Date()
                let today = Date()
                let differenceDays = Calendar.current.dateComponents([.day], from: lastGelDate, to: today).day
                
                //swap every 4 weeks
                if differenceDays != nil && differenceDays != 0 {
                    if differenceDays! >= 28 {
                        let noon = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: today)!
                        let gelN = createGelNotification(date: noon)
                        //scheduleCalendarNotification(task: gelN, daily: true)
                        scheduleNotification(task: gelN, kind: .screeningPaused, gel: true)
                    }
                }
            }
        } catch{
            print("failure with get latest journal gel event")
        }
    }
    
    func scheduleCalendarNotification(task: NotificationTask, daily: Bool = false, exact: Bool = false){
        let content = UNMutableNotificationContent()
        content.title = task.name
        let taskData = try? JSONEncoder().encode(task)
        if let taskData = taskData {
          content.userInfo = ["Task": taskData]
        }
        var trigger: UNNotificationTrigger?
        if exact{
            if let date = task.reminder.date    {
                trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.month, .day, .hour], from: date), repeats: task.reminder.repeats)
            }
        }
        else{
            if daily {
                if let date = task.reminder.date{
                    trigger = UNCalendarNotificationTrigger(
                        dateMatching: Calendar.current.dateComponents([.hour, .minute], from: date), repeats: task.reminder.repeats)
                }
            }
            else{
                if let date = task.reminder.date{
                    trigger = UNCalendarNotificationTrigger(
                        dateMatching: Calendar.current.dateComponents([.weekday, .hour, .minute], from: date), repeats: task.reminder.repeats)
                }
            }
        }
        content.threadIdentifier =
          NotificationManagerConstants.calendarBasedNotificationThreadId
        
        if let trigger = trigger {
          let request = UNNotificationRequest(
            identifier: task.id,
            content: content,
            trigger: trigger)
          UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
              print(error)
            }
          }
        }
    }
    
    func createJournalNotification(date: Date) -> NotificationTask{
        let task = NotificationTask(id: "JournalRemind", name: "To get the most from your Therapy, remember to record your events in the Diary", completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 2.0, date: date, reminderType: .calendar, repeats: true))
        return task
    }
    
    func createTherapyNotifcation(date: Date) -> NotificationTask{
        let task = NotificationTask(id: "TherapyRemind", name: "It's time ⏳ for a Therapy session", completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 2.0, date: date, reminderType: .calendar, repeats: true))
        return task
    }
    
    func createGelNotification(date: Date) -> NotificationTask{
        let task = NotificationTask(id: "GelRemind", name: "It's time ⏳ to replace your Gel Cushions! Tap Confirm if you changed them recently", completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 2.0, date: date, reminderType: .calendar, repeats: true))
        return task
    }
    
    func removeCalendarNotifications(journal: Bool){
        if journal {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["JournalRemind"])
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["JournalRemind"])
        }
        else{
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["TherapyRemind"])
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["TherapyRemind"])
        }
    }
    
    func removeGelCalendarNotifications(){
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["GelRemind"])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["GelRemind"])
    }
    
    
    //MARK: Journal Hour Reminder time
    func loadJournalRemindUnits(){
        let savedHour = UserDefaults.standard.integer(forKey: "reminderHour")
        journalReminderHour = savedHour > 0 ? savedHour : 13
    }
    
    func setJournalRemindUnits(hr: Int){
        journalReminderHour = hr + 1
    }
    
    func saveJournalRemindUnits(){
        UserDefaults.standard.set(journalReminderHour, forKey: "reminderHour")
    }
    func clearJournalRemindUnits(){
        UserDefaults.standard.removeObject(forKey: "reminderHour")
    }
}
