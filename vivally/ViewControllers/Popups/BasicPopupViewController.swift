//
//  BasicPopupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 9/29/22.
//

import UIKit

protocol BasicPopupDelegate{
    func option1Selected()
    func option2Selected()
    func closeSelected()
    func videoSelected()
}

enum PopupIcons{
    case question
    case exclamation
    case warning
    case check
    
    func getIconImage() -> UIImage{
        switch self {
        case .question:
            return UIImage(named: "questionIcon") ?? UIImage()
        case .exclamation:
            return UIImage(named: "exclamationIcon") ?? UIImage()
        case .warning:
            return UIImage(named: "warningIcon") ?? UIImage()
        case .check:
            return UIImage(named: "checkIcon") ?? UIImage()
        }
    }
}

struct BasicPopupContent{
    var title = ""
    var message = ""
    var option1 = ""
    var option2 = ""
    var flipPrimary = false
    var xClose = true
    var videoMesssage = ""
    var icon: PopupIcons = .question
    
    init(title: String, message: String, option1: String, option2: String = "", flipPrimary: Bool = false, xClose: Bool = true, icon: PopupIcons = .question, videoMesssage: String = "") {
        self.title = title
        self.message = message
        self.option1 = option1
        self.option2 = option2
        self.flipPrimary = flipPrimary
        self.xClose = xClose
        self.videoMesssage = videoMesssage
        self.icon = icon
    }
}

class BasicPopupViewController: BasePopupViewController {

    var baseContent:BasicPopupContent?
    
    var delegate: BasicPopupDelegate?
    
    var icon = UIImageView()
    var titleLabel = UILabel()
    var messageView = UIView()
    var messageLabel = UILabel()
    var buttonStack = UIStackView()
    var option1Button = ActionButton()
    var option2Button = ActionButton()
    
    var closeButton = UIButton()
    var videoLabel = UILabel()
    var playButton = UIButton()
    
    var contentPadding:CGFloat = 24
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if baseContent != nil{
            setupPopupViewViaStacks()
        }
    }
    
    var videoStack = UIStackView()
    var popStack = UIStackView()
    func setupPopupViewViaStacks(){
        icon = UIImageView(image: baseContent?.icon.getIconImage())
        let iconParentView = UIView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconParentView.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: iconParentView.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconParentView.centerYAnchor),
            icon.leadingAnchor.constraint(greaterThanOrEqualTo: iconParentView.leadingAnchor),
            icon.topAnchor.constraint(equalTo: iconParentView.topAnchor),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1)
        ])
        
        titleLabel.text = baseContent!.title
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.h4
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.numberOfLines = 0
        
        messageLabel.text = baseContent!.message
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.bodyMed
        messageLabel.textColor = UIColor.fontBlue
        messageLabel.numberOfLines = 0
        
        option1Button.setTitle(baseContent!.option1, for: .normal)
        buttonStack = UIStackView(arrangedSubviews: [option1Button])
        if baseContent!.option2 != ""{
            option2Button.setTitle(baseContent!.option2, for: .normal)
            
            (baseContent?.flipPrimary ?? false) ? option1Button.toSecondary() : option2Button.toSecondary()
            buttonStack = UIStackView(arrangedSubviews: [option1Button, option2Button])
            buttonStack.distribution = .fillEqually
            buttonStack.spacing = 24
        }
        
        
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        var headerStack = UIStackView(arrangedSubviews: [iconParentView])
        if baseContent?.xClose == true && UIDevice.current.userInterfaceIdiom == .phone{
            let spacer = UIView()
            headerStack = UIStackView(arrangedSubviews: [spacer, iconParentView, closeButton])
            headerStack.alignment = .center
            headerStack.distribution = .equalCentering
        }
        
        popStack = UIStackView(arrangedSubviews: [headerStack, titleLabel, messageLabel, buttonStack])
        if baseContent!.videoMesssage != ""{
            videoLabel.text = baseContent!.videoMesssage
            videoLabel.textAlignment = .right
            videoLabel.numberOfLines = 0
            
            playButton.setImage(UIImage(named: "play_video"), for: .normal)
            videoStack = UIStackView(arrangedSubviews: [videoLabel, playButton])
            videoStack.alignment = .fill
            videoStack.distribution = .fill
            videoStack.spacing = 10
            videoStack.arrangedSubviews[1].setContentCompressionResistancePriority(.required, for: .horizontal)
            NSLayoutConstraint.activate([
                videoStack.arrangedSubviews[1].widthAnchor.constraint(equalTo: videoStack.arrangedSubviews[1].heightAnchor)
            ])
            
            popStack = UIStackView(arrangedSubviews: [headerStack, titleLabel, messageLabel, buttonStack, videoStack])
        }
        
        popStack.axis = .vertical
        popStack.alignment = .fill
        popStack.distribution = .fill
        popStack.spacing = 30
        
        popStack.arrangedSubviews[0].setContentCompressionResistancePriority(.required, for: .horizontal)
        
        UIDevice.current.userInterfaceIdiom == .phone ? setPhoneLayouts() : setTabletLayouts()
        setTargets()
    }
    
    var rootStack = UIStackView()
    func setTabletLayouts(){
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        
        rootStack = baseContent?.xClose == true ? UIStackView(arrangedSubviews: [leftSpacer, popStack, closeButton]) : UIStackView(arrangedSubviews: [leftSpacer, popStack, rightSpacer])
        rootStack.alignment = .top
        rootStack.distribution = .equalSpacing
        
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
            rootStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            rootStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentPadding),
            rootStack.arrangedSubviews[1].widthAnchor.constraint(equalToConstant: view.getWidthConstant())
        ])
    }
    
    func setPhoneLayouts(){
        popStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(popStack)
        
        NSLayoutConstraint.activate([
            popStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
            popStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            popStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            popStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentPadding)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func setTargets(){
        option1Button.addTarget(self, action: #selector(tappedOption1(_:)), for: .touchUpInside)
        if baseContent?.option2 != ""{
            option2Button.addTarget(self, action: #selector(tappedOption2(_:)), for: .touchUpInside)
        }
        if baseContent?.xClose == true{
            closeButton.addTarget(self, action: #selector(tappedClose(_:)), for: .touchUpInside)
        }
        if baseContent?.videoMesssage != ""{
            playButton.addTarget(self, action: #selector(tappedVideo(_:)), for: .touchUpInside)
        }
        
    }
    
    @objc func tappedOption1(_ sender: UIButton){
        delegate?.option1Selected()
    }
    
    @objc func tappedOption2(_ sender: UIButton){
        delegate?.option2Selected()
    }
    
    @objc func tappedClose(_ sender: UIButton){
        delegate?.closeSelected()
    }
    
    @objc func tappedVideo(_ sender: UIButton){
        delegate?.videoSelected()
    }
}
