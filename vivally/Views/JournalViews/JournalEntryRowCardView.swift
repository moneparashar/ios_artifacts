//
//  JournalEntryRowCardView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 4/27/23.
//

import UIKit

protocol JournalEntryRowCardViewDelegate{
    func changedValue(sender: JournalEntryRowCardView, val: Int)
}

class JournalEntryRowCardView: UIView {

    var titleLabel = UILabel()
    var slideview = TicklessHorizontalSlider()
    var lineEdge = UIView()
    
    var delegate: JournalEntryRowCardViewDelegate?
    
    var stack = UIStackView()
    
    required init(){
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure(){
        
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.font = UIFont.bodyMed
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        
        slideview.delegate = self
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            let spacerView = UIView()
            let sliderStack = UIStackView(arrangedSubviews: [spacerView, slideview])
            sliderStack.translatesAutoresizingMaskIntoConstraints = false
            sliderStack.arrangedSubviews[1].setContentCompressionResistancePriority(.required, for: .vertical)
            NSLayoutConstraint.activate([
                sliderStack.arrangedSubviews[1].widthAnchor.constraint(equalTo: sliderStack.widthAnchor, multiplier: 25/28)
            ])
            
            stack = UIStackView(arrangedSubviews: [titleLabel, sliderStack])
            stack.axis = .vertical
            stack.distribution = .fill
            stack.spacing = 8
        }
        else{
            stack = UIStackView(arrangedSubviews: [titleLabel, slideview])
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.alignment = .top
            
        }
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.arrangedSubviews[0].setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        NSLayoutConstraint.activate([
            stack.arrangedSubviews[1].heightAnchor.constraint(greaterThanOrEqualToConstant: 42)
        ])
        addSubview(stack)
        
        lineEdge.backgroundColor = UIColor.casperBlue
        lineEdge.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineEdge)

        stack.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: lineEdge.topAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            lineEdge.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            lineEdge.centerXAnchor.constraint(equalTo: stack.centerXAnchor),
            lineEdge.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            lineEdge.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func setup(title: String, currentVal: Double, lowRange: Int = 0, highRange: Int = 8, showBottomLine: Bool = true, discrete: Bool = true, overRideInterval: Double? = nil){
        titleLabel.text = title
        
        slideview.slider.minimumValue = Float(lowRange)
        slideview.slider.maximumValue = Float(highRange)
        slideview.slider.setValue(Float(currentVal), animated: true)
        
        
        
        slideview.highestRange = Double(highRange)
        
        slideview.getTickInterval()
        var tickNum = lowRange
        for tL in slideview.numLabels{
            tL.text = String(tickNum)
            tickNum += Int(slideview.tickLabelInterval)
        }
        slideview.isDiscrete = discrete
        
        // added condition for intervalUniqueSet should be nil when Unit is Ounce
        if overRideInterval != nil || ConversionManager.sharedInstance.fluidUnit.rawValue == 1{
            slideview.intervalUniqueSet = overRideInterval
        }
        
        lineEdge.isHidden = true
        lineEdge.isHidden = !showBottomLine
    }
}

extension JournalEntryRowCardView: HorizontalSliderDelegate{
    func didChangeValue() {
        delegate?.changedValue(sender: self, val: Int(slideview.slider.value))
    }
}
