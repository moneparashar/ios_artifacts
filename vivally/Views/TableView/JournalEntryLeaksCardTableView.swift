//
//  JournalEntryLeaksCardTableView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/2/23.
//

import UIKit

protocol JournalEntryLeaksCardTableDelegate{
    func updatedLeaks(val: Int)
    func updatedLeakUrges(val: Int)
    func updatedChanges(val: Int)
    func updatedLeakSleep(val: Int)
}

class JournalEntryLeaksCardTableView: UIView {

    var delegate: JournalEntryLeaksCardTableDelegate?
    
    var allStack = UIStackView()
    
    var cardHeader = JournalEntryHeaderCardView()
    var allSliderStack = UIStackView()
    
    var leaksView = JournalEntryRowCardView()
    var urgeView = JournalEntryRowCardView()
    var padsView = JournalEntryRowCardView()
    var sleepView = JournalEntryRowCardView()
    
    var leaksVal = 0.0
    var urgeVal = 0.0
    var padsVal = 0.0
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
        
        allSliderStack = UIStackView(arrangedSubviews: [leaksView, urgeView, padsView, sleepView])
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
        leaksView.delegate = self
        urgeView.delegate = self
        padsView.delegate = self
        sleepView.delegate = self
    }
    
    func setDisplays(){
        cardHeader.setup(mainTitle: "Leaks (Incontinence)", closeCard: collapse)
        
        leaksView.setup(title: "Total leaks", currentVal: leaksVal, showBottomLine: true)
        urgeView.setup(title: "With urge", currentVal: urgeVal, showBottomLine: true)
        padsView.setup(title: "With changes in pads or clothing", currentVal: padsVal, showBottomLine: true)
        sleepView.setup(title: "With interrupted sleep", currentVal: sleepVal, showBottomLine: false)
    }
    
    func checkLeakValues(){
        if padsVal >= leaksVal{
            padsVal = leaksVal
            delegate?.updatedChanges(val: Int(leaksVal))
            
            padsView.slideview.slider.setValue(Float(leaksVal), animated: true)
            padsView.slideview.plusButton.isEnabled = false
        }
        else{
            padsView.slideview.checkButtonEnabling()
        }
        
        if urgeVal >= leaksVal{
            urgeVal = leaksVal
            delegate?.updatedChanges(val: Int(urgeVal))
            
            urgeView.slideview.slider.setValue(Float(urgeVal), animated: true)
            urgeView.slideview.plusButton.isEnabled = false
        }
        
        if sleepVal >= leaksVal{
            sleepVal = leaksVal
            delegate?.updatedLeakSleep(val: Int(sleepVal))
            
            sleepView.slideview.slider.setValue(Float(sleepVal), animated: true)
            sleepView.slideview.plusButton.isEnabled = false
        }
        else{
            urgeView.slideview.checkButtonEnabling()
        }
    }
}

extension JournalEntryLeaksCardTableView: JournalEntryHeaderCardViewDelegate{
    func tappedArrow(shouldCollapse: Bool) {
        collapse = shouldCollapse
        UIView.animate(withDuration: 0.3){
            self.allStack.arrangedSubviews[1].isHidden = self.collapse
        }
    }
    
    func dropSelected(ind: Int, option: String, sender: JournalEntryHeaderCardView) {}
}

extension JournalEntryLeaksCardTableView: JournalEntryRowCardViewDelegate{
    func changedValue(sender: JournalEntryRowCardView, val: Int) {
        switch sender{
        case leaksView:
            leaksVal = Double(val)
            delegate?.updatedLeaks(val: val)
        case padsView:
            padsVal = Double(val)
            delegate?.updatedChanges(val: val)
        case urgeView:
            urgeVal = Double(val)
            delegate?.updatedLeakUrges(val: val)
        case sleepView:
            sleepVal = Double(val)
            delegate?.updatedLeakSleep(val: val)
        default:
            return
        }
        checkLeakValues()
    }
}
