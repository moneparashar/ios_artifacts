//
//  DatePicker.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/21/22.
//

import UIKit

class DatePicker: UIPickerView {

    var selectedDayRow = 0
    var selectedTimeRow = 0
    var selectedUnitRow = 0
    
    var selectedDayView = UIView()
    var selectedTimeView = UIView()
    
    var allDates = [Date]()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func datePicked() -> Int{
        allDates = setupDates()
        var row = 0
        for index in allDates.indices{
            let today = Date()
            if Calendar.current.compare(today, to: allDates[index], toGranularity: .day) == .orderedSame{
                row = index
            }
        }
        return row
    }
    
    func setupDates() -> [Date]{
        allDates.append(contentsOf: Date.lastYear())
        //allDates.append(contentsOf: Date.nextYear())
        allDates.append(Date())
        return allDates
    }
    
    func addComponentBackground(){
        selectedDayView.backgroundColor = UIColor.gray
        selectedDayView.isOpaque = false
        selectedDayView.alpha = 0.1
        
        selectedDayView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(selectedDayView)
        
        let lead = UIScreen.main.bounds.width/100 * 10
        let width = UIScreen.main.bounds.width/100 * 35
        NSLayoutConstraint.activate([
            //selectedDayView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: lead),
            selectedDayView.widthAnchor.constraint(equalToConstant: width),
            selectedDayView.heightAnchor.constraint(equalToConstant: 30),
            selectedDayView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            selectedDayView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: UIScreen.main.bounds.width/200 * (-40))
            
            
        ])
        
    }
    
    func fixComponentBackground(width: Double, height: Double){
        
    }
    
    func selectDate(date: Date){
        
        let dayrow = findDateDay(date: date)
        selectRow(dayrow, inComponent: 0, animated: true)
        
        let timerow = findDateTime(date: date)
    }
    
    func findDateDay(date: Date) -> Int{
        var i = 0
        for day in allDates{
            if Calendar.current.compare(day, to: date, toGranularity: .day) == .orderedSame{
                return i
            }
            i += 1
        }
        return 0
    }
    
    func findDateTime(date: Date) -> Int{
        var i = 0
        for day in allDates{
            if Calendar.current.compare(day, to: date, toGranularity: .hour) == .orderedSame{
                return i
            }
            i += 1
        }
        return 0
    }

}

