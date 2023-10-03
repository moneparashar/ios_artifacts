//
//  SettingDemoModeTableViewCell.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 10/12/21.
//

import UIKit

enum StimModes {
    case lowStim
    case noStim
}

class SettingDemoModeTableViewCell: UITableViewCell {

    @IBOutlet weak var demoMD: MDTextFieldView!
    var enablePicker = ToolbarPickerView()
    let enableValues = ["LOW SITM", "NO STIM"]
    var enableSelected:StimModes = .lowStim
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView(){
        setupEnableDropdown()
    }
    
    func setupEnableDropdown(){
        demoMD.tF.inputView = enablePicker
        demoMD.tF.inputAccessoryView = enablePicker.toolbar
        
        self.enablePicker.dataSource = self
        self.enablePicker.delegate = self
        self.enablePicker.toolbarDelegate = self
        
        self.enablePicker.reloadAllComponents()
        
        let dropIcon = UIImageView(image: UIImage(named: "arrow_icon"))
        demoMD.tF.trailingView = dropIcon
        demoMD.tF.trailingViewMode = .always
    }
    
    func updateEnableDropdown(){
        switch enableSelected {
        case .lowStim:
            demoMD.tF.text = "LOW STIM"
        case .noStim:
            demoMD.tF.text = "NO STIM"
        }
    }
}

extension SettingDemoModeTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate, ToolbarPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return enableValues.count
    }
    
    func didTapDone(pickerView: ToolbarPickerView) {
        
        updateEnableDropdown()
        demoMD.tF.resignFirstResponder()
    }
    
    func didTapCancel(pickerView: ToolbarPickerView) {
        updateEnableDropdown()
        demoMD.tF.resignFirstResponder()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        demoMD.tF.text = enableValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return enableValues[row]
    }
    
}
