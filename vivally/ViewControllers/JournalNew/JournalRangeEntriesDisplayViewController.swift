//
//  JournalRangeEntriesViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/20/22.
//

import UIKit

enum JournalEntryTableRows{
    case fluid
    case restroom
    case leaks
    case life
    case options
}

protocol JournalRangeEntriesDisplayViewDelegate{
    func valuesUpdated(event: JournalEvents, range: JournalDayEntryNavigationPages)
    func changeDateSelected()
    func deleteEntrySelected()
    func updatedFluidUnit()
}

//view controller shown in container of journal entry inbetween range tab and discard/save buttons
class JournalRangeEntriesDisplayViewController: UIViewController {

    @IBOutlet weak var deletButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var fluidCardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var restroomCardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leaksCardHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fluidCard: JournalEntryFluidCardTableView!
    @IBOutlet weak var restroomCard: JournalEntryRestroomCardTableView!
    @IBOutlet weak var leaksCard: JournalEntryLeaksCardTableView!
    @IBOutlet weak var lifeCard: JournalEntryLifeCardView!
    
    var selectedRange:JournalDayEntryNavigationPages = .night
    //var entryDate:Date = Date()
    
    var delegate: JournalRangeEntriesDisplayViewDelegate?
    var je = JournalEvents()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayRangeTime()
        
        fluidCard.delegate = self
        restroomCard.delegate = self
        leaksCard.delegate = self
        lifeCard.delegate = self
        
        dateButton.setTitleColor(UIColor.fontBlue, for: .normal)
        if JournalEventsManager.sharedInstance.isEdit
        {
            deletButton.isHidden = false
        }
        else
        {
            deletButton.isHidden = true
        }
    }
    
    func displayRangeTime(){
        var cal = Calendar(identifier: .gregorian)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        dateFormatter.dateFormat = "d MMM yyyy, "
        
        let tmstmp = je.eventTimestamp.treatTimestampStrAsDate() ?? Date()
        var dateStr = dateFormatter.string(from: tmstmp)
        
        switch selectedRange {
        case .night:
            dateStr += "12am - 6am"
        case .morning:
            dateStr += "6am - 12pm"
        case .afternoon:
            dateStr += "12pm - 6pm"
        case .evening:
            dateStr += "6pm - 12am"
        }
        
        dateButton.setTitle(dateStr, for: .normal)
        
    }
    
    func setFluidValues(){
        switch ConversionManager.sharedInstance.fluidUnit{
        case .ounces:
            fluidCard.waterVal = ConversionManager.sharedInstance.getOunces(milli: je.drinksWaterOther ?? 0)
            fluidCard.cafVal = ConversionManager.sharedInstance.getOunces(milli: je.drinksCaffeinated ?? 0)
            fluidCard.alcoholVal = ConversionManager.sharedInstance.getOunces(milli: je.drinksAlcohol ?? 0)
        case .cups:
            fluidCard.waterVal = Double(ConversionManager.sharedInstance.getCups(milli: je.drinksWaterOther ?? 0))
            fluidCard.cafVal = Double(ConversionManager.sharedInstance.getCups(milli: je.drinksCaffeinated ?? 0))
            fluidCard.alcoholVal = Double(ConversionManager.sharedInstance.getCups(milli: je.drinksAlcohol ?? 0))
        case .milliliters:
            fluidCard.waterVal = Double(je.drinksWaterOther ?? 0)
            fluidCard.cafVal = Double(je.drinksCaffeinated ?? 0)
            fluidCard.alcoholVal = Double(je.drinksAlcohol ?? 0)
        }
    }
    
    func setValues(){
        ConversionManager.sharedInstance.loadFluidUnit()
        setFluidValues()
        
        restroomCard.voidsVal = Double(je.restroomDrops ?? 0)
        restroomCard.urgeVal = Double(je.restroomUrges ?? 0)
        restroomCard.sleepVal = Double(je.restroomSleep ?? 0)
        
        leaksCard.leaksVal = Double(je.accidentsDrops ?? 0)
        leaksCard.urgeVal = Double(je.accidentsUrges ?? 0)
        leaksCard.padsVal = Double(je.accidentsChanges ?? 0)
        leaksCard.sleepVal = Double(je.accidentsSleep ?? 0)
        
        fluidCard.setDisplays()
        restroomCard.setDisplays()
        leaksCard.setDisplays()
        
        lifeCard.setup(je: je)
    }

    @IBAction func HelpTapped(_ sender: UIButton) {
        //open help vc
        let storyboard = UIStoryboard(name: "journalNew", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "JournalRangeHelpViewController") as! JournalRangeHelpViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func changeDateTapped(_ sender: UIButton) {
        delegate?.changeDateSelected()
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        delegate?.deleteEntrySelected()
    }
    
    func getMilli(pval: Double) -> Double{
        var passVal = pval
        switch ConversionManager.sharedInstance.fluidUnit{
        case .ounces:
            passVal = ConversionManager.sharedInstance.getMilli(amt: passVal)
        case .cups:
            passVal = ConversionManager.sharedInstance.getMilli(amt: passVal, ounces: false)
        case .milliliters:
            return passVal
        }
        return passVal
    }
}

extension JournalRangeEntriesDisplayViewController: JournalEntryFluidCardTableDelegate{
    func updatedFluidUnit() {
        setFluidValues()
        fluidCard.setDisplays()
        delegate?.updatedFluidUnit()
    }
    //Change value to double for decimal value
    func updatedWater(val: Int) {
        let passVal = Double(val)
        je.drinksWaterOther = Double(getMilli(pval: passVal))
        setFluidValues()
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
    //Change value to double for decimal value
    func updatedCaf(val: Int) {
        let passVal = Double(val)
        je.drinksCaffeinated = Double(getMilli(pval: passVal))
        setFluidValues()
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
    //Change value to double for decimal value
    func updatedAlc(val: Int) {
        let passVal = Double(val)
        je.drinksAlcohol = Double(getMilli(pval: passVal))
        setFluidValues()
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
}

extension JournalRangeEntriesDisplayViewController: JournalEntryRestroomCardTableDelegate{
    func updatedVoids(val: Int) {
        je.restroomDrops = val
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
    
    func updatedRestroomUrges(val: Int) {
        je.restroomUrges = val
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
    
    func updatedSleep(val: Int) {
        je.restroomSleep = val
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
}

extension JournalRangeEntriesDisplayViewController: JournalEntryLeaksCardTableDelegate{
    func updatedLeakSleep(val: Int) {
        je.accidentsSleep = val
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
    
    func updatedLeaks(val: Int) {
        je.accidentsDrops = val
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
    
    func updatedLeakUrges(val: Int) {
        je.accidentsUrges = val
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
    
    func updatedChanges(val: Int) {
        je.accidentsChanges = val
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
}

extension JournalRangeEntriesDisplayViewController: JournalEntryLifeCardDelegate{
    func gelTap(select: Bool) {
        je.lifeGelPads = select
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
    
    func medicationTap(select: Bool) {
        je.lifeMedication = select
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
    
    func exerciseTap(select: Bool) {
        je.lifeExercise = select
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
    
    func dietTap(select: Bool) {
        je.lifeDiet = select
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
    
    func stressTap(select: Bool) {
        je.lifeStress = select
        delegate?.valuesUpdated(event: je, range: selectedRange)
    }
}
