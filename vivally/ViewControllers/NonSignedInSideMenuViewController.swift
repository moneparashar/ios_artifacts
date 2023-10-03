//
//  NonSignedInSideMenuViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 10/20/21.
//

import UIKit

enum NonSignedInSideMenuMainPages:Int{
    case bluetoothStatus
    case wifiStatus
    case contactUs
}

protocol NonSignedInSideMenuViewControllerDelegate {
    func selectedCell(_ row: Int)
}

class NonSignedInSideMenuViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var defaultHighlightedCell: Int = 0
    
    var delegate:NonSignedInSideMenuViewControllerDelegate?
    
    let mainPages:[NonSignedInSideMenuMainPages] = [.bluetoothStatus, .wifiStatus, .contactUs]
    let isSubmenu:[Bool] = [true, true, true]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        //revealNonSignedInViewController()?.revealSideMenu()
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

extension NonSignedInSideMenuViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainPages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NonSignedInPageCell", for: indexPath) as! NonSignedInMenuTableViewCell
        cell.setupView(page: mainPages[indexPath.row], isSubMenu: isSubmenu[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.selectedCell(indexPath.row)
    }
    
    
}
