//
//  PatientMainViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 5/10/21.
//

import UIKit
import CoreBluetooth

import Toast_Swift

/*
protocol PatientMainViewControllerDelegate {
    func messageToDeviceStatus()
} */

class PatientMainViewController: UIViewController {
    //var delegate: PatientMainViewControllerDelegate?
    
    //private var sideMenuViewController: PatientSideMenuViewController!
    private var sideMenuRevealWidth: CGFloat = 260
    private let paddingForRotation: CGFloat = 150
    private var isExpanded: Bool = false
    
    private var draggingIsEnabled: Bool = false
    private var panBaseLocation: CGFloat = 0.0
    
    // Expand/Collapse the side menu by changing trailing's constant
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    
    private var revealSideMenuOnTop: Bool = true
    private var sideMenuShadowView: UIView!
    
    var allowBleToast = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.sharedInstance.delegate = self
        BluetoothManager.sharedInstance.toastDelegate = self
        
        
        // Default Main View Controller
        showViewController(viewController: UINavigationController.self, storyboardId: "HomeNavID", storyboardName: "Main")
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
        print("Touches Ended within patient Main")
        //ActivityManager.sharedInstance.resetInactivityCount()
    }
    
    
    // Call this Button Action from the View Controller you want to Expand/Collapse when you tap a button
    @IBAction open func revealSideMenu() {
        self.sideMenuState(expanded: self.isExpanded ? false : true)
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

extension PatientMainViewController:PatientSideMenuViewControllerDelegate{
    func selectedCell(_ row: Int) {
        switch row {
        case 0:
            // Home
            self.showViewController(viewController: UINavigationController.self, storyboardId: "HomeNavID", storyboardName: "Main")
        case 2:
            // Therapy
            self.showViewController(viewController: UINavigationController.self, storyboardId: "TherapyHistoryNavViewController", storyboardName: "therapy")
            
            //quick test with new therapy
            /*
            let storyboard = UIStoryboard(name: "therapy", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TherapyPreparationViewController") as! TherapyPreparationViewController
            NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: true)
            */
        case 3:
            // Journal
            self.showViewController(viewController: UINavigationController.self, storyboardId: "JournalNavController", storyboardName: "journal")
        case 5:
            
            // Bluetooth Status
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        case 6:
            // Wi-Fi Status
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        case 7:
            // Device Pairing
            //self.showViewController(viewController: UINavigationController.self, storyboardId: "DevicePairingNavViewController", storyboardName: "Main")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //let vc = storyboard.instantiateViewController(withIdentifier: "DevicePairingViewController") as! DevicePairingViewController
            //NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: true)
        case 8:
            //self.showViewController(viewController: UINavigationController.self, storyboardId: "DeviceNavViewController", storyboardName: "Main")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //let vc = storyboard.instantiateViewController(withIdentifier: "DeviceStatusViewController") as! DeviceStatusViewController
            //NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: true)
           
            
        case 9:
            // Subject Manual
            //self.showViewController(viewController: UINavigationController.self, storyboardId: "SubjectManualNavController", storyboardName: "Main")
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SubjectManualViewController") as! SubjectManualViewController
            NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: true)
            
        case 10:
            //Help
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
            NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: true)
        case 11:
            //Settings
            //self.showViewController(viewController: UINavigationController.self, storyboardId: "SettingsNavController", storyboardName: "Main")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: true)
        case 12:
            // Privacy Policy
            //self.showViewController(viewController: UINavigationController.self, storyboardId: "PrivacyNavController", storyboardName: "Main")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: true)
        case 13:
            // Contact Us
            //self.showViewController(viewController: UINavigationController.self, storyboardId: "ContactUsNavController", storyboardName: "Main")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: true)
        default:
            break
        }
        
        // Collapse side menu with animation
        DispatchQueue.main.async { self.sideMenuState(expanded: false) }
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
    
    func sideMenuState(expanded: Bool) {
        if expanded {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? 0 : self.sideMenuRevealWidth) { _ in
                self.isExpanded = true
            }
            // Animate Shadow (Fade In)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.6 }
        }
        else {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? (-self.sideMenuRevealWidth - self.paddingForRotation) : 0) { _ in
                self.isExpanded = false
            }
            // Animate Shadow (Fade Out)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = targetPosition
                self.view.layoutIfNeeded()
            }
            else {
                self.view.subviews[1].frame.origin.x = targetPosition
            }
        }, completion: completion)
    }
}

extension UIViewController {
    
    // With this extension you can access the MainViewController from the child view controllers.
    func revealViewController() -> PatientMainViewController? {
        var viewController: UIViewController? = self
        
        if viewController != nil && viewController is PatientMainViewController {
            return viewController! as? PatientMainViewController
        }
        while (!(viewController is PatientMainViewController) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is PatientMainViewController {
            return viewController as? PatientMainViewController
        }
        return nil
    }
}

extension PatientMainViewController: UIGestureRecognizerDelegate {
    @objc func TapGestureRecognizer(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if self.isExpanded {
                self.sideMenuState(expanded: false)
            }
        }
    }
    
    // Close side menu when you tap on the shadow background view
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        /*
        if (touch.view?.isDescendant(of: self.sideMenuViewController.view))! {
            return false
        }
         */
        return true
    }
    
    // Dragging Side Menu
    @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        // ...
        
        let position: CGFloat = sender.translation(in: self.view).x
        let velocity: CGFloat = sender.velocity(in: self.view).x
        
        switch sender.state {
        case .began:
            
            // If the user tries to expand the menu more than the reveal width, then cancel the pan gesture
            if velocity > 0, self.isExpanded {
                sender.state = .cancelled
            }
            
            // If the user swipes right but the side menu hasn't expanded yet, enable dragging
            if velocity > 0, !self.isExpanded {
                self.draggingIsEnabled = true
            }
            // If user swipes left and the side menu is already expanded, enable dragging they collapsing the side menu)
            else if velocity < 0, self.isExpanded {
                self.draggingIsEnabled = true
            }
            
            if self.draggingIsEnabled {
                // If swipe is fast, Expand/Collapse the side menu with animation instead of dragging
                let velocityThreshold: CGFloat = 550
                if abs(velocity) > velocityThreshold {
                    self.sideMenuState(expanded: self.isExpanded ? false : true)
                    self.draggingIsEnabled = false
                    return
                }
                
                if self.revealSideMenuOnTop {
                    self.panBaseLocation = 0.0
                    if self.isExpanded {
                        self.panBaseLocation = self.sideMenuRevealWidth
                    }
                }
            }
            
        case .changed:
            
            // Expand/Collapse side menu while dragging
            if self.draggingIsEnabled {
                if self.revealSideMenuOnTop {
                    // Show/Hide shadow background view while dragging
                    let xLocation: CGFloat = self.panBaseLocation + position
                    let percentage = (xLocation * 150 / self.sideMenuRevealWidth) / self.sideMenuRevealWidth
                    
                    let alpha = percentage >= 0.6 ? 0.6 : percentage
                    self.sideMenuShadowView.alpha = alpha
                    
                    // Move side menu while dragging
                    if xLocation <= self.sideMenuRevealWidth {
                        self.sideMenuTrailingConstraint.constant = xLocation - self.sideMenuRevealWidth
                    }
                }
                else {
                    if let recogView = sender.view?.subviews[1] {
                        // Show/Hide shadow background view while dragging
                        let percentage = (recogView.frame.origin.x * 150 / self.sideMenuRevealWidth) / self.sideMenuRevealWidth
                        
                        let alpha = percentage >= 0.6 ? 0.6 : percentage
                        self.sideMenuShadowView.alpha = alpha
                        
                        // Move side menu while dragging
                        if recogView.frame.origin.x <= self.sideMenuRevealWidth, recogView.frame.origin.x >= 0 {
                            recogView.frame.origin.x = recogView.frame.origin.x + position
                            sender.setTranslation(CGPoint.zero, in: view)
                        }
                    }
                }
            }
        case .ended:
            self.draggingIsEnabled = false
            // If the side menu is half Open/Close, then Expand/Collapse with animationse with animation
            if self.revealSideMenuOnTop {
                let movedMoreThanHalf = self.sideMenuTrailingConstraint.constant > -(self.sideMenuRevealWidth * 0.5)
                self.sideMenuState(expanded: movedMoreThanHalf)
            }
            else {
                if let recogView = sender.view?.subviews[1] {
                    let movedMoreThanHalf = recogView.frame.origin.x > self.sideMenuRevealWidth * 0.5
                    self.sideMenuState(expanded: movedMoreThanHalf)
                }
            }
        default:
            break
        }
    }
    
    
}


//having these called on main view controllers make it easier than to go to each vc
//plus on logout toasts don't display
extension PatientMainViewController: NetworkManagerDelegate{
    func networkDisconnect() {
        DispatchQueue.main.async {
            var style = ToastStyle()
            style.backgroundColor = UIColor(named: "avationLtGray")!
            style.titleAlignment = .center
            style.messageAlignment = .center
            style.messageColor = UIColor(named: "avationFont")!
            style.titleColor = UIColor(named: "avationFont")!
            self.view.makeToast("Connect to WiFi to ensure your date is uploaded", duration: 5.0, position: .bottom, title: "WIFI NOT CONNECTED", image: nil, style: style)
        }
    }
}

extension  PatientMainViewController: BluetoothManagerToastDelegate{
    func deviceConnection(connection: Bool) {
        if allowBleToast{
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
}
/*
extension PatientMainViewController: DeviceErrorManagerDelegate{
    func dataRecoveryAvailable() {
        if !TherapyManager.sharedInstance.therapyRunning && DataRecoveryManager.sharedInstance.recoveryAvailable{
            var style = ToastStyle()
            style.backgroundColor = UIColor(named: "avationLtGray")!
            style.titleAlignment = .center
            style.messageAlignment = .center
            style.messageColor = UIColor(named: "avationFont")!
            style.titleColor = UIColor(named: "avationFont")!
            style.cornerRadius = 25
            self.view.makeToast("The connected device has data available for recovery. Go to the status page to start recovery.", duration: 5.0, position: .bottom, title: "DATA RECOVERY AVAILABLE", image: nil, style: style) { didTap in
                if didTap{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "DeviceStatusViewController") as! DeviceStatusViewController
                    NavigationManager.sharedInstance.currentNav.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
*/
//for the gel cushions notifications would send delegate and have toast show here
extension PatientMainViewController: GelDelegate{
    func updatedGel() {
        
        /* TODO
        var style = ToastStyle()
        style.backgroundColor = UIColor(named: "avationLtGray")!
        style.messageAlignment = .center
        style.messageColor = UIColor(named: "avationFont")!
        style.cornerRadius = 25
        
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC") ?? .current
        let currentDay = cal.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()
        do{
            let name = KeychainManager.sharedInstance.accountData?.username ?? ""
            let latestGelJournal = try JournalEventsDataHelper.getLatestGel(user: name)
            var entryExists = false
            if latestGelJournal != nil{
                if currentDay < latestGelJournal?.eventTimestamp ?? Date(){
                    entryExists = true
                }
            }
            if entryExists{
                latestGelJournal?.lifeGelPads = true
                latestGelJournal?.modified = Date()
                JournalEventsManager.sharedInstance.updateJournalEvent(je: latestGelJournal!)
            }
            else{
                var je = JournalEvents()
                je.username = name
                je = JournalEventsManager.sharedInstance.setRange(journalEvent: je, navpage: .life)
                je.lifeGelPads = true
                JournalEventsManager.sharedInstance.addJournalEvent(je: je)
            }
            
        } catch{
            print("issue with get journal gelpads")
        }
        
        self.view.makeToast("A new Replaced Gel Cushions journal entry has been added for today", duration: 5.0, position: .bottom, image: nil, style: style)
        
        */
    }
}
