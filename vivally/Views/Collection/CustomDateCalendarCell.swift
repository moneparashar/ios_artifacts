//
//  CustomDateCalendarCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 11/10/22.
//

import UIKit
import FSCalendar



class CustomDateCalendarCell: FSCalendarCell{
    
    weak var therapyImageView: UIImageView!
    
    var backView: UIView = UIView()
    
    //var selectView: UIView = UIView()
    var selectImageView: UIImageView = UIImageView(image: UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysTemplate))
    var currentDateImageView: UIImageView = UIImageView(image: UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysTemplate))
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        //back
        self.contentView.insertSubview(backView, belowSubview: self.titleLabel)
        backView.backgroundColor = UIColor.lavendarMist
        
        //selected
        selectImageView.tintColor = UIColor.androidGreen
        contentView.insertSubview(selectImageView, belowSubview: titleLabel)
        
        // current date
        currentDateImageView.tintColor = UIColor.gray
        contentView.insertSubview(currentDateImageView, belowSubview: selectImageView)
        
        //therapy
        let therapyImageView = UIImageView(image: UIImage(named: "journal_therapy_day")!)
        //self.contentView.insertSubview(therapyImageView, at: 1)
        contentView.insertSubview(therapyImageView, belowSubview: titleLabel)
        self.therapyImageView = therapyImageView
        
        //selectView.backgroundColor = UIColor.androidGreen
        
        
        //self.contentView.insertSubview(selectView, belowSubview: titleLabel)
        //selectView.isHidden = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shapeBounds = self.shapeLayer.bounds
        
        let titlePadHeight = (self.titleLabel.bounds.height - self.shapeLayer.bounds.height) / 2
        self.therapyImageView.frame = CGRect(x: self.contentView.bounds.midX - (shapeBounds.width / 2), y: self.titleLabel.bounds.minY + titlePadHeight, width: shapeBounds.width, height: shapeBounds.height)
        
        
        self.backView.frame = self.titleLabel.frame
        
        //selectView.frame = therapyImageView.frame
        selectImageView.frame = therapyImageView.frame
        currentDateImageView.frame = therapyImageView.frame
    }
    
    /*
    func drawCircle(){
        let dLineWidth:CGFloat = 1.0
        let halfSize:CGFloat = selectView.bounds.size.width / 4
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: halfSize, y: halfSize),
            radius: CGFloat(halfSize - (dLineWidth/2)),
            startAngle: 0,
            endAngle: CGFloat(Double.pi * 2),
            clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1
        selectView.layer.addSublayer(shapeLayer)
    }
    */
}
