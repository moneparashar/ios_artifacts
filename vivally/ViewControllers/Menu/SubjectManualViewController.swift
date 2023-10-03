//
//  SubjectManualViewController.swift
//  vivally
//
//  Created by Joe Sarkauskas on 4/23/21.
//

import UIKit
import PDFKit

class SubjectManualViewController: BaseNavViewController {
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var searchTextField: TextFieldStackView!
    @IBOutlet weak var searchStack: UIStackView!
    @IBOutlet weak var pdfView: UIView!
    
    var startingPage:Int = 0
    
    var pView = PDFView()
    
    var currentSearchIndex = 0
    
    var foundSet: [PDFSelection] = []
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.showOnlyRightLogo = true
        super.viewDidLoad()

        title = "User Guide"
        setupPDF()
        searchTextField.setup(title: "", placeholder: "Search", search: true)
        searchTextField.errorText.isHidden = true
        //searchTextField.errorLabel.isHidden = true
        searchTextField.delegate = self
        
        checkPageEnabling()
    }
    
    func setupPDF(){
        pView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.addSubview(pView)
        
        pView.leadingAnchor.constraint(equalTo: pdfView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pView.trailingAnchor.constraint(equalTo: pdfView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pView.topAnchor.constraint(equalTo: pdfView.safeAreaLayoutGuide.topAnchor).isActive = true
        pView.bottomAnchor.constraint(equalTo: pdfView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        // Do any additional setup after loading the view.
        if let path = Bundle.main.path(forResource: "vivally-user-guide", ofType: "pdf") {
            let url = URL(fileURLWithPath: path)
            if let pdfDocument = PDFDocument(url: url) {
                pView.displayMode = .singlePage
                pView.autoScales = true
                pView.displayDirection = .horizontal
                
                pView.document = pdfDocument
                
                pView.usePageViewController(true, withViewOptions: nil)
                if let startPage = pdfDocument.page(at: startingPage){
                    pView.go(to: startPage)
                }
            }
        }
    }
    
    func tapSearch(){
        if !searchStack.isHidden{
            searchStack.isHidden = true
        }
        foundSet = []
        currentSearchIndex = -1
        let textToSearch = searchTextField.tf.text ?? ""
        if textToSearch != ""{
            if let found = pView.document?.findString(textToSearch, withOptions: .caseInsensitive){
                self.pView.setCurrentSelection(found.first, animate: true)
                self.pView.go(to: found.first!)
                foundSet = found
                currentSearchIndex = 0
                searchStack.isHidden = false
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    @IBAction func tappedForwardPage(_ sender: Any) {
        stepManualView(index: 1)
    }
    
    @IBAction func tappedBackPage(_ sender: Any) {
        stepManualView(index: -1)
    }
    
    @IBAction func tappedDownload(_ sender: AnyObject) {
        if let manualData = pView.document?.dataRepresentation(){
            let activityViewController = UIActivityViewController(activityItems: [manualData], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sender.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    func stepManualView(index: Int){
        if let count = pView.document?.pageCount, let currentPage = pView.currentPage?.pageRef?.pageNumber{
            if count == currentPage && index == 1{    //last page
                pView.goToFirstPage(self)
            }
            else if currentPage == 1 && index == -1{    //first page
                pView.goToLastPage(self)
            }
            else{
                index > 0 ? pView.goToNextPage(self) : pView.goToPreviousPage(self)
            }
        }
        checkPageEnabling()
    }
    
    func checkPageEnabling(){
        if let count = pView.document?.pageCount, let currentPage = pView.currentPage?.pageRef?.pageNumber{
            leftButton.isEnabled = currentPage > 1
            rightButton.isEnabled = currentPage < 30 // remove to enable restarting from page 1 after pressing on last page
        }
    }
    
    
    
    @IBAction func tappedBackSearch(_ sender: Any) {
        stepSearchList(index: -1)
    }
    
    @IBAction func tappedNextSearch(_ sender: Any) {
        stepSearchList(index: 1)
    }
    
    func stepSearchList(index: Int){
        if foundSet.count > 1 {
            if currentSearchIndex + 1 == foundSet.count && index == 1{
                currentSearchIndex = 0
                pView.setCurrentSelection(foundSet.first, animate: true)
                pView.go(to: foundSet.first!)
            }
            else if currentSearchIndex == 0 && index == -1{
                currentSearchIndex = foundSet.count - 1
                pView.setCurrentSelection(foundSet.last, animate: true)
                pView.go(to: foundSet.last!)
            }
            else{
                currentSearchIndex += index
                pView.setCurrentSelection(foundSet[currentSearchIndex], animate: true)
                pView.go(to: foundSet[currentSearchIndex])
            }
        }
    }
}

extension SubjectManualViewController: TextFieldStackViewDelegate{
    func tappedDropdown() {
        tapSearch()
    }
}
