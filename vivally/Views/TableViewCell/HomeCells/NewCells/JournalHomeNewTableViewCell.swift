//
//  JournalHomeNewTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/14/22.
//
// TODO: figure out what to do if there is no journal entry

import UIKit

protocol JournalHomeNewTableViewCellDelegate{
    func tappedEvent()
    func tappedViewDiaryButton()
}
class JournalHomeNewTableViewCell: UITableViewCell {

    var fontSize = UIFont()
    var outerStack = UIStackView()
    var innerStack = UIStackView()
    var outerButtonStack = UIStackView()
    var buttonStack = UIStackView()
    
    var journalTitleLabel = UILabel()
    var journalSubtitleLabel = UILabel()
    var lastEntryLabel = UILabel()
    var eventButton = ActionButton()
    var viewDiaryButton = ActionButton()
    
    var topStackViews: [UIView] = []
    
    //var eggBackImageView = UIImageView(image: UIImage(named: "homeCardEgg"))
    
    
    var delegate:JournalHomeNewTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        
        //eggBackImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //contentView.addSubview(eggBackImageView)
        contentView.backgroundColor = .lilyWhite ?? .white
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        
        journalTitleLabel.text = "My eDiary"
        journalTitleLabel.font = UIFont.h4
        journalTitleLabel.textAlignment = .left
        journalTitleLabel.numberOfLines = 0
        journalTitleLabel.textColor = UIColor.black
        
        journalSubtitleLabel.text = "Use your diary daily to record your fluid intake, symptom frequency and other life events to optimally manage your symptoms"
        journalSubtitleLabel.font = UIFont.bodyMed
        journalSubtitleLabel.textAlignment = .left
        journalSubtitleLabel.numberOfLines = 0
        journalSubtitleLabel.textColor = UIColor.fontBlue
        
        lastEntryLabel.text = "Last eDiary entry on DD MMM YYYY"
        lastEntryLabel.font = UIFont.bodyMed
        lastEntryLabel.numberOfLines = 0
        lastEntryLabel.textColor = UIColor.fontBlue
        
        topStackViews = [journalTitleLabel, journalSubtitleLabel]
        
        // MARK: Inner Stack
        innerStack = UIStackView(arrangedSubviews: topStackViews)
        innerStack.alignment = .leading
        innerStack.distribution = .equalSpacing
        innerStack.axis = .vertical
        
        eventButton.setTitle("Add new entry", for: .normal)
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        
        viewDiaryButton.setTitle("View eDiary", for: .normal)
        viewDiaryButton.translatesAutoresizingMaskIntoConstraints = false
        viewDiaryButton.toSecondary()
        
        buttonStack = UIStackView(arrangedSubviews: [viewDiaryButton, eventButton])
        if UIDevice.current.userInterfaceIdiom == .pad{
            buttonStack.spacing = 16
            buttonStack.axis = .horizontal
            buttonStack.alignment = .center
        }
        else{
            buttonStack.axis = .vertical
            buttonStack.spacing = 12
            buttonStack.alignment = .fill
        }
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            outerButtonStack = UIStackView(arrangedSubviews: [buttonStack])
        }
        else{
            let spaceView = UIView()
            outerButtonStack = UIStackView(arrangedSubviews: [spaceView, buttonStack])
            outerButtonStack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                outerButtonStack.arrangedSubviews[1].widthAnchor.constraint(equalTo: outerButtonStack.widthAnchor, multiplier: 0.6)
            ])
        }
        
        outerStack = UIStackView(arrangedSubviews: [innerStack, lastEntryLabel, outerButtonStack])
        outerStack.alignment = .fill
        outerStack.distribution = .equalSpacing
        outerStack.spacing = 24
        outerStack.axis = .vertical
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(outerStack)
        
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            outerStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            outerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            outerStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        
        eventButton.addTarget(self, action: #selector(tapEvent), for: .touchDown)
        viewDiaryButton.addTarget(self, action: #selector(tapViewDiary), for: .touchDown)
    }
    
    @objc func tapEvent(){
        delegate?.tappedEvent()
    }
    
    @objc func tapViewDiary() {
        delegate?.tappedViewDiaryButton()
    }

    func setupView(lastJournal: String = ""){
        lastEntryLabel.text = ""
        lastEntryLabel.text = lastJournal.isEmpty ? "" : "Last eDiary Entry on " + lastJournal + "."
    }
    
    func addShadow(){
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.shadowOpacity = 1
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowColor = UIColor(red: 0.09, green: 0.255, blue: 0.431, alpha: 0.17).cgColor
        
        // add corner radius on `contentView`
    }
}
