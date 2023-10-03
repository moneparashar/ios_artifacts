//
//  JournalEntryLifeCardView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/5/23.
//

import UIKit

protocol JournalEntryLifeCardDelegate{
    func gelTap(select: Bool)
    func medicationTap(select: Bool)
    func exerciseTap(select: Bool)
    func dietTap(select: Bool)
    func stressTap(select: Bool)
}

class JournalEntryLifeCardView: UIView {

    var delegate: JournalEntryLifeCardDelegate?
    var collapse = false
    
    //UI
    var allButtons:[UIButton] = []
    var allLifeStack:[UIStackView] = []
    var rStack:[UIStackView] =  []
    
    var cardPadding = CGFloat(12)
    
    var stack = UIStackView()
    
    var cardHeader = JournalEntryHeaderCardView()

    var AllRowsStack = UIStackView()
    var row1Stack = UIStackView()
    var gelStack = UIStackView()
    var gelButton = UIButton()
    var gelLabel = UILabel()
    var spaceView = UIView()
    
    var row2Stack = UIStackView()
    var medicationStack = UIStackView()
    var medicationButton = UIButton()
    var medicationLabel = UILabel()
    var exerciseStack = UIStackView()
    var exerciseButton = UIButton()
    var exerciseLabel = UILabel()
    
    var row3Stack = UIStackView()
    var dietStack = UIStackView()
    var dietButton = UIButton()
    var dietLabel = UILabel()
    var stressStack = UIStackView()
    var stressButton = UIButton()
    var stressLabel = UILabel()
    
    var lineSeparator = UIView()
    var lineSeparator2 = UIView()
    var spaceLineSeparator = UIView()
    
    var upImage = UIImage(named: "UpChevron")
    var downImage = UIImage(named: "DownChevron")
    
    var uncheckImage = UIImage(named: "emptyCheckbox")
    var checkedImage = UIImage(named: "filledCheckbox")
    
    required init(){
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure(){
        configureUI()
    }
    
    private func configureUI(){
        layer.borderColor = UIColor.casperBlue?.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 15
        
        setAllCheckButtons()
        setLabels()
        
        //row1
        gelLabel.text = "Replaced Gel Cushions"
        gelStack = UIStackView(arrangedSubviews: [gelButton, gelLabel])
        
        //row2
        medicationLabel.text = "Medication"
        medicationStack = UIStackView(arrangedSubviews: [medicationButton, medicationLabel])
        exerciseLabel.text = "Exercise"
        exerciseStack = UIStackView(arrangedSubviews: [exerciseButton, exerciseLabel])
        
        //row3
        dietLabel.text = "Diet"
        dietStack = UIStackView(arrangedSubviews: [dietButton, dietLabel])
        stressLabel.text = "Stress"
        stressStack = UIStackView(arrangedSubviews: [stressButton, stressLabel])
        
        setLifeStacks()
        
        row1Stack = UIStackView(arrangedSubviews: [gelStack])
        row2Stack = UIStackView(arrangedSubviews: [medicationStack, exerciseStack])
        row3Stack = UIStackView(arrangedSubviews: [dietStack, stressStack])
        setRowStacks()
        
        lineSeparator.backgroundColor = UIColor.casperBlue
        lineSeparator.translatesAutoresizingMaskIntoConstraints = false
        let line1View = UIView()
        line1View.addSubview(lineSeparator)
        NSLayoutConstraint.activate([
            lineSeparator.heightAnchor.constraint(equalToConstant: 1),
            lineSeparator.topAnchor.constraint(equalTo: line1View.topAnchor),
            lineSeparator.bottomAnchor.constraint(equalTo: line1View.bottomAnchor),
            lineSeparator.leadingAnchor.constraint(equalTo: line1View.leadingAnchor),
            lineSeparator.trailingAnchor.constraint(equalTo: line1View.trailingAnchor)
        ])
        
        lineSeparator2.backgroundColor = UIColor.casperBlue
        lineSeparator2.translatesAutoresizingMaskIntoConstraints = false
        let line2View = UIView()
        line2View.addSubview(lineSeparator2)
        NSLayoutConstraint.activate([
            lineSeparator2.heightAnchor.constraint(equalToConstant: 1),
            lineSeparator2.topAnchor.constraint(equalTo: line2View.topAnchor),
            lineSeparator2.bottomAnchor.constraint(equalTo: line2View.bottomAnchor),
            lineSeparator2.leadingAnchor.constraint(equalTo: line2View.leadingAnchor),
            lineSeparator2.trailingAnchor.constraint(equalTo: line2View.trailingAnchor)
        ])
        
        AllRowsStack = UIStackView(arrangedSubviews: [row1Stack, line1View, row2Stack, line2View, row3Stack])
        AllRowsStack.axis = .vertical
        AllRowsStack.alignment = .fill
        AllRowsStack.distribution = .fill
        AllRowsStack.spacing = 8
        
        stack = UIStackView(arrangedSubviews: [cardHeader, AllRowsStack])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            stack.topAnchor.constraint(equalTo: self.topAnchor, constant: cardPadding),
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        cardHeader.delegate = self
    }
    
    private func setAllCheckButtons(){
        allButtons = [gelButton, medicationButton, exerciseButton, dietButton, stressButton]
        for b in allButtons{
            b.setImage(uncheckImage, for: .normal)
            b.setImage(checkedImage, for: .selected)
            b.addTarget(self, action: #selector(didTapLifeButton(lifeButton:)), for: .touchDown)
        }
    }
    
    @objc func didTapLifeButton(lifeButton: UIButton){
        lifeButton.isSelected = !lifeButton.isSelected
        lifeButton.setImage(lifeButton.isSelected ? checkedImage : uncheckImage, for: .normal)
        if lifeButton == gelButton{
            delegate?.gelTap(select: lifeButton.isSelected)
        }
        else if lifeButton == medicationButton{
            delegate?.medicationTap(select: lifeButton.isSelected)
        }
        else if lifeButton == exerciseButton{
            delegate?.exerciseTap(select: lifeButton.isSelected)
        }
        else if lifeButton == dietButton{
            delegate?.dietTap(select: lifeButton.isSelected)
        }
        else if lifeButton == stressButton{
            delegate?.stressTap(select: lifeButton.isSelected)
        }
    }
        
    private func setLifeStacks(){
        allLifeStack = [gelStack, medicationStack, exerciseStack, dietStack, stressStack]
        for life in allLifeStack{
            life.alignment = .fill
            life.distribution = .fill
            life.spacing = 8
            life.arrangedSubviews[0].setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        }
    }
    
    private func setRowStacks(){
        rStack = [row1Stack, row2Stack, row3Stack]
        for rs in rStack{
            rs.alignment = .fill
            rs.distribution = .fillEqually
        }
    }
    
    var lifeLabels:[UILabel] = []
    private func setLabels(){
        lifeLabels = [gelLabel, medicationLabel, exerciseLabel, dietLabel, stressLabel]
        for lab in lifeLabels{
            lab.textAlignment = .left
            lab.textColor = UIColor.regalBlue
            lab.font = UIFont.bodyMed
            lab.numberOfLines = 0
            lab.lineBreakMode = .byWordWrapping
        }
    }
    
    func setup(je: JournalEvents){
        cardHeader.setup(mainTitle: "Life Events", closeCard: collapse)
        gelButton.isSelected = je.lifeGelPads == true
        medicationButton.isSelected = je.lifeMedication == true
        exerciseButton.isSelected = je.lifeExercise == true
        dietButton.isSelected = je.lifeDiet == true
        stressButton.isSelected = je.lifeStress == true
    }
    
}

extension JournalEntryLifeCardView:JournalEntryHeaderCardViewDelegate{
    func tappedArrow(shouldCollapse: Bool) {
        collapse = shouldCollapse
        UIView.animate(withDuration: 0.3){
            self.stack.arrangedSubviews[1].isHidden = self.collapse
        }
    }
    
    func dropSelected(ind: Int, option: String, sender: JournalEntryHeaderCardView) {
    }
}
