//
//  LifeOptionView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 9/6/22.
//

import UIKit

protocol lifeButtonDelegate{
    func didTapLifeIcon()
}

class LifeOptionView: UIView {

    var lifeTypeLabel = UILabel()
    var lifeIcon = UIImageView()
    var boxButton = UIButton()
    
    var openBox = UIImage(named: "checkbox")
    var selectBox = UIImage(named: "checkbox_selected")
    
    var delegate:lifeButtonDelegate?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure(){
        lifeTypeLabel.textAlignment = .right
        lifeTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        lifeIcon.translatesAutoresizingMaskIntoConstraints = false
        boxButton.setImage(openBox, for: .normal)
        boxButton.setImage(selectBox, for: .selected)
        boxButton.setImage(selectBox, for: .highlighted)
        boxButton.translatesAutoresizingMaskIntoConstraints = false
        boxButton.addTarget(self, action: #selector(tappedLifeBox), for: .touchUpInside)
        
        self.addSubview(lifeTypeLabel)
        self.addSubview(lifeIcon)
        self.addSubview(boxButton)
        
        NSLayoutConstraint.activate([
            boxButton.topAnchor.constraint(equalTo: self.topAnchor),
            boxButton.rightAnchor.constraint(equalTo: self.rightAnchor),
            boxButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            boxButton.widthAnchor.constraint(equalTo: boxButton.heightAnchor),
            boxButton.leftAnchor.constraint(equalTo: lifeIcon.rightAnchor, constant: 12),
            
            lifeIcon.widthAnchor.constraint(equalTo: lifeIcon.heightAnchor),
            lifeIcon.widthAnchor.constraint(equalToConstant: 20),
            lifeIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            lifeIcon.leftAnchor.constraint(equalTo: lifeTypeLabel.rightAnchor, constant: 10),
            
            lifeTypeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            lifeTypeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    @objc func tappedLifeBox(){
        boxButton.isSelected = !boxButton.isSelected
        delegate?.didTapLifeIcon()
    }
}
