//
//  DropdownOriginView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 4/19/23.
//

import UIKit
import DropDown

protocol DropdownOriginViewDelegate{
    func dropSelected(ind: Int, option: String, sender: DropdownOriginView)
}

class DropdownOriginView: UIView{
    
    var delegate:DropdownOriginViewDelegate?
    
    var open = false
    
    var stack = UIStackView()
    var titleLabel = UILabel()
    var dropViewOrigin = UIView()
    var errorLabel = UILabel()
    
    var dropStack = UIStackView()
    var contentLabel = UILabel()
    var placeholderLabel = UILabel()
    var dropDownImage = UIImageView()
    
    var dropDown = DropDown()
    
    var upArrow = UIImage(named: "UpChevron")?.withRenderingMode(.alwaysTemplate)
    var downArrow = UIImage(named: "DownChevron")?.withRenderingMode(.alwaysTemplate)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure(){
        titleLabel.font = UIFont.h6
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.fontBlue
        
        dropViewOrigin.backgroundColor = UIColor.lilyWhite
        dropViewOrigin.layer.borderWidth = 1.2
        dropViewOrigin.layer.borderColor = UIColor.casperBlue?.cgColor
        dropViewOrigin.layer.cornerRadius = 6
        
        contentLabel.font = UIFont.bodyMed
        contentLabel.textColor = UIColor.fontBlue
        contentLabel.textAlignment = .left
        
        //check if this gets used for dropdowns
        placeholderLabel.font = UIFont.bodyMed
        placeholderLabel.textColor = UIColor.wedgewoodBlue
        placeholderLabel.textAlignment = .left
        
        dropDownImage.image = downArrow
        dropDownImage.tintColor = UIColor.wedgewoodBlue
        
        dropStack = UIStackView(arrangedSubviews: [contentLabel, placeholderLabel, dropDownImage])
        dropStack.spacing = 8
        dropStack.axis = .horizontal
        dropStack.alignment = .center
        dropStack.distribution = .fill
        
        dropStack.translatesAutoresizingMaskIntoConstraints = false
        dropStack.arrangedSubviews[2].setContentCompressionResistancePriority(.required, for: .horizontal)
        dropStack.arrangedSubviews[2].setContentHuggingPriority(.required, for: .horizontal)
    
        NSLayoutConstraint.activate([
            dropStack.arrangedSubviews[2].heightAnchor.constraint(equalTo: dropStack.arrangedSubviews[2].widthAnchor)
        ])
        dropStack.translatesAutoresizingMaskIntoConstraints = false
        dropViewOrigin.addSubview(dropStack)
        
        NSLayoutConstraint.activate([
            dropStack.leadingAnchor.constraint(equalTo: dropViewOrigin.leadingAnchor, constant: 16),
            dropStack.topAnchor.constraint(equalTo: dropViewOrigin.topAnchor),
            dropStack.centerXAnchor.constraint(equalTo: dropViewOrigin.centerXAnchor),
            dropStack.centerYAnchor.constraint(equalTo: dropViewOrigin.centerYAnchor)
        ])
    
        
        errorLabel.font = UIFont.bodySm
        errorLabel.textColor = UIColor.error
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        
        stack = UIStackView(arrangedSubviews: [titleLabel, dropViewOrigin, errorLabel])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            stack.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            stack.arrangedSubviews[1].heightAnchor.constraint(greaterThanOrEqualToConstant: 46)
        ])
        
        dropDown.anchorView = stack.arrangedSubviews[1]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        dropViewOrigin.addGestureRecognizer(tap)
        
        dropDown.cancelAction = { [unowned self] in
            open = false
            dropViewOrigin.layer.borderColor = UIColor.casperBlue?.cgColor
        }
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String)in
            open = false
            dropViewOrigin.layer.borderColor = UIColor.casperBlue?.cgColor
            contentLabel.text = item
            
            if contentLabel.isHidden && item != ""{
                contentLabel.isHidden = false
                placeholderLabel.isHidden = true
            }
            
            delegate?.dropSelected(ind: index, option: item, sender: self)
        }
    }
    
    @objc func handleTap(){
        open = !open
        if open{
            dropDown.bottomOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
            dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
            dropDown.show()
            dropViewOrigin.layer.borderColor = UIColor.regalBlue?.cgColor
        }
        else{
            dropDown.hide()
        }
    }
    
    func setup(title: String, content: String = "",placeholder: String = "", options: [String]){
        titleLabel.text = title
        contentLabel.text = content
        placeholderLabel.text = placeholder.isEmpty ? " " : placeholder
        errorLabel.text = " "
        
        //check to see if this doesn't cause any errors
        placeholderLabel.isHidden = !content.isEmpty
        contentLabel.isHidden = content.isEmpty
    
        dropDown.dataSource = options
    }
    
    func selectRow(ind: Int){
        dropDown.selectRow(at: ind)
        contentLabel.text = dropDown.selectedItem
        if contentLabel.isHidden && contentLabel.text?.isEmpty != true{
            contentLabel.isHidden = false
            placeholderLabel.isHidden = true
        }
    }
    
    func resetErrorMessage(){
        errorLabel.text = " "
    }
}

