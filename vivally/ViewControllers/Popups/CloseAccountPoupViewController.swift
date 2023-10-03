//
//  CloseAccountPoupViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 3/1/23.
//

import UIKit

class CloseAccountPoupViewController: BasePopupViewController {

    var rootStack = UIStackView()
    var allStack = UIStackView()
    
    var icon = UIImageView()
    var titleLabel = UILabel()
    var messageView = UIView()
    var messageLabel = UILabel()
    
    var reasonTextStack = DropdownOriginView()
    
    var buttonStack = UIStackView()
    var closeButton = ActionButton()
    var cancelButton = ActionButton()
    
    var contentPadding:CGFloat = 24
    
    var selectedRow = 0
    var reasonsStr:[String] = []
    var reasonsIds:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getReasons()
        
        setupStack()
        closeButton.addTarget(self, action: #selector(tappedClose(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(tappedCancel(_:)), for: .touchUpInside)

        if !reasonsStr.isEmpty{
            reasonTextStack.selectRow(ind: 0)
        }
    }
    
    @objc func tappedClose(_ sendwer: UIButton){
        let requestDataDeletion = RequestDataDeletion()
        if !reasonsIds.isEmpty{
            requestDataDeletion.requestedDataDeletionReason = reasonsIds[selectedRow]
            requestDataDeletion.requestedDataDeletionReasonText = reasonsStr[selectedRow]
            
            AccountManager.sharedInstance.requestCloseAccount(rdd: requestDataDeletion){
                self.dismiss(animated: false)
                NetworkManager.sharedInstance.logoutClear()
                DataRecoveryManager.sharedInstance.removeRecovery()
                let initialViewController = NonSignedInMainViewController()
                NavigationManager.sharedInstance.setRootViewController(viewController: initialViewController)
            }
        }
    }
    
    @objc func tappedCancel(_ sendwer: UIButton){
        self.dismiss(animated: false)
    }
    
    func getReasons(){
        reasonsStr = []
        reasonsIds = []
        
        let demoReason = ScreeningManager.sharedInstance.loadCloseReasonDemographics()
        for seqDemo in demoReason{
            reasonsStr.append(seqDemo.displayName)
            reasonsIds.append(seqDemo.id)
        }
    }
    
    func setupStack(){
        icon = UIImageView(image: PopupIcons.warning.getIconImage())
        let iconParentView = UIView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconParentView.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: iconParentView.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconParentView.centerYAnchor),
            icon.leadingAnchor.constraint(greaterThanOrEqualTo: iconParentView.leadingAnchor),
            icon.topAnchor.constraint(equalTo: iconParentView.topAnchor),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1)
        ])
        
        titleLabel.text = "Delete account"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.h4
        titleLabel.textColor = UIColor.fontBlue
        titleLabel.numberOfLines = 0
        
        messageLabel.text = "Are you sure you want to delete your account?"
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.bodyMed
        messageLabel.textColor = UIColor.fontBlue
        messageLabel.numberOfLines = 0
        
        //text
        reasonTextStack.setup(title: "Reason for deleting the account", content: "", placeholder: "", options: reasonsStr)
        reasonTextStack.errorLabel.isHidden = true
        
        closeButton.setTitle("Delete account", for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        closeButton.toSecondary()
        
        buttonStack = UIStackView(arrangedSubviews: [closeButton, cancelButton])
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 24
        
        
        allStack = UIStackView(arrangedSubviews: [iconParentView, titleLabel, messageLabel, reasonTextStack, buttonStack])
        allStack.axis = .vertical
        allStack.alignment = .fill
        allStack.distribution = .fill
        allStack.spacing = 24
        
        UIDevice.current.userInterfaceIdiom == .phone ? setPhoneLayouts() : setTabletLayouts()
    }
    
    func setTabletLayouts(){
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        rootStack = UIStackView(arrangedSubviews: [leftSpacer, allStack, rightSpacer])
        rootStack.alignment = .top
        rootStack.distribution = .equalSpacing
        
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
            rootStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            rootStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentPadding),
            rootStack.arrangedSubviews[1].widthAnchor.constraint(equalToConstant: view.getWidthConstant())
        ])
    }
    
    func setPhoneLayouts(){
        allStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(allStack)
        
        NSLayoutConstraint.activate([
            allStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
            allStack.centerXAnchor.constraint(equalTo:  contentView.centerXAnchor),
            allStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            allStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentPadding),
        ])
    }
}

extension CloseAccountPoupViewController: DropdownOriginViewDelegate{
    func dropSelected(ind: Int, option: String, sender: DropdownOriginView) {
        selectedRow = ind
    }
}
