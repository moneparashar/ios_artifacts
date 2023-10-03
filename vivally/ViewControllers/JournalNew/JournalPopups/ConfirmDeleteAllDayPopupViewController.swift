//
//  ConfirmDeletePopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/13/23.
//

import UIKit

class ConfirmDeleteAllDayPopupViewController: BasicPopupViewController {

    var journalsToDelete:[JournalEvents] = []
    
    override func viewDidLoad() {
        if let firstDate = journalsToDelete.first?.eventTimestamp.treatTimestampStrAsDate(){
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = Calendar.current.timeZone
            dateFormatter.dateFormat = "MMMM, YYYY, d"
            let datestr = dateFormatter.string(from: firstDate)
            baseContent = BasicPopupContent(title: "Delete eDiary entry", message: "Are you sure you want to delete the eDiary entry on \(datestr)?", option1: "Delete", option2: "Cancel", icon: .question)
        }
        super.viewDidLoad()
    }

    override func tappedOption1(_ sender: UIButton) {
        //delete
        JournalEventsManager.sharedInstance.deleteEntry(rangeJournals: journalsToDelete){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNames.journalsUpdated.rawValue), object: nil)

            self.dismiss(animated: false, completion: nil)
            NavigationManager.sharedInstance.currentNav.popViewController(animated: true)
        }
    }
    
    override func tappedOption2(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    override func tappedClose(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
