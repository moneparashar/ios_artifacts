//
//  FluidLineChartView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/16/23.
//

import UIKit
import Charts
import DropDown

protocol FluidLineChartViewDelegate{
    func switchedFluidUnitViaChart()
}

class FluidLineChartView: UIView {

    var collapse = false
    
    var axisFormatDelegate: AxisValueFormatter?
    
    var journalEvents:[JournalEvents] = []
    var journalCopy:[JournalEvents] = []
    var journalDrinks:[[Double]] = []
    var xAxisText:[String] = []
    var sectionDates:[Date] = []
    
    var activeCoffee = true
    var activeWater = true
    var activeAlcohol = true
    
    var padding:CGFloat = 16
    
    var selectedUnit: FluidUnits = .ounces
    var pickerValues:[String] = []
    var delegate:FluidLineChartViewDelegate?
    
    var dropDown = DropDown()
    var openDropdown = false
    
    //UI
    var outerStack = UIStackView()
    var titleStack = UIStackView()
    var collapseArrowButton = UIImageView()
    var titleLabel = UILabel()
    
    var conversionStack = UIStackView()
    var convertUnitLabel = UILabel()
    var convertDropdownButton = UIImageView()
    
    var chartView = LineChartView()

    var optionStack = UIStackView()
    var coffeeView = UIStackView()
    var waterView = UIStackView()
    var alcoholView = UIStackView()
    
    var coffeeButton = UIButton()
    var waterButton = UIButton()
    var alcoholButton = UIButton()
    
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
        
        collapseArrowButton.image = UIImage(named: "UpChevron")
        
        titleLabel.text = "Fluid intake history"
        titleLabel.font = UIFont.h4
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.textAlignment = .left
        
        convertUnitLabel.textColor = UIColor.fontBlue
        convertUnitLabel.textAlignment = .right
        convertUnitLabel.font = UIFont.bodyMed
        
        convertDropdownButton.image = downImage
        conversionStack = UIStackView(arrangedSubviews: [convertUnitLabel, convertDropdownButton])
        conversionStack.alignment = .top
        conversionStack.distribution = .fill
        conversionStack.spacing = 3
        conversionStack.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .horizontal)
        conversionStack.arrangedSubviews[1].setContentCompressionResistancePriority(.required, for: .horizontal)
        conversionStack.arrangedSubviews[0].setContentHuggingPriority(.required, for: .horizontal)
        conversionStack.arrangedSubviews[1].setContentHuggingPriority(.required, for: .horizontal)
        
        titleStack = UIStackView(arrangedSubviews: [collapseArrowButton, titleLabel, conversionStack])
        titleStack.alignment = .top
        titleStack.distribution = .fill
        titleStack.spacing = 8
        titleStack.arrangedSubviews[1].setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        titleStack.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .horizontal)
        titleStack.arrangedSubviews[0].setContentHuggingPriority(.required, for: .horizontal)
        titleStack.arrangedSubviews[2].setContentHuggingPriority(.required, for: .horizontal)
        
        let collapseTap = UITapGestureRecognizer(target: self, action: #selector(didTapHeaderArrow))
        titleStack.addGestureRecognizer(collapseTap)
        
        //chart
        chartConfigure()
        //options
        setButtons()
        
        coffeeButton.setTitle("Coffee", for: .normal)
        let coffeeKey = UIImageView(image: chartKey)
        coffeeKey.tintColor = coffeeColor
        coffeeView = UIStackView(arrangedSubviews: [coffeeButton, coffeeKey])
        coffeeView.axis = .vertical
        coffeeView.alignment = .leading
        coffeeView.distribution = .fill
        coffeeView.spacing = 4
        
        waterButton.setTitle("Water", for: .normal)
        let waterKey = UIImageView(image: chartKey)
        waterKey.tintColor = waterColor
        waterView = UIStackView(arrangedSubviews: [waterButton, waterKey])
        waterView.axis = .vertical
        waterView.alignment = .leading
        waterView.distribution = .fill
        waterView.spacing = 4
        
        alcoholButton.setTitle("Alcohol", for: .normal)
        let alcoholKey = UIImageView(image: chartKey)
        alcoholKey.tintColor = alcoholColor
        alcoholView = UIStackView(arrangedSubviews: [alcoholButton, alcoholKey])
        alcoholView.axis = .vertical
        alcoholView.alignment = .leading
        alcoholView.distribution = .fill
        alcoholView.spacing = 4
        
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
     
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            outerStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            outerStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            outerStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            outerStack.arrangedSubviews[1].heightAnchor.constraint(equalToConstant: 211)
        ])
        
        dropDown.anchorView = conversionStack
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        conversionStack.addGestureRecognizer(tap)
        
        setupDropdown()
    }
    
    func setupDropdown(){
        for fluidUn in FluidUnits.allCases{
            pickerValues.append(fluidUn.getStr())
        }
        dropDown.dataSource = pickerValues
        dropDown.cancelAction = { [unowned self] in
            openDropdown = false
        }
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String)in
            openDropdown = false
            convertUnitLabel.text = item
            
            selectedUnit = FluidUnits(rawValue: index + 1) ?? .ounces
            if selectedUnit != ConversionManager.sharedInstance.fluidUnit{
                ConversionManager.sharedInstance.fluidUnit = selectedUnit
                ConversionManager.sharedInstance.saveFluidUnit()
                delegate?.switchedFluidUnitViaChart()
            }
        }
        
        
        convertUnitLabel.text = selectedUnit.getStr()
    }
    
    @objc func handleTap(){
        openDropdown = !openDropdown
        if openDropdown{
            dropDown.bottomOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
            dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
            dropDown.show()
        }
        else{
            dropDown.hide()
        }
    }
    
    func updateConversionPicker(){
        selectedUnit = ConversionManager.sharedInstance.fluidUnit
        var ind = 0
        for fluidUn in FluidUnits.allCases{
            if fluidUn == selectedUnit{
                break
            }
            ind += 1
        }
        
        dropDown.selectRow(at: ind)
        convertUnitLabel.text = dropDown.selectedItem
        
        getJournalList()
        setChartData()
    }
    
    func setButtons(){
        let allButtons = [coffeeButton, waterButton, alcoholButton]
        for b in allButtons{
            b.setTitleColor(UIColor.regalBlue, for: .normal)
            b.setImage(checkedImage, for: .normal)
            b.addTarget(self, action: #selector(tappedOption(opt:)), for: .touchDown)
        }
    }
    
    @objc func tappedOption(opt: UIButton){
        if opt == coffeeButton{
            activeCoffee = !activeCoffee
            opt.setImage(activeCoffee ? checkedImage : uncheckImage, for: .normal)
        }
        else if opt == waterButton{
            activeWater = !activeWater
            opt.setImage(activeWater ? checkedImage: uncheckImage, for: .normal)
        }
        else if opt == alcoholButton{
            activeAlcohol = !activeAlcohol
            opt.setImage(activeAlcohol ? checkedImage: uncheckImage, for: .normal)
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
        //chartView.leftAxis.axisMaximum = 16.0
        chartView.leftAxis.axisMinimum = 0
        //chartView.leftAxis.granularity = 4.0
        
        //xaxis intervals
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.granularity = 1 //double check this as well
        
        //chartView.xAxis.avoidFirstLastClippingEnabled = true
        if UIDevice.current.userInterfaceIdiom == .phone{
                    chartView.xAxis.labelRotationAngle = -90
                }
        
    }
    
    func setChartData(){
        var  index = 0
        var emptyArray:[ChartDataEntry] = []
        var ccdeArray:[ChartDataEntry] = []
        var wcdeArray:[ChartDataEntry] = []
        var acdeArray:[ChartDataEntry] = []
        
        for monthDay in 0 ..< dayNum{
            emptyArray.append(ChartDataEntry(x: Double(monthDay), y: 0, data: xAxisText as AnyObject))
        }
        
        for item in journalDrinks{
            let xVal = Double(index)
            var coffee = 0.0
            var water = 0.0
            var alcohol = 0.0
            
            if activeCoffee{
                coffee = Double(item[0])
            }
            if activeWater{
                water = Double(item[1])
            }
            if activeAlcohol{
                alcohol = Double(item[2])
            }
            
            let ccde = ChartDataEntry(x: xVal, y: coffee, data: xAxisText as AnyObject?)
            let wcde = ChartDataEntry(x: xVal, y: water, data: xAxisText as AnyObject?)
            let acde = ChartDataEntry(x: xVal, y: alcohol, data: xAxisText as AnyObject?)
            
            if index == journalDrinks.count {
                //below condition for only add respective value
                if journalEvents.count == 1{
                    if activeCoffee{acdeArray.append(ccde)}
                    if activeWater{ wcdeArray.append(wcde)}
                    if activeAlcohol{ ccdeArray.append(acde)}
                }
            }else
            {
                if journalEvents.count == 1{
                    if coffee != 0{
                        if activeCoffee{acdeArray.append(ccde)}
                    }
                    if water != 0{
                        if activeWater{ wcdeArray.append(wcde)}
                    }
                    if alcohol != 0{
                        if activeAlcohol{ ccdeArray.append(acde)}
                    }
                } else {
                    if activeCoffee{acdeArray.append(ccde)}
                    if activeWater{ wcdeArray.append(wcde)}
                    if activeAlcohol{ ccdeArray.append(acde)}
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
                    drinkSet.lineWidth = 2.1
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
    
    func convertJournals(){
        journalCopy = []
        var listIndex = 0
        var prevDate:Date?
        for item in journalEvents{
            let jTmstmp = item.eventTimestamp.treatTimestampStrAsDate() ?? Date()
            if prevDate == nil{
                let temp = JournalEvents()
                temp.drinksWaterOther = item.drinksWaterOther
                temp.drinksCaffeinated = item.drinksCaffeinated
                temp.drinksAlcohol = item.drinksAlcohol
                temp.eventTimestamp = item.eventTimestamp
                journalCopy.append(temp)
                prevDate = jTmstmp
            }
            else{
                let sameDay = Calendar.current.isDate(prevDate!, inSameDayAs: jTmstmp)
                if sameDay{
                    journalCopy.last!.drinksWaterOther = (journalCopy.last!.drinksWaterOther ?? 0) + item.drinksWaterOther!
                    journalCopy.last!.drinksCaffeinated = (journalCopy.last!.drinksCaffeinated ?? 0) + item.drinksCaffeinated!
                    journalCopy.last!.drinksAlcohol = (journalCopy.last!.drinksAlcohol ?? 0) + item.drinksAlcohol!
                }
                else{
                    let temp = JournalEvents()
                    temp.drinksWaterOther = item.drinksWaterOther
                    temp.drinksCaffeinated = item.drinksCaffeinated
                    temp.drinksAlcohol = item.drinksAlcohol
                    temp.eventTimestamp = item.eventTimestamp
                    journalCopy.append(temp)
                }
                prevDate = jTmstmp
            }
            listIndex += 1
        }
        
        //actual conversion
        //Change value to double for accept decimal value
        ConversionManager.sharedInstance.loadFluidUnit()
        listIndex = 0
        for item in journalCopy{
            switch ConversionManager.sharedInstance.fluidUnit{
            case .ounces:
                journalCopy[listIndex].drinksWaterOther = Double(ConversionManager.sharedInstance.getOunces(milli: item.drinksWaterOther ?? 0.0))
                journalCopy[listIndex].drinksCaffeinated = Double(ConversionManager.sharedInstance.getOunces(milli: item.drinksCaffeinated ?? 0.0))
                journalCopy[listIndex].drinksAlcohol = Double(ConversionManager.sharedInstance.getOunces(milli: item.drinksAlcohol ?? 0.0))
            case .cups:
                journalCopy[listIndex].drinksWaterOther = Double(ConversionManager.sharedInstance.getCups(milli: item.drinksWaterOther ?? 0.0))
                journalCopy[listIndex].drinksCaffeinated = Double(ConversionManager.sharedInstance.getCups(milli: item.drinksCaffeinated ?? 0.0))
                journalCopy[listIndex].drinksAlcohol = Double(ConversionManager.sharedInstance.getCups(milli: item.drinksAlcohol ?? 0.0))
            case .milliliters:
                continue
            }
            listIndex += 1
        }
    }
    
    func getSections(){
        var totalStartWeek = 4
        if journalEvents.count != 0{
            if let firstTime = journalEvents.first?.eventTimestamp.treatTimestampStrAsDate(){
                dayNum = Calendar.current.range(of: .day, in: .month, for: firstTime)?.count ?? 0
                let startOfMonth = firstTime.startOfMonth()
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
                    sectionDates.append(weekSection)
                    weekSection = Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: weekSection) ?? Date()
                }
            }
        }
    }
    
    var textOffset = 0
    var dayNum = 0
    
    //due to charts setup have to set journalDrinks to every value in month
    func getJournalList(){
        journalDrinks = []
        xAxisText = []
        sectionDates = []
        
        getSections()
        convertJournals()
        
        var lastDay = 0
        //find last journal entry day
        if let lastEntry = journalCopy.last{
            let lastTmstmp = lastEntry.eventTimestamp.treatTimestampStrAsDate() ?? Date()
            lastDay = Calendar.current.component(.day, from: lastTmstmp)
            journalDrinks = Array.init(repeating: [0, 0, 0], count: lastDay+1)
        }
        
        var todayDay = 0
        if !journalCopy.isEmpty{
            let jCopyTmstmp = journalCopy.first?.eventTimestamp.treatTimestampStrAsDate() ?? Date()
            if Calendar.current.isDate(jCopyTmstmp, equalTo: Date(), toGranularity: .month){
                todayDay = Calendar.current.component(.day, from: Date())
            }
        }
        
        var index = 0
        for _ in journalDrinks{
            var journalCopyIndex = 0
            var match = false
            for day in journalCopy{
                let dayTmstmp = day.eventTimestamp.treatTimestampStrAsDate() ?? Date()
                if !journalCopy[journalCopyIndex].dirty{
                    let dayIndex = Calendar.current.component(.day, from: dayTmstmp)
                    if (dayIndex) == index{
                        let drinks = Double(journalDrinks[index][1]) + day.drinksWaterOther!
                        let caffeinated = Double(journalDrinks[index][0]) + day.drinksCaffeinated!
                        let alcohol = Double(journalDrinks[index][2]) + day.drinksAlcohol!
                        journalDrinks[index] = [caffeinated, drinks, alcohol]
                        
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
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        var labelStr = ""
        
        dateFormatter.dateFormat = "MMM d"
        labelStr = dateFormatter.string(from: date)
        
        xAxisText.append(labelStr)
    }
    
    @objc func didTapHeaderArrow(){
        collapse = !collapse
        collapseArrowButton.image = self.collapse ? self.downImage : self.upImage
        
        // old implem.
        // conversionStack.isHidden = collapse
        
        self.outerStack.arrangedSubviews[1].isHidden = self.collapse
        self.outerStack.arrangedSubviews[2].isHidden = self.collapse
    }
}

extension FluidLineChartView: AxisValueFormatter{
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
