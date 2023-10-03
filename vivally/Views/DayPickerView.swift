//
//  DayPickerView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 8/29/22.
//

import UIKit

protocol DayPickerViewDelegate{
    func cancelTapped(sender: DayPickerView)
    func editTapped(sender: DayPickerView)
    func addTapped(sender: DayPickerView)
    func changeTimeTapped(sender: DayPickerView)
    func pickerChanged(sender: DayPickerView)
}

class DayPickerView: UIView {

    var delegate:DayPickerViewDelegate?
    
    let nibName = "DayPickerView"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var dayPickerView: UIPickerView!
    @IBOutlet weak var journalExistsLabel: UILabel!
    @IBOutlet weak var cancelButton: ActionButton!
    @IBOutlet weak var editButton: ActionButton!
    @IBOutlet weak var addButton: ActionButton!
    @IBOutlet weak var changeTimeButton: ActionButton!
    
    var allDates = [Date]()
    var selectedDate:Date?
    var selectedDayRow = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        
        setupDates()
        dayPickerView.dataSource = self
        dayPickerView.delegate = self
        
        cancelButton.toSecondary()
        
        pickerContainerView.layer.cornerRadius = 10
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func setupDates(){
        allDates.append(contentsOf: Date.lastYear())
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC") ?? .current
        let startDate = cal.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()
        allDates.append(startDate)
    }
    
    func selectDate(date: Date){
        selectedDayRow = findDateDay(date: date)
        dayPickerView.selectRow(selectedDayRow, inComponent: 0, animated: true)
        
        self.pickerView(dayPickerView, didSelectRow: selectedDayRow, inComponent: 0)
    }
    
    func findDateDay(date: Date) -> Int{
        var i = 0
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC") ?? .current
        for day in allDates{
            if cal.compare(day, to: date, toGranularity: .day) == .orderedSame{
                return i
            }
            i += 1
        }
        return 0
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        delegate?.cancelTapped(sender: self)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        delegate?.editTapped(sender: self)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        delegate?.addTapped(sender: self)
    }
    
    @IBAction func changeTimeButtonTapped(_ sender: Any) {
        delegate?.changeTimeTapped(sender: self)
    }
    
}

extension DayPickerView: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        allDates.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDayRow = row
        
        selectedDate = allDates[selectedDayRow]
        delegate?.pickerChanged(sender: self)
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = .center
        
        let date = allDates[row]
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(identifier: "UTC")
        //dateFormat.dateFormat = "E MMMM, d, YYYY"
        dateFormat.dateFormat = "E MMMM d"
        pickerLabel.text = dateFormat.string(from: date)
        pickerLabel.textColor = row == selectedDayRow ? UIColor(named: "avationMdGreen") : UIColor.black
        return pickerLabel
    }
    
    
}
