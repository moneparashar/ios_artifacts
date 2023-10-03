/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import IQKeyboardManagerSwift
import BackgroundTasks
import Firebase
import FirebaseMessaging
import MetricKit
import IOSSecuritySuite


protocol GelDelegate {
    func updatedGel()
}

func areTestsRunning() -> Bool{
    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
        return true
    }
    return false
}

//@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    var gelDelegate:GelDelegate?
    var metricManager: MetricManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Add to dealy splash screen for jailbreak check
        SplashScreenTiming()
        
        metricManager = MetricManager()
        
        //AWS Logging setup
        if !AppSettings.debug{
            let awLogDestination = AWSDestination()
            Slim.addLogDestination(awLogDestination)
        }
        
        //attempt to create notfication center
        NotificationManager.sharedInstance.setupNotifyCenters()
        
        //clear keychain data if first run
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "firstRun") {
            KeychainManager.sharedInstance.clearAccountData()
            userDefaults.set(true, forKey: "firstRun")
        }
        
        UserDefaults.standard.set(false, forKey: "loggedIn")
        
        AppUpdateManager.sharedInstance.checkForAppUpdate()
        OTAManager.sharedInstance.setupManager()
        BluetoothDeviceInfoManager.sharedInstance.setupManager()
        BluetoothManager.sharedInstance.setupManager()
        KeychainManager.sharedInstance.setupManager()
        
        if !OTAManager.sharedInstance.OTAMode{
            BluetoothManager.sharedInstance.clearOTAPairing()
        }
        
        FirebaseApp.configure()
        
        //attempt to check network connectivity
        NetworkManager.sharedInstance.setupManager()
        
        
        configureUserNotifications()
        SQLiteDataStore.sharedInstance.setupDatabase()
        
        IQKeyboardManager.shared.enable = true
        // set some appearance
        UITextField.appearance().tintColor = UIColor.regalBlue
        setUpNavigationBar()
        
        NotificationManager.sharedInstance.requestAuthorization { granted in
            print("Notification Granted = \(granted)")
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "refresh", using: nil){ task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        return true
        
    }
    
     func SplashScreenTiming(){
        //add logic to add splash screen
        let LunchScreenVC = UIStoryboard.init(name: "SplashScreen", bundle: nil)
           let rootVc = LunchScreenVC.instantiateViewController(withIdentifier: "SplashScreen")
           
           self.window?.rootViewController = rootVc
           self.window?.makeKeyAndVisible()
         Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DismissSpalshController), userInfo: nil, repeats: false)
    }
    
    @objc func DismissSpalshController(){
        
        //if device is jailbreak or reverseEngineered
        if IOSSecuritySuite.amIJailbroken() || IOSSecuritySuite.amIReverseEngineered() {
            print("This device is jailbroken")
            let alert = UIAlertController(title: "", message:"Your Device is not compatible with vivally app", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
           
        }
        else {
            //MARK: First Display
            //correct nav
            properNavSetup()
            
            //debug screens
            //testOneScreenSetup()
            //testSpecificPopup()
        }
    }
    
    //MARK: DISPLAY OPTIONS
    
    func properNavSetup(){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if KeychainManager.sharedInstance.accountData?.token != "" && !RefreshManager.sharedInstance.willRefreshExpire(){
            if (KeychainManager.sharedInstance.accountData!.roles.contains("Patient")) && KeychainManager.sharedInstance.accountData?.pinValue != ""{
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "StartNavPIN")
                self.window?.rootViewController = initialViewController
            }
            else{
                goToBaseSignIn()
            }
        }
        else{
            goToBaseSignIn()
        }
        self.window?.makeKeyAndVisible()
    }
    
    func goToBaseSignIn(){
        NetworkManager.sharedInstance.logoutClear()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        KeychainManager.sharedInstance.clearAccountData()
        ActivityManager.sharedInstance.loggedOut()
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "StartNav")
        self.window?.rootViewController = initialViewController
    }
    
    //for debugging specifc screens
    func testOneScreenSetup(){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "clinician", bundle: nil)
        
        //let initialViewController = UIDevice.current.userInterfaceIdiom == .phone ? storyboard.instantiateViewController(withIdentifier: "ClinicianHomePageTabletViewController") as! ClinicianHomePageTabletViewController : storyboard.instantiateViewController(withIdentifier: "ClinicianHomePageTabletViewController") as! ClinicianHomePageTabletViewController
        
        //let initialViewController = storyboard.instantiateViewController(withIdentifier: "ClinicianHomePageTabletViewController") as! ClinicianHomePageTabletViewController
        let initialViewController = EulaViewController()
        
        let navVC = UINavigationController(rootViewController: initialViewController)
        
        self.window?.rootViewController = navVC
        self.window?.makeKeyAndVisible()
    }
    
    func testSpecificPopup(){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "clinician", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "ClinicianHomePageTabletViewController") as! ClinicianHomePageTabletViewController
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            
            //let vc = BasicPopupViewController()
            //let bah = BasicPopupContent(title: "Discard journal entry", message: "Are you sure you want to discard this entry?\nAll changes in this entry will be lost", option1: "Continue", option2: "Discard")
            //vc.baseContent = bah
            //let vc = FirmwareUpdatePopupViewController()
            let vc = RecoverFirmwarePopupViewController()
            
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical
            initialViewController.present(vc, animated: false, completion: nil)
        }
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
    
    func setUpNavigationBar(){
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.backgroundColor =  UIColor.white
        navigationBarAppearance.tintColor = .regalBlue
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.regalBlue ?? .blue, .font: UIFont.h4 ?? .systemFont(ofSize: 16)]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.regalBlue ?? .blue, .font: UIFont.h4 ?? .systemFont(ofSize: 16)]
        
        navigationBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearance.shadowImage = UIImage()
        
        let newNavigationBarAppearance = UINavigationBarAppearance()
        newNavigationBarAppearance.backgroundColor  = UIColor.white
        newNavigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.regalBlue ?? .blue, .font: UIFont.h4 ?? .systemFont(ofSize: 16)]
        newNavigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.regalBlue ?? .blue, .font: UIFont.h4 ?? .systemFont(ofSize: 16)]
        
        newNavigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.regalBlue ?? .blue, .font: UIFont.h4 ?? .systemFont(ofSize: 16)]
        newNavigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.regalBlue ?? .blue, .font: UIFont.h4 ?? .systemFont(ofSize: 16)]
        
        newNavigationBarAppearance.shadowColor = UIColor.clear
        
        navigationBarAppearance.standardAppearance = newNavigationBarAppearance
        navigationBarAppearance.scrollEdgeAppearance = newNavigationBarAppearance
        
        /*
        // to reduce navbar button spacing
        let navigationBarStackViewAppearance = UIStackView.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        navigationBarStackViewAppearance.spacing = -15
         */
    }

    //MARK: Background Process
    func handleAppRefresh(task: BGAppRefreshTask){
        task.expirationHandler = {
            Slim.info("background expiration reached")
            task.setTaskCompleted(success: false)
        }
        
        NetworkManager.sharedInstance.setupManager()
        let accountData = KeychainManager.sharedInstance.loadAccountData()
        if accountData?.refreshToken != nil && accountData?.refreshToken != "" && NetworkManager.sharedInstance.connected{
            var ground = "background"
            let state = UIApplication.shared.applicationState
            if state == .active{
                ground = "active"
            }
            else if state == .inactive{
                ground = "inactive"         //app transitions from background to foreground
            }
            Slim.info("refresh called in background handler in \(ground) state")
            AccountManager.sharedInstance.refreshToken(token: accountData!.refreshToken){ success, data, errorMessage, timout in
                if success{
                    Slim.info("successful background refresh")
                    RefreshManager.sharedInstance.saveLastTime()
                    
                    if KeychainManager.sharedInstance.accountData!.roles.contains("Patient") {
                        //notify
                        NotificationManager.sharedInstance.checkIfGelDone()
                        NotificationManager.sharedInstance.checkIfTherapyDone()
                        NotificationManager.sharedInstance.checkIfJournalDone()
                        
                        let group = DispatchGroup()
                        group.enter()
                        group.enter()
                        group.enter()
                        
                        NetworkManager.sharedInstance.sendBulkStimAndEMGData(){
                            group.leave()
                        }
                        NetworkManager.sharedInstance.sendJournalData(){
                            group.leave()
                        }
                        NetworkManager.sharedInstance.sendTherapyOnlyData(){
                            group.leave()
                        }
                        
                        group.notify(queue: DispatchQueue.global()){
                            task.setTaskCompleted(success: true)
                        }
                    }
                }
                else if timout{
                    task.setTaskCompleted(success: false)
                }
                else{
                    NetworkManager.sharedInstance.logoutClear()
                    task.setTaskCompleted(success: false)
                }
            }
        }
        else{
            task.setTaskCompleted(success: false)
        }
        
        
        
        scheduleAppRefresh()
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "refresh")
        
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do{
            try BGTaskScheduler.shared.submit(request)
        } catch{
            Slim.error("could not schedule app refresh: \(error)")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if TherapyManager.sharedInstance.therapyRunning {
            if TherapyManager.sharedInstance.therapyPaused {
                let task = NotificationTask(id: "TherapyPause", name: "Therapy has been temporaily paused.\nTap Resume to continue", completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 1.0, date: Date(), reminderType: .time, repeats: false))
                NotificationManager.sharedInstance.scheduleNotification(task: task, kind: .therapyPaused)
            }
            
            else{
                let notifTaskName = TherapyManager.sharedInstance.pauseLimitReached ? "Hooray! Therapy is in progress (Pause limit reached)" : "Hooray! Therapy is in progress. Tap to return to Therapy or tap and hold to Pause or Stop"
                
                let task = NotificationTask(id: "TherapyRun", name: notifTaskName, completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 1.0, date: Date(), reminderType: .time, repeats: false))
                
                NotificationManager.sharedInstance.scheduleNotification(task: task, kind: TherapyManager.sharedInstance.pauseLimitReached ? .therapyRunningNoPausesLeft : .therapyRunning)
               // NotificationManager.sharedInstance.scheduleNotification(task: task, kind: .therapyRunning)
            }
        }
        
        
        if ScreeningProcessManager.sharedInstance.screeningRunning{
            if ScreeningProcessManager.sharedInstance.screeningPaused {
                let task = NotificationTask(id: "ScreeningPause", name: "Screening Paused", completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 1.0, date: Date(), reminderType: .time, repeats: false))
                NotificationManager.sharedInstance.scheduleNotification(task: task, kind: .screeningPaused)
            }
            
            else{
                let task = NotificationTask(id: "ScreeningRun", name: "Therapy Personalization in progress", completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 1.0, date: Date(), reminderType: .time, repeats: false))
                NotificationManager.sharedInstance.scheduleNotification(task: task, kind: .screeningRunning)
            }
        }
        
        if OTAManager.sharedInstance.updateAvailable && !ScreeningProcessManager.sharedInstance.screeningRunning && !TherapyManager.sharedInstance.therapyRunning && BluetoothManager.sharedInstance.isConnectedToDevice() && !OTAManager.sharedInstance.updateRunning{
            let task = NotificationTask(id: "FirmwareUpdate", name: "Firmware Update Available", completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 1.0, date: Date(), reminderType: .time, repeats: false))
            NotificationManager.sharedInstance.scheduleNotification(task: task, kind: .none)
        }
        
        (UIApplication.shared.delegate as! AppDelegate).scheduleAppRefresh()
        
        if UserDefaults.standard.bool(forKey: "loggedIn"){
            if !(TherapyManager.sharedInstance.therapyRunning || ScreeningProcessManager.sharedInstance.screeningRunning){
                ActivityManager.sharedInstance.saveLastTime()
                print("saved Last Time")
                ActivityManager.sharedInstance.stopActivityTimers()
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if UserDefaults.standard.bool(forKey: "loggedIn"){
            if !(TherapyManager.sharedInstance.therapyRunning || ScreeningProcessManager.sharedInstance.screeningRunning){
                ActivityManager.sharedInstance.loadLastTime()
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let _ = KeychainManager.sharedInstance.loadAccountData()
        if UserDefaults.standard.bool(forKey: "loggedIn"){
            RefreshManager.sharedInstance.handleRefresh()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let _ = KeychainManager.sharedInstance.loadAccountData()
        if UserDefaults.standard.bool(forKey: "loggedIn"){
            if TherapyManager.sharedInstance.therapyRunning{
                let stimGuid = StimDataManager.sharedInstance.stimData.guid
                DataRecoveryManager.sharedInstance.saveTimestampStimGuid(guid: stimGuid)
            }
            
            if KeychainManager.sharedInstance.accountData?.roles.contains("Clinician") == true{
                NetworkManager.sharedInstance.logoutClear()
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        NotificationManager.sharedInstance.firebaseToken = fcmToken
    }
}


// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler(.banner)
  }

  private func configureUserNotifications() {
    UNUserNotificationCenter.current().delegate = self
    // 1
    let resumeAction = UNNotificationAction(
      identifier: "resume",
      title: "Resume",
      options: []
    )
    let pauseAction = UNNotificationAction(
      identifier: "pause",
      title: "Pause",
        options: []
    )
    let confirmAction = UNNotificationAction(
        identifier: "confirm", title: "Confirm", options: []
    )
    let stopAction = UNNotificationAction(identifier: "stop", title: "Stop", options: [.destructive])
    
    // 2
    let runCategory = UNNotificationCategory(
      identifier: "RunningCategory",
      actions: [pauseAction, stopAction],
      intentIdentifiers: [],
      options: []
    )
      
      let runMaxPauseCategory = UNNotificationCategory(
        identifier: "RunningMaxPauseCategory",
        actions: [stopAction],
        intentIdentifiers: [],
        options: []
      )
      
    
    let screeningRunCategory = UNNotificationCategory(
        identifier: "ScreeningRunCategory",
        actions: [pauseAction],
        intentIdentifiers: [],
        options: []
      )
    
    let pauseCategory = UNNotificationCategory(
        identifier: "PauseCategory",
        actions: [resumeAction],
        intentIdentifiers: [],
        options: []
    )
    
    let gelCategory = UNNotificationCategory(
        identifier: "GelCategory",
        actions: [confirmAction],
        intentIdentifiers: [],
        options: []
    )
    
    UNUserNotificationCenter.current().setNotificationCategories([runCategory, runMaxPauseCategory, pauseCategory, screeningRunCategory])
  }
    
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
      
    if response.actionIdentifier == "resume" {
        
        //need to use dispatch to give enough time to update pauseLimitReached
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            if TherapyManager.sharedInstance.therapyPaused {
                
                
                let notifTaskName = TherapyManager.sharedInstance.pauseLimitReached ? "Hooray! Therapy is in progress (Pause limit reached)" : "Hooray! Therapy is in progress. Tap to return to Therapy or tap and hold to Pause or Stop"
                
                let task = NotificationTask(id: "TherapyRun", name: notifTaskName, completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 0.1, date: Date(), reminderType: .time, repeats: false))
                NotificationManager.sharedInstance.scheduleNotification(task: task, kind: .therapyRunning)
                
                NotificationManager.sharedInstance.scheduleNotification(task: task, kind: TherapyManager.sharedInstance.pauseLimitReached ? .therapyRunningNoPausesLeft : .therapyRunning)
                TherapyManager.sharedInstance.resumeTherapy()
                
            }
            
            
            if ScreeningProcessManager.sharedInstance.screeningPaused {
                let task = NotificationTask(id: "ScreeningRun", name: "Therapy Personalization in progress", completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 0.1, date: Date(), reminderType: .time, repeats: false))
                NotificationManager.sharedInstance.scheduleNotification(task: task, kind: .screeningRunning)
                
                ScreeningProcessManager.sharedInstance.resumeScreening()
            }
        }
    }
    
    if response.actionIdentifier == "pause" {
        if TherapyManager.sharedInstance.therapyRunning {
            let task = NotificationTask(id: "TherapyPause", name: "Therapy has been temporarily paused.\nTap Resume to continue", completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 1.0, date: Date(), reminderType: .time, repeats: false))
            NotificationManager.sharedInstance.scheduleNotification(task: task, kind: .therapyPaused)
            
            TherapyManager.sharedInstance.pauseTherapy()
        }
        
        else if ScreeningProcessManager.sharedInstance.screeningRunning{
            let task = NotificationTask(id: "ScreeningPause", name: "Oops! Personalization is paused.\nTap Resume to continue", completed: false, reminderEnabled: true, reminder: Reminder(timeInterval: 1.0, date: Date(), reminderType: .time, repeats: false))
            NotificationManager.sharedInstance.scheduleNotification(task: task, kind: .screeningPaused)
            
            ScreeningProcessManager.sharedInstance.pauseScreening()
        }
        
    }
    if response.actionIdentifier == "confirm" {
        NotificationManager.sharedInstance.resetGelNotify()
        gelDelegate?.updatedGel()
        
    }
    if response.actionIdentifier == "stop" {
        if TherapyManager.sharedInstance.therapyRunning {
            TherapyManager.sharedInstance.userStopTherapy()
        }
    }
    
    completionHandler()
  }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

class CustomApplication:UIApplication{
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        if UserDefaults.standard.bool(forKey: "loggedIn"){
            if let touches = event.allTouches{
                for _ in touches {
                    ActivityManager.sharedInstance.resetInactivityCount()
                }
            }
        }
    }
}
