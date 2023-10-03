//
//  JournalRangeHelpViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 2/2/23.
//

import UIKit

class JournalRangeHelpViewController: BaseNavViewController {

    @IBOutlet weak var leaksSubView: UIView!
    @IBOutlet weak var restroomSubView: UIView!
    @IBOutlet weak var fluidSubView: UIView!
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        contentWidth.constant = view.getWidthConstant()
        title = "eDiary entry help"
        
        fluidSubView.layer.cornerRadius = 10
        fluidSubView.layer.borderWidth = 1
        fluidSubView.layer.borderColor = UIColor.casperBlue?.cgColor
        
        leaksSubView.layer.cornerRadius = 10
        leaksSubView.layer.borderWidth = 1
        leaksSubView.layer.borderColor = UIColor.casperBlue?.cgColor
        
        restroomSubView.layer.cornerRadius = 10
        restroomSubView.layer.borderWidth = 1
        restroomSubView.layer.borderColor = UIColor.casperBlue?.cgColor
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
