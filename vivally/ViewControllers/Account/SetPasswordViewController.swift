//
//  SetPasswordViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 5/18/21.
//

import UIKit

class SetPasswordViewController: UIViewController {

    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var passwordTextField: EntryTextField!
    @IBOutlet weak var confirmPasswordTextField: EntryTextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func setPasswordTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToSetPin", sender: self)
    }
    
    

}
