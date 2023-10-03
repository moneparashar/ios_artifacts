//
//  GroupedSegmentView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 3/17/23.
//

import UIKit

protocol GroupedSegmentViewDelegate{
    func changedOption()
}

class GroupedSegmentView: UIView {

    var buttonStack = UIStackView()
    var slidingSelectedView = UIView()
    var sectionSplitterStack = UIStackView()
    
    var buttonsArray:[UIButton] = []
    var buttonDict:[UIButton: Int] = [:]
    var optionCount = 2
    
    var separatorArray:[UIView] = []
    
    var selectedOption = 0
    
    var padding = CGFloat(3) //for top and left
    var slidingLeadingConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var slidingLeadingConstant: CGFloat = 0
    var cornerRad = CGFloat(20)
    
    var delegate:GroupedSegmentViewDelegate?
    
    //colors
    var selectedTintTextOrImage = UIColor.white
    var nonSelectedTintTextOrImage = UIColor.wedgewoodBlue
    var selectedSlidingColor = UIColor.regalBlue
    var dividerColor = UIColor.wedgewoodBlue
    var isFirstLayout = true
    
    required init(optionNum: Int) {
        optionCount = optionNum
        super.init(frame: .zero)
        configure()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // setting foot selection to right by defaule
        // Only call selectSegment on the first layout (initial load)
        if isFirstLayout {
        selectSegment(segment: optionCount - 1)
        isFirstLayout = false // Set the flag to false to prevent subsequent calls
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure(){
        backgroundColor = UIColor.lavendarMist
        layer.cornerRadius = cornerRad
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        //layer.cornerRadius = bounds.size.height / 2
        
        for num in 0 ..< optionCount{
            let btn = UIButton()
            btn.titleLabel?.font = UIFont.h7
            btn.addTarget(self, action: #selector(tappedButton), for: .touchDown)
            buttonsArray.append(btn)
            buttonDict[btn] = num
            
            let separatorView = UIView()
            separatorArray.append(separatorView)
        }
        separatorArray.append(UIView())
        
        slidingSelectedView.backgroundColor = selectedSlidingColor
        slidingSelectedView.layer.cornerRadius = 16
        slidingSelectedView.layer.cornerCurve = .continuous
        slidingSelectedView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slidingSelectedView)
        
        sectionSplitterStack = UIStackView(arrangedSubviews: separatorArray)
        sectionSplitterStack.distribution = .equalSpacing
        sectionSplitterStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sectionSplitterStack)
        for sect in sectionSplitterStack.arrangedSubviews{
            NSLayoutConstraint.activate([
                sect.widthAnchor.constraint(equalToConstant: 1),
            ])
        }
        
        buttonStack = UIStackView(arrangedSubviews: buttonsArray)
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)
        
        slidingLeadingConstraint = slidingSelectedView.leadingAnchor.constraint(equalTo: buttonStack.leadingAnchor, constant: slidingLeadingConstant)
        let sldingWidthMultipler = CGFloat(Float(1) / Float(optionCount))
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            buttonStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            buttonStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            buttonStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            
            sectionSplitterStack.leadingAnchor.constraint(equalTo: buttonStack.leadingAnchor),
            sectionSplitterStack.centerXAnchor.constraint(equalTo: buttonStack.centerXAnchor),
            sectionSplitterStack.centerYAnchor.constraint(equalTo: buttonStack.centerYAnchor),
            sectionSplitterStack.heightAnchor.constraint(equalTo: buttonStack.heightAnchor, multiplier: 16/44),
            
            slidingLeadingConstraint,
            slidingSelectedView.leadingAnchor.constraint(greaterThanOrEqualTo: buttonStack.leadingAnchor),
            slidingSelectedView.topAnchor.constraint(equalTo: buttonStack.topAnchor),
            slidingSelectedView.bottomAnchor.constraint(equalTo: buttonStack.bottomAnchor),
            slidingSelectedView.widthAnchor.constraint(equalTo: buttonStack.widthAnchor, multiplier: sldingWidthMultipler)
        ])
    }
    
    @objc func tappedButton(_ button: UIButton){
        let tappedDifferent = selectedOption != buttonDict[button]
        if let toSelectSegment = buttonDict[button]{
            selectSegment(segment: toSelectSegment)
        }
        if tappedDifferent{
            delegate?.changedOption()
        }
    }
    
    //may need to change slidingLeadingConstraint logic if want selectSegment to display at viewDidLoad()
    func selectSegment(segment: Int){
        self.slidingLeadingConstant = CGFloat(CGFloat(segment) * self.slidingSelectedView.frame.width)
        self.slidingLeadingConstraint.constant = self.slidingLeadingConstant
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        })
        
        var selectBtn = UIButton()
        for bt in buttonDict{
            if bt.value == segment{
                selectBtn = bt.key
                break
            }
        }
        for btn in buttonsArray{
            if btn == selectBtn{
                btn.setTitleColor(selectedTintTextOrImage, for: .normal)
                btn.tintColor = selectedTintTextOrImage
            }
            else{
                btn.setTitleColor(nonSelectedTintTextOrImage, for: .normal)
                btn.tintColor = nonSelectedTintTextOrImage
            }
        }
        
        //hide/show dividers
        var ind = 0
        for sep in separatorArray{
            if ind == segment || ind == segment + 1{
                sep.backgroundColor = UIColor.clear
            }
            else if ind != 0 && ind != optionCount{
                sep.backgroundColor = dividerColor
            }
            ind += 1
        }
        
        selectedOption = segment
    }
    
    func setup(textArr:[String]){
        var ind = 0
        for opt in textArr{
            if buttonsArray.count > ind{
                buttonsArray[ind].setTitle(opt, for: .normal)
                ind += 1
            }
        }
    }
    
    func setup(imgArr:[UIImage]){
        var ind = 0
        for opt in imgArr{
            if buttonsArray.count > ind{
                buttonsArray[ind].setImage(opt, for: .normal)
                ind += 1
            }
        }
    }
    
    func disableAll(){
        isUserInteractionEnabled = false
    }
    
    func enableAll(){
        isUserInteractionEnabled = true
    }
}
