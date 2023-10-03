/*
 * Copyright 2022, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

protocol RefreshManagerDelegate {
    func refreshFailed()
}

class RefreshManager {
    static let sharedInstance = RefreshManager()
    
    var accessTimer: Timer?
    var delegate: RefreshManagerDelegate?
    let refreshWindowEnd = 172800    //seconds = 2 days * 24 * 60 * 60
    let fullRefreshAllowed =  31536000  // 365 * 24 * 60 * 60
    let halfHour = 1800
    
    func resetRefreshChecks(){
        saveLastTime()
        stopRefreshTimer()
        accessTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(willAccessExpire), userInfo: nil, repeats: true)
    }
    
    func stopRefreshTimer(){
        if accessTimer != nil{
            accessTimer?.invalidate()
        }
        accessTimer = nil
    }
    
    
    //typically access expires in 3600
    @objc func willAccessExpire(){
        loadLastRefreshTime()
    }
    
    @objc func checkExpired(){
        stopRefreshTimer()
        if loadFirstLogin() != nil{
            handleRefresh(after401Fail: true)
        }
    }
    
    //access token check
    func willRefreshExpire() -> Bool{
        if let firstLog = loadFirstLogin(){
            let lastDate = Date(timeIntervalSince1970: firstLog)
            if let secondsDifference = Calendar.current.dateComponents([.second], from: lastDate, to: Date()).second{
                return secondsDifference >= fullRefreshAllowed - refreshWindowEnd
            }
        }
        return true
    }
    
    func saveFirstLogin(){
        let firstDate = Date()
        UserDefaults.standard.set(firstDate.timeIntervalSince1970, forKey: "firstLogin")
    }
    
    func clearFirstLogin(){
        UserDefaults.standard.removeObject(forKey: "firstLogin")
    }
    
    func loadFirstLogin() -> Double?{
        let firstLog = UserDefaults.standard.double(forKey: "firstLogin")
        if firstLog == 0{
            return nil
        }
        return firstLog
    }
    
    
    //refresh token check
    func loadLastRefreshTime(){
        if loadFirstLogin() != nil{
            let lastDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "lastAccessRefresh"))
            if let secondsDifference = Calendar.current.dateComponents([.second], from: lastDate, to: Date()).second{
                if secondsDifference >= halfHour{
                    //trigger refresh
                    if NetworkManager.sharedInstance.connected{
                        stopRefreshTimer()
                        handleRefresh()
                    }
                }
                else{
                    if willRefreshExpire(){
                        stopRefreshTimer()
                        delegate?.refreshFailed()
                    }
                }
            }
        }
        else{
            stopRefreshTimer()
        }
    }
    
    func saveLastTime(){
        let lastTime = Date()
        UserDefaults.standard.set(lastTime.timeIntervalSince1970, forKey: "lastAccessRefresh")
    }
    
    func clearLastRefreshTime(){
        UserDefaults.standard.removeObject(forKey: "lastAccessRefresh")
    }
    
    func handleRefresh(after401Fail: Bool = false){
        if NetworkManager.sharedInstance.connected{
            let _ = KeychainManager.sharedInstance.loadAccountData()
            if let tok = KeychainManager.sharedInstance.accountData?.refreshToken{
                AccountManager.sharedInstance.refreshToken(token: tok){ success, data, errorMessage, timout  in
                    if success{
                        if self.loadFirstLogin() != nil{
                            self.resetRefreshChecks()
                        }
                    }
                    else if timout{
                        self.accessTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.checkExpired), userInfo: nil, repeats: true)
                    }
                    else{
                        print("failed refresh via manager")
                        if !(TherapyManager.sharedInstance.therapyRunning || ScreeningProcessManager.sharedInstance.screeningRunning || OTAManager.sharedInstance.updateRunning){
                            self.stopRefreshTimer()
                            if after401Fail{
                                self.delegate?.refreshFailed()
                            }
                            else{
                                self.accessTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.checkExpired), userInfo: nil, repeats: true)
                            }
                        }
                        else{
                            self.accessTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.checkExpired), userInfo: nil, repeats: true)
                        }
                    }
                }
            }
        }
    }
   
    
}
