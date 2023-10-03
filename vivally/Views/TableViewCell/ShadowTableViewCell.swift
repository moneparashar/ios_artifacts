//
//  ShadowTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 4/28/22.
//

import UIKit

class ShadowTableViewCell: UITableViewCell {

    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 10.0
    //private var fillColor: UIColor = .blue // the color applied to the shadowLayer, rather than the view's backgroundColor
    var fillColor: UIColor = .white
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.clear
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.black.cgColor
        layer.masksToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
          
        /* only works with bottom shadows
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        //self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.25
        self.layer.masksToBounds = false
       
        
        let bound = self.bounds
        let rect = CGRect(x: bound.minX, y: bound.midY, width: bound.width, height: (bound.height / 2))
        //let rect = CGRect(x: bound.minX, y: bound.minY, width: (bound.width), height: (bound.height))
        self.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: 15).cgPath
        */
        
        //new attempt
        
    }
    
}
