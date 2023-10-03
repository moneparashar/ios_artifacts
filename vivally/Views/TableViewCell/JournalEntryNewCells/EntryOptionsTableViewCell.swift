//
//  EntryOptionsTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 1/2/23.
//

import UIKit
protocol EntryOptionTableViewCellDelegate{
    func tapChangeDate()
    func tapDeleteEntry()
}

class EntryOptionsTableViewCell: UITableViewCell {

    var changeDateButton = UIButton()
    var deleteEntryButton = UIButton()
    
    var calendarImage = UIImage(named: "calendar")?.withRenderingMode(.alwaysTemplate)
    var deleteImage = UIImage(named: "closeIcon")?.withRenderingMode(.alwaysTemplate)
    
    var stack = UIStackView()
    
    var delegate:EntryOptionTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure(){
        selectionStyle = .none
        
        changeDateButton.setTitle("Change date", for: .normal)
        changeDateButton.setImage(calendarImage, for: .normal)
        changeDateButton.tintColor = UIColor.regalBlue
        
        deleteEntryButton.setTitle("Delete Entry", for: .normal)
        deleteEntryButton.setImage(deleteImage, for: .normal)
        deleteEntryButton.tintColor = UIColor.regalBlue
        
        stack = UIStackView(arrangedSubviews: [changeDateButton, deleteEntryButton])
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor)
        ])
        
        changeDateButton.addTarget(self, action: #selector(tappedDate), for: .touchDown)
        deleteEntryButton.addTarget(self, action: #selector(tappedDelete), for: .touchDown)
    }
    
    @objc func tappedDate(){
        delegate?.tapChangeDate()
    }
    
    @objc func tappedDelete(){
        delegate?.tapDeleteEntry()
    }
}
