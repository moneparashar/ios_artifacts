//
//  JournalEntryHeaderCardView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 4/27/23.
//

import UIKit
import DropDown

protocol JournalEntryHeaderCardViewDelegate{
    func tappedArrow(shouldCollapse: Bool)
    func dropSelected(ind: Int, option: String, sender: JournalEntryHeaderCardView)
}

class JournalEntryHeaderCardView: UIView {

    var collapseButton = UIImageView()
    var titleLabel = UILabel()
    
    var collapse = false
    var upArrow = UIImage(named: "UpChevron")?.withRenderingMode(.alwaysTemplate)
    var downArrow = UIImage(named: "DownChevron")?.withRenderingMode(.alwaysTemplate)
    
    var optionStack = UIStackView()
    var optionText = UILabel()
    var optionButton = UIImageView()
    
    var fullStack = UIStackView()
    
    var optionsAvailable = false
    var dropDown = DropDown()
    var openDropdown = false

    var pickerValues:[String] = []
    var selectedFluidRow = 0
    var selectedUnit: FluidUnits = .ounces
    
    var delegate:JournalEntryHeaderCardViewDelegate?

    
    required init(){
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure(){
        collapseButton.tintColor = UIColor.regalBlue
        //collapseButton.addTarget(self, action: #selector(tappedCollapse), for: .touchDown)
        
        titleLabel.font = UIFont.h4
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.textAlignment = .left
        
        optionText.font = UIFont.h6
        optionText.textColor = UIColor.fontBlue
        
        optionButton.image = downArrow
        optionButton.tintColor = UIColor.regalBlue
        
        optionStack = UIStackView(arrangedSubviews: [optionText, optionButton])
        
        
        fullStack = UIStackView(arrangedSubviews: [collapseButton, titleLabel, optionStack])
        fullStack.distribution = .equalSpacing
        fullStack.spacing = 12
        
        fullStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fullStack)
        
        NSLayoutConstraint.activate([
            fullStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            fullStack.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            fullStack.topAnchor.constraint(equalTo: self.topAnchor),
            fullStack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        
        dropDown.anchorView = optionText
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        optionStack.addGestureRecognizer(tap)
        
        let collapseTap = UITapGestureRecognizer(target: self, action: #selector(tappedCollapse))
        self.addGestureRecognizer(collapseTap)
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
            optionText.text = item
            
            selectedUnit = FluidUnits(rawValue: index + 1) ?? .ounces
            if selectedUnit != ConversionManager.sharedInstance.fluidUnit{
                ConversionManager.sharedInstance.fluidUnit = selectedUnit
                ConversionManager.sharedInstance.saveFluidUnit()
                delegate?.dropSelected(ind: index, option: item, sender: self)
            }
        }
    }
    
    func setup(mainTitle: String, optionFluid: FluidUnits? = nil, closeCard: Bool = false){
        titleLabel.text = ""
        optionText.text = ""
        titleLabel.text = mainTitle
        optionsAvailable = optionFluid != nil
        fullStack.arrangedSubviews[2].isHidden = !optionsAvailable
        optionText.text = optionFluid?.getStr()
        
        collapse = false
        collapse = closeCard
        setCollapseState()
    }
    
    func selectRow(ind: Int){
        dropDown.selectRow(at: ind)
        optionText.text = dropDown.selectedItem
    }
    
    func setCollapseState(){
        //collapseButton.setImage((collapse ? downArrow : upArrow), for: .normal)
        collapseButton.image = collapse ? downArrow : upArrow
        if optionsAvailable{
            fullStack.arrangedSubviews[2].isHidden = collapse
        }
    }
    
    @objc func tappedCollapse(){
        collapse = !collapse
        setCollapseState()
        delegate?.tappedArrow(shouldCollapse: collapse)
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
    
}
