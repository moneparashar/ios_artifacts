/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation
import UIKit


extension UINavigationController {
    func popViewControllerWithHandler(completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: true)
        CATransaction.commit()
    }
    func pushViewController(viewController: UIViewController, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func displayErrorDialog(message:String, title:String,_ action:UIAlertAction? = nil){
        let errorMessage = NSLocalizedString(message, comment: "")
        let alertController = UIAlertController(title: NSLocalizedString(title, comment: ""), message: errorMessage, preferredStyle: .alert)
        
        let alertAction = action ?? UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayMessageDialog(message:String,_ action:UIAlertAction? = nil){
        let errorMessage = NSLocalizedString(message, comment: "")
        let alertController = UIAlertController(title: NSLocalizedString("Alert", comment: ""), message: errorMessage, preferredStyle: .alert)
        
        let alertAction = action ?? UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSuccessPopup(){
        let vc = PatientEnrollmentMessagePopupViewController()
        vc.status = .added
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false, completion: nil)
    }
    
    func showLoading(){
        if let oldView1 = self.view.viewWithTag(0xDEADBEEF1){
            oldView1.removeFromSuperview()
        }
        
        if let oldView2 = self.view.viewWithTag(0xDEADBEEF2){
            oldView2.removeFromSuperview()
        }
        
        
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.color = .white
        indicator.startAnimating()
        indicator.autoresizingMask = [
                .flexibleLeftMargin, .flexibleRightMargin,
                .flexibleTopMargin, .flexibleBottomMargin
            ]
        
        indicator.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        indicator.tag = 0xDEADBEEF2
        
        let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView.alpha = 0.3
            
            // Setting the autoresizing mask to flexible for
            // width and height will ensure the blurEffectView
            // is the same size as its parent view.
            blurEffectView.autoresizingMask = [
                .flexibleWidth, .flexibleHeight
            ]
        blurEffectView.tag = 0xDEADBEEF1
        blurEffectView.frame = UIScreen.main.bounds//self.view.bounds
       
        
        UIView.transition(with: self.view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            self.view.addSubview(blurEffectView)
            self.view.addSubview(indicator)
            self.navigationController?.navigationBar.layer.zPosition = -1;
            
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            
        }, completion: nil)
        
    }
    
    func hideLoading(){
        
        if let oldView1 = self.view.viewWithTag(0xDEADBEEF1){
            UIView.animate(withDuration: 0.5) {
                oldView1.alpha = 0
            } completion: { (success) in
                oldView1.removeFromSuperview()
                self.navigationController?.navigationBar.layer.zPosition = 0;
                
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
            }
        }
        
        if let oldView2 = self.view.viewWithTag(0xDEADBEEF2){
            UIView.animate(withDuration: 0.5) {
                oldView2.alpha = 0
            } completion: { (success) in
                oldView2.removeFromSuperview()
            }
        }
    }
    
    
    func showDropDown(fr: CGRect, contentTable: UITableView){
        if let dropView = self.view.viewWithTag(0xD509D044){
            dropView.removeFromSuperview()
        }
        
        let shadows = UIView()
        shadows.clipsToBounds = false
        shadows.translatesAutoresizingMaskIntoConstraints = false
        shadows.addSubview(shadows)
        //containerView.layer.shadowColor = UIColor
        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 0)
        let layer0 = CALayer()
        layer0.shadowPath = shadowPath0.cgPath
        layer0.shadowColor = UIColor(red: 0.141, green: 0.255, blue: 0.365, alpha: 0.3).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 4
        layer0.shadowOffset = CGSize(width: 1, height: 1)
        layer0.bounds = shadows.bounds
        layer0.position = shadows.center
        shadows.layer.addSublayer(layer0)
        
        let tableView = contentTable
        tableView.translatesAutoresizingMaskIntoConstraints = false
        shadows.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
        ])
        
    }
    
    func hideDropDown(){
        if let dropView = self.view.viewWithTag(0xD509D044){
            UIView.animate(withDuration: 0.5){
                dropView.removeFromSuperview()
            }
        }
    }
}

extension UIApplication {

     static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
     }
    
     static var build: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
     }
    
} 
