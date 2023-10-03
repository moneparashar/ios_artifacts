//
//  DropdownTextField.swift
//  vivally
//
//  Created by Joe Sarkauskas on 6/24/21.
//

import UIKit

class DropdownTextField: UITextField {
    
    struct Constants {
        static let sidePadding: CGFloat = 20
        static let topPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 5
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupView()
        //setShadow()
    }
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        //setShadow()
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    func setupView(){
        let imageView = UIImageView(image: UIImage(named: "dropdownArrow"))
        imageView.frame = CGRect(x: 0, y: 0, width: 12, height: 6)
        imageView.contentMode = .scaleAspectFit
        //imageView.transform = imageView.transform.rotated(by: .pi / 2)
        imageView.tintColor = UIColor(named: "avationMdGreen")
        // declare how much padding I want to have
        let padding: CGFloat = 11
        
        // create the view that would act as the padding
        let rightView = UIView(frame: CGRect(
                                x: 0, y: 0, // keep this as 0, 0
                                width: imageView.frame.width + padding, // add the padding
                                height: imageView.frame.height))
        rightView.addSubview(imageView)
        
        // set the rightView UIView as the textField's rightView
        self.rightViewMode = .always
        self.rightView = rightView
    }
    
    var isSublayerAdded:Bool = false
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: bounds.origin.x + Constants.sidePadding,
            y: bounds.origin.y + Constants.topPadding,
            width: bounds.size.width - Constants.sidePadding * 2,
            height: bounds.size.height - Constants.topPadding * 2
        )
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    
    func setShadow(){
        
        self.backgroundColor = UIColor(named: "avationBackground")
        
        let shadows = UIView()

        shadows.frame = bounds

        shadows.clipsToBounds = false
        shadows.isUserInteractionEnabled = false

        self.insertSubview(shadows, at: 0)


        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 5)

        let layer0 = CALayer()

        layer0.shadowPath = shadowPath0.cgPath

        layer0.shadowColor = UIColor(red: 1, green: 0.992, blue: 0.992, alpha: 1).cgColor

        layer0.shadowOpacity = 1

        layer0.shadowRadius = 4

        layer0.shadowOffset = CGSize(width: 0, height: -3)

        layer0.bounds = shadows.bounds

        layer0.position = shadows.center

        shadows.layer.addSublayer(layer0)


        let shadowPath1 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 5)

        let layer1 = CALayer()

        layer1.shadowPath = shadowPath1.cgPath

        layer1.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor

        layer1.shadowOpacity = 1

        layer1.shadowRadius = 4

        layer1.shadowOffset = CGSize(width: 0, height: 3)

        layer1.bounds = shadows.bounds

        layer1.position = shadows.center

        shadows.layer.addSublayer(layer1)


        let shapes = UIView()
        shapes.isUserInteractionEnabled = false
        shapes.frame = bounds
        shapes.clipsToBounds = true
        insertSubview(shadows, belowSubview: shadows)


        let layer2 = CALayer()

        layer2.backgroundColor = UIColor(red: 0.954, green: 0.954, blue: 0.954, alpha: 1).cgColor

        layer2.bounds = shapes.bounds

        layer2.position = shapes.center

        shapes.layer.addSublayer(layer2)


        shapes.layer.cornerRadius = 5

        shapes.layer.borderWidth = 1

        shapes.layer.borderColor = UIColor(red: 0.942, green: 0.942, blue: 0.942, alpha: 1).cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = Constants.cornerRadius
        
        if !isSublayerAdded{
            isSublayerAdded = true
            setShadow()
        }
        
        
    }
    
   /* private func addShadow() {
        
        isSublayerAdded = true
        
        self.borderStyle = .none
        self.backgroundColor = UIColor(named: "avationBackground")
        
        self.layer.cornerRadius = Constants.cornerRadius
        
        self.layer.borderWidth = 0.25
        self.layer.borderColor = UIColor(named: "avationBackground")!.cgColor
        
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4.0
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
    }*/
    
   
}
