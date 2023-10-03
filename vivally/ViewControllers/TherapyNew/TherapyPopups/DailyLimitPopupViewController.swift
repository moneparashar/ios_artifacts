//
//  DailyLimitPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/27/23.
//

import UIKit

class DailyLimitPopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        do{
            if let user = KeychainManager.sharedInstance.accountData?.username{
                let lastSession = try SessionDataDataHelper.getLatest(name: user)
                if let time = lastSession?.eventTimestamp?.treatTimestampStrAsDate(){
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "EEEE, d, h:mm: a"
                    let dateStr = dateFormat.string(from: time)
                    baseContent = BasicPopupContent(title: "Therapy Session Not Available", message: "Your last session was performed on \(dateStr)", option1: "OK", xClose: false)
                    super.viewDidLoad()
                } else { // if event timestamp = ""
                    baseContent = BasicPopupContent(title: "Therapy Session Not Available", message: " ", option1: "OK")
                    super.viewDidLoad()
                }
            }
        } catch{
            baseContent = BasicPopupContent(title: "Therapy Session Not Available", message: " ", option1: "OK")
            super.viewDidLoad()
        }
    }
    

    override func tappedOption1(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    override func tappedClose(_ sender: UIButton) {
        dismiss(animated: false)
    }
}
