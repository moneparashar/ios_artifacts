//
//  UrinaryLineChartView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/16/23.
//

import UIKit
import Charts

class UrinaryLineChartView: UIView {
    
    var collapse = false
    
    var axisFormatDelegate: AxisValueFormatter?
    
    var journalEvents:[JournalEvents] = []
    var journalCopy:[JournalEvents] = []
    var journalDrinks:[[Int]] = []
    var xAxisText:[String] = []
    
    var activeRestroom = true
    var activeLeaks = true
    var activeUrges = true
    
    var textOffset = 0
    var dayNum = 0
    
    var padding:CGFloat = 16
    
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
    
    var chartView = LineChartView()
    
    var optionStack = UIStackView()
    var coffeeView = UIStackView()
    var waterView = UIStackView()
    var alcoholView = UIStackView()
    
    var restroomButton = UIButton()
    var leaksButton = UIButton()
    var urgesButton = UIButton()
    
    var lineChartAxisColor = UIColor.lineChartGray
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
        titleLabel.font = UIFont.h4
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.textAlignment = .left
        
        titleStack = UIStackView(arrangedSubviews: [collapseArrowButton, titleLabel, spacerView, numberOfEvents])
        titleStack.alignment = .fill
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
        coffeeView = UIStackView(arrangedSubviews: [restroomButton, coffeeKey])
        coffeeView.axis = .vertical
        coffeeView.alignment = .leading
        coffeeView.distribution = .fill
        coffeeView.spacing = 4
        
        leaksButton.setTitle("Leaks", for: .normal)
        let waterKey = UIImageView(image: chartKey)
        waterKey.tintColor = waterColor
        waterView = UIStackView(arrangedSubviews: [leaksButton, waterKey])
        waterView.axis = .vertical
        waterView.alignment = .leading
        waterView.distribution = .fill
        waterView.spacing = 4
        
        urgesButton.setTitle("Urges", for: .normal)
        let alcoholKey = UIImageView(image: chartKey)
        alcoholKey.tintColor = alcoholColor
        alcoholView = UIStackView(arrangedSubviews: [urgesButton, alcoholKey])
        alcoholView.axis = .vertical
        alcoholView.alignment = .leading
        alcoholView.distribution = .fill
        alcoholView.spacing = 4
        
        coffeeView.translatesAutoresizingMaskIntoConstraints = false
        waterView.translatesAutoresizingMaskIntoConstraints = false
        alcoholView.translatesAutoresizingMaskIntoConstraints = false
        coffeeView.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .horizontal)
        waterView.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .horizontal)
        alcoholView.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .horizontal)
        
        optionStack = UIStackView(arrangedSubviews: [coffeeView, waterView, alcoholView])
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
        else if opt == leaksButton{
            activeLeaks = !activeLeaks
            opt.setImage(activeLeaks ? checkedImage: uncheckImage, for: .normal)
        }
        else if opt == urgesButton{
            activeUrges = !activeUrges
            opt.setImage(activeUrges ? checkedImage: uncheckImage, for: .normal)
        }
        setChartData()
    }
    
    func chartConfigure(){
        axisFormatDelegate = self
        
        //disable highlights
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
        
        //disable zooming
        chartView.setScaleEnabled(false)
        chartView.doubleTapToZoomEnabled = false
        chartView.pinchZoomEnabled = false
        
        //gridlines
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        
        chartView.leftAxis.drawGridLinesBehindDataEnabled = true
        chartView.leftAxis.gridLineDashLengths = [4]
        
        //hide right axis and move x axis to bottom
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = UIFont.h6!
        
        //hide legend and description
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        
        //yaxis intervals
        chartView.leftAxis.axisMinimum = 0
        
        //xaxis intervals
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.granularity = 1
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            chartView.xAxis.labelRotationAngle = -90
        }
        
    }
    
    func setChartData(){
        var index = 0
        var emptyArray:[ChartDataEntry] = []
        var ccdeArray:[ChartDataEntry] = []
        var wcdeArray:[ChartDataEntry] = []
        var acdeArray:[ChartDataEntry] = []
        
        for monthDay in 0 ..< dayNum{
            emptyArray.append(ChartDataEntry(x: Double(monthDay), y: 0, data: xAxisText as AnyObject))
        }
        
        for item in journalDrinks{
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
            
            let ccde = ChartDataEntry(x: xVal, y: urges, data: xAxisText as AnyObject?)
            let wcde = ChartDataEntry(x: xVal, y: accidents, data: xAxisText as AnyObject?)
            let acde = ChartDataEntry(x: xVal, y: restroom, data: xAxisText as AnyObject?)
            
            if index == journalDrinks.count{
                //below condition for only add respective value
                if journalEvents.count == 1{
                    if activeRestroom{acdeArray.append(acde) }
                    if activeLeaks{ wcdeArray.append(wcde) }
                    if activeUrges{ ccdeArray.append(ccde) }
                }
            }else
            {
                if journalEvents.count == 1{
                    if urges != 0{
                        if activeUrges{ ccdeArray.append(ccde) }
                    }
                    if accidents != 0{
                        if activeLeaks{ wcdeArray.append(wcde) }
                    }
                    if restroom != 0{
                        if activeRestroom{ acdeArray.append(acde) }
                    }
                } else {
                    if activeRestroom{acdeArray.append(acde)}
                    if activeLeaks{ wcdeArray.append(wcde)}
                    if activeUrges{ ccdeArray.append(ccde)}
                }
            }
            index += 1
        } //!for
        
        let eset = LineChartDataSet(entries: emptyArray)
        let cset = LineChartDataSet(entries: ccdeArray)
        let wset = LineChartDataSet(entries: wcdeArray)
        let aset = LineChartDataSet(entries: acdeArray)
        
        //colors
        eset.colors = [lineChartAxisColor!]
        cset.colors = [alcoholColor!]
        wset.colors = [waterColor!]
        aset.colors = [coffeeColor!]
        
        let allSets = [eset, cset, wset, aset]
        if journalEvents.count == 1 { // dots
            for drinkSet in allSets{
                drinkSet.drawValuesEnabled = false
                drinkSet.drawCirclesEnabled = true
                drinkSet.drawCircleHoleEnabled = false
                
                eset.drawCirclesEnabled = false
            }
            
        } else {
            for drinkSet in allSets{
                drinkSet.drawValuesEnabled = false
                drinkSet.drawCirclesEnabled = false
                
                drinkSet.lineWidth = 2
                if drinkSet == aset {
                    drinkSet.lineDashLengths = [2]
                }
                if drinkSet == eset {
                    drinkSet.lineWidth = 2.5
                }
            }
        }

        if journalEvents.count == 1
        {
            wset.circleColors = [waterColor!, waterColor!, waterColor!]
            aset.circleColors = [coffeeColor!, coffeeColor!, coffeeColor!]
            cset.circleColors = [alcoholColor!, alcoholColor!, alcoholColor!]
            eset.circleColors = [lineChartAxisColor!, lineChartAxisColor!, lineChartAxisColor!, lineChartAxisColor!]
        }
        
        let data = LineChartData(dataSets: [eset, cset, eset, wset, eset, aset, eset])
        chartView.xAxisRenderer =
        XAxisRenderer(viewPortHandler: chartView.viewPortHandler, axis: chartView.xAxis, transformer: chartView.getTransformer(forAxis: YAxis.AxisDependency.left))
        chartView.data = data
        chartView.xAxis.valueFormatter = axisFormatDelegate
        
        if data.yMax > 0{
            chartView.leftAxis.axisMaximum = data.yMax
            
            chartView.xAxis.setLabelCount(dayNum, force: true)
        }
        
        
        chartView.setNeedsDisplay()
    }
    
    func getSections(){
        var totalStartWeek = 4
        if journalEvents.count != 0{
            if let firstTime = journalEvents.first?.eventTimestamp{
                let firstTimeTmstmp = firstTime.treatTimestampStrAsDate() ?? Date()
                dayNum = Calendar.current.range(of: .day, in: .month, for: firstTimeTmstmp)?.count ?? 0
                let startOfMonth = firstTimeTmstmp.startOfMonth()
                let startDayNum = Calendar.current.component(.weekday, from: startOfMonth)
                
                textOffset = startDayNum != 7 ? startDayNum - 1 : -1
                
                if dayNum == 29 && startDayNum == 1{
                    totalStartWeek = 5
                }
                //30 days, 1st & 2nd day occur 5 times
                else if dayNum == 30 && (startDayNum == 1 || startDayNum == 7){
                    totalStartWeek = 5
                }
                //31 days 1st - 3rd day occur 5 times
                else if dayNum == 31 && (startDayNum == 1 || startDayNum >= 6){
                    totalStartWeek = 5
                }
                
                var weekSection = startDayNum == 1 ? startOfMonth :  Calendar.current.date(byAdding: .day, value: (1 - startDayNum + 7), to: startOfMonth) ?? Date()
                for _ in 1 ... totalStartWeek{
                    getSectionDay(date: weekSection)
                    weekSection = Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: weekSection) ?? Date()
                }
            }
        }
    }
    
    func convertJournals(){
        journalCopy = []
        var listIndex = 0
        var prevDate:Date?
        for item in journalEvents{
            let tmstmp = item.eventTimestamp.treatTimestampStrAsDate() ?? Date()
            if prevDate == nil{
                let temp = JournalEvents()
                temp.restroomUrges = item.restroomUrges
                temp.restroomDrops = item.restroomDrops
                temp.accidentsDrops = item.accidentsDrops
                temp.accidentsUrges = item.accidentsUrges
                temp.eventTimestamp = item.eventTimestamp
                journalCopy.append(temp)
                prevDate = tmstmp
            }
            else{
                let sameDay = Calendar.current.isDate(prevDate!, inSameDayAs: tmstmp)
                if sameDay{
                    journalCopy.last!.restroomUrges = (journalCopy.last!.restroomUrges ?? 0) + item.restroomUrges!
                    journalCopy.last!.restroomDrops = (journalCopy.last!.restroomDrops ?? 0) + item.restroomDrops!
                    journalCopy.last!.accidentsDrops = (journalCopy.last!.accidentsDrops ?? 0) + item.accidentsDrops!
                    journalCopy.last!.accidentsUrges = (journalCopy.last!.accidentsUrges ?? 0) + item.accidentsUrges!
                }
                else{
                    let temp = JournalEvents()
                    temp.restroomUrges = item.restroomUrges
                    temp.restroomDrops = item.restroomDrops
                    temp.accidentsDrops = item.accidentsDrops
                    temp.accidentsUrges = item.accidentsUrges
                    temp.eventTimestamp = item.eventTimestamp
                    journalCopy.append(temp)
                }
                prevDate = tmstmp
            }
            listIndex += 1
        }
    }
    
    func getJournalList(){
        journalDrinks = []
        xAxisText = []
        
        getSections()
        convertJournals()
        
        var lastDay = 0
        //find last journal entry day
        if let lastEntry = journalCopy.last{
            let tstmp = lastEntry.eventTimestamp.treatTimestampStrAsDate() ?? Date()
            lastDay = Calendar.current.component(.day, from: tstmp)
            journalDrinks = Array.init(repeating: [0, 0, 0], count: lastDay+1)
        }
        
        var todayDay = 0
        if !journalCopy.isEmpty{
            let tstmp = journalCopy.first!.eventTimestamp.treatTimestampStrAsDate() ?? Date()
            if Calendar.current.isDate(tstmp, equalTo: Date(), toGranularity: .month){
                todayDay = Calendar.current.component(.day, from: Date())
            }
        }
       
        var index = 0
        for _ in journalDrinks{
            var journalCopyIndex = 0
            var match = false
            for day in journalCopy{
                if !journalCopy[journalCopyIndex].dirty{
                    let tmstmp = day.eventTimestamp.treatTimestampStrAsDate() ?? Date()
                    let dayIndex = Calendar.current.component(.day, from: tmstmp)
                    if (dayIndex) == index{
                        let urges = journalDrinks[index][0] + day.restroomUrges! + day.accidentsUrges!
                        let restroom = journalDrinks[index][1] + day.restroomDrops!
                        let accidents = journalDrinks[index][2] + day.accidentsDrops!
                        journalDrinks[index] = [urges, restroom, accidents]
                        journalCopy[journalCopyIndex].dirty = true
                        match = true
                        break
                    }
                }
                journalCopyIndex += 1
            }
            if !match{
                if index != 0{
                    if todayDay == 0{
                        let lastTmp = journalDrinks[index]
                        journalDrinks[index] = lastTmp
                    }
                    else if index <= todayDay - 1{
                        let lastTmp = journalDrinks[index]
                        journalDrinks[index] = lastTmp
                    }
                }
            }
            index += 1
        }
        
    }
    
    func getSectionDay(date: Date){
        let dateFormatter = DateFormatter()
        var labelStr = ""
        
        dateFormatter.dateFormat = "MMM d"
        labelStr = dateFormatter.string(from: date)
        
        xAxisText.append(labelStr)
    }
    
    @objc func didTapHeaderArrow(){
        collapse = !collapse
        
        collapseArrowButton.image = self.collapse ? self.downImage : self.upImage

        self.outerStack.arrangedSubviews[1].isHidden = self.collapse
        self.outerStack.arrangedSubviews[2].isHidden = self.collapse
    }

}
extension UrinaryLineChartView: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value >= 0{
            let currentVal = Int(value)
            if (currentVal + textOffset) % 7 == 0{
                let index = textOffset > 0 ? ((currentVal + textOffset) / 7) - 1 : ((currentVal + textOffset) / 7)
                if index <= xAxisText.count - 1{
                    return xAxisText[index]
                }
            }
        }
        return ""
    }
}
