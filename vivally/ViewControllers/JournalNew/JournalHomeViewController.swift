//
//  JournalHomeViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/19/22.
//

import UIKit

class JournalHomeViewController: BaseNavViewController {
    
    @IBOutlet weak var dateSegmentContainerView: UIView!
    @IBOutlet weak var dateDisplay: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var buttonSpacerView: UIView!
    @IBOutlet weak var addEntryButton: ActionButton!
    @IBOutlet weak var editEntryButton: ActionButton!
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    var selectedDate:Date = Date()
    var selectedTimeFrame: JournalTimeRanges = .weekly
    var journalsPassing:[[JournalEvents]] = []
    
    var rangeSegment = GroupedSegmentView(optionNum: 3)
    var observersSet = false
    
    override func viewDidLoad() {
        goBackEnabled = true
        super.viewDidLoad()
        
        buttonSpacerView.isHidden = UIDevice.current.userInterfaceIdiom == .phone
        title = "My eDiary"
        contentWidth.constant = view.getWidthConstant()
        
        setupSegment()
        
        JournalEventsManager.sharedInstance.selectedDateCheck = selectedDate
        getJournals(){
            self.updateDateDisplay()
            self.addNewPage(timeRange: self.selectedTimeFrame)
            self.updateChildDisplay()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !observersSet{
            addObsevers()
            observersSet = true
        }
        
        switch selectedTimeFrame {
        case .daily:
            rangeSegment.selectSegment(segment: 0)
        case .weekly:
            rangeSegment.selectSegment(segment: 1)
        case .monthly:
            rangeSegment.selectSegment(segment: 2)
        }
        
        if selectedTimeFrame == .monthly{
            monthlyViewController.monthCalendarView.calView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // scroll Date = whatever date user is on when they come back to the view controller
        
        updateDateDisplay()
        JournalEventsManager.sharedInstance.scrollDate = selectedDate
        getJournals(){
            self.updateDateDisplay()
            self.addNewPage(timeRange: self.selectedTimeFrame)
            self.updateChildDisplay()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent{
            dismissObservers()
        }
    }
    
    func dismissObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.journalEdit.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.journalsUpdated.rawValue), object: nil)
        observersSet = false
    }
    
    func addObsevers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.editJournalGo(notif:)), name: NSNotification.Name(NotificationNames.journalEdit.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.journalNotify(notif:)), name: NSNotification.Name(NotificationNames.journalsUpdated.rawValue), object: nil)
    }
    
    @objc func journalNotify(notif:Notification){
        //reload
        getJournals {
            self.updateChildDisplay()
        }
    }
    
    @objc func editJournalGo(notif:Notification){
        // TODO: test that journal via main works
        selectedDate = JournalEventsManager.sharedInstance.scrollDate
        updateJournalPassing() // load scroll date entries
        
        let storyboard = UIStoryboard(name: "journalNew", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "JournalEntryMainViewController") as! JournalEntryMainViewController
        
        vc.selectedRange = .night
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupSegment(){
        rangeSegment.translatesAutoresizingMaskIntoConstraints = false
        dateSegmentContainerView.addSubview(rangeSegment)
        NSLayoutConstraint.activate([
            rangeSegment.leadingAnchor.constraint(equalTo: dateSegmentContainerView.leadingAnchor),
            rangeSegment.centerXAnchor.constraint(equalTo: dateSegmentContainerView.centerXAnchor),
            rangeSegment.topAnchor.constraint(equalTo: dateSegmentContainerView.topAnchor),
            rangeSegment.centerYAnchor.constraint(equalTo: dateSegmentContainerView.centerYAnchor)
        ])
        rangeSegment.delegate = self
        rangeSegment.setup(textArr: ["Daily", "Weekly", "Monthly"])
        
        rangeSegment.layoutIfNeeded()
    }
    
    func getJournals(completion:@escaping () -> ()){
        switch selectedTimeFrame {
        case .daily:
            JournalRangesManager.sharedInstance.getJournalList(jrange: .daily, jpass: selectedDate){ jlist in
                self.journalsPassing = jlist
                completion()
            }
        case .weekly:
            JournalRangesManager.sharedInstance.getJournalList(jrange: .weekly, jpass: selectedDate){ jlist in
                self.journalsPassing = jlist
                completion()
            }
        case .monthly:
            JournalRangesManager.sharedInstance.getJournalList(jrange: .monthly, jpass: selectedDate){ jlist in
                self.journalsPassing = jlist
                completion()
            }
        }
    }
    
    // journalPassing = scrollDateEntries
    func updateJournalPassing() {
        JournalRangesManager.sharedInstance.getJournalList(jrange: .daily, jpass: selectedDate){ jlist in
            self.journalsPassing = jlist
        }
    }
    
    private var _dayViewController:DayWeeklyViewController? = nil
    private var dayViewController: DayWeeklyViewController  {
        if(_dayViewController == nil){
            // Load Storyboard
            let storyboard = UIStoryboard(name: "journalNew", bundle: Bundle.main)
            
            // Instantiate View Controller
            let viewController = storyboard.instantiateViewController(withIdentifier: "DayWeeklyViewController") as! DayWeeklyViewController
            viewController.journalList = journalsPassing
            viewController.timeRange = .daily
            viewController.delegate = self
            // Add View Controller as Child View Controller
            self.add(asChildViewController: viewController)
            
            
            _dayViewController =  viewController
        }
        return _dayViewController!
    }
    
    private var _weeklyViewController:DayWeeklyViewController? = nil
    private var weeklyViewController: DayWeeklyViewController  {
        if(_weeklyViewController == nil){
            // Load Storyboard
            let storyboard = UIStoryboard(name: "journalNew", bundle: Bundle.main)
            
            // Instantiate View Controller
            let viewController = storyboard.instantiateViewController(withIdentifier: "DayWeeklyViewController") as! DayWeeklyViewController
            viewController.journalList = journalsPassing
            viewController.timeRange = .weekly
            viewController.delegate = self
            // Add View Controller as Child View Controller
            self.add(asChildViewController: viewController)
            
            
            _weeklyViewController =  viewController
        }
        return _weeklyViewController!
    }
    
    private var _monthlyViewController:MonthlyViewController? = nil
    private var monthlyViewController: MonthlyViewController  {
        if(_monthlyViewController == nil){
            // Load Storyboard
            let storyboard = UIStoryboard(name: "journalNew", bundle: Bundle.main)
            
            // Instantiate View Controller
            let viewController = storyboard.instantiateViewController(withIdentifier: "MonthlyViewController") as! MonthlyViewController
            viewController.journalList = journalsPassing
            viewController.delegate = self
            // Add View Controller as Child View Controller
            self.add(asChildViewController: viewController)
            
            viewController.monthCalendarView.setDate(date: selectedDate)
            _monthlyViewController =  viewController
        }
        return _monthlyViewController!
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
    
    func addNewPage(timeRange: JournalTimeRanges){
        switch timeRange {
        case .daily:
            add(asChildViewController: dayViewController)
        case .weekly:
            add(asChildViewController: weeklyViewController)
        case .monthly:
            add(asChildViewController: monthlyViewController)
            break
        }
        
        self.checkToShowEdit()
    }
    
    private func updateView(){
        //only three options now, empty view day/week, and month
        switch selectedTimeFrame {
        case .daily:
            remove(asChildViewController: dayViewController)
        case .weekly:
            remove(asChildViewController: weeklyViewController)
        case .monthly:
            remove(asChildViewController: monthlyViewController)
        }
        
        switch rangeSegment.selectedOption{
        case 0:
            selectedTimeFrame = .daily
        case 1:
            selectedTimeFrame = .weekly
        case 2:
            selectedTimeFrame = .monthly
        default:
            break
        }
        
        getJournals(){
            self.updateDateDisplay()
            self.addNewPage(timeRange: self.selectedTimeFrame)
            self.updateChildDisplay()
        }
    }
    
    func updateChildDisplay(){
        switch selectedTimeFrame {
        case .daily:
            _dayViewController?.journalList = journalsPassing
            _dayViewController?.emptyEntryLabel.isHidden = !journalsPassing.isEmpty
            _dayViewController?.scrollView.isHidden = journalsPassing.isEmpty
            
            _dayViewController?.tableView.reloadData()
            _dayViewController?.setCharts()
            if _dayViewController != nil{
                _dayViewController?.view.layoutIfNeeded()
            }
            
        case .weekly:
            _weeklyViewController?.journalList = journalsPassing
            _weeklyViewController?.emptyEntryLabel.isHidden = !journalsPassing.isEmpty
            _weeklyViewController?.scrollView.isHidden = journalsPassing.isEmpty
            _weeklyViewController?.tableView.reloadData()
            _weeklyViewController?.setCharts()
            if _weeklyViewController != nil{
                _weeklyViewController?.view.layoutIfNeeded()
            }
            
        case .monthly:
            _monthlyViewController?.journalList = journalsPassing
            _monthlyViewController?.emptyEntryLabel.isHidden = !journalsPassing.isEmpty
            _monthlyViewController?.monthEntryChartStack.isHidden = journalsPassing.isEmpty
            
            _monthlyViewController?.tableView.reloadData()
            _monthlyViewController?.setCharts()
            _monthlyViewController?.monthCalendarView.setDate(date: selectedDate)
            _monthlyViewController?.monthCalendarView.getTherapies()
            _monthlyViewController?.monthCalendarView.getJournalDates()
            _monthlyViewController?.monthCalendarView.calView.reloadData()
            if _monthlyViewController != nil{
                _monthlyViewController?.view.layoutIfNeeded()
            }
            break
        }
    }
    
    func changeDate(progression: Int){
        let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: selectedDate) ?? Date()
        
        switch selectedTimeFrame {
        case .daily:
            selectedDate = Calendar.current.date(byAdding: .day, value: progression, to: startDate) ?? Date()
        case .weekly:
            selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: progression, to: startDate) ?? Date()
        case .monthly:
            selectedDate = Calendar.current.date(byAdding: .month, value: progression, to: startDate) ?? Date()
        }
        
        getJournals(){
            // update selectedDateCheck, scrollDate
            self.updateDateDisplay()
            self.updateChildDisplay()
            self.updateJournalPassing()
            self.updateEventsManagerDates()
        }
    }
    
    func updateEventsManagerDates() {
        JournalEventsManager.sharedInstance.scrollDate = selectedDate
        JournalEventsManager.sharedInstance.selectedDateCheck = selectedDate
    }
    
    func updateDateDisplay(){
        let startDate = Calendar.current.startOfDay(for: selectedDate)
        var dateStr = ""
        let df = DateFormatter()
        switch selectedTimeFrame {
        case .daily:
            df.dateFormat = "d MMM YYYY"
            dateStr = df.string(from: startDate)
            if Calendar.current.isDateInToday(startDate){
                dateStr = "Today, " + dateStr
            }else
            {
                let day = Calendar.current.component(.weekday, from: startDate)
                let weekdaySymbols = Calendar.current.shortWeekdaySymbols
                let todayDayName = weekdaySymbols[day - 1]
                dateStr = "\(todayDayName), " + dateStr
            }
            
        case .weekly:
            let startWeek = startDate.startOfWeek()
            let endWeek = Calendar.current.date(byAdding: .day, value: -1, to: startWeek.addWeek()) ?? Date()
            
            df.dateFormat = "d MMM YYYY"
            dateStr = df.string(from: startWeek) + " - " + df.string(from: endWeek)
        case .monthly:
            df.dateFormat = "MMMM YYYY"
            dateStr = df.string(from: startDate)
        }
        
        dateDisplay.setTitle(dateStr, for: .normal)
        checkDateButtonEnabling()
    }
    
    func openEntry(jPass: [JournalEvents], index: Int, forceFirstRange: Bool = false){
        JournalEventsManager.sharedInstance.isEdit = true
        JournalEventsManager.sharedInstance.allDayJournals = JournalEventsManager.sharedInstance.setOldEntries(currentJes: jPass)
        let selectedTimeRange = forceFirstRange ? JournalDayEntryNavigationPages(rawValue: index * 6) : JournalEventsManager.sharedInstance.idRange(event: jPass[index])
        //let selectedTimeRange = forceFirstRange ? .night: JournalEventsManager.sharedInstance.idRange(event: jPass[index])
        let storyboard = UIStoryboard(name: "journalNew", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "JournalEntryMainViewController") as! JournalEntryMainViewController
        
        vc.selectedRange = selectedTimeRange ?? .night
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Check that the current date isn't less than date user is allowed to add entries
    func checkSelectedDate(date: Date) {
        if let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date()) {
            if let testDate = Calendar.current.date(byAdding: .day, value: -2, to: oneYearBefore){
                addEntryButton.isEnabled = date > testDate
            }
        }
    }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
        changeDate(progression: -1)
        updateView()
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        changeDate(progression: 1)
        updateView()
    }
    
    @IBAction func addEntry(_ sender: UIButton) {
        let vc = DayNewPickViewController()
        vc.selectedDate = selectedDate
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    //only available for daily
    @IBAction func editEntryTapped(_ sender: UIButton) {
        if !journalsPassing.isEmpty{
            openEntry(jPass: journalsPassing[0], index: 0, forceFirstRange: true)
        }
    }
    
    func checkToShowEdit(){
        if selectedTimeFrame == .daily && !journalsPassing.isEmpty{
            editEntryButton.isHidden = false
            addEntryButton.isHidden = true
        }
        else{
            addEntryButton.isHidden = false
            editEntryButton.isHidden = true
        }
    }
    
    func checkDateButtonEnabling(){
        let startDate = Calendar.current.startOfDay(for: selectedDate)
        switch selectedTimeFrame {
        case .daily:
            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: startDate){
                forwardButton.isEnabled = nextDay <= Date()
            }
        case .weekly:
            let startWeek = startDate.startOfWeek()
            if let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startWeek){
                forwardButton.isEnabled = nextWeek <= Date()
            }
        case .monthly:
            let startMonth = startDate.startOfMonth()
            if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startMonth){
                forwardButton.isEnabled = nextMonth <= Date()
            }
        }
    }
}

extension JournalHomeViewController: DayWeeklyViewDelegate{
    func changedDate(newDate: Date) {
        selectedDate = newDate
        updateEventsManagerDates()
        checkSelectedDate(date: newDate)
    }
    
    func chartChangedFluid() {
        //update all vc
        if _dayViewController != nil{
            dayViewController.fluidView.updateConversionPicker()
            dayViewController.tableView.reloadData()
        }
        if _weeklyViewController != nil{
            weeklyViewController.fluidView.updateConversionPicker()
            weeklyViewController.tableView.reloadData()
        }
        if _monthlyViewController != nil{
            monthlyViewController.fluidLineChartView.updateConversionPicker()
            monthlyViewController.tableView.reloadData()
        }
        
    }
    
    func tappedEvent(jeArr: [JournalEvents], index: Int) {
        if selectedTimeFrame == .weekly{
            openEntry(jPass: jeArr, index: index)
        }
        else{
            openEntry(jPass: jeArr, index: index, forceFirstRange: true)
        }
    }
    
    func swipeTriggered(prog: Int){
        //wonder if can add check here
        let monthDate = monthlyViewController.monthCalendarView.calView.currentPage
        if Calendar.current.isDate(monthDate, equalTo: selectedDate, toGranularity: .month){
            changeDate(progression: prog)
            updateView()
        }
    }
}

extension JournalHomeViewController:GroupedSegmentViewDelegate{
    func changedOption() {
        updateView()
    }
}
