//
//  FluidChartView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/3/23.
//

import UIKit
import Charts
import DropDown

protocol FluidChartViewDelegate{
    func switchedFluidUnit()
}

class FluidChartView: UIView {

    var collapse = false
    var timeRange:JournalTimeRanges = .daily
    
    var axisFormatDelegate: AxisValueFormatter?
    
    var journalEvents:[JournalEvents] = []
    var journalCopy:[JournalEvents] = []
    var journalDrinks:[[Double]] = []
    var xAxisText:[String] = []
    
    var activeCoffee = true
    var activeWater = true
    var activeAlcohol = true
    
    var selectedUnit: FluidUnits = .ounces
    var pickerValues:[String] = []
    var delegate:FluidChartViewDelegate?
    
    var dropDown = DropDown()
    var openDropdown = false
    
    var padding: CGFloat = 16
    
    //UI
    var outerStack = UIStackView()
    
    var titleStack = UIStackView()
    var collapseArrowButton = UIImageView()
    var titleLabel = UILabel()
    
    var conversionStack = UIStackView()
    var convertUnitLabel = UILabel()
    var convertDropdownButton = UIImageView()
    
    var chartView = BarChartView()
    
    var optionStack = UIStackView()
    var coffeeView = UIStackView()
    var waterView = UIStackView()
    var alcoholView = UIStackView()
    
    var coffeeButton = UIButton()
    var waterButton = UIButton()
    var alcoholButton = UIButton()
    
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
        ConversionManager.sharedInstance.loadFluidUnit()
        selectedUnit = ConversionManager.sharedInstance.fluidUnit
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
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.h4
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
                delegate?.switchedFluidUnit()
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
        
        chartView.xAxis.wordWrapEnabled = true  //new attempt to get dates to appear under weekday title
        
        //hide legend and description
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        
        //yaxis intervals
        chartView.leftAxis.axisMinimum = 0
        //chartView.leftAxis.granularity = 4.0
        //chartView.leftAxis.labelCount = 5
        //chartView.leftAxis.axisMinLabels = 2
        
        //chartView.leftAxis.drawTopYLabelEntryEnabled = true
        
        
        //xaxis intervals
        chartView.xAxis.granularity = 1.0
    }
    
    func setChartData(){
        var index = 0
        var bcdeArray:[BarChartDataEntry] = []
        
        for item in journalDrinks{
            let xVal = Double(index)
            var coffee = 0.0
            var water = 0.0
            var alcohol = 0.0
            if activeCoffee{
                coffee = Double(item[1])
            }
            if activeWater{
                water = Double(item[0])
            }
            if activeAlcohol{
                alcohol = Double(item[2])
            }
            let bcde = BarChartDataEntry(x: xVal, yValues: [alcohol, water, coffee], data: xAxisText as AnyObject?)
            
            bcdeArray.append(bcde)
            index += 1
        }
        
        let set = BarChartDataSet(entries: bcdeArray)
        
        set.drawIconsEnabled = false
        set.colors = [alcoholColor!, waterColor!, coffeeColor!]
        set.drawValuesEnabled = false
        
        let data = BarChartData(dataSet: set)
        
        data.barWidth = 0.3
        
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
       
        chartView.notifyDataSetChanged()
        chartView.setNeedsDisplay()
        
    }
    //Change value to double to accept decimal value
    func convertJournals(){
        journalCopy = []
        ConversionManager.sharedInstance.loadFluidUnit()
        var index = 0
        for item in journalEvents{
            journalCopy.append(JournalEvents())
            journalCopy[index].eventTimestamp = item.eventTimestamp
            switch ConversionManager.sharedInstance.fluidUnit{
            case .ounces:
                journalCopy[index].drinksWaterOther = Double(ConversionManager.sharedInstance.getOunces(milli: item.drinksWaterOther ?? 0.0))
                
                journalCopy[index].drinksCaffeinated = Double(ConversionManager.sharedInstance.getOunces(milli: item.drinksCaffeinated ?? 0.0))
                
                journalCopy[index].drinksAlcohol = Double(ConversionManager.sharedInstance.getOunces(milli: item.drinksAlcohol ?? 0.0))
            case .cups:
                journalCopy[index].drinksWaterOther = Double(ConversionManager.sharedInstance.getCups(milli: (item.drinksWaterOther ?? 0.0)))
                journalCopy[index].drinksCaffeinated = Double(ConversionManager.sharedInstance.getCups(milli: item.drinksCaffeinated ?? 0))
                journalCopy[index].drinksAlcohol = Double(ConversionManager.sharedInstance.getCups(milli: item.drinksAlcohol ?? 0))
            case .milliliters:
                journalCopy[index].drinksWaterOther = item.drinksWaterOther ?? 0
                journalCopy[index].drinksCaffeinated = item.drinksCaffeinated ?? 0
                journalCopy[index].drinksAlcohol = item.drinksAlcohol ?? 0
            }
            index += 1
        }
    }
    
    func getJournalList(){
        journalDrinks = []
        xAxisText = []
        
        //conversions
        convertJournals()
        
        if timeRange == .daily{
            xAxisText = ["Night\n12am - 6am","Morning\n6am - 12pm","Afternoon\n12pm - 6pm","Evening\n6pm - 12am"]
            
            for navRange in JournalDayEntryNavigationPages.allCases{
                var temp:[Double] = [0, 0, 0]
                for item in journalCopy{
                    let tmstmp = item.eventTimestamp.treatTimestampStrAsDate() ?? Date()
                    let hour = Calendar.current.component(.hour, from: tmstmp)
                    if navRange.insideRange(hour: hour){
                        if JournalRangesManager.sharedInstance.checkForDrinks(je: item){
                            temp = [item.drinksWaterOther!, item.drinksCaffeinated!, item.drinksAlcohol!]
                        }
                        break
                    }
                }
                journalDrinks.append(temp)
                
            }
        }
        else{
            xAxisText = ["S", "M", "T", "W", "T", "F", "S"]
            
            if let jTmstmp = journalCopy.first?.eventTimestamp.treatTimestampStrAsDate(){
                let startWeekDate = jTmstmp.startOfWeek()
                var dayOfWeek = startWeekDate
                var axisIndex = 0
                for _ in xAxisText{
                    let dayVal = Calendar.current.component(.day, from: dayOfWeek)
                    xAxisText[axisIndex] = xAxisText[axisIndex] + "\n" + (String(dayVal))
                    dayOfWeek = Calendar.current.date(byAdding: .day, value: 1, to: dayOfWeek) ?? Date()
                    axisIndex += 1
                }
            }
            
            for _ in xAxisText{
                journalDrinks.append([0, 0, 0])
            }
            
            for weekdayJournalUnit in 1 ... 7{
                for item in journalCopy{
                    let iTmstmp = item.eventTimestamp.treatTimestampStrAsDate() ?? Date()
                    if weekdayJournalUnit == Calendar.current.component(.weekday, from: iTmstmp){
                        if JournalRangesManager.sharedInstance.checkForDrinks(je: item){
                            let drinks = journalDrinks[weekdayJournalUnit - 1][0] + item.drinksWaterOther!
                            let caffeinated = journalDrinks[weekdayJournalUnit - 1][1] + item.drinksCaffeinated!
                            let alcohol = journalDrinks[weekdayJournalUnit - 1][2] + item.drinksAlcohol!
                            journalDrinks[weekdayJournalUnit - 1] = [drinks, caffeinated, alcohol]
                        }
                    }
                }
                
                
            }
        }
    }
    
    func getSectionDay(date: Date){
        let dateFormatter = DateFormatter()
        var labelStr = ""
        
        if timeRange == .daily {
            labelStr = getDailyTextStr(d: date)
            
        } else if timeRange == .weekly {
            dateFormatter.dateFormat = "EEEEE\nd"
            labelStr = dateFormatter.string(from: date)
            
        } else if timeRange == .monthly {
            dateFormatter.dateFormat = "MMM d"
            labelStr = dateFormatter.string(from: date)
        }
        
        xAxisText.append(labelStr)
    }
    
    func getDailyTextStr(d: Date) -> String{
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        let hour = cal.component(.hour, from: d)
        switch hour{
        case 6 ... 11: return "Morning\n6am - 12pm"
        case 12 ... 17: return "Afternoon\n12pm - 6pm"
        case 18 ... 23: return "Evening\n6am - 12am"
        case 0 ... 5: return "Night\n12am - 6am"
        default: return ""
        }
    }

    @objc func didTapHeaderArrow(){
        collapse = !collapse
        collapseArrowButton.image = self.collapse ? self.downImage : self.upImage
        // old implem.
        //conversionStack.isHidden = collapse
        
        self.outerStack.arrangedSubviews[1].isHidden = self.collapse
        self.outerStack.arrangedSubviews[2].isHidden = self.collapse
        
    }
}
extension FluidChartView: AxisValueFormatter{
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xAxisText[Int(value)]
    }
}
