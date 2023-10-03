//
//  RoundedView.swift
//  vivally
//
//  Created by Joe Sarkauskas on 3/3/22.
//

import UIKit

class RoundedView: UIView {

    var cornerRadius:CGFloat = 12
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
      
    }
    
    private func configure() {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
    }
}
