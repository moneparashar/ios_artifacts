//
//  TextFieldStackView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/12/22.
//

import UIKit

protocol TextFieldStackViewDelegate{
    func tappedDropdown()
}

class TextFieldStackView: UIView {

    var delegate:TextFieldStackViewDelegate?
    
    var stack = UIStackView()
    var titleLabel = UILabel()
    var tf = UITextField()
    var errorText = UITextField()
    var secure = false
    
    var allowErrorImage = true
     
    fileprivate var eyeOpenedImage: UIImage
    fileprivate var eyeClosedImage: UIImage
    
    override init(frame: CGRect) {
        self.eyeOpenedImage = UIImage(systemName: "eye")!.withRenderingMode(.alwaysTemplate)
        self.eyeClosedImage = UIImage(systemName: "eye.slash")!.withRenderingMode(.alwaysTemplate)
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        self.eyeOpenedImage = UIImage(systemName: "eye")!.withRenderingMode(.alwaysTemplate)
        self.eyeClosedImage = UIImage(systemName: "eye.slash")!.withRenderingMode(.alwaysTemplate)
        super.init(coder: coder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func configure() {
        titleLabel.font = UIFont.h6
        titleLabel.textAlignment = .left
        
        tf.textAlignment = .left
        tf.layer.borderColor = UIColor.casperBlue?.cgColor
        tf.layer.borderWidth = 1.2
        tf.layer.cornerRadius = 4
        tf.clearsOnBeginEditing = false
        tf.autocapitalizationType = .none
        tf.textColor = UIColor.fontBlue
        
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: tf.frame.height))
        tf.leftViewMode = .always
        
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: tf.frame.height))
        tf.rightViewMode = .always
        
        errorText.font = UIFont.bodySm
        errorText.textColor = UIColor.error
        errorText.textAlignment = .left
        errorText.borderStyle = .none
        errorText.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: errorText.frame.height))
        errorText.leftViewMode = .always
        errorText.isEnabled = false
        
        stack = UIStackView(arrangedSubviews: [titleLabel, tf, errorText])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        stack.setCustomSpacing(0, after: tf)
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
    }
    
    func resetErrorMessage(){
        tf.layer.borderColor = UIColor.casperBlue?.cgColor
        errorText.text = " "
        
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: tf.frame.height))
        tf.rightViewMode = .always
    }
    
    func setErrorMessage(message: String){
        tf.layer.borderColor = UIColor.error?.cgColor
        errorText.text = message
        
        if allowErrorImage{
            let errorImageView = UIImageView(image: (UIImage(named: "errorMessagingSymbol")?.withRenderingMode(.alwaysTemplate)))
            errorImageView.tintColor = UIColor.error
            
            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: errorImageView.frame.width + 16, height: errorImageView.frame.height))
            rightView.addSubview(errorImageView)
            
            tf.rightView = rightView
            tf.rightViewMode = .always
        }
    }
    
    func setup(title: String, placeholder: String = "", toggle: Bool = false, dropDown: Bool = false, search: Bool = false,keyboardType: UIKeyboardType? = nil){
        titleLabel.text = title
        tf.placeholder = placeholder
        //add handling for password toggle
        if let keyboardType = keyboardType {
            tf.keyboardType = keyboardType
        }
        errorText.text = " "
        allowErrorImage = true
        if toggle{
            allowErrorImage = false
            passwordToggle()
        }
        
        else if dropDown{
            allowErrorImage = false
            addDropDown()
        }
        else if search{
            allowErrorImage = false
            addSearch()
        }
    }
    
    var eyeIcon = UIImageView(image: UIImage(systemName: "eye.slash"))
    private func passwordToggle(){
        secure = true
        tf.isSecureTextEntry = secure
        eyeIcon.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedEye(_:)))
        eyeIcon.tintColor = UIColor.neutralGray
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: eyeIcon.frame.width + 28, height: eyeIcon.frame.height))
        rightView.addSubview(eyeIcon)
        rightView.addGestureRecognizer(tap)
       
        tf.rightView = rightView
        tf.rightViewMode = .always
    }
    
    private func addDropDown(){
        let dropDownImageView = UIImageView(image: UIImage(named: "arrow_down"))
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedDropDown(_:)))
        dropDownImageView.addGestureRecognizer(tap)
        dropDownImageView.isUserInteractionEnabled = true
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: dropDownImageView.frame.width + 16, height: dropDownImageView.frame.height))
        rightView.addSubview(dropDownImageView)
        tf.rightView = rightView
        tf.rightViewMode = .always
    }
    
    private func addSearch(){
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        
        searchIcon.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedDropDown(_:)))
        searchIcon.addGestureRecognizer(tap)
        searchIcon.tintColor = UIColor(named: "avationMdGray")
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: searchIcon.frame.width + 16, height: searchIcon.frame.height))
        rightView.addSubview(searchIcon)
        tf.rightView = rightView
        tf.rightViewMode = .always
    }
    
    @objc func tappedEye(_ sender: UITapGestureRecognizer? = nil){
        secure = !secure
        tf.isSecureTextEntry = secure
        eyeIcon.image = secure ? eyeClosedImage : eyeOpenedImage
    }
    
    @objc func tappedDropDown(_ sender: UITapGestureRecognizer? = nil){
        delegate?.tappedDropdown()
    }
}
