/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import AVKit

class HelpManager: NSObject{
    static let sharedInstance = HelpManager()
    
    var helpSet: HelpTimestampSet?
    
    //later these should be fetched from cloud
    let pairStimTimestamp = 0.0
    let placeGarmentAndGelCushionsTimestamp = 93.0
    let conductTherapySessionTimestamp = 197.0
    let useJournalTimestamp = 262.0
    
    func playSectionVideo(vc: UIViewController, helpInfo: HelpSections){
        if helpSet == nil{
            loadURL()
        }
        
        let sec = getSeconds(helpSect: helpInfo)
        playVideo(vc: vc, startTime: Double(sec))
    }
    
    func getSeconds(helpSect: HelpSections) -> Int{
        if helpSect != .none && helpSet != nil{
            let helpType = helpSect.rawValue
            for helpTime in helpSet!.timestamps{
                if helpTime.type == helpType{
                    return helpTime.seconds
                }
            }
        }
        return 0
    }
    
    func playVideo(vc: UIViewController, startTime: Double){
        if helpSet != nil{
            if let url = URL(string: helpSet!.url){
                let player = AVPlayer(url: url)
                let vcPlayer = AVPlayerViewController()
                vcPlayer.player = player
                let seekTime = CMTime(seconds: startTime, preferredTimescale: Int32(NSEC_PER_SEC))
                vcPlayer.player?.seek(to: seekTime)
                vcPlayer.player?.play()
                vc.present(vcPlayer, animated: false, completion: nil)
            }
        }
    }
    
    func saveHelpURL(){
        let helpConfig = try? JSONEncoder().encode(helpSet)
        UserDefaults.standard.set(helpConfig, forKey: "HelpTimestamps")
    }
    
    func loadURL(){
        if let helpConfig = UserDefaults.standard.object(forKey: "HelpTimestamps"){
            do{
                helpSet = try JSONDecoder().decode(HelpTimestampSet.self, from: helpConfig as! Data)
            } catch{
                helpSet = HelpTimestampSet()
            }
        }
    }
    
    func getHelpTimestamps(completion:@escaping(Bool, String) -> ()){
        APIClient.getVideoTimestamps(){ success, result, errorMessage in
            if success{
                self.helpSet = result
                self.saveHelpURL()
                
            }
            completion(success, errorMessage)
        }
    }
}
