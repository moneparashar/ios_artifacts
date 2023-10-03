//
//  JournalEntrySliderTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/2/23.
//

import UIKit

protocol JournalEntrySliderTableViewDelegate{
    func changedValue(path: Int, val: Int)
}

class JournalEntrySliderTableViewCell: UITableViewCell {

    var titleLabel = UILabel()
    var slideview = TicklessHorizontalSlider()
    var lineEdge = UIView()
    
    var delegate: JournalEntrySliderTableViewDelegate?
    
    var stack = UIStackView()
    
    var currentRow = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in subviews where view != contentView {
            view.removeFromSuperview()
        }
    }
    
    private func configure(){
        selectionStyle = .none
        //self.layer.masksToBounds = false
        
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
        contentView.addSubview(stack)
        
        lineEdge.backgroundColor = UIColor.casperBlue
        lineEdge.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lineEdge)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: lineEdge.topAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            lineEdge.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            lineEdge.centerXAnchor.constraint(equalTo: stack.centerXAnchor),
            lineEdge.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lineEdge.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func setup(rowNum: Int, title: String, currentVal: Double, lowRange: Int = 0, highRange: Int = 8, showBottomLine: Bool = true, discrete: Bool = true){
        titleLabel.text = title
        currentRow = rowNum
        
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
        
        lineEdge.isHidden = true
        lineEdge.isHidden = !showBottomLine
    }
}

extension JournalEntrySliderTableViewCell: HorizontalSliderDelegate{
    func didChangeValue() {
        delegate?.changedValue(path: currentRow, val: Int(slideview.slider.value))
    }
}
