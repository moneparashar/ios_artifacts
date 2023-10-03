//
//  JournalEntryMainViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/3/23.
//

import UIKit

class JournalEntryMainViewController: BaseNavViewController {

    @IBOutlet weak var rangeSegmentContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var discardButton: ActionButton!
    @IBOutlet weak var saveButton: ActionButton!
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    //var rangeOptions:[JournalDayEntryNavigationPages] = [ .night, .morning, .afternoon, .evening]
    var selectedRange:JournalDayEntryNavigationPages = .night
    
    var oldJournalEntries:[JournalEvents] = []
    var oldJournalNavEntries:[JournalDayEntryNavigationPages: JournalEvents] = [:]
    
    var rangeSegment = GroupedSegmentView(optionNum: 4)
    
    var change = false
    
    let morningImage = UIImage(named: "morningLight")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    let noonImage = UIImage(named: "noonLight")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    let eveningImage = UIImage(named: "eveningLight")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    let nightImage = UIImage(named: "nightLight")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.goBackPrompt = true
        super.showOnlyRightLogo = true
        
        super.viewDidLoad()
        super.delegate = self
        contentWidth.constant = view.getWidthConstant()
        title = "My eDiary entry"
        setupSegment()
        
        oldJournalEntries = JournalEventsManager.sharedInstance.allDayJournals
        setJournals()
        
        addNewPage(newPage: selectedRange)
        //container view
        //add(asChildViewController: morningRangeViewController)
        discardButton.toDisable()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rangeSegment.selectSegment(segment: getMatchingRangeIndex(range: selectedRange))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func changedTime(notif:Notification){
        setJournals(firstSet: false)
        updateTimes()
        
        //valuesUpdated
        var totalChange = false
        for jrange in JournalDayEntryNavigationPages.allCases{
            if let currentJe = JournalEventsManager.sharedInstance.journalSects[jrange]{
                if let oldEvent = oldJournalNavEntries[jrange]{
                    let jeChange = JournalEventsManager.sharedInstance.didJournalsChange(oldJe: oldEvent, currentJe: currentJe)
                    
                    if !totalChange && jeChange{
                        totalChange = jeChange
                        break
                    }
                }
            }
        }
        
        if totalChange{
            let changedJes = JournalEventsManager.sharedInstance.saveAllowed(oldEntry: oldJournalNavEntries, currentEntry: JournalEventsManager.sharedInstance.journalSects)
            change = changedJes != nil
        }
        else{
            change = false
        }
        
        saveButton.isEnabled = change
        discardButton.isEnabled = change
    }
    
    func setJournals(firstSet: Bool = true){
        
        for je in oldJournalEntries{
            if let navRange = JournalEventsManager.sharedInstance.idRange(event: je){
                JournalEventsManager.sharedInstance.journalSects[navRange] = je.createCopy()
                if firstSet{
                    oldJournalNavEntries[navRange] = je.createCopy()
                }
            }
        }
        
        saveButton.isEnabled = false
        saveButton.backgroundColor = UIColor.casperBlue
        discardButton.isUserInteractionEnabled = false
        

    }
    
    func setupSegment(){
        rangeSegment.translatesAutoresizingMaskIntoConstraints = false
        rangeSegmentContainerView.addSubview(rangeSegment)
        NSLayoutConstraint.activate([
            rangeSegment.leadingAnchor.constraint(equalTo: rangeSegmentContainerView.leadingAnchor),
            rangeSegment.centerXAnchor.constraint(equalTo: rangeSegmentContainerView.centerXAnchor),
            rangeSegment.topAnchor.constraint(equalTo: rangeSegmentContainerView.topAnchor),
            rangeSegment.centerYAnchor.constraint(equalTo: rangeSegmentContainerView.centerYAnchor)
        ])
        rangeSegment.delegate = self
        rangeSegment.setup(imgArr: [nightImage, morningImage, noonImage, eveningImage])
        
        rangeSegment.selectSegment(segment: getMatchingRangeIndex(range: selectedRange))
    }
    
    func updateView(){
        switch selectedRange{
        case .morning:
            remove(asChildViewController: morningRangeViewController)
        case .afternoon:
            remove(asChildViewController: afternoonRangeViewController)
        case .evening:
            remove(asChildViewController: eveningRangeViewController)
        case .night:
            remove(asChildViewController: nightRangeViewController)
        }
        
        selectedRange = getMatchingRange(index: rangeSegment.selectedOption) ?? selectedRange
        
        addNewPage(newPage: selectedRange)
        updateChildDisplay()
    }
    
    func updateChildDisplay(){
        switch selectedRange {
        case .night:
            nightRangeViewController.setValues()
        case .morning:
            morningRangeViewController.setValues()
        case .afternoon:
            afternoonRangeViewController.setValues()
        case .evening:
            eveningRangeViewController.setValues()
        }
    }
    
    func disableFutureRanges(){
        let today = Date()
        
        for btn in rangeSegment.buttonsArray{
            btn.isEnabled = true
        }
        
        for nav in JournalDayEntryNavigationPages.allCases{
            if let navDate = JournalEventsManager.sharedInstance.journalSects[nav]?.eventTimestamp.treatTimestampStrAsDate(){
                if navDate > today{
                    switch nav {
                    case .morning:
                        rangeSegment.buttonsArray[1].isEnabled = false
                    case .afternoon:
                        rangeSegment.buttonsArray[2].isEnabled = false
                    case .evening:
                        rangeSegment.buttonsArray[3].isEnabled = false
                    case .night:
                        rangeSegment.buttonsArray[0].isEnabled = false
                    }
                }
            }
        }
    }
    
    func getMatchingRangeIndex(range: JournalDayEntryNavigationPages) -> Int{
        switch range {
        case .night:
            return 0
        case .morning:
            return 1
        case .afternoon:
            return 2
        case .evening:
            return 3
        }
    }
    
    func getMatchingRange(index: Int) -> JournalDayEntryNavigationPages?{
        switch index{
        case 0:
            return .night
        case 1:
            return .morning
        case 2:
            return .afternoon
        case 3:
            return .evening
        default:
            return nil
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        containerView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    func addNewPage(newPage: JournalDayEntryNavigationPages){
        switch newPage {
        case .morning:
            add(asChildViewController: morningRangeViewController)
            break
        case .afternoon:
            add(asChildViewController: afternoonRangeViewController)
            break
        case .evening:
            add(asChildViewController: eveningRangeViewController)
            break
        case .night:
            add(asChildViewController: nightRangeViewController)
            break
        }

        disableFutureRanges()
    }
    
    private var _morningRangeViewController:JournalRangeEntriesDisplayViewController? = nil
    private var morningRangeViewController: JournalRangeEntriesDisplayViewController  {
        if(_morningRangeViewController == nil){
            // Load Storyboard
            let storyboard = UIStoryboard(name: "journalNew", bundle: Bundle.main)
            
            // Instantiate View Controller
            let viewController = storyboard.instantiateViewController(withIdentifier: "JournalRangeEntriesDisplayViewController") as! JournalRangeEntriesDisplayViewController
            viewController.delegate = self
            viewController.selectedRange = .morning
            viewController.je = JournalEventsManager.sharedInstance.journalSects[.morning] ?? JournalEvents()
            
            // Add View Controller as Child View Controller
            self.add(asChildViewController: viewController)
            viewController.setValues()
            
            _morningRangeViewController =  viewController
            
        }
        return _morningRangeViewController!
    }
    
    private var _afternoonRangeViewController:JournalRangeEntriesDisplayViewController? = nil
    private var afternoonRangeViewController: JournalRangeEntriesDisplayViewController  {
        if(_afternoonRangeViewController == nil){
            // Load Storyboard
            let storyboard = UIStoryboard(name: "journalNew", bundle: Bundle.main)
            
            // Instantiate View Controller
            let viewController = storyboard.instantiateViewController(withIdentifier: "JournalRangeEntriesDisplayViewController") as! JournalRangeEntriesDisplayViewController
            viewController.delegate = self
            viewController.selectedRange = .afternoon
            viewController.je = JournalEventsManager.sharedInstance.journalSects[.afternoon] ?? JournalEvents()
            
            // Add View Controller as Child View Controller
            self.add(asChildViewController: viewController)
            
            viewController.setValues()
            _afternoonRangeViewController =  viewController
        }
        return _afternoonRangeViewController!
    }
    
    private var _eveningRangeViewController:JournalRangeEntriesDisplayViewController? = nil
    private var eveningRangeViewController: JournalRangeEntriesDisplayViewController  {
        if(_eveningRangeViewController == nil){
            // Load Storyboard
            let storyboard = UIStoryboard(name: "journalNew", bundle: Bundle.main)
            
            // Instantiate View Controller
            let viewController = storyboard.instantiateViewController(withIdentifier: "JournalRangeEntriesDisplayViewController") as! JournalRangeEntriesDisplayViewController
            viewController.delegate = self
            viewController.selectedRange = .evening
            viewController.je = JournalEventsManager.sharedInstance.journalSects[.evening] ?? JournalEvents()
            
            // Add View Controller as Child View Controller
            self.add(asChildViewController: viewController)
            
            viewController.setValues()
            
            _eveningRangeViewController =  viewController
        }
        return _eveningRangeViewController!
    }
    
    private var _nightRangeViewController:JournalRangeEntriesDisplayViewController? = nil
    private var nightRangeViewController: JournalRangeEntriesDisplayViewController  {
        if(_nightRangeViewController == nil){
            // Load Storyboard
            let storyboard = UIStoryboard(name: "journalNew", bundle: Bundle.main)
            
            // Instantiate View Controller
            let viewController = storyboard.instantiateViewController(withIdentifier: "JournalRangeEntriesDisplayViewController") as! JournalRangeEntriesDisplayViewController
            viewController.delegate = self
            viewController.selectedRange = .night
            viewController.je = JournalEventsManager.sharedInstance.journalSects[.night] ?? JournalEvents()
            
            // Add View Controller as Child View Controller
            self.add(asChildViewController: viewController)
            
            viewController.setValues()
            
            _nightRangeViewController =  viewController
        }
        return _nightRangeViewController!
    }
    
    func saveEntries(){
        if let journalsToSaveNav = JournalEventsManager.sharedInstance.saveAllowed(oldEntry: oldJournalNavEntries, currentEntry: JournalEventsManager.sharedInstance.journalSects){
            
            var journalsToSave:[JournalEvents] = []
            
            for je in journalsToSaveNav{
                journalsToSave.append(je.value)
            }
            
            if !journalsToSave.isEmpty{
                JournalEventsManager.sharedInstance.saveEntry(rangeJournals: journalsToSave){
                    NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.journalsUpdated.rawValue), object: nil)
                    
                    if JournalEventsManager.sharedInstance.comingFromHomeVc{
                        JournalEventsManager.sharedInstance.comingFromHomeVc = false
                        
                         //move user to view journal home screen
                        let storyboard = UIStoryboard(name: "journalNew", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "JournalHomeViewController") as! JournalHomeViewController
                        
                        let s2 = UIStoryboard(name: "Main", bundle: nil)
                        let homeVc = s2.instantiateViewController(withIdentifier: "HomeViewController")
                        
                        self.navigationController?.setViewControllers([homeVc, vc], animated: false)
                    }
                    else{
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func discardTapped(){
        let vc = ConfirmDiscardPopupViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        saveEntries()
    }
    
    func updateTimes(){
        let allRange = [nightRangeViewController, morningRangeViewController, afternoonRangeViewController, eveningRangeViewController]
        let allRangeNav:[JournalDayEntryNavigationPages] = [.night, .morning, .afternoon, .evening]
        var ind = 0
        for rangeVc in allRange{
            rangeVc.je = JournalEventsManager.sharedInstance.journalSects[allRangeNav[ind]] ?? JournalEvents()
            ind += 1
            rangeVc.displayRangeTime()
        }
    }
}

extension JournalEntryMainViewController: JournalRangeEntriesDisplayViewDelegate{
    func updatedFluidUnit() {
        
    }
    
    func changeDateSelected() {
        let vc = DayNewPickViewController()
        
        vc.onlyChangeTime = true
        vc.journalsToChangeTime = JournalEventsManager.sharedInstance.allDayJournals
        vc.selectedDate = JournalEventsManager.sharedInstance.journalSects[.night]?.eventTimestamp.treatTimestampStrAsDate() ?? Date()
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .coverVertical
        
        self.present(vc, animated: false)
    }
    
    // delete date
    func deleteEntrySelected() {
        if JournalEventsManager.sharedInstance.isEdit 
        {
            let vc = ConfirmDeleteAllDayPopupViewController()
            
            vc.journalsToDelete = JournalEventsManager.sharedInstance.allDayJournals
            vc.modalPresentationStyle = .overFullScreen
            
            self.present(vc, animated: false)
        }
        
    }
    
    func valuesUpdated(event: JournalEvents, range: JournalDayEntryNavigationPages) {
        JournalEventsManager.sharedInstance.journalSects[range] = event
        
        if let oldEvent = oldJournalNavEntries[range]{
            let jeChange = JournalEventsManager.sharedInstance.didJournalsChange(oldJe: oldEvent, currentJe: event)
            if !oldEvent.isEmpty(){
                JournalEventsManager.sharedInstance.journalSects[range]?.modified = jeChange ? Date() : oldEvent.modified
            }
            if jeChange != change{
                if jeChange{
                    change = jeChange
                }
                else{
                    let changedJes = JournalEventsManager.sharedInstance.saveAllowed(oldEntry: oldJournalNavEntries, currentEntry: JournalEventsManager.sharedInstance.journalSects)
                    change = changedJes != nil
                }
            }
            saveButton.isEnabled = change
            discardButton.toSecondary()
            discardButton.isUserInteractionEnabled = true
            if !change{
                saveButton.backgroundColor = UIColor.casperBlue
                discardButton.toDisable()
                discardButton.isUserInteractionEnabled = false
            }
           
            
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.changedTime(notif:)), name: NSNotification.Name(NotificationNames.journalChangeTime.rawValue), object: nil)
    }
}

extension JournalEntryMainViewController: GroupedSegmentViewDelegate{
    func changedOption() {
        updateView()
    }
}

extension JournalEntryMainViewController: BackPromptDelegate{
    func goBackSelected() {
        if saveButton.isEnabled{
            let vc = ConfirmDiscardPopupViewController()
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        }
        else{
            navigationController?.popViewController(animated: true)
        }
    }
}
