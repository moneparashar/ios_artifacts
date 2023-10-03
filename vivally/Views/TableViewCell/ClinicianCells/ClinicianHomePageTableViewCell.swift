//
//  ClinicianHomePageTableViewCell.swift
//  vivally
//
//  Created by Ryan Levels on 1/31/23.
//

// TODO: fix shadows and corner radius

import UIKit

class ClinicianHomePageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var rowShadowView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupView(patient: PatientExists) {
        patientNameLabel.text = ""
        
        let first = patient.firstName ?? ""
        var mid = patient.middleName ?? ""
        var last = patient.lastName ?? ""
        
        patientNameLabel.text = mid.isEmpty ? "\(first) \(last)" : "\(first) \(mid) \(last)"
        
        addDimensionsAndShadow()
    }
    
    func addDimensionsAndShadow(){
        contentView.backgroundColor = UIColor.clear
        
        mainView.layer.cornerRadius = 10
        mainView.backgroundColor = UIColor.lilyWhite
        mainView.clipsToBounds = true
        
        rowShadowView.layer.cornerRadius = 10
        rowShadowView.clipsToBounds = false
    }
}
