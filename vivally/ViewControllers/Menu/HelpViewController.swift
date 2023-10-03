//
//  HelpViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 10/6/21.
//

import UIKit

import AVKit

public enum HelpSections: Int, CaseIterable{
    case none = 0   //values are of their type
    case garment = 1
    case pair = 2
    case conduct = 3
    case journal = 4
}

class HelpViewController: BaseNavViewController {

    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    
    var preRollSection:HelpSections = .none
    
    var tableRows:[HelpSections] = [.garment, .pair, .conduct, .journal]
        
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.goBackEnabled = true
        //super.clearRightBarItems = true
        super.showOnlyRightLogo = true
        super.viewDidLoad()

        contentWidthConstraint.constant = view.getWidthConstant()
        
        getTableOrder()
        // Do any additional setup after loading the view.
        if preRollSection != .none{
            HelpManager.sharedInstance.playSectionVideo(vc: self, helpInfo: preRollSection)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "HelpCell")
        tableView.clipsToBounds = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func getTableOrder(){
        tableRows = []
        if let allTimestamps = HelpManager.sharedInstance.helpSet?.timestamps{
            let sortedTimestamps = allTimestamps.sorted(by: {$0.sequence < $1.sequence})
            for sect in sortedTimestamps{
                tableRows.append(HelpSections(rawValue:sect.type) ?? .none)
            }
        }
    }
}

extension HelpViewController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableRows.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath) as! ProfileTableViewCell
        
        switch tableRows[indexPath.section]{
        case .none:
            cell.setup(title: "")
        case .pair:
            cell.setup(title: "Pairing Controller")
        case .garment:
            cell.setup(title: "Placing Garment and Gel Cushions")
        case .conduct:
            cell.setup(title: "Conduct a Therapy Session")
        case .journal:
            cell.setup(title: "Using the eDiary")
        }
        cell.layer.cornerRadius = 15
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableRows[indexPath.section]{
        case .none:
            return
        case .pair, .garment, .conduct, .journal:
            HelpManager.sharedInstance.playSectionVideo(vc: self, helpInfo: tableRows[indexPath.section])
        }
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.0
        }
        return 10
    }
}
