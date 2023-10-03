//
//  PatientSideMenuViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 5/10/21.
//

import UIKit

enum PatientSideMenuMainPages:Int{
    case home
    case homeSeparator
    case therapy
    case journal
    case journalSeparator
    case bluetoothStatus
    case wifiStatus
    case devicePairing
    case deviceStatus
    case subjectManual
    case help
    case settings
    case privacy
    case contactUs
}

protocol PatientSideMenuViewControllerDelegate {
    func selectedCell(_ row: Int)
}

class PatientSideMenuViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var defaultHighlightedCell: Int = 0
    
    var delegate:PatientSideMenuViewControllerDelegate?
    
    let mainPages:[PatientSideMenuMainPages] = [.home, .homeSeparator, .therapy, .journal, .journalSeparator, .bluetoothStatus, .wifiStatus, .devicePairing, .deviceStatus, .subjectManual, .help,  .settings, .privacy, .contactUs]
    let isSubmenu:[Bool] = [false, false, false, false, false, true, true, true, true, true, true, true, true, true]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    

    @IBAction func closeButtonTapped(_ sender: Any) {
        revealViewController()?.revealSideMenu()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PatientSideMenuViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainPages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainPageCell", for: indexPath) as! PatientMenuTableViewCell
        cell.setupView(page: mainPages[indexPath.row], isSubMenu: isSubmenu[indexPath.row])
        if indexPath.row == 1 || indexPath.row == 4{
            cell.isUserInteractionEnabled = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.selectedCell(indexPath.row)
    }
}
