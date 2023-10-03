//
//  TherapyHomeNewTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/15/22.
//

import UIKit

protocol TherapyHomeNewTableViewCellDelegate{
    func tappedTherapyButton()
    func tappedViewHistoryButton()
}
class TherapyHomeNewTableViewCell: UITableViewCell {
    
    var outerStack = UIStackView()
    var innerStack = UIStackView()
    var outerButtonStack = UIStackView()
    var buttonStack = UIStackView()
    var therapyTitleLabel = UILabel()
    var therapySubtitleLabel = UILabel()
    var lastCompletedLabel = UILabel()
    
    
    var therapyButton = ActionButton()
    var viewHistoryButton = ActionButton()
    
    var topStackViews:[UIView] = []

    
    //var eggBackImageView = UIImageView(image: UIImage(named: "homeCardEgg"))
    
    var delegate:TherapyHomeNewTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
        
    private func configure() {
        // MARK: green egg
        /*
        eggBackImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eggBackImageView)
         */
        contentView.backgroundColor = .lilyWhite ?? .white
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        
        therapyTitleLabel.text = "My Therapy"
        therapyTitleLabel.font = UIFont.h4
        therapyTitleLabel.textAlignment = .left
        therapyTitleLabel.numberOfLines = 0
        therapyTitleLabel.textColor = UIColor.black
        
        therapySubtitleLabel.text = "Vivally Therapy uses neuromodulation to treat the symptoms of urinary urgency and urge urinary incontinence."
        therapySubtitleLabel.font = UIFont.bodyMed
        therapySubtitleLabel.textAlignment = .left
        therapySubtitleLabel.numberOfLines = 0
        therapySubtitleLabel.textColor = UIColor.fontBlue
        
        lastCompletedLabel.text = "Last completed session on\n DD MMM YYYY"
        lastCompletedLabel.font = UIFont.bodyMed
        lastCompletedLabel.numberOfLines = 0
        lastCompletedLabel.textColor = UIColor.fontBlue
        
        topStackViews = [therapyTitleLabel, therapySubtitleLabel]
        
        innerStack = UIStackView(arrangedSubviews: topStackViews)
        innerStack.alignment = .fill
        innerStack.distribution = .equalSpacing
        innerStack.axis = .vertical
        
        viewHistoryButton.toSecondary()
        therapyButton.translatesAutoresizingMaskIntoConstraints = false
        therapyButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        
        buttonStack = UIStackView(arrangedSubviews: [viewHistoryButton, therapyButton])
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
        //contentView.addSubview(buttonStack)
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            outerButtonStack = UIStackView(arrangedSubviews: [buttonStack])
        }
        else{
            let spaceView = UIView()
            outerButtonStack = UIStackView(arrangedSubviews: [spaceView, buttonStack])
            outerButtonStack.translatesAutoresizingMaskIntoConstraints = false
            
            let widthConstraint = outerButtonStack.arrangedSubviews[1].widthAnchor.constraint(equalTo: outerButtonStack.widthAnchor, multiplier: 0.6)
            widthConstraint.priority = UILayoutPriority(999)
            NSLayoutConstraint.activate([
                widthConstraint
            ])
        }
        
        outerStack = UIStackView(arrangedSubviews: [innerStack, lastCompletedLabel, outerButtonStack])
        //outerStack = UIStackView(arrangedSubviews: [innerStack, lastCompletedLabel, buttonStack])
        outerStack.alignment = .fill
        outerStack.distribution = .equalSpacing
        outerStack.spacing = 24
        outerStack.axis = .vertical
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(outerStack)
        
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            outerStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            outerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            outerStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        
        //addShadow()
        therapyButton.addTarget(self, action: #selector(tapEvent), for: .touchDown)
        viewHistoryButton.addTarget(self, action: #selector(tappedViewHistory), for: .touchDown)
    }
    
    @objc func tapEvent(){
        delegate?.tappedTherapyButton()
    }
    
    @objc func tappedViewHistory() {
        delegate?.tappedViewHistoryButton()
    }
    
    func setupView(lastTherapy:String = "", progressNum: Int = 0, progressDenom: Int = 0, battery: Int = 0, connected: Bool = false, therapyRunning: Bool = false , paired: Bool = false){
        lastCompletedLabel.text = ""
        lastCompletedLabel.text = lastTherapy.isEmpty ? "" : "Last completed session on " + lastTherapy + "."
        lastCompletedLabel.isHidden = lastTherapy.isEmpty
        
        //buttons
        if paired
        {
            therapyButton.setTitle(therapyRunning ? "Therapy in progress" : "Start Therapy", for: .normal)
        }else
        {
            therapyButton.setTitle( "Pair Controller", for: .normal)
        }
       
        viewHistoryButton.setTitle("View History", for: .normal)
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
