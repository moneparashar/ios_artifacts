//
//  DayWeeklyViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/4/23.
//

import UIKit

protocol DayWeeklyViewDelegate{
    func tappedEvent(jeArr: [JournalEvents], index: Int)
    func chartChangedFluid()
    func changedDate(newDate: Date)
    func swipeTriggered(prog: Int)
}

class DayWeeklyViewController: UIViewController {

    @IBOutlet weak var emptyEntryLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var entryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var entryWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollContentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var entryView: UIView!
    @IBOutlet weak var fluidView: FluidChartView!
    @IBOutlet weak var urinaryView: UrinaryChartView!
    
    var delegate:DayWeeklyViewDelegate?
    
    var journalList:[[JournalEvents]] = []
    var allJournals:[JournalEvents] = []
    
    var tableView = UITableView()
    
    var cellID = "cell"
    var weekID = "weekCell"
    
    var timeRange:JournalTimeRanges = .daily
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryWidth.constant = view.getWidthConstant()
        
        addTable()
        setCharts()
        
        if timeRange == .daily{
            entryView.layer.cornerRadius = 16
            entryView.layer.borderWidth = 1
            entryView.layer.borderColor = UIColor.lavendarMist?.cgColor
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // add logic for diable future date or event
        if journalList.count > 0{
            JournalEventsManager.sharedInstance.allDayJournals = JournalEventsManager.sharedInstance.setOldEntries(currentJes: journalList[0])
            
            for je in JournalEventsManager.sharedInstance.allDayJournals{
                if let navRange = JournalEventsManager.sharedInstance.idRange(event: je){
                    JournalEventsManager.sharedInstance.journalSects[navRange] = je.createCopy()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        entryHeightConstraint.constant = tableView.contentSize.height
    }
    
    func addTable(){
        tableView.backgroundColor = UIColor.white
        tableView.alwaysBounceVertical = false
        tableView.clipsToBounds = false
        tableView.register(DailyTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.register(WeeklyMonthlyTableViewCell.self, forCellReuseIdentifier: weekID)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        entryView.addSubview(tableView)
        
        let tH = tableView.heightAnchor.constraint(equalToConstant: 30)
        tH.isActive = true
        tH.priority = UILayoutPriority(rawValue: 900)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: entryView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: entryView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: entryView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: entryView.trailingAnchor)
        ])
            
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setCharts(){
        fluidView.timeRange = timeRange
        urinaryView.timeRange = timeRange
        
        let chartJournals = getAllJournal(dayJournal: journalList)
        
        fluidView.journalEvents = chartJournals
        urinaryView.journalEvents = chartJournals
        
        fluidView.chartConfigure()
        urinaryView.chartConfigure()
        
        fluidView.setup()
        urinaryView.setup()
        
        fluidView.delegate = self
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
    
    func getJournalListText(je: JournalEvents) -> String{
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
                listText = String(format:"%.0f", drinks) + " ml fluid intake"
                
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
extension DayWeeklyViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if timeRange == .daily{
            if journalList.count != 0{
                return 4
            }
        }
        else if timeRange == .weekly{
            return journalList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.0
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if timeRange == .daily{
            return nil
        }
        else{
            let headerView = UIView()
            headerView.backgroundColor = UIColor.clear
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if timeRange == .daily{
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DailyTableViewCell
            if journalList.count != 0{
                
                for jl in journalList[0]{
                    if let crange = JournalEventsManager.sharedInstance.idRange(event: jl){
                        if crange.rawValue == (indexPath.section * 6){
                            let rangeText = getJournalListText(je: jl)
                            cell.setup(dayrange: crange, journalText: rangeText)
                            return cell
                        }
                    }
                }
                
                if let navPage = JournalDayEntryNavigationPages(rawValue: indexPath.section * 6){
                    cell.setup(dayrange: navPage)
                    return cell
                }
            }
            return UITableViewCell()
        }
        else if timeRange == .weekly{
            let cell = tableView.dequeueReusableCell(withIdentifier: weekID, for: indexPath) as! WeeklyMonthlyTableViewCell
            
            if let firstEvent = journalList[indexPath.section].first{
                let weekStr = firstEvent.eventTimestamp.getDateStrOfDay()
                let rangeText = getJournalListWeekText(jeArr: journalList[indexPath.section])
                
                // remove separators, remove highlight on tap
                tableView.separatorStyle = .none
                cell.selectionStyle = .none
                
                cell.setup(titleStr: weekStr, journalStr: rangeText)
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var jePass: [JournalEvents] = []
        let today = Date()
        if timeRange == .daily{
            // add logic for diable future date or event
            if let navPage = JournalDayEntryNavigationPages(rawValue: indexPath.section * 6){
                if let navDate = JournalEventsManager.sharedInstance.journalSects[navPage]?.eventTimestamp.treatTimestampStrAsDate(){
                    if navDate < today{
                        jePass = journalList[0]
                        delegate?.tappedEvent(jeArr: jePass, index: indexPath.section)
                    }
                }
            }
        }
        else if timeRange == .weekly {
            jePass = journalList[indexPath.section]
            delegate?.tappedEvent(jeArr: jePass, index: 0)
        }
    }
}

extension DayWeeklyViewController:FluidChartViewDelegate{
    func switchedFluidUnit() {
        delegate?.chartChangedFluid()
    }
}
