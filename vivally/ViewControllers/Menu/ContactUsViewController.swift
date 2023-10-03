//
//  ContactUsViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 4/23/21.
//

import UIKit
import MessageUI

enum ContactCells{
    case email
    case phone
    case address
    
    func getStrs() -> [String]{
        switch self {
        case .email:
            return ["Email", "customercare@avation.com"]
        case .phone:
            return ["Phone number", "1 888 972 5694"]
        case .address:
            return ["Address", "1375 Perry Street,\nColumbus, OH 43201"]
        }
    }
}

class ContactUsViewController: BaseNavViewController {
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    var tableRows:[ContactCells] = [.email, .phone, .address]
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.clearRightBarItems = true
        super.viewDidLoad()
        
        title = "Contact Us"
        
        contentWidth.constant = view.getWidthConstant()

        tableView.register(ContactUsTableViewCell.self, forCellReuseIdentifier: "contactCell")
        tableView.register(ContactUsLinkTableViewCell.self, forCellReuseIdentifier: "emailCell")
        
        appVersionLabel.text = "App version: " +  (UIApplication.appVersion ?? "") + "." + (UIApplication.build ?? "")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layer.backgroundColor = UIColor.lilyWhite?.cgColor
        tableView.layer.cornerRadius = 15
        tableView.layer.borderWidth =  1
        tableView.layer.borderColor = UIColor.casperBlue?.cgColor
        
        tableView.contentInset = UIEdgeInsets(top: tableInset, left: 0, bottom: 0, right: 0)
        tableView.isScrollEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        setHeight()
    }
    
    var tableInset:CGFloat = 8
    
    @IBAction func contactLinkTapped(_ sender: Any) {
        let urlStr = "https://www.avation.com"
        if let url = URL(string:urlStr), !url.absoluteString.isEmpty {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
    }
    
    func setHeight(){
        var h: CGFloat = 0
        if tableView.visibleCells.count == tableRows.count{
            for cell in tableView.visibleCells{
                h += cell.bounds.height
            }
            tableHeight.constant = h + tableInset
        }
    }
}

extension ContactUsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableRows[indexPath.row] == .email{
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath) as! ContactUsLinkTableViewCell
            let strs = tableRows[indexPath.row].getStrs()
            if strs.count == 2{
                cell.setupView(leadText: strs[0], trailText: strs[1], underline: true)
            }
            cell.delegate = self
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactUsTableViewCell
            
            let strs = tableRows[indexPath.row].getStrs()
            if strs.count == 2{
                cell.setupView(leadText: strs[0], trailText: strs[1])
            }
            return cell
        }
    }
}

extension ContactUsViewController:ContactUsLinkTableViewCellDelegate{
    func tappedEmail(_ sender: AnyObject) {
        //this will fail on stimulators, use actual device
        if MFMailComposeViewController.canSendMail(){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["customercare@avation.com"])
            
            self.present(mail, animated: true)
        }
        
    }
}

extension ContactUsViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
