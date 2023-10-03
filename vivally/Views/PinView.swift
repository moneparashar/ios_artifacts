//
//  PinView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/1/22.
//
// TODO: add masking for pin logic

import UIKit

protocol PinViewDelegate{
    func didFillView()
}
class PinView: UIView {
    
    @IBOutlet weak var eyeButton: UIButton!

    var delegate:PinViewDelegate?
    var pinTextFieldsArray:[UITextField] = []
    
    var pinDict:[UITextField: Int] = [:]
    var pinCount = 4
    
    var stack = UIStackView()
    
    var spacingToPinWidthMultiplier:Double = 3/26
    var pinWidthRatio = 0.0
    
    var secure = true

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    /*
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
        configure()
    }
    */
    
    required init(fieldNum: Int){
        pinCount = fieldNum
        
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if AccountManager.sharedInstance.comingFromEmailLogin == false {
            enlargeEye()
        }
    }
    */
    
    // Mask pin
    @IBAction func tappedEye(_ sender: UIButton) {
        eyeButton.isSelected = !eyeButton.isSelected
        secure = !secure
        
        for pins in pinTextFieldsArray{
            pins.isSecureTextEntry = secure
        }
    }

    private func configure() {
        for num in 0 ..< pinCount{
            //let txtfield = UITextField()
            let txtfield = SingleTextField()
            pinTextFieldsArray.append(txtfield)
            pinDict[txtfield] = num
        }
        
        for i in pinTextFieldsArray{
            i.textAlignment = .center
            i.font = UIFont.bodyLarge
            i.backgroundColor = UIColor.lilyWhite
            i.layer.borderColor = UIColor.casperBlue?.cgColor
            i.layer.borderWidth = 1.2
            i.layer.cornerRadius = 4
            i.keyboardType = .numberPad
            i.delegate = self
            i.clearsOnBeginEditing = false
            
            i.addTarget(self, action: #selector(textfieldDidChange(_:)), for: .editingChanged)
        }
        
        stack = UIStackView(arrangedSubviews: pinTextFieldsArray)
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            //stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        calcWidths()
        for box in stack.arrangedSubviews{
            NSLayoutConstraint.activate([
                box.heightAnchor.constraint(equalTo: box.widthAnchor, multiplier: 15/13),
                //box.widthAnchor.constraint(greaterThanOrEqualToConstant: 52)
                box.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/CGFloat(pinWidthRatio))
            ])
        }
        
        // secure pins before user presses eye icon
        for pins in pinTextFieldsArray{
            pins.isSecureTextEntry = true
        }
    }
    
    func calcWidths(){
        pinWidthRatio = Double(pinCount) + Double(pinCount) * spacingToPinWidthMultiplier - spacingToPinWidthMultiplier
    }
    
    // Makes eye image slightly larger
    func enlargeEye() {
        eyeButton.contentVerticalAlignment = .fill
        eyeButton.contentHorizontalAlignment = .fill
        eyeButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func getPIN()->String{
        var pinStr = ""
        for p in pinTextFieldsArray{
            pinStr += p.text ?? ""
        }
        return pinStr
    }
    
    func clearAll(){
        for tfv in pinTextFieldsArray{
            tfv.text = ""
        }
        pinTextFieldsArray.last?.resignFirstResponder()
    }
    
    @objc func textfieldDidChange(_ textField: UITextField) {
        let ind = pinDict[textField] ?? 0
        
        if textField.text != ""{
            if ind == pinCount - 1{
                delegate?.didFillView()
            }
            else{
                pinTextFieldsArray[ind + 1].becomeFirstResponder()
            }
        }
        else{       //for when deletion occurs
            if ind != 0{
                pinTextFieldsArray[ind - 1].becomeFirstResponder()
            }
        }
    }
    
    @objc func didTapTextfield(_ textField: UITextField) {
        //clearAll()
        //pinTextFieldsArray[0].becomeFirstResponder()
        
        
    }
}
extension PinView: SingleTextFieldDelegate{
    func didPressBackspace(_ textfield: SingleTextField) {
        print("backspace pressed")
        textfieldDidChange(textfield)
    }
    
//extension PinView: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var ind = 0
        for tf in pinTextFieldsArray{
            if pinTextFieldsArray[ind].text == ""{
                if pinDict[textField] ?? 0 > ind{
                    tf.becomeFirstResponder()
                    return false
                }
                
            }
            ind += 1
        }
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.wedgewoodBlue?.cgColor
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.casperBlue?.cgColor
    }
    
    //ensure only 1 digit passed
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 1{
            return false
        }
        if textField.text?.count ?? 0 > 0{
            textField.text?.removeLast()
        }
        print("should change call")
        
        
        return true
    }
}

protocol SingleTextFieldDelegate: UITextFieldDelegate{
    func didPressBackspace(_ textfield: SingleTextField)
}
class SingleTextField: UITextField{
    override func deleteBackward() {
        super.deleteBackward()
        if let pinDelegate = self.delegate as? SingleTextFieldDelegate{
            pinDelegate.didPressBackspace(self)
        }
    }
}
