//
//  SettingsJournalTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 10/5/21.
//
// TODO: figure out if time reminder is supposed to be just for today

import UIKit

class SettingsJournalTableViewCell: UITableViewCell {

    @IBOutlet weak var hourDropDownOrigin: DropdownOriginView!
    @IBOutlet weak var frequencyDropDownOrigin: DropdownOriginView!
    @IBOutlet weak var timeContainerView: UIView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var showRemindersTextField: TextFieldStackView!
    @IBOutlet weak var showDiaryEntryReminderTextField: TextFieldStackView!
    
    var datePicker = UIDatePicker()
    var selectedDate: Date = Date()
    
    var hourVal:[String] = []
    var notifyValues:[String] = []
    var notifyPicker = ToolbarPickerView()
    var notifySelected: JournalRemindTimes = .once
    var hourSelected = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupView() {
        loadFrequency()
        loadReminderHour()
    }
    
    func loadFrequency(){
        let notifyFrequencies = NotificationManager.sharedInstance.loadJournalNotificationData()
        notifySelected = JournalRemindTimes(rawValue: notifyFrequencies) ?? .never
        
        for remindTime in JournalRemindTimes.allCases{
            notifyValues.append(remindTime.getStr())
        }
        frequencyDropDownOrigin.setup(title: "eDiary entry reminder interval", options: notifyValues)
        frequencyDropDownOrigin.delegate = self
        
        var index = 0
        for nV in notifyValues{
            if nV == notifySelected.getStr(){
                break
            }
            index += 1
        }
        frequencyDropDownOrigin.selectRow(ind: index)
        
        frequencyDropDownOrigin.errorLabel.isHidden = true
    }
    
    func loadReminderHour(){
        NotificationManager.sharedInstance.loadJournalRemindUnits()
        hourSelected = NotificationManager.sharedInstance.journalReminderHour - 1
        
        let analog = isAnalog()
        for hr in 0 ... 23{
            var hrStr = ""
            if hr == 0{
                hrStr = analog ? "12 am" : "0"
            }
            else if hr > 0 && hr < 12{
                hrStr = analog ? String(hr) + " am" : String(hr)
            }
            else if hr == 12{
                hrStr = analog ? "12 pm" : String(hr)
            }
            else{
                hrStr = analog ? String(hr - 12) + " pm" : String(hr)
            }
            
            hourVal.append(hrStr)
        }
        hourDropDownOrigin.setup(title: "Scheduled reminders time", options: hourVal)
        hourDropDownOrigin.delegate = self
        
        if hourSelected <= 0{
            hourDropDownOrigin.selectRow(ind: 0)
        }
        else{
            hourDropDownOrigin.selectRow(ind: NotificationManager.sharedInstance.journalReminderHour - 1)
        }
        hourDropDownOrigin.errorLabel.isHidden = true
    }
    
    func isAnalog() -> Bool{
        if let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: NSLocale.current){
            return dateFormat.contains("a")
        }
        return false
    }
}
extension SettingsJournalTableViewCell: DropdownOriginViewDelegate{
    func dropSelected(ind: Int, option: String, sender: DropdownOriginView) {
        if sender == frequencyDropDownOrigin{
            for remindFreq in JournalRemindTimes.allCases{
                if remindFreq.getStr() == option{
                    notifySelected = remindFreq
                    break
                }
            }
        }
        else if sender == hourDropDownOrigin{
            hourSelected = ind
        }
        
        NotificationManager.sharedInstance.clearJournalReminder()
        NotificationManager.sharedInstance.saveJournalReminder(data: notifySelected.rawValue)
        NotificationManager.sharedInstance.setJournalRemindUnits(hr: hourSelected)
        NotificationManager.sharedInstance.saveJournalRemindUnits()
    }
}
