//
//  BasePopupViewController.swift
//  
//
//  Created by Nadia Karina Camacho Cabrera on 9/29/22.
//

import UIKit

class BasePopupViewController: UIViewController {

    var contentView = RoundedView()
    var containerView = UIView()
    var allowDismiss = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupContentViewOuterLayout()
        
        NotificationCenter.default.addObserver(self, selector: #selector(lockoutReached), name: NSNotification.Name(NotificationNames.lockout.rawValue), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //popupView()
    }

    //may pass variable for contentView size, with default normal; other options would be change time size and eula size (takes up whole page)
    func setupContentViewOuterLayout(){
        setupAlpha()
        
        contentView.backgroundColor = UIColor.white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            //contentView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 5),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupAlpha(){
        containerView.backgroundColor = UIColor.black
        containerView.layer.opacity = 0.5
        containerView.isOpaque = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupAlphaForPopup(){
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        //containerView.frame = self.view.frame
        let screenSize = UIScreen.main.bounds.size
        containerView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height * 2)
        view?.addSubview(containerView)
        
        if allowDismiss{
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(slideUpViewTapped))
            containerView.addGestureRecognizer(tapGesture)
        }
    }
    
    func popupView(){
        let screenSize = UIScreen.main.bounds.size
        containerView.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
            self.containerView.alpha = 0.6
            //self.contentView.frame = CGRect(x: 0, y: screenSize.height - self.contentHeight, width: screenSize.width, height: self.contentHeight)
            
            self.containerView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        }, completion: nil)
    }
    
    //hide content
    @objc func slideUpViewTapped(){
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
          self.containerView.alpha = 0
            //self.contentView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.contentHeight)
            self.containerView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height + self.contentView.frame.height)
        }, completion: nil)
    }
    
    
    @objc func lockoutReached(){
        if allowDismiss{
            dismiss(animated: false)
        }
    }
}
