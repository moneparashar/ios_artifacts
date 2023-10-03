//
//  AccountView.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 7/11/22.
//

import UIKit

enum AccountViewType{
    case unsigned
    case patient
    case clinician
}

protocol AccountTableDelegate{
    func rowSelected(sender: AccountView, row: Int)
}

class AccountView: UIView {

    let cellId = "AccountCell"
    
    var viewHeight:CGFloat = 0
    var containerView = UIView()
    var alphaView = UIView()
    var roundview = RoundedView()
    var tableView = UITableView()
    
    var tableList:[AccountPages] = []
    var delegate:AccountTableDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure(){
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: cellId)
        
        /*
        alphaView.backgroundColor = .black
        alphaView.alpha = 0.5
        alphaView.isOpaque = false
        alphaView.translatesAutoresizingMaskIntoConstraints = false
        */
        roundview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(roundview)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        roundview.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            roundview.topAnchor.constraint(equalTo: self.topAnchor),
            roundview.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            roundview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            roundview.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: roundview.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: roundview.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: roundview.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: roundview.bottomAnchor),
        ])
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func selectedRow(row: Int, hide: Bool = true){
        if hide{
            slideUpViewTapped()
        }
        delegate?.rowSelected(sender: self, row: row)
    }
    
    func popupTable(view: UIView){
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.frame = view.frame
        view.addSubview(containerView)
        
        let tapGestrue = UITapGestureRecognizer(target: self, action: #selector(slideUpViewTapped))
        containerView.addGestureRecognizer(tapGestrue)
        
        let screenSize = UIScreen.main.bounds.size
        print(tableView.frame.height)
        self.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: viewHeight)
        view.addSubview(self)
        
        containerView.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
            self.containerView.alpha = 0.6
            self.frame = CGRect(x: 0, y: screenSize.height - self.viewHeight, width: screenSize.width, height: self.viewHeight)
        }, completion: nil)
        
    }
    
    @objc func slideUpViewTapped(){
        let screenSize = UIScreen.main.bounds.size
          UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
            self.containerView.alpha = 0
              self.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.viewHeight)
          }, completion: nil)
        
    }
}

extension AccountView:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AccountTableViewCell
        
        let firstName = KeychainManager.sharedInstance.accountData?.userModel?.givenName
        let lastName = KeychainManager.sharedInstance.accountData?.userModel?.familyName
        let name = (firstName != nil && lastName != nil) ? (firstName! + lastName!) : ""
        
        //cell.setupView(page: tableList[indexPath.row], name: name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewHeight = CGFloat(tableList.count * 60)
        return tableList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow(row: indexPath.row)
    }
}
