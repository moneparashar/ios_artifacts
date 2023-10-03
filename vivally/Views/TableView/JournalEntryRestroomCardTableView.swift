//
//  JournalEntryRestroomCardTableView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/2/23.
//

import UIKit

protocol JournalEntryRestroomCardTableDelegate{
    func updatedVoids(val: Int)
    func updatedRestroomUrges(val: Int)
    func updatedSleep(val: Int)
}

class JournalEntryRestroomCardTableView: UIView {

    var delegate:JournalEntryRestroomCardTableDelegate?
    
    var allStack = UIStackView()
    
    var cardHeader = JournalEntryHeaderCardView()
    var allSliderStack = UIStackView()
    
    var voidView = JournalEntryRowCardView()
    var restroomView = JournalEntryRowCardView()
    var sleepView = JournalEntryRowCardView()
    
    var voidsVal = 0.0
    var urgeVal = 0.0
    var sleepVal = 0.0
    
    var collapse = false
    
    var cardTopPadding:CGFloat = 12
    
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
        
        allSliderStack = UIStackView(arrangedSubviews: [voidView, restroomView, sleepView])
        allSliderStack.axis = .vertical
        allSliderStack.distribution = .equalSpacing
        
        allStack = UIStackView(arrangedSubviews: [cardHeader, allSliderStack])
        allStack.axis = .vertical
        allStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(allStack)
        
        allStack.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            allStack.topAnchor.constraint(equalTo: self.topAnchor, constant: cardTopPadding),
            allStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            allStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            allStack.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
     
        cardHeader.delegate = self
        voidView.delegate = self
        restroomView.delegate = self
        sleepView.delegate = self
    }
    
    func setDisplays(){
        cardHeader.setup(mainTitle: "Voids", closeCard: collapse)
        voidView.setup(title: "Total voids", currentVal: voidsVal, showBottomLine: true)
        restroomView.setup(title: "With urge", currentVal: urgeVal, showBottomLine: true)
        sleepView.setup(title: "With interrupted sleep", currentVal: sleepVal, showBottomLine: true)
    }
    
    func checkRestroomValues(){
        if urgeVal >= voidsVal{
            urgeVal = voidsVal
            delegate?.updatedRestroomUrges(val: Int(urgeVal))
            
            restroomView.slideview.slider.setValue(Float(urgeVal), animated: true)
            restroomView.slideview.plusButton.isEnabled = false
        }
        else{
            restroomView.slideview.checkButtonEnabling()
        }
        if sleepVal >= voidsVal{
            sleepVal = voidsVal
            delegate?.updatedSleep(val: Int(sleepVal))
            
            sleepView.slideview.slider.setValue(Float(sleepVal), animated: true)
            sleepView.slideview.plusButton.isEnabled = false
        }
        else{
            sleepView.slideview.checkButtonEnabling()
        }
    }
}
extension JournalEntryRestroomCardTableView: JournalEntryHeaderCardViewDelegate{
    func tappedArrow(shouldCollapse: Bool) {
        collapse = shouldCollapse
        UIView.animate(withDuration: 0.3){
            self.allStack.arrangedSubviews[1].isHidden = self.collapse
        }
    }
    
    func dropSelected(ind: Int, option: String, sender: JournalEntryHeaderCardView) {}
}

extension JournalEntryRestroomCardTableView: JournalEntryRowCardViewDelegate{
    func changedValue(sender: JournalEntryRowCardView, val: Int) {
        switch sender{
        case voidView:
            voidsVal = Double(val)
            delegate?.updatedVoids(val: val)
        case restroomView:
            urgeVal = Double(val)
            delegate?.updatedRestroomUrges(val: val)
        case sleepView:
            sleepVal = Double(val)
            delegate?.updatedSleep(val: val)
        default:
            return
        }
        checkRestroomValues()
    }
}
