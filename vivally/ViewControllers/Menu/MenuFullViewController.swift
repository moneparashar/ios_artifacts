//
//  HomeNewViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/14/22.
//

import UIKit

class MenuFullViewController: BaseNavViewController {

    var outerStack = UIStackView()
    var headerStack = UIStackView()
    
    var profileView = UIView()
    var initialsLabel = UILabel()
    
    var nameLabel = UILabel()
    var idLabel = UILabel()
    
    var tableView = UITableView()
    
    var menuRows:[AccountPages] = []
    var accountType: AccountViewType = .unsigned
    
    var cellId = "menuCell"
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.showOnlyRightLogo = true
        super.viewDidLoad()

        title = " "
        // Do any additional setup after loading the view.
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setAccountTable(){
        switch accountType {
        case .unsigned:
            menuRows = [.contactAbout]
        case .patient:
            menuRows = [.system, .help, .privacy, .contactAbout, .settings, .changePassword, .changePIN, .signOut]
        case .clinician:
            menuRows = [.system, .help, .privacy, .contactAbout, .settings, .changePassword, .signOut]
        }
    }
    
    func configure(){
        view.backgroundColor = UIColor.white
        
        if #available(iOS 15.0, *) {
          tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.backgroundColor = UIColor.clear
        tableView.clipsToBounds = false
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: cellId)
        setAccountTable()
        
        let profileContainerView = UIView()
        profileView.translatesAutoresizingMaskIntoConstraints = false
        profileContainerView.addSubview(profileView)
        
        
        let circleImageView = UIImageView(image: UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysTemplate))
        circleImageView.tintColor = UIColor.lavendarMist
        circleImageView.translatesAutoresizingMaskIntoConstraints = false
        profileView.addSubview(circleImageView)
        
        //status icon? add later
        
        if accountType == .patient{
            let firstName = KeychainManager.sharedInstance.loadAccountData()?.userModel?.givenName ?? ""
            let middleName = KeychainManager.sharedInstance.accountData?.userModel?.middleName ?? ""
            let lastName = KeychainManager.sharedInstance.accountData?.userModel?.familyName ?? ""
            
            let initials = firstName.prefix(1) + lastName.prefix(1)
            initialsLabel.text = String(initials)
            
            // there's a middle name
            if middleName != "" {
                nameLabel.text = firstName + " " + middleName + " " + lastName
            
            // no middle
            } else {
                nameLabel.text = firstName + " " + lastName
            }
            
            //once cloud updates pull from usermodel the patientId
            idLabel.text = "ID: " + (KeychainManager.sharedInstance.accountData?.userModel?.patientId ?? "")
        }
        else if accountType == .clinician{
            let firstName = KeychainManager.sharedInstance.loadAccountData()?.userModel?.givenName ?? ""
            let middleName = KeychainManager.sharedInstance.accountData?.userModel?.middleName ?? ""
            let lastName = KeychainManager.sharedInstance.accountData?.userModel?.familyName ?? ""
                 
            let initials = firstName.prefix(1) + lastName.prefix(1)
            initialsLabel.text = String(initials)
            
            // there's a middle name
            if middleName != "" {
                nameLabel.text = firstName + " " + middleName + " " + lastName
            
            // no middle
            } else {
                nameLabel.text = firstName + " " + lastName
            }
            
            idLabel.text = KeychainManager.sharedInstance.accountData?.userModel?.clinicianId ?? ""
        }
        initialsLabel.textColor = UIColor.wedgewoodBlue
        initialsLabel.textAlignment = .center
        initialsLabel.font = UIFont.h1
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        profileView.addSubview(initialsLabel)
        
        NSLayoutConstraint.activate([
            profileView.topAnchor.constraint(equalTo: profileContainerView.topAnchor),
            profileView.bottomAnchor.constraint(equalTo: profileContainerView.bottomAnchor),
            profileView.centerXAnchor.constraint(equalTo: profileContainerView.centerXAnchor),
            profileView.widthAnchor.constraint(equalTo: profileView.heightAnchor),
            
            circleImageView.topAnchor.constraint(equalTo: profileView.topAnchor),
            circleImageView.leadingAnchor.constraint(equalTo: profileView.leadingAnchor),
            circleImageView.centerXAnchor.constraint(equalTo: profileView.centerXAnchor),
            circleImageView.centerYAnchor.constraint(equalTo: profileView.centerYAnchor),
            circleImageView.heightAnchor.constraint(equalToConstant: 80),
            
            initialsLabel.centerXAnchor.constraint(equalTo: circleImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: circleImageView.centerYAnchor),
        ])
        
        nameLabel.textColor = UIColor.fontBlue
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.h3
        
        idLabel.textColor = UIColor.fontBlue
        idLabel.textAlignment = .center
        idLabel.font = UIFont.bodyLarge
        
        headerStack = UIStackView(arrangedSubviews: [profileContainerView, nameLabel, idLabel])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 20
        headerStack.distribution = .equalSpacing
        headerStack.isLayoutMarginsRelativeArrangement = true
        headerStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0)
        
        //try
        let tableContainerView = UIView()
        tableContainerView.clipsToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableContainerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            headerStack.arrangedSubviews[0].widthAnchor.constraint(equalTo: headerStack.arrangedSubviews[0].heightAnchor),
            
            tableContainerView.topAnchor.constraint(equalTo: tableView.topAnchor),
            tableContainerView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            tableContainerView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            tableContainerView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        outerStack = UIStackView(arrangedSubviews: [headerStack, tableContainerView])
        outerStack.axis = .vertical
        outerStack.alignment = .fill
        outerStack.distribution = .fill
        outerStack.spacing = 0
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outerStack)
        
        let wid = view.getWidthConstant()
        let contentWidthConstraint = outerStack.widthAnchor.constraint(equalToConstant: wid)
        contentWidthConstraint.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            outerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            outerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            outerStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentWidthConstraint
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}
extension MenuFullViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ProfileTableViewCell
        
        var cellTitle = ""
        var icon:iconLIst = .video
        
        switch menuRows[indexPath.section]{
        case .system:
            cellTitle = "User Guide"
            icon = .manual
        case .help:
            cellTitle = "Help"
            icon = .help
        case .privacy:
            cellTitle = "Privacy"
            icon = .privacy
        case .contactAbout:
            cellTitle = "Contact & About"
            icon = .contact
        case .settings:
            cellTitle = "Settings"
            icon = .settings
        case .changePassword:
            cellTitle = "Change Password"
            icon = .password
        case .changePIN:
            cellTitle = "Change PIN"
            icon = .pin
        case .signOut:
            cellTitle = "Sign Out"
            icon = .signOut
        default:
            return cell
        }
        cell.setup(title: cellTitle, icon: icon)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch menuRows[indexPath.section]{
            
        // name
        case .name:
            break
        
        // system
        case .system:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SubjectManualViewController") as! SubjectManualViewController
            
            self.navigationController?.pushViewController(viewController, animated: true)
        
        // help
        case .help:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
            
            self.navigationController?.pushViewController(viewController, animated: true)
         
        // privacy
        case .privacy:
            let viewController = PrivacyPolicyViewController()
            
            self.navigationController?.pushViewController(viewController, animated: true)
        
        // contact about
        case .contactAbout:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            
            self.navigationController?.pushViewController(viewController, animated: true)
           
        // settings
        case .settings:
            let storyboard = UIStoryboard(name: "account", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            
            self.navigationController?.pushViewController(viewController, animated: true)
         
        // change password
        case .changePassword:
            let storyboard = UIStoryboard(name: "account", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
            
            self.navigationController?.pushViewController(viewController, animated: true)
           
        // change pin
        case .changePIN:
            let storyboard = UIStoryboard(name: "account", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ChangePinViewController") as! ChangePinViewController
            
            self.navigationController?.pushViewController(viewController, animated: true)
          
        // sign out
        case .signOut:
            if ScreeningProcessManager.sharedInstance.screeningRunning || TherapyManager.sharedInstance.therapyRunning{
                break
            }
            let viewController = SignOutConfirmationPopupViewController()
            //let storyboard = UIStoryboard(name: "account", bundle: nil)
            //let viewController = storyboard.instantiateViewController(withIdentifier: "SignOutConfirmationViewController") as! SignOutConfirmationViewController
            viewController.modalPresentationStyle = .overCurrentContext
            viewController.modalTransitionStyle = .coverVertical
            
            self.present(viewController, animated: false, completion: nil)
        }
        /*
        let accountInfo:[String: AccountPages] = ["accountOption": menuRows[indexPath.row]]
        self.dismiss(animated: false)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AccountAction"), object: nil, userInfo: accountInfo)
        */
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuRows.count
    }
}
