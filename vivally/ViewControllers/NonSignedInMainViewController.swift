//
//  NonSignedInMainViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 10/20/21.
//

import UIKit

class NonSignedInMainViewController: UIViewController {

    //private var sideMenuViewController: NonSignedInSideMenuViewController!
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

        showViewController(viewController: UINavigationController.self, storyboardId: "StartNav", storyboardName: "Main")
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
}

extension UIViewController {
    
    // With this extension you can access the MainViewController from the child view controllers.
    func revealNonSignedInViewController() -> NonSignedInMainViewController? {
        var viewController: UIViewController? = self
        
        if viewController != nil && viewController is NonSignedInMainViewController {
            return viewController! as? NonSignedInMainViewController
        }
        while (!(viewController is NonSignedInMainViewController) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is NonSignedInMainViewController {
            return viewController as? NonSignedInMainViewController
        }
        return nil
    }
    
}
