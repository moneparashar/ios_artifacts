//
//  PrivacyPolicyViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 8/3/21.
//

import UIKit

class PrivacyPolicyViewController: BaseNavViewController {

    var textView = UITextView()
    var bottomStack = UIStackView()
    
    let leftPad = UIView()
    let rightPad = UIView()
    var downloadButton = ActionButton()
    
    var pdfText:NSAttributedString?
    
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        //super.clearRightBarItems = true
        super.showOnlyRightLogo = true
        super.viewDidLoad()
        
        title = "Avation Privacy Policy"

        configure()
        
        bottomStack.arrangedSubviews[0].isHidden = UIDevice.current.userInterfaceIdiom == .phone
    }
    
    func configure(){
        view.backgroundColor = UIColor.white
        EulaManager.sharedInstance.loadEula()
        if let eulaHtml = EulaManager.sharedInstance.eulaHtml?.html{
            let parsed = eulaHtml.replacingOccurrences(of: "\n", with: "")
            
            pdfText = parsed.htmlToAttributedString
            textView.attributedText = parsed.htmlToAttributedString
            textView.isEditable = false
            textView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(textView)
            
            downloadButton.setTitle("Download", for: .normal)
            
            bottomStack = UIStackView(arrangedSubviews: [leftPad, downloadButton, rightPad])
            bottomStack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomStack)
            
            
            let width = view.getWidthConstant()
            let contentWidthConstraint = textView.widthAnchor.constraint(equalToConstant: width)
            contentWidthConstraint.priority = UILayoutPriority(999)
            let safe = view.safeAreaLayoutGuide
            
            bottomStack.arrangedSubviews[0].setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
            bottomStack.arrangedSubviews[2].setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
            bottomStack.arrangedSubviews[1].setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
            bottomStack.arrangedSubviews[1].setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
            bottomStack.arrangedSubviews[1].setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
            NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(greaterThanOrEqualTo: safe.leadingAnchor),
                textView.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
                textView.topAnchor.constraint(equalTo: safe.topAnchor),
                textView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -12),
                contentWidthConstraint,
                
                bottomStack.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
                bottomStack.widthAnchor.constraint(equalTo: textView.widthAnchor),
                bottomStack.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -24),
                
                bottomStack.arrangedSubviews[1].widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
                bottomStack.arrangedSubviews[0].widthAnchor.constraint(equalTo: bottomStack.arrangedSubviews[2].widthAnchor)
            ])
            
            downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchDown)
        }
    }
    
    @objc func downloadTapped(_ sender: AnyObject){
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docsUrl.appendingPathComponent("vivally-eula.pdf")
        
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = sender.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    
}
