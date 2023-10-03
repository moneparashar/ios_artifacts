//
//  DatePickerViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/5/23.
//

import UIKit

enum journalState: Int{
    case add = 0
    case edit = 1
    case changeTime = 2
}

class DayNewPickViewController: BasePopupViewController {

    var pickerState = journalState.add
    
    var enterViaHome = false
    var enterViaEntry = false
    var onlyChangeTime = false
    var selectedDate = Date()
    var selectedDateCheck = Date()
    var dayPickerSelectedDate = Date()
    var journalsToChangeTime:[JournalEvents] = []
    
    //UI
    
    var contentPadding:CGFloat = 24
    
    var tabletStack = UIStackView()
    var closeButton = UIButton()
    
    var dateStack = UIStackView()   //title, date, buttons
    var headerStack = UIStackView()
    var titleLabel = UILabel()
    
    //day picker view
    var roundedView = UIView()
    var datePicker = UIPickerView()
    
    var errorMessage = UILabel()
    
    var buttonStack = UIStackView()
    var cancelButton = ActionButton()
    var addEntryButton = ActionButton()
    var editEntryButton = ActionButton()
    var changeTimeButton = ActionButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure(){
        setupUI()
        setup()

        // set date observer to 0 time to match 0 time of selected date
        selectedDateCheck = JournalEventsManager.sharedInstance.selectedDateCheck
        selectedDateCheck = Calendar.current.startOfDay(for: selectedDateCheck)
        selectDate(date: selectedDate)
    }
    
    private func setupUI(){
        
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.h4
        titleLabel.textAlignment = .center
        
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        
        //setup datepicker ui
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        roundedView.layer.borderColor = UIColor.casperBlue?.cgColor
        roundedView.layer.borderWidth = 1.2
        roundedView.layer.cornerRadius = 8
        roundedView.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: roundedView.topAnchor, constant: 11),
            datePicker.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor),
            datePicker.widthAnchor.constraint(equalTo: roundedView.widthAnchor, multiplier: CGFloat(144.0/215.0)),   //might need changed priority
            datePicker.centerXAnchor.constraint(equalTo: roundedView.centerXAnchor),
            datePicker.leadingAnchor.constraint(greaterThanOrEqualTo: roundedView.leadingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 194)
        ])
        
        //setup button stack
        setupButtons()
        buttonStack = UIStackView(arrangedSubviews: [cancelButton, addEntryButton, editEntryButton, changeTimeButton])
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 24
        buttonStack.arrangedSubviews[2].isHidden = true
        buttonStack.arrangedSubviews[3].isHidden = true
        
        
        dateStack = UIStackView(arrangedSubviews: [titleLabel, roundedView, errorMessage, buttonStack])
        if UIDevice.current.userInterfaceIdiom == .phone{
            let spacer = UIView()
            headerStack = UIStackView(arrangedSubviews: [spacer, titleLabel, closeButton])
            headerStack.alignment = .center
            headerStack.distribution = .equalCentering
            dateStack = UIStackView(arrangedSubviews: [headerStack, roundedView, errorMessage, buttonStack])
        }
        dateStack.arrangedSubviews[2].isHidden = true
        
        dateStack.axis = .vertical
        dateStack.alignment = .fill
        dateStack.distribution = .fill
        dateStack.spacing = 24
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            setupPhoneLayout()
        }
        else{
            setupTabletLayout()
        }
        
    }
    
    private func setupButtons(){
        //var allPrimaryButtons = [cancelButton, addEntryButton, editEntryButton, changeTimeButton]
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.toSecondary()
        addEntryButton.setTitle("Add Entry", for: .normal)
        editEntryButton.setTitle("Edit Entry", for: .normal)
        changeTimeButton.setTitle("Change Time", for: .normal)
        
        cancelButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchDown)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchDown)
        addEntryButton.addTarget(self, action: #selector(addButtonTapped), for: .touchDown)
        editEntryButton.addTarget(self, action: #selector(editButtonTapped), for: .touchDown)
        changeTimeButton.addTarget(self, action: #selector(changeButtonTapped), for: .touchDown)
    }
    
    private func setupPhoneLayout(){
        dateStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateStack)
        
        NSLayoutConstraint.activate([
            dateStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
            dateStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dateStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentPadding)
        ])
    }
    
    private func setupTabletLayout(){
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        
        tabletStack = UIStackView(arrangedSubviews: [leftSpacer, dateStack, rightSpacer])
        tabletStack.alignment = .top
        tabletStack.distribution = .equalSpacing
        
        tabletStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tabletStack)
        
        NSLayoutConstraint.activate([
            tabletStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
            tabletStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tabletStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tabletStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentPadding),
            tabletStack.arrangedSubviews[1].widthAnchor.constraint(equalToConstant: view.getWidthConstant())
        ])
    }
    
    func setup(){
        setupDates()
        datePicker.dataSource = self
        datePicker.delegate = self
        
    }
    
    
    //MARK: DATE SETUP

    var allDates:[Date] = []
    var selectedDayRow: Int = 0
    //date picker setup
    func setupDates(){
        allDates.append(contentsOf: Date.lastYear())
        let startDate = Calendar.current.startOfDay(for: Date())
        allDates.append(startDate)
    }
    
    func selectDate(date: Date){
        selectedDayRow = findDateDay(date: date)
        
        datePicker.selectRow(selectedDayRow, inComponent: 0, animated: true)
        self.pickerView(datePicker, didSelectRow: selectedDayRow, inComponent: 0)
    }
    
    func findDateDay(date:Date) -> Int{
        var i = 0
        
        for day in allDates{
            if Calendar.current.compare(day, to: date, toGranularity: .day) == .orderedSame{
                return i
            }
            i += 1
        }
        return 0
    }
    
    func pickerTimeChanged(){
        var exists = false
        
        let user = KeychainManager.sharedInstance.accountData?.username ?? ""
        do{
            if onlyChangeTime{
                pickerState = .changeTime
                exists = try JournalEventsDataHelper.eventDayExistsExcept(date: selectedDate, events: journalsToChangeTime)
                
                // selected date is the same as change date? Disable change date button
                if selectedDate == selectedDateCheck {
                    changeTimeButton.isEnabled = false
                 
                // normal operation
                } else {
                    changeTimeButton.isEnabled = !exists
                }
                
            }
            else{
                exists = try JournalEventsDataHelper.eventDayExists(date: selectedDate, name: user)
                pickerState = exists ? .edit : .add

                // if date picker date != current date, save new date
                if
                    selectedDateCheck != selectedDate {
                    updateScrollDate()
                }
                //updatePickerView()
            }
            updatePickerView()
            
        } catch{
            print("error with picker time change dpvc")
        }
    }
    
    // change selected date
    func updateScrollDate() {
        JournalEventsManager.sharedInstance.scrollDate = selectedDate
    }
    
    //MARK: Entry func
    func updatePickerView(){
        switch pickerState {
        case .add:
            titleLabel.text = "New eDiary Entry"
            editEntryButton.isHidden = true
            changeTimeButton.isHidden = true
            addEntryButton.isHidden = false
        case .edit:
            titleLabel.text = "Edit Journal Entry"
            addEntryButton.isHidden = true
            changeTimeButton.isHidden = true
            editEntryButton.isHidden = false
        case .changeTime:
            titleLabel.text = "Change eDiary Entry Time"
            addEntryButton.isHidden = true
            editEntryButton.isHidden = true
            changeTimeButton.isHidden = false
        }
    }
    
    func addEntry(){
        let newEntries = JournalEventsManager.sharedInstance.setNewEntries(date: selectedDate)
        JournalEventsManager.sharedInstance.isEdit = false
        JournalEventsManager.sharedInstance.allDayJournals = newEntries
        
        
        if enterViaHome{
            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.journalAdd.rawValue), object: nil)
        }
        else{
            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.journalEdit.rawValue), object: nil)
        }
        self.dismiss(animated: false)
    }
    
    func editEntry(){
        do{
            JournalEventsManager.sharedInstance.isEdit = true
            let username = KeychainManager.sharedInstance.loadAccountData()?.username ?? ""
            
            let editEvents = try JournalEventsDataHelper.getDayEvents(date: selectedDate, user: username)
            
            if !editEvents.isEmpty{
                let oldEntries = JournalEventsManager.sharedInstance.setOldEntries(currentJes: editEvents)
                JournalEventsManager.sharedInstance.allDayJournals = oldEntries
                
                if enterViaHome{
                    NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.journalAdd.rawValue), object: nil)
                }
                else{
                    NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.journalEdit.rawValue), object: nil)
                }
                self.dismiss(animated: false)
            }
        } catch{
            print("issue with getting event after tapping edit entry")
        }
    }
    
    func changeTime(){
        let earlyTmstmp = journalsToChangeTime.first?.eventTimestamp.treatTimestampStrAsDate() ?? Date()
        let earliestDay = Calendar.current.startOfDay(for: earlyTmstmp)
        let dayDifference = Calendar.current.dateComponents([.day], from: earliestDay, to: selectedDate)
        
        for je in journalsToChangeTime{
            let jTmpstmp = je.eventTimestamp.treatTimestampStrAsDate() ?? Date()
            let nDate = Calendar.current.date(byAdding: .day, value: dayDifference.day ?? 0, to: jTmpstmp) ?? Date()
            je.eventTimestamp = nDate.convertDateToOffsetStr()
            je.modified = Date()
            je.dirty = true
        }
        
        JournalEventsManager.sharedInstance.allDayJournals = journalsToChangeTime
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.journalChangeTime.rawValue), object: nil)
        
        self.dismiss(animated: false)
        
    }
    
    //MARK: Button Actions
    
    @objc func closeButtonTapped(_ sender: UIButton){
        self.dismiss(animated: false)
    }
    
    @objc func editButtonTapped(_ sender: UIButton){
        editEntry()
    }
    
    @objc func addButtonTapped(_ sender: UIButton){
        addEntry()
    }
    
    @objc func changeButtonTapped(_ sender: UIButton){
        changeTime()
    }
}

extension DayNewPickViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        allDates.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDayRow = row
        selectedDate = allDates[selectedDayRow]
        pickerTimeChanged()
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = .center
        
        let date = allDates[row]
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "E MMMM d yyyy"
        pickerLabel.text = dateFormat.string(from: date)
        pickerLabel.textColor = row == selectedDayRow ? UIColor(named: "avationMdGreen") : UIColor.black
        return pickerLabel
    }
    
}
