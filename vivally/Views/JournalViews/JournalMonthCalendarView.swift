//
//  JournalMonthCalendarView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/9/23.
//

import UIKit
import FSCalendar

protocol JournalMonthCalendarDelegate{
    func tappedDate(date: Date)
    func triggerMonthSwipe(progress: Int)
}

class JournalMonthCalendarView: UIView {

    var delegate:JournalMonthCalendarDelegate?
    var calView = FSCalendar()
    
    var eventsList:[JournalEvents] = []
    
    var hasTherapy:[Date] = []
    var hasEvent:[Date] = []
    
    var customCell = "cell"
    
    required init(){
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure(){
        configureUI()
        
        calView.delegate = self
        calView.dataSource = self
        
        calView.register(CustomDateCalendarCell.self, forCellReuseIdentifier: customCell)
    }
    
    private func configureUI(){
        setupCalendar()
        calView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(calView)
        
        NSLayoutConstraint.activate([
            calView.topAnchor.constraint(equalTo: self.topAnchor),
            calView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            calView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            calView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
    private func setupCalendar(){
        calView.appearance.weekdayTextColor = UIColor.fontBlue
        calView.appearance.caseOptions = FSCalendarCaseOptions.weekdayUsesUpperCase
        calView.appearance.selectionColor = UIColor.clear
        calView.placeholderType = .fillHeadTail
        calView.allowsSelection = true
        
        calView.calendarHeaderView.isHidden = true
        calView.headerHeight = 0
        
        calView.formatter.calendar = Calendar.current
        calView.formatter.timeZone = Calendar.current.timeZone
        
        calView.appearance.todayColor = UIColor.gray
        
        calView.scrollEnabled = false   //currently scrolling isn't working
    }
    
    func setDate(date: Date){
        //calView.currentPage = date
        calView.select(date)
        delegate?.tappedDate(date: date)
    }
    
    func getTherapies(){
        hasTherapy = []
        do{
            let user = KeychainManager.sharedInstance.loadAccountData()?.username ?? ""
            let allCompletedTherapiesRange = try SessionDataDataHelper.getCompletedDatesInMonth(name: user, passDate: calView.currentPage) ?? []
            for therapyDate in allCompletedTherapiesRange{
                
                hasTherapy.append(therapyDate)
            }
        } catch{
            print("failed to grab therapies")
        }
    }
    
    func getJournalDates(){
        hasEvent = []
        do{
            let user = KeychainManager.sharedInstance.loadAccountData()?.username ?? ""
            
            hasEvent = try JournalEventsDataHelper.getJournalDatesInMonth(name: user, passDate: calView.currentPage) ?? []
            
        } catch{
            print("failed to grab month journal dates")
        }
    }
}

extension JournalMonthCalendarView: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        //calendar.reloadData()   //
        
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if let currentDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()){
            if date <= currentDate {
                return true
            }
        }
        return false
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition, showTherapy: Bool = false, showBold: Bool = false){
        
        // save selected date for add entry scroll date
        if let newDate = calView.selectedDate {
            JournalEventsManager.sharedInstance.monthlyDateContainer = newDate
        }
        
        let customCell = (cell as! CustomDateCalendarCell)
        
        customCell.backView.isHidden = true
        customCell.therapyImageView.isHidden = !showTherapy
        customCell.selectImageView.isHidden = true
        customCell.currentDateImageView.isHidden = true
        
        if let selectedDate = calView.selectedDate{
            customCell.selectImageView.isHidden = selectedDate != date
            
            customCell.backView.isHidden = Calendar.current.compare(selectedDate, to: date, toGranularity: .weekOfYear) == .orderedSame ? false : true
        }
        if let todayDate = calView.today {
            customCell.currentDateImageView.isHidden = calView.today != date
            
        }
        
        customCell.titleLabel.font = showBold ? UIFont.h4 : UIFont.bodySm
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: customCell, for: date, at: position)
            return cell
        }

    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        var therapyDone = false
        for comDate in hasTherapy{
            if Calendar.current.isDate(comDate, inSameDayAs: date){
                therapyDone = true
                break
            }
        }
        
        var jDone = false
        for jDate in hasEvent{
            if Calendar.current.isDate(jDate, inSameDayAs: date){
                jDone = true
                break
            }
        }
        
        self.configure(cell: cell, for: date, at: monthPosition, showTherapy: therapyDone, showBold: jDone)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        delegate?.tappedDate(date: date)
        calView.reloadData()
    }
}
