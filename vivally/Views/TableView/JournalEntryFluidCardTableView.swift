//
//  JournalEntryFluidCardTableView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/2/23.
//

import UIKit

protocol JournalEntryFluidCardTableDelegate{
    func updatedWater(val: Int)
    func updatedCaf(val: Int)
    func updatedAlc(val: Int)
    func updatedFluidUnit()
}

class JournalEntryFluidCardTableView: UIView {

    var delegate: JournalEntryFluidCardTableDelegate?
    
    var allStack = UIStackView()
    
    var cardHeader = JournalEntryHeaderCardView()
    var allSliderStack = UIStackView()
    
    var waterView = JournalEntryRowCardView()
    var caffeineView = JournalEntryRowCardView()
    var alcoholView = JournalEntryRowCardView()
    
    var waterVal = 0.0
    var cafVal = 0.0
    var alcoholVal = 0.0
    
    var collapse = false
    
    var fluidTopPadding:CGFloat = 12
    
    var currentFluidUnit:FluidUnits = .ounces
    
    required init(){
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func configure(){
        layer.borderColor = UIColor.casperBlue?.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 15
        layer.backgroundColor = UIColor.white.cgColor
        
        allSliderStack = UIStackView(arrangedSubviews: [waterView, caffeineView, alcoholView])
        allSliderStack.axis = .vertical
        allSliderStack.distribution = .equalSpacing
        
        allStack = UIStackView(arrangedSubviews: [cardHeader, allSliderStack])
        allStack.axis = .vertical
        allStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(allStack)
        
        allStack.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            allStack.topAnchor.constraint(equalTo: self.topAnchor, constant: fluidTopPadding),
            allStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            allStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            allStack.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
     
        cardHeader.delegate = self
        waterView.delegate = self
        caffeineView.delegate = self
        alcoholView.delegate = self
    }
    
    func setDisplays(){
        grabFluidUnit()
        cardHeader.setup(mainTitle: "Fluid intake", optionFluid: currentFluidUnit, closeCard: collapse)
        
        var highVal = 0
        var isDiscrete = false
        var overrideIntervals:Double? = nil
        switch currentFluidUnit {
        case .ounces:
            highVal = 32
            isDiscrete = true
        case .cups:
            highVal = 4
            overrideIntervals = 0.125
        case .milliliters:
            highVal = 960
            isDiscrete = true
            //commented the below line because it give 30 interval on plus button it should be on manual slide 
            overrideIntervals = 30
        }
        
        waterView.setup(title: "Water and other", currentVal: waterVal, highRange: highVal, showBottomLine: true, discrete: isDiscrete, overRideInterval: overrideIntervals)
        caffeineView.setup(title: "Caffeinated", currentVal: cafVal, highRange: highVal, showBottomLine: true, discrete: isDiscrete, overRideInterval: overrideIntervals)
        alcoholView.setup(title: "Alcohol", currentVal: alcoholVal, highRange: highVal, showBottomLine: false, discrete: isDiscrete, overRideInterval: overrideIntervals)
    }
    
    func grabFluidUnit(){
        ConversionManager.sharedInstance.loadFluidUnit()
        currentFluidUnit = ConversionManager.sharedInstance.fluidUnit
    }
}

extension JournalEntryFluidCardTableView: JournalEntryHeaderCardViewDelegate{
    func tappedArrow(shouldCollapse: Bool) {
        collapse = shouldCollapse
        UIView.animate(withDuration: 0.3){
            self.allStack.arrangedSubviews[1].isHidden = self.collapse
        }
    }
    
    func dropSelected(ind: Int, option: String, sender: JournalEntryHeaderCardView) {
        currentFluidUnit = ConversionManager.sharedInstance.fluidUnit
        delegate?.updatedFluidUnit()
    }
}

extension JournalEntryFluidCardTableView: JournalEntryRowCardViewDelegate{
    func changedValue(sender: JournalEntryRowCardView, val: Int) {
        switch sender{
        case waterView:
            delegate?.updatedWater(val: val)
        case caffeineView:
            delegate?.updatedCaf(val: val)
        case alcoholView:
            delegate?.updatedAlc(val: val)
        default:
            return
        }
    }
}
