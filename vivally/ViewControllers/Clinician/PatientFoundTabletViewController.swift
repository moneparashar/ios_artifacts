//
//  PatientFoundTabletViewController.swift
//  vivally
//
//  Created by Ryan Levels on 1/23/23.
//

import UIKit

class PatientFoundTabletViewController: BaseNavViewController {

    @IBOutlet weak var tableWidth: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var notificationView: UIView!
    
    @IBOutlet weak var editInfoButton: ActionButton!
    @IBOutlet weak var screeningButton: ActionButton!
    
    @IBOutlet weak var bottomButtonStackWidth: NSLayoutConstraint!
    var userInfo:UserModel? = nil
    var patientData:PatientExists? = nil
    
    // tableView rows
    var tableRows:[PatientFoundTableRows] = [.patientId, .firstName, .middleName, .lastName, .patientSuffix, .dateOfBirth, .gender, .emailAddress, .phoneNumber, .garmentSize, .therapySchedule, .mostBothersomeSymptom, .diagnosisCode, .study, .patientHeight, .patientWeight, .smoking, .comorbidity, .race]

    override func viewDidLoad() {
        super.goBackEnabled = true
        super.goBackPrompt = true
        super.viewDidLoad()

        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        tableWidth.constant = view.getWidthConstant()
        bottomButtonStackWidth.constant = view.getWidthConstant()
        title = "Existing Patient"
        patientData = ScreeningManager.sharedInstance.patientData
        editInfoButton.toSecondary()
        setupView()
        initTableView()
        super.delegate = self
        super.showOnlyRightLogo = true
        
        checkforPersonalization()     //check which values these apply to
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if(keyPath == "contentSize"){
             if let newvalue = change?[.newKey]
             {
                 DispatchQueue.main.async {
                 let newsize  = newvalue as! CGSize
                 self.tableViewHeight.constant = newsize.height
                 }

             }
         }
     }

    @IBAction func tappedEditInfo(_ sender: Any) {
        let storyboard = UIStoryboard(name: "clinician", bundle: nil)
        
        // old implementation
        // let homeVC = storyboard.instantiateViewController(withIdentifier: "ClinicianHomePageTabletViewController") as! ClinicianHomePageTabletViewController
        
        if UIDevice.current.userInterfaceIdiom == .phone{ let vc = storyboard.instantiateViewController(withIdentifier: "NewPatientPhoneViewController") as! NewPatientPhoneViewController
            vc.editInfo = true
            vc.patientData = patientData
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            // old imp.
            // self.navigationController?.setViewControllers([homeVC, vc], animated: true)
        }
        else{
            let vc = storyboard.instantiateViewController(withIdentifier: "NewPatientTabletViewController") as! NewPatientTabletViewController
            vc.editInfo = true
            vc.patientData = patientData
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            // old imp.
            // self.navigationController?.setViewControllers([homeVC, vc], animated: true)
        }
    }

    @IBAction func tappedTherapyPersonalization(_ sender: Any) {
        screeningButton.isEnabled = false
        let sch = TherapySchedules(rawValue: patientData?.therapySchedule ?? 0)
        let therapyLength = Int32(1800)
        
        ScreeningProcessManager.sharedInstance.therapySchedule = sch.rawValue
        ScreeningProcessManager.sharedInstance.therapyLength = Int(therapyLength)
        let screenGuid = UUID()
        ScreeningManager.sharedInstance.screening(username: patientData?.username ?? "", screenGuid: screenGuid.uuidString){ success, didSend, errorMessage in
            if success{
                
                ScreeningManager.sharedInstance.patientData = self.patientData
                ScreeningManager.sharedInstance.screeningGuid = screenGuid
                ScreeningManager.sharedInstance.saveScreeningGuid()
                
                let storyboard = UIStoryboard(name: "therapyNew", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TherapyPrepViewController") as! TherapyPrepViewController
                vc.prepTherapy = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else{
                let vc = GenericErrorPopupViewController()
                vc.baseContent = BasicPopupContent(title: "Error", message: "Error to start screening.\nTry again", option1: "OK")
            }
            self.screeningButton.isEnabled = true
        }
        
        
        
    }
    
    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Set dynamic height and width
    private func setupView(){
        addBorder()
        
        let notificationHeight: CGFloat = 100
        //let padding: CGFloat = 24

    } // !setupView
    
    private func addBorder() {
        self.tableView.layer.borderWidth = 1
        self.tableView.layer.borderColor = UIColor.wedgewoodBlue?.cgColor
        
        self.notificationView.layer.cornerRadius = 15
        self.notificationView.layer.borderWidth = 1
        self.notificationView.layer.borderColor = UIColor.casperBlue?.cgColor
    }
    
    func checkforPersonalization(){
        var valid = false
        if patientData != nil{
            valid = ScreeningManager.sharedInstance.checkForPersonalization(pData: patientData!)
        }
        
        screeningButton.isEnabled = valid
        notificationView.isHidden = valid
    }
} // !class

extension PatientFoundTabletViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Patient Id
        if tableRows[indexPath.row] == .patientId {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            //cell.delegate = self
            cell.setupView(rowName: "Patient ID", info: patientData?.patientId ?? "")
            
            return cell
            
        // First Name
        } else if tableRows[indexPath.row] == .firstName {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            //cell.delegate = self
            cell.setupView(rowName: "First name", info: patientData?.givenName ?? "")
            
            return cell
            
        // Middle Name
        } else if tableRows[indexPath.row] == .middleName {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            var middle = patientData?.middleName ?? "-"
            //cell.delegate = self
            cell.setupView(rowName: "Middle name/initial (Optional)", info: middle)
            
            return cell
            
        // Last Name
        } else if tableRows[indexPath.row] == .lastName {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            //cell.delegate = self
            cell.setupView(rowName: "Last name", info: patientData?.familyName ?? "")
            
            return cell
            
        // Suffix
        } else if tableRows[indexPath.row] == .patientSuffix {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            let suffix = patientData?.suffix ?? "-"
            cell.setupView(rowName: "Suffix (optional)", info: suffix)
            
            return cell
            
        // Date Of Birth
        } else if tableRows[indexPath.row] == .dateOfBirth {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            cell.setupView(rowName: "Date of birth", info: patientData?.birthDate ?? "")
            
            return cell
            
        // Gender
        } else if tableRows[indexPath.row] == .gender {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            var genderStr = "-"
            let genderCode = patientData?.gender
            let genderList = ScreeningManager.sharedInstance.demographicDict[.gender]
            if let genderDemo = genderList?.enumerated().first(where: {$0.element.id == genderCode}){
                genderStr = genderDemo.element.displayName
            }
            cell.setupView(rowName: "Gender", info: genderStr)
            
            return cell
            
        // Email Address
        } else if tableRows[indexPath.row] == .emailAddress {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            let email = patientData?.email ?? "-"
            cell.setupView(rowName: "Email address", info: email)
            
            return cell
            
        // Phone Number
        } else if tableRows[indexPath.row] == .phoneNumber {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            var phoneTxt = patientData?.phoneNumber ?? ""
            if !phoneTxt.isEmpty{
                phoneTxt = String(phoneTxt.dropFirst(2))
                phoneTxt.insert("(", at: phoneTxt.startIndex)
                phoneTxt.insert(")", at: phoneTxt.index(phoneTxt.startIndex, offsetBy: 4))
                phoneTxt.insert(" ", at: phoneTxt.index(phoneTxt.startIndex, offsetBy: 5))
                
                phoneTxt.insert("-", at: phoneTxt.index(phoneTxt.startIndex, offsetBy: 9))
            }
            
            cell.setupView(rowName: "Phone number", info: phoneTxt)
            
            return cell
            
        // Garment Size
        } else if tableRows[indexPath.row] == .garmentSize {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            let garmentStr = patientData?.garmentSize ?? "-"
            cell.setupView(rowName: "Garment size", info: garmentStr)
            
            return cell
            
        // Therapy Schedule
        } else if tableRows[indexPath.row] == .therapySchedule {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            let schedule = patientData?.therapySchedule ?? 0
            
            if schedule > 7{
                let weeks = schedule / 7
                cell.setupView(rowName: "Therapy schedule", info: "1 / \(weeks)-weeks")
            }
            else{
                cell.setupView(rowName: "Therapy schedule", info: "\(schedule)/ Week")
            }
            return cell
         
        // Most Bothersome Symptom
        } else if tableRows[indexPath.row] == .mostBothersomeSymptom {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            var bothersomeStr = "-"
            let bothersomeCode = patientData?.mostBothersomeSymptom
            let demoList = ScreeningManager.sharedInstance.demographicDict[.mostBothersomeSymptom]
            if let bothersomeDemo = demoList?.enumerated().first(where: {$0.element.id == bothersomeCode}){
                bothersomeStr = bothersomeDemo.element.displayName
            }
            
            cell.setupView(rowName: "Most bothersome symptom", info: bothersomeStr)
            
            return cell
            
        // Diagnosis Code
        } else if tableRows[indexPath.row] == .diagnosisCode {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            var diagnosisStr = "-"
            let diagnosisCode = patientData?.diagnosisCode
            let demoList = ScreeningManager.sharedInstance.demographicDict[.diagnosisCode]
            if let diagnosisDemo = demoList?.enumerated().first(where: {$0.element.id == diagnosisCode}){
                diagnosisStr = diagnosisDemo.element.displayName
            }
            cell.setupView(rowName: "Diagnosis code", info: diagnosisStr)
            
            return cell
        
        // Height
        }
        else if tableRows[indexPath.row] == .study{
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            var studyStr = "-"
            let studyType = patientData?.studyId ?? 0
            
            for item in ScreeningManager.sharedInstance.clinicList{
                if item.id == studyType{
                    studyStr = item.name
                    break
                }
            }
            
            cell.setupView(rowName: "Study", info: studyStr)
            return cell
        }
        
        else if tableRows[indexPath.row] == .patientHeight {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            var heightStr = "-"
            if let heightIn = patientData?.heightInches{
                var heightFt = heightIn / 12
                var heightRemInches = heightIn % 12
                heightStr = String(heightFt) + "ft, " + String(heightRemInches) + "in"
            }
            
            cell.setupView(rowName: "Height", info: heightStr)
            
            return cell
        
        // Weight
        } else if tableRows[indexPath.row] == .patientWeight {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            var weightStr = "-"
            if let weight = patientData?.weightPounds{
                weightStr = String(weight) + "lb"
            }
            cell.setupView(rowName: "Weight", info: weightStr)
            
            return cell
          
        // Smoking
        } else if tableRows[indexPath.row] == .smoking {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            var smokeStr = "-"
            if patientData?.smoking != nil{
                smokeStr = (patientData?.smoking!)! ? "Yes" : "No"
            }
            cell.setupView(rowName: "Smoking", info: smokeStr)
            
            return cell
            
        // Comorbidity
        } else if tableRows[indexPath.row] == .comorbidity {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            var comorbidityStr = "-"
            let comorbidityCode = patientData?.comorbidity
            let demoList = ScreeningManager.sharedInstance.demographicDict[.comorbidity]
            if let comorbidityDemo = demoList?.enumerated().first(where: {$0.element.id == comorbidityCode}){
                comorbidityStr = comorbidityDemo.element.displayName
            }
            cell.setupView(rowName: "Co-morbidity", info: comorbidityStr)
            
            return cell
            
        // Race
        } else if tableRows[indexPath.row] == .race {
            let cell = tableView.dequeueReusableCell(withIdentifier: "patientFoundTableViewCell", for: indexPath) as! PatientFoundTableViewCell
            
            var raceStr = "-"
            let raceCode = patientData?.race
            let demoList = ScreeningManager.sharedInstance.demographicDict[.race]
            if let raceDemo = demoList?.enumerated().first(where: {$0.element.id == raceCode}){
                raceStr = raceDemo.element.displayName
            }
            cell.setupView(rowName: "Race", info: raceStr)
            
            return cell
        }
            
        return UITableViewCell()
    }
}

extension PatientFoundTabletViewController: BackPromptDelegate{
    func goBackSelected() {
        for con in (navigationController?.viewControllers ?? []) as Array{
            if con.isKind(of: ClinicianHomePageTabletViewController.self){
                self.navigationController?.popToViewController(con, animated: true)
            }
        }
    }
}
