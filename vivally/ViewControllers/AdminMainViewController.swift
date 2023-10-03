//
//  AdminMainViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 8/2/21.
//

import UIKit
import Toast_Swift

class AdminMainViewController: UIViewController {

    private var sideMenuRevealWidth: CGFloat = 260
    private let paddingForRotation: CGFloat = 150
    private var isExpanded: Bool = false
    
    private var draggingIsEnabled: Bool = false
    private var panBaseLocation: CGFloat = 0.0
    
    // Expand/Collapse the side menu by changing trailing's constant
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    
    private var revealSideMenuOnTop: Bool = true
    private var sideMenuShadowView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkManager.sharedInstance.delegate = self
        BluetoothManager.sharedInstance.toastDelegate = self
        
        // Default Main View Controller
        showViewController(viewController: UINavigationController.self, storyboardId: "ClinicianHomeNavViewController", storyboardName: "clinician")

    }
    
    func showViewController<T: UIViewController>(viewController: T.Type, storyboardId: String, storyboardName:String) -> () {
        // Remove the previous View
        for subview in view.subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
            }
        }
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardId) as! T
        vc.view.tag = 99
        view.insertSubview(vc.view, at: self.revealSideMenuOnTop ? 0 : 1)
        addChild(vc)
        if !self.revealSideMenuOnTop {
            if isExpanded {
                vc.view.frame.origin.x = self.sideMenuRevealWidth
            }
            if self.sideMenuShadowView != nil {
                vc.view.addSubview(self.sideMenuShadowView)
            }
        }
        vc.didMove(toParent: self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = self.isExpanded ? 0 : (-self.sideMenuRevealWidth - self.paddingForRotation)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches Ended within admin Main")
        //ActivityManager.sharedInstance.resetInactivityCount()
    }


    func disable() {
        print("mainview's disable called")
        let gestures = view.gestureRecognizers
        for gest in gestures!{
            gest.isEnabled = false
        }
    }
    func enable(){
        let gestures = view.gestureRecognizers
        for gest in gestures! {
            gest.isEnabled = true
        }
    }
}

extension UIViewController {
    
    // With this extension you can access the MainViewController from the child view controllers.
    func revealAdminViewController() -> AdminMainViewController? {
        var viewController: UIViewController? = self
        
        if viewController != nil && viewController is AdminMainViewController {
            return viewController! as? AdminMainViewController
        }
        while (!(viewController is AdminMainViewController) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is AdminMainViewController {
            return viewController as? AdminMainViewController
        }
        return nil
    }
}

extension AdminMainViewController: NetworkManagerDelegate{
    func networkDisconnect() {
        DispatchQueue.main.async {
            var style = ToastStyle()
            style.backgroundColor = UIColor(named: "avationLtGray")!
            style.titleAlignment = .center
            style.messageAlignment = .center
            style.messageColor = UIColor(named: "avationFont")!
            style.titleColor = UIColor(named: "avationFont")!
            self.view.makeToast("Connect to WiFi to ensure your date is uploaded", duration: 5.0, position: .bottom, title: "WIFI NOT CONNECTED", image: nil, style: style)
            
            //self.view.makeToast("Disconnect Occured!")
        }
    }
}

extension  AdminMainViewController: BluetoothManagerToastDelegate{
    func deviceConnection(connection: Bool) {
        var style = ToastStyle()
        style.backgroundColor = UIColor(named: "avationLtGray")!
        style.titleAlignment = .center
        style.messageAlignment = .center
        style.messageColor = UIColor(named: "avationFont")!
        style.titleColor = UIColor(named: "avationFont")!
        style.cornerRadius = 25
        if connection {
            self.view.makeToast("Bluetooth connection has been successfully re-established", duration: 5.0, position: .bottom, title: "BLUETOOTH CONNECTION RESTORED", image: nil, style: style)
        }
        else{
            self.view.makeToast("Move Stimulator closer to your mobile device", duration: 5.0, position: .bottom, title: "BLUETOOTH CONNECTION LOST", image: nil, style: style)
        }
    }
}
