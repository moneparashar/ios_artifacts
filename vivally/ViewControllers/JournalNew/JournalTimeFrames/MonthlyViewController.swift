//
//  MonthlyViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/13/23.
//

import UIKit

protocol MonthlyViewDelegate{
    func tappedMonthEvent(jeArr: [JournalEvents], index: Int)
    func lineChartChangedFluid()
}

class MonthlyViewController: UIViewController {

    @IBOutlet weak var emptyEntryLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var entryHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var monthCalendarView: JournalMonthCalendarView!
    @IBOutlet weak var monthEntryChartStack: UIStackView!
    @IBOutlet weak var entriesview: UIView!
    @IBOutlet weak var fluidLineChartView: FluidLineChartView!
    @IBOutlet weak var urinaryLineChartView: UrinaryLineChartView!
    
    @IBOutlet weak var monthContentWidth: NSLayoutConstraint!
    var delegate:DayWeeklyViewDelegate?
    
    var journalList:[[JournalEvents]] = []
    var allJournals:[JournalEvents] = []
    
    var tableView = UITableView()
    
    var cellID = "cell"
    var weekID = "weekCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        monthContentWidth.constant = view.getWidthConstant()
        addTable()
        setCharts()
        
        monthCalendarView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        entryHeightConstraint.constant = tableView.contentSize.height
    }
    
    func addTable(){
        // remove separators
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        
        tableView.alwaysBounceVertical = false
        tableView.clipsToBounds = false
        tableView.register(DailyTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.register(WeeklyMonthlyTableViewCell.self, forCellReuseIdentifier: weekID)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        entriesview.addSubview(tableView)
        
        let tH = tableView.heightAnchor.constraint(equalToConstant: 30)
        tH.isActive = true
        tH.priority = UILayoutPriority(rawValue: 900)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: entriesview.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: entriesview.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: entriesview.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: entriesview.trailingAnchor)
        ])
            
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setCharts(){
        let chartJournals = getAllJournal(dayJournal: journalList)
        fluidLineChartView.journalEvents = chartJournals
        urinaryLineChartView.journalEvents = chartJournals
        
        fluidLineChartView.setup()
        urinaryLineChartView.setup()
        
        fluidLineChartView.delegate = self
    }
    
    func getAllJournal(dayJournal: [[JournalEvents]]) -> [JournalEvents]{
        var allje:[JournalEvents] = []
        for journalGroup in dayJournal{
            for j in journalGroup{
                allje.append(j)
            }
        }
        return allje
    }
    
    func getJournalListText(je: JournalEvents) -> String{       //will have to update eventually with milliters
        var listText = ""
        
        if JournalRangesManager.sharedInstance.checkForDrinks(je: je){
            let drinks = (je.drinksWaterOther ?? 0) + (je.drinksAlcohol ?? 0) + (je.drinksCaffeinated ?? 0)
            
            switch ConversionManager.sharedInstance.fluidUnit{
            case .ounces:
                let totalOunces = ConversionManager.sharedInstance.getOunces(milli: drinks)
                listText = String(format:"%.0f", totalOunces) + " ounces fluid intake"
            case .cups:
                let totalOunces = ConversionManager.sharedInstance.getOunces(milli: drinks)
                let cups = Int(totalOunces / 7)
                let remOunces = Int(totalOunces) % 7
                if cups != 0 && remOunces != 0{
                    listText = "\(cups) cups \(remOunces) ounces fluid intake"
                }
                else if cups != 0{
                    listText = "\(cups) cups fluid intake"
                }
                else if remOunces != 0{
                    listText = "\(remOunces) ounces fluid intake"
                }
            case .milliliters:
                listText = "\(drinks) milliliters fluid intake"
            }
        }
        
        if JournalRangesManager.sharedInstance.checkForRestroom(je: je){
            let restroom = (je.restroomDrops!)
            listText = listText.isEmpty ? "\(restroom) voids" : listText + ", \(restroom) voids"
        }
        
        if JournalRangesManager.sharedInstance.checkForLeaks(je: je){
            let leak = (je.accidentsDrops!)
            listText = listText.isEmpty ? "\(leak) leaks" : listText + ", \(leak) leaks"
        }
        
        if je.lifeGelPads == true{
            listText = listText.isEmpty ? "replaced gel cushions" : listText + ", replaced gel cushions"
        }
        if je.lifeMedication == true{
            listText = listText.isEmpty ? "medication" : listText + ", medication"
        }
        if je.lifeExercise == true{
            listText = listText.isEmpty ? "exercise" : listText + ", exercise"
        }
        if je.lifeDiet == true{
            listText = listText.isEmpty ? "diet" : listText + ", diet"
        }
        if je.lifeStress == true{
            listText = listText.isEmpty ? "stress" : listText + ", stress"
        }
        
        return listText
    }
    
    func getJournalListWeekText(jeArr: [JournalEvents]) -> String{
        let newJe = JournalEvents()
        for j in jeArr{
            newJe.drinksWaterOther = newJe.drinksWaterOther! + j.drinksWaterOther!
            newJe.drinksAlcohol = newJe.drinksAlcohol! + j.drinksAlcohol!
            newJe.drinksCaffeinated = newJe.drinksCaffeinated! + j.drinksCaffeinated!
            
            newJe.restroomDrops = newJe.restroomDrops! + j.restroomDrops!
            newJe.restroomUrges = newJe.restroomUrges! + j.restroomUrges!
            newJe.restroomSleep = newJe.restroomSleep! + j.restroomSleep!
            
            newJe.accidentsDrops = newJe.accidentsDrops! + j.accidentsDrops!
            newJe.accidentsUrges = newJe.accidentsUrges! + j.accidentsUrges!
            newJe.accidentsChanges = newJe.accidentsChanges! + j.accidentsChanges!
            
            newJe.lifeGelPads = newJe.lifeGelPads! || j.lifeGelPads!
            newJe.lifeMedication = newJe.lifeMedication! || j.lifeMedication!
            newJe.lifeExercise = newJe.lifeExercise! || j.lifeExercise!
            newJe.lifeDiet = newJe.lifeDiet! || j.lifeDiet!
            newJe.lifeStress = newJe.lifeStress! || j.lifeStress!
        }
        
        return getJournalListText(je: newJe)
    }
}
extension MonthlyViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return journalList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.0
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: weekID, for: indexPath) as! WeeklyMonthlyTableViewCell
        
        if let firstEvent = journalList[indexPath.section].first{
            let weekStr = firstEvent.eventTimestamp.getDateStrOfDay()
            let rangeText = getJournalListWeekText(jeArr: journalList[indexPath.section])
            
            // remove highlight on tap
            cell.selectionStyle = .none
            
            cell.setup(titleStr: weekStr, journalStr: rangeText)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var jePass: [JournalEvents] = []
        
        jePass = journalList[indexPath.section]
        delegate?.tappedEvent(jeArr: jePass, index: 0)
    }
    
}
extension MonthlyViewController:FluidLineChartViewDelegate{
    func switchedFluidUnitViaChart() {
        delegate?.chartChangedFluid()
    }
}

extension MonthlyViewController:JournalMonthCalendarDelegate{
    func tappedDate(date: Date) {
        delegate?.changedDate(newDate: date)
    }
    
    func triggerMonthSwipe(progress: Int){
        delegate?.swipeTriggered(prog: progress)
    }
}
