//
//  DiaryDayPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 3/1/23.
//

import UIKit

class DiaryDayPopupViewController: BasicPopupViewController {

    override func viewDidLoad() {
        baseContent = BasicPopupContent(title: "3 day baseline Diary requested", message: "Your clinician has requested that you complete a 3-Day Diary to detail all of your fluid intake and symptoms. If you are ready to begin the event now click the Begin button below. If you would like to postpone the event until tomorrow click the Remind later button below", option1: "Remind later", option2: "Begin", flipPrimary: true, xClose: false, icon: .question)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tappedOption1(_ sender: UIButton) {
        option1Button.isEnabled = false
        //send remind later to cloud
        let focus = JournalEventFocusPeriodManager.sharedInstance.loadFocus()
        JournalEventFocusPeriodManager.sharedInstance.currentFocusPeriod?.postponedCount = (focus?.postponedCount ?? 0) + 1
        JournalEventFocusPeriodManager.sharedInstance.saveFocus()
        JournalEventFocusPeriodManager.sharedInstance.postpostLatestFocusPeriod(){ success, result, errorMessage in
        }
        self.dismiss(animated: false)
    }
    
    override func tappedOption2(_ sender: UIButton) {
        //begin
        option2Button.isEnabled = false
        let focus = JournalEventFocusPeriodManager.sharedInstance.loadFocus()
        JournalEventFocusPeriodManager.sharedInstance.currentFocusPeriod?.acknowledged = Date()
        JournalEventFocusPeriodManager.sharedInstance.saveFocus()
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.diaryEventConfirm.rawValue), object: nil)
        JournalEventFocusPeriodManager.sharedInstance.startLatestFocusPeriod(){ success, result, errorMessage in
        }
        self.dismiss(animated: false)
        
    }
}
