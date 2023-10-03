/*
 * Copyright 2022, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

protocol ActivityManagerDelegate {
    func inactivityReached()
    func maxInactivityReached()
}

class ActivityManager: NSObject {
    static let sharedInstance = ActivityManager()
    
    var idleTimer: Timer?
    var fullyIdleTimer: Timer?
    var delegate:ActivityManagerDelegate?
    var lockout = false
    
    func resetInactivityCount(){
        stopAlmostInactiveTimer()
        stopMaxInactiveTimer()
        if !TherapyManager.sharedInstance.therapyRunning && !ScreeningProcessManager.sharedInstance.screeningRunning && !OTAManager.sharedInstance.updateRunning && !DataRecoveryManager.sharedInstance.runningRecovery{
        //will test for 10 seconds of inactivity, but should be 10 * 60 = 600 seconds of inactivity
            //idleTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(almostInactiveReached), userInfo: nil, repeats: false)
            idleTimer = Timer.scheduledTimer(timeInterval: 600.0, target: self, selector: #selector(almostInactiveReached), userInfo: nil, repeats: false)
        }
    }
    
    func stopActivityTimers(){
        stopAlmostInactiveTimer()
        stopMaxInactiveTimer()
    }
    
    func stopAlmostInactiveTimer(){
        if idleTimer != nil {
            idleTimer?.invalidate()
        }
        idleTimer = nil
    }
    
    func stopMaxInactiveTimer(){
        if fullyIdleTimer != nil {
            fullyIdleTimer?.invalidate()
        }
        fullyIdleTimer = nil
    }
    
    @objc func almostInactiveReached(){
        stopAlmostInactiveTimer()
        print("reached Inactivity")
        delegate?.inactivityReached()
        
        //fullyIdleTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(fullInactiveReached), userInfo: nil, repeats: false)
        fullyIdleTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(fullInactiveReached), userInfo: nil, repeats: false)
    }
    
    @objc func fullInactiveReached(){
        stopMaxInactiveTimer()
        delegate?.maxInactivityReached()
    }
    
    func saveLastTime(){
        var lastTime = Date()
        print("Time When leaving: \(lastTime)")
        if let timeLeft = idleTimer?.fireDate.timeIntervalSinceNow{
            //lastTime = lastTime - (10 - timeLeft)
            lastTime = lastTime - (600 - timeLeft)
            print("Time since last touch: \(lastTime)")
            UserDefaults.standard.set(lastTime.timeIntervalSince1970, forKey: "lastSavedTime")
            return
        }
        else{
            UserDefaults.standard.set(lastTime.timeIntervalSince1970, forKey: "lastSavedTime")
        }
        /*
        else if let timeLeft = fullyIdleTimer?.fireDate.timeIntervalSinceNow{
            lastTime = lastTime - (5 - timeLeft) -
            //lastTime = lastTime - (60 - timeLeft) - (600)
            print("Time since last touch: \(lastTime)")
            UserDefaults.standard.set(lastTime.timeIntervalSince1970, forKey: "lastSavedTime")
        }
        */
    }
    
    func clearLastTime(){
        UserDefaults.standard.removeObject(forKey: "lastSavedTime")
    }
    
    func loadLastTime(){
        let lastDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "lastSavedTime"))
        
        let currentDate = Date()
        
        print("lastDate: \(lastDate)")
        print("currentDate: \(currentDate)")
        
        if let secondsDifference = Calendar.current.dateComponents([.second], from: lastDate, to: Date()).second{
            print("secondsDifference: \(secondsDifference)")
            
            //if secondsDifference >= 10 && secondsDifference <= 15{
            if secondsDifference >= 600 && secondsDifference <= 660{    //should be 600
                clearLastTime()
                almostInactiveReached()
            }
            //else if secondsDifference > 15{
            else if secondsDifference > 660{
                clearLastTime()
                //stopAlmostInactiveTimer()
                
                print("seconds Difference: \(secondsDifference)")
                delegate?.maxInactivityReached()
            }
            else{
                clearLastTime()
                resetInactivityCount()
            }
        }
        
    }
    
    func loggedOut(){
        stopActivityTimers()
        clearLastTime()
        lockout = false
        
        UserDefaults.standard.set(false, forKey: "loggedIn")
        
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.lockout.rawValue), object: nil)
    }
}
