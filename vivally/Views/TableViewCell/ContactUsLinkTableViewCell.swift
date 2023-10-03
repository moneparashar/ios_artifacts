//
//  ContactUsLinkTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 5/22/23.
//

import UIKit

protocol ContactUsLinkTableViewCellDelegate{
    func tappedEmail(_ sender: AnyObject)
}
class ContactUsLinkTableViewCell: UITableViewCell {

    var leadingLabel = UILabel()
    var endLabel = UIButton()
    
    var delegate:ContactUsLinkTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        leadingLabel.font  = UIFont.bodyLarge
        leadingLabel.textColor = UIColor.fontBlue
        leadingLabel.numberOfLines = 0
        leadingLabel.textAlignment = .left
        
        endLabel.titleLabel?.font = UIFont.h5
        endLabel.setTitleColor(UIColor.wedgewoodBlue, for: .normal)
        endLabel.contentHorizontalAlignment = .right
        endLabel.titleLabel?.numberOfLines = 0
        
        endLabel.addTarget(self, action: #selector(tappedEndButton), for: .touchDown)
        
        let stack = UIStackView(arrangedSubviews: [leadingLabel, endLabel])
        
        stack.alignment = .center
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 15
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        stack.arrangedSubviews[1].setContentCompressionResistancePriority(.required, for: .vertical)
        stack.arrangedSubviews[0].setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    @objc func tappedEndButton(){
        delegate?.tappedEmail(endLabel)
    }
    
    func setupView(leadText: String, trailText: String, underline: Bool = false){
        
        // underline  end label text
        if underline {
            let underline: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue]
            let underlinedLeadText = NSMutableAttributedString(
                string: trailText,
                attributes: underline
                )
            
            endLabel.setAttributedTitle(underlinedLeadText, for: .normal)

        // normal end label text
        } else {
            endLabel.setTitle(trailText, for: .normal)
        }
        
        leadingLabel.text = leadText
        endLabel.sizeToFit()
    }
    
    
}
