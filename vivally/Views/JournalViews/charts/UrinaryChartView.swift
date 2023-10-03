//
//  UrinaryChartView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/4/23.
//

import UIKit
import Charts

class UrinaryChartView: UIView {

    var collapse = false
    
    var timeRange:JournalTimeRanges = .daily
    
    var axisFormatDelegate: AxisValueFormatter?
    
    var journalEvents:[JournalEvents] = []
    var journalCopy:[JournalEvents] = []
    var journalUrinary:[[Int]] = []
    var xAxisText:[String] = []
    
    var activeRestroom = true
    var activeLeaks = true
    var activeUrges = true
    
    var padding: CGFloat = 16
    
    //UI
    var outerStack = UIStackView()
    
    var titleStack = UIStackView()
    var collapseArrowButton = UIImageView()
    var titleLabel = UILabel()
    
    private lazy var numberOfEvents: UILabel = {
        let numberOfEvents = UILabel()
        
        numberOfEvents.text = "# of events"
        numberOfEvents.numberOfLines = 0
        numberOfEvents.font = UIFont.bodyMed
        numberOfEvents.textColor = UIColor.fontBlue
        
        return numberOfEvents
    }()
    
    var spacerWidth: CGFloat = 1 // stack will auto adjust width
    private lazy var spacerView: UIView = {
        let spacerView = UIView()
        spacerView.frame = CGRect(x: 0, y: 0, width: spacerWidth, height: 0)
        
        return spacerView
    }()
    
    var chartView = BarChartView()
    
    var optionStack = UIStackView()
    var restroomView = UIStackView()
    var leaksView = UIStackView()
    var urgesView = UIStackView()
    
    var restroomButton = UIButton()
    var leaksButton = UIButton()
    var urgesButton = UIButton()
    
    var coffeeColor = UIColor.wedgewoodBlue
    var waterColor = UIColor.lavendarMist
    var alcoholColor = UIColor.macCheese
    
    let chartKey = UIImage(named: "chartKey")?.withRenderingMode(.alwaysTemplate)
    
    var uncheckImage = UIImage(named: "emptyCheckbox") ?? UIImage()
    var checkedImage = UIImage(named: "filledCheckbox") ?? UIImage()
    
    var downImage = UIImage(named: "DownChevron")
    var upImage = UIImage(named: "UpChevron")
     
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        didTapHeaderArrow()
    }
    
    required init(){
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure(){
        setupUI()
    }
    
    func setup(){
        getJournalList()
        setChartData()
    }
    
    private func setupUI(){
        layer.borderColor = UIColor.casperBlue?.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 15
        layer.backgroundColor = UIColor.white.cgColor
        
        collapseArrowButton.image = upImage
        
        titleLabel.text = "Urinary history"
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.h4
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.textAlignment = .left
        
        titleStack = UIStackView(arrangedSubviews: [collapseArrowButton, titleLabel, spacerView, numberOfEvents])
        titleStack.alignment = .top
        titleStack.distribution = .fill
        titleStack.spacing = 8
        titleStack.arrangedSubviews[0].setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        
        let collapseTap = UITapGestureRecognizer(target: self, action: #selector(didTapHeaderArrow))
        titleStack.addGestureRecognizer(collapseTap)
        
        //chart
        chartConfigure()
        //options
        setButtons()
        
        restroomButton.setTitle("Voids", for: .normal)
        let coffeeKey = UIImageView(image: chartKey)
        coffeeKey.tintColor = coffeeColor
        restroomView = UIStackView(arrangedSubviews: [restroomButton, coffeeKey])
        restroomView.axis = .vertical
        restroomView.alignment = .leading
        restroomView.distribution = .fill
        restroomView.spacing = 4
        
        leaksButton.setTitle("Leaks", for: .normal)
        let waterKey = UIImageView(image: chartKey)
        waterKey.tintColor = waterColor
        leaksView = UIStackView(arrangedSubviews: [leaksButton, waterKey])
        leaksView.axis = .vertical
        leaksView.alignment = .leading
        leaksView.distribution = .fill
        leaksView.spacing = 4
        
        urgesButton.setTitle("Urges", for: .normal)
        let alcoholKey = UIImageView(image: chartKey)
        alcoholKey.tintColor = alcoholColor
        urgesView = UIStackView(arrangedSubviews: [urgesButton, alcoholKey])
        urgesView.axis = .vertical
        urgesView.alignment = .leading
        urgesView.distribution = .fill
        urgesView.spacing = 4
        
        restroomView.translatesAutoresizingMaskIntoConstraints = false
        leaksView.translatesAutoresizingMaskIntoConstraints = false
        urgesView.translatesAutoresizingMaskIntoConstraints = false
        restroomView.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .horizontal)
        leaksView.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .horizontal)
        urgesView.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .horizontal)
        
        optionStack = UIStackView(arrangedSubviews: [restroomView, leaksView, urgesView])
        optionStack.alignment = .fill
        optionStack.distribution = .equalSpacing
        
        outerStack = UIStackView(arrangedSubviews: [titleStack, chartView, optionStack])
        outerStack.axis = .vertical
        outerStack.alignment = .fill
        outerStack.distribution = .fill
        outerStack.spacing = 8
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(outerStack)
     
        let paddingConstraint = outerStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding)
        paddingConstraint.priority = UILayoutPriority(rawValue: 999)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            outerStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            paddingConstraint,
            outerStack.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            outerStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            outerStack.arrangedSubviews[1].heightAnchor.constraint(equalToConstant: 211)
        ])
    }
    
    func setButtons(){
        let allButtons = [restroomButton, leaksButton, urgesButton]
        for b in allButtons{
            b.setTitleColor(UIColor.regalBlue, for: .normal)
            b.setImage(checkedImage, for: .normal)
            b.addTarget(self, action: #selector(tappedOption(opt:)), for: .touchDown)
        }
    }
    
    @objc func tappedOption(opt: UIButton){
        if opt == restroomButton{
            activeRestroom = !activeRestroom
            opt.setImage(activeRestroom ? checkedImage : uncheckImage, for: .normal)
        }
        else if opt == urgesButton{
            activeUrges = !activeUrges
            opt.setImage(activeUrges ? checkedImage: uncheckImage, for: .normal)
        }
        else if opt == leaksButton{
            activeLeaks = !activeLeaks
            opt.setImage(activeLeaks ? checkedImage: uncheckImage, for: .normal)
        }
        setChartData()
    }
    
    func chartConfigure(){
        axisFormatDelegate = self
        
        //chartView
        chartView.maxVisibleCount = timeRange == .daily ? 4 : 7
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        
        //disable highlights
        chartView.highlightPerDragEnabled = false
        chartView.highlightPerTapEnabled = false
        
        //disable zooming
        chartView.setScaleEnabled(false)
        chartView.doubleTapToZoomEnabled = false
        chartView.pinchZoomEnabled = false
        
        //hide grid lines
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.gridLineDashLengths = [4]
        
        //hide right axis and move x axis to bottom
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        
        //hide legend and description
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        
        //yaxis intervals
        chartView.leftAxis.axisMinimum = 0

        
        //xaxis intervals
        chartView.xAxis.granularity = 1.0
    }
    
    func setChartData(){
        var index = 0
        var bcdeArray:[BarChartDataEntry] = []
        
        for item in journalUrinary{
            let xVal = Double(index)
            var urges = 0.0
            var restroom = 0.0
            var accidents = 0.0
            
            if activeRestroom{
                restroom = Double(item[1])
            }
            if activeLeaks{
                accidents = Double(item[2])
            }
            if activeUrges{
                urges = Double(item[0])
            }
            
            let bcde = BarChartDataEntry(x: xVal, yValues: [urges, accidents, restroom], data: xAxisText as AnyObject?)
            
            bcdeArray.append(bcde)
            index += 1
        }
        
        let set = BarChartDataSet(entries: bcdeArray)
        
        set.drawIconsEnabled = false
        set.colors = [alcoholColor!, waterColor!, coffeeColor!]
        set.drawValuesEnabled = false
        
        let data = BarChartData(dataSet: set)
        
        data.barWidth = 0.3
        chartView.leftAxis.axisMaximum = data.yMax
        
        //allows xaxis to have 2 lines
        chartView.xAxisRenderer =
        XAxisRenderer(viewPortHandler: chartView.viewPortHandler, axis: chartView.xAxis, transformer: chartView.getTransformer(forAxis: YAxis.AxisDependency.left))
        
        //x axis label
        chartView.data = data
        chartView.xAxis.valueFormatter = axisFormatDelegate
        
        if data.yMax > 0{
            chartView.leftAxis.axisMaximum = data.yMax
            
            chartView.leftAxis.forceLabelsEnabled = true
            chartView.leftAxis.labelCount = 5
        }
        
        chartView.setNeedsDisplay()
    }
    
    func getJournalList(){
        journalUrinary = []
        xAxisText = []
        
        if timeRange == .daily{
            xAxisText = ["Night \n 12am - 6am","Morning \n 6am - 12pm","Afternoon \n 12pm - 6pm","Evening \n 6pm - 12am"]
            for navRange in JournalDayEntryNavigationPages.allCases{
                var match = false
                var temp:[Int] = [0,0,0]
                for item in journalEvents{
                    let tmpstmp = item.eventTimestamp.treatTimestampStrAsDate() ?? Date()
                    let hour = Calendar.current.component(.hour, from: tmpstmp)
                    if navRange.insideRange(hour: hour){
                    //if JournalEventsManager.sharedInstance.idRange(event: item) == navRange{
                        if JournalRangesManager.sharedInstance.checkForRestroomLeaksAndUrges(je: item){
                            match = true
                            temp = [item.restroomUrges! + item.accidentsUrges!,
                                          item.restroomDrops!,
                                          item.accidentsDrops!]
                            getSectionDay(date: tmpstmp)
                        }
                        break
                    }
                }
                if !match{
                    xAxisText.append(navRange.getStr())
                }
                journalUrinary.append(temp)
            }
        }
        else{
            xAxisText = ["S", "M", "T", "W", "T", "F", "S"]
            for _ in xAxisText{
                journalUrinary.append([0 ,0, 0])
            }
            
            let startDate = journalEvents.first?.eventTimestamp.treatTimestampStrAsDate() ?? Date()
            let startWeekDate = startDate.startOfWeek()
            var dayOfWeek = startWeekDate
            var axisIndex = 0
            for _ in xAxisText{
                let dayVal = Calendar.current.component(.day, from: dayOfWeek)
                xAxisText[axisIndex] = xAxisText[axisIndex] + "\n" + (String(dayVal))
                dayOfWeek = Calendar.current.date(byAdding: .day, value: 1, to: dayOfWeek) ?? Date()
                axisIndex += 1
            }
            
            for weekdayJournalUnit in 1 ... 7{
                for item in journalEvents{
                    let itmstmp = item.eventTimestamp.treatTimestampStrAsDate() ?? Date()
                    if weekdayJournalUnit == Calendar.current.component(.weekday, from: itmstmp){
                        if JournalRangesManager.sharedInstance.checkForRestroomLeaksAndUrges(je: item){
                            let urges = journalUrinary[weekdayJournalUnit - 1][0] + item.restroomUrges! + item.accidentsUrges!
                            let restroom = journalUrinary[weekdayJournalUnit - 1][1] + item.restroomDrops!
                            let accidents = journalUrinary[weekdayJournalUnit - 1][2] + item.accidentsDrops!
                            journalUrinary[weekdayJournalUnit - 1] = [urges, restroom, accidents]
                        }
                    }
                }
            }
        }
    }
    
    
    func getSectionDay(date: Date){
        let dateFormatter = DateFormatter()
        var labelStr = ""
        
        if timeRange == .daily{
            labelStr = getDailyTextStr(d: date)
        }
        else if timeRange == .weekly{
            dateFormatter.dateFormat = "EEEEE\nd"
            labelStr = dateFormatter.string(from: date)
        }
        else if timeRange == .monthly{
            dateFormatter.dateFormat = "MMM d"
            labelStr = dateFormatter.string(from: date)
        }
        
        xAxisText.append(labelStr)
    }
    
    func getDailyTextStr(d: Date) -> String{
        //if let utc = TimeZone(identifier: "UTC"){
            var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
            let hour = cal.component(.hour, from: d)
            switch hour{
            case 6 ... 11: return "Morning"
            case 12 ... 17: return "Afternoon"
            case 18 ... 23: return "Evening"
            case 0 ... 5: return "Night"
            default: return ""
            }
        //}
        //return ""
    }
    
    @objc func didTapHeaderArrow(){
        collapse = !collapse
        collapseArrowButton.image = self.collapse ? self.downImage : self.upImage
        
        self.outerStack.arrangedSubviews[1].isHidden = self.collapse
        self.outerStack.arrangedSubviews[2].isHidden = self.collapse
    }
}
extension UrinaryChartView: AxisValueFormatter{
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value >= 0 && Int(value) < xAxisText.count{
            return xAxisText[Int(value)]
        }
        return ""
    }
}
