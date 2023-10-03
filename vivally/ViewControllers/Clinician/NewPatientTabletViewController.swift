//
//  NewPatientTabletViewController.swift
//  vivally
//
//  Created by Ryan Levels on 1/17/23.
//

import UIKit
import PhoneNumberKit

class NewPatientTabletViewController: BaseNavViewController {
    
    @IBOutlet weak var stackViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var subjectIDLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    // New patient information
    @IBOutlet weak var firstNameStack: TextFieldStackView!
    @IBOutlet weak var middleNameStack: TextFieldStackView!
    @IBOutlet weak var lastNameStack: TextFieldStackView!
    @IBOutlet weak var suffixDropdownStack: DropdownOriginView!
    @IBOutlet weak var dateBirthStack: TextFieldStackView!
    @IBOutlet weak var genderDropdown: DropdownOriginView!
    @IBOutlet weak var emailStack: TextFieldStackView!
    @IBOutlet weak var phoneStack: TextFieldStackView!
    @IBOutlet weak var garmentDropdown: DropdownOriginView!
    @IBOutlet weak var therapyScheduleDropdown: DropdownOriginView!
    @IBOutlet weak var mostBothersomeSymptomDropdown: DropdownOriginView!
    @IBOutlet weak var diagnosisDropdown: DropdownOriginView!
    @IBOutlet weak var studyDropdown: DropdownOriginView!
    
    // Optional information
    @IBOutlet weak var optionalInfoStack: UIStackView!
    @IBOutlet weak var optionalInfoView: UIView!
    @IBOutlet weak var optionalInformationButton: UIButton!
    @IBOutlet weak var heightFeetDropdown: DropdownOriginView!
    @IBOutlet weak var heightInchesDropdown: DropdownOriginView!
    @IBOutlet weak var comorbidityDropdown: DropdownOriginView!
    @IBOutlet weak var weightDropdown: DropdownOriginView!
    @IBOutlet weak var smokingDropdown: DropdownOriginView!
    @IBOutlet weak var raceDropdown: DropdownOriginView!
    
    @IBOutlet weak var cancelButton: ActionButton!
    @IBOutlet weak var addButton: ActionButton!
    @IBOutlet weak var saveButton: ActionButton!
    
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    var datePicker: UIDatePicker!
    var dob: Date? = nil
    
    // suffix
    var suffixValues:[String] = []
    var suffixSelected: SuffixType = .none
    
    // garment size
    var garmentSizeValues:[String] = []
    var garmentSelected: GarmentSizes = .none
    
    // therapy sched.
    var therapyScheduleSelected: TherapySchedules = .oneTimes
    var therapyScheduleNumValues = [[Int]]()
    var therapyScheduleNames = [[String]]()
    var therapyScheduleValues: [String] = []
    var therapyScheduleIndex = 0
    
/*--*///MARK: Optional info variables
    // height
    var heightFeetValues:[String] = []
    var heightInchesValues:[String] = []
    var heightFeetSelected: HeightFeetValues = .none
    var heightInchesSelected: HeightInchesValues = .none
    
    // weight
    var weightValues:[String] = []
    
    // smoking
    var smokingValues:[String] = []
    var smokingSelected: SmokingValues = .none
    
    //study
    var studyValues:[Int] = []
    var studyNames:[String] = []
    var studyRowSelected:Int?
    
    var observersSet = false
    var editInfo = false
    var patientData:PatientExists?
    var singleStudyID:Int?
    
    var newStudyToChange = 0
    
    //demographics
    var demoIds:[DemographicsTypeValues : [Int]] = [:]
    var demoDisplayNames:[DemographicsTypeValues: [String]] = [:]
    var demoSelectedRow:[DemographicsTypeValues: Int] = [:]
    
    override func viewDidLoad() {
        super.goBackEnabled = true
        super.viewDidLoad()

        stackViewWidth.constant = view.getWidthConstant()
        
        phoneStack.tf.delegate = self
        let requiredStack = [firstNameStack, lastNameStack, dateBirthStack, emailStack, phoneStack]
        for reqField in requiredStack{
            reqField?.tf.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        }
        
        addButton.isEnabled = false
        addButton.backgroundColor = UIColor.casperBlue
        
        // Do any additional setup after loading the view.
        setupDemographics()
        setupOtherDropValues()
        setupOptionalInfoView()
        
        setupStacks()
        cancelButton.toSecondary()
                
        addButton.isHidden = editInfo
        saveButton.isHidden = !editInfo
        
        if editInfo && patientData != nil{
            loadValues()
        }
        else{
            loadClinics()
            studyDropdown.setup(title: "Study", options: studyNames)
            if therapyScheduleIndex > 0{
                therapyScheduleDropdown.setup(title: "Therapy schedule", options: therapyScheduleNames[therapyScheduleIndex])
            }
            preSelect()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !observersSet{
            addObservers()
            observersSet = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isBeingDismissed || self.isMovingFromParent{
            dismissObservers()
        }
    }
    
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(goToScreeningPrep), name: NSNotification.Name(NotificationNames.screeningPrepGo.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToErrorPopup), name: NSNotification.Name(NotificationNames.screeningCreateFail.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeStudy(notif:)), name: NSNotification.Name(NotificationNames.changeStudy.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelChangeStudy(notif:)), name: NSNotification.Name(NotificationNames.cancelChangeStudy.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNavigationBackNotification(notif:)), name: NSNotification.Name(NotificationNames.navigationBackScreen.rawValue), object: nil)
    }
    
    func dismissObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.screeningPrepGo.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.screeningCreateFail.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.changeStudy.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.cancelChangeStudy.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationNames.navigationBackScreen.rawValue), object: nil)
        observersSet = false
    }
    
    @objc func cancelChangeStudy(notif:Notification){
        if studyRowSelected != nil{
            studyDropdown.selectRow(ind: studyRowSelected!)
        }
        else{
            studyDropdown.contentLabel.text = " "
        }
    }
    
    @objc func changeStudy(notif:Notification){
        therapyScheduleIndex = newStudyToChange
        studyRowSelected = studyDropdown.dropDown.indexForSelectedRow ?? 0
        
        therapyScheduleDropdown.dropDown.dataSource = therapyScheduleNames[therapyScheduleIndex]
        therapyScheduleDropdown.selectRow(ind: 0)
        
        let chosenNum = therapyScheduleNumValues[studyRowSelected!][0]
        therapyScheduleSelected = TherapySchedules(rawValue: chosenNum)
    }
    
    @objc func handleNavigationBackNotification(notif:Notification) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func goToScreeningPrep(){
        let storyboard = UIStoryboard(name: "therapyNew", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TherapyPrepViewController") as! TherapyPrepViewController
        vc.prepTherapy = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToErrorPopup(){
        let vc = GenericErrorPopupViewController()
        vc.baseContent = BasicPopupContent(title: "Error", message: "Error to start screening.\nTry again", option1: "OK")
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    @IBAction func tappedCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    @IBAction func tappedAddPatient(_ sender: UIButton) {
        if validateAllFields(){
            addPatient()
        }
    }
    
    @IBAction func tappedSave(_ sender: ActionButton) {
        if validateAllFields(){
            sendPatientUpdate()
        }
    }
    
    
    // hide optional info stack with animation
    @IBAction func tappedOptionalInfoButton(_ sender: UIButton) {
        UIStackView.transition(with: optionalInformationButton, duration: 0.4, animations: { [self] in optionalInfoStack.isHidden = !optionalInfoStack.isHidden})
    }

    func setupStacks(){
        setupDOBField()
        
        // if view is new patient view, hide subject info
        
        if !editInfo {
            title = "New Patient Information"
            subjectIDLabel.isHidden = true
            subjectLabel.isHidden = true
            lineView.isHidden = true
        
        }
        else {
            title = "Edit Patient Information"
            subjectIDLabel.isHidden = false
            subjectLabel.isHidden = false
            lineView.isHidden = false
        }
        
        firstNameStack.setup(title: "First name")
        middleNameStack.setup(title: "Middle name (Optional)")
        lastNameStack.setup(title: "Last name")
        suffixDropdownStack.setup(title: "Suffix", placeholder: "", options: suffixValues)
        dateBirthStack.setup(title: "Date of birth")
        genderDropdown.setup(title: "Gender", options: demoDisplayNames[.gender] ?? [])
        emailStack.setup(title: "Email address")
        phoneStack.setup(title: "Phone number",keyboardType: .phonePad)
        studyDropdown.setup(title: "Study", options: studyNames)
        garmentDropdown.setup(title: "Garment Size", options: garmentSizeValues)
        therapyScheduleDropdown.setup(title: "Therapy schedule", options: [])
        mostBothersomeSymptomDropdown.setup(title: "Most bothersome symptom", options: demoDisplayNames[.mostBothersomeSymptom] ?? [])
        diagnosisDropdown.setup(title: "Diagnosis code", options: demoDisplayNames[.diagnosisCode] ?? [])
        
        heightFeetDropdown.setup(title: "Height (ft, in)", options: heightFeetValues)
        heightInchesDropdown.setup(title: " ", options: heightInchesValues)
        weightDropdown.setup(title: "Weight (lbs)", options: weightValues)
        smokingDropdown.setup(title: "Smoking", options: smokingValues)
        demoDisplayNames[.comorbidity]?.insert("", at: 0)
        comorbidityDropdown.setup(title: "Co-morbidity", options: demoDisplayNames[.comorbidity] ?? [])
        demoDisplayNames[.race]?.insert("", at: 0)
        raceDropdown.setup(title: "Race", options: demoDisplayNames[.race] ?? [])
        
        
        genderDropdown.delegate = self
        studyDropdown.delegate = self
        therapyScheduleDropdown.delegate = self
        mostBothersomeSymptomDropdown.delegate = self
        diagnosisDropdown.delegate = self
        heightFeetDropdown.delegate = self
        heightInchesDropdown.delegate = self
        smokingDropdown.delegate = self
        comorbidityDropdown.delegate = self
        raceDropdown.delegate = self
    }
    
    //MARK: Setup cloud dropdowns
    //gender, diagnosis code, co-morbidity, race, bothersome symptom
    func setupDemographics(){
        demoIds = [:]
        demoDisplayNames = [:]
        demoSelectedRow = [:]
        
        let demoDict = ScreeningManager.sharedInstance.demographicDict
        for demoType in DemographicsTypeValues.allCases{
            if demoType != .closeAccountReason{
                if let specificDemo = demoDict[demoType]{
                    demoDisplayNames[demoType] = []
                    demoIds[demoType] = []
                    let sequenceArray = specificDemo.sorted(by: { $0.sequence < $1.sequence })
                    for seqDemo in sequenceArray{
                        demoDisplayNames[demoType]?.append(seqDemo.displayName)
                        demoIds[demoType]?.append(seqDemo.id)
                    }
                }
            }
        }
    }
    
    func setupOtherDropValues(){
        for suffix in SuffixType.allCases {
            suffixValues.append(suffix.getStr())
        }
        for garment in GarmentSizes.allCases{
            garmentSizeValues.append(garment.getStr())
        }
        for heightFt in HeightFeetValues.allCases{
            heightFeetValues.append(heightFt.getStr())
        }
        for heightIn in HeightInchesValues.allCases{
            heightInchesValues.append(heightIn.getStr())
        }
        for smoke in SmokingValues.allCases{
            smokingValues.append(smoke.getStr())
        }
        for schedule in TherapySchedules.allCases{
            if schedule != .unknownSchedule{
                therapyScheduleValues.append(schedule.getStr())
            }
        }
        
        for screenWeight in ScreeningManager.sharedInstance.minWeight ... ScreeningManager.sharedInstance.maxWeight{
            weightValues.append(String(screenWeight))
        }
        weightValues.append(String(ScreeningManager.sharedInstance.maxWeight) + "+")
        weightValues.insert("", at: 0)
    }
    
    func setupOptionalInfoView() {
        optionalInfoView.layer.borderWidth = 1
        optionalInfoView.layer.cornerRadius = 15
        optionalInfoView.layer.borderColor = UIColor.casperBlue?.cgColor
    }
    
/*--*/// MARK: Setup Date Picker
    func setupDOBField(){
        datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200))
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .allEvents)
        datePicker.datePickerMode = .date
        if #available(iOS 15, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        else{
            datePicker.preferredDatePickerStyle = .wheels
        }
        dateBirthStack.tf.inputView = datePicker
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.datePickerDone))
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        dateBirthStack.tf.inputAccessoryView = toolBar
    }
    
    func displayDate(date:Date){
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        dateBirthStack.tf.text = df.string(from: date)
    }
    
    @objc func datePickerDone() {
        dateBirthStack.tf.resignFirstResponder()
        dob = datePicker.date
        addPatientValidation()
      }
    
    @objc func dateChanged() {
      displayDate(date: datePicker.date)
    }
/*--*/// !Setup Date Picker
    
    //MARK: Add/Edit Patient Info
    func addPatient(){
        if let patientToAdd = getPatientModel(){
            showLoading()
            ScreeningManager.sharedInstance.addPatient(patientExists: patientToAdd){ success, result, errorMessage in
                let vc = PatientEnrollmentMessagePopupViewController()
                if success{
                    patientToAdd.username = result?.user?.username
                    ScreeningManager.sharedInstance.saveAccountData(data: patientToAdd)
                    
                    vc.status = ScreeningManager.sharedInstance.checkForPersonalization(pData: patientToAdd) ? .added : .addedWithoutPersonalization
                }
                else{
                    vc.status = .failedAddPatient
                }
                
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: false)
                
                self.hideLoading()
            }
        }
    }
    
    
    func sendPatientUpdate(){
        if let updatedPatient = getPatientModel(){
            showLoading()
            ScreeningManager.sharedInstance.updatePatient(patientExists: updatedPatient){ success, result, errorMessage in
                if success{
                    updatedPatient.deviceMode = result?.user?.deviceMode
                    ScreeningManager.sharedInstance.saveAccountData(data: updatedPatient)
                    
                    //save succesful
                    let storyboard = UIStoryboard(name: "clinician", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PatientFoundTabletViewController") as! PatientFoundTabletViewController
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                else{
                    let vc = PatientEnrollmentMessagePopupViewController()
                    vc.status = .failedEdit
                    vc.modalPresentationStyle = .overCurrentContext
                    self.present(vc, animated: false)
                }
                self.hideLoading()
            }
        }
    }
    
    func getPatientModel() -> PatientExists?{
        let patientExists = patientData != nil ? patientData! : PatientExists()
        var acceptedPhoneNumber = ""
        let phoneNumberKit = PhoneNumberKit()
        do{
            let phoneNum = try phoneNumberKit.parse(phoneStack.tf.text!, withRegion: "US", ignoreType: true)
            acceptedPhoneNumber = phoneNumberKit.format(phoneNum, toType: .e164)
            
            patientExists.email = emailStack.tf.text!
            patientExists.phoneNumber = acceptedPhoneNumber
            patientExists.phone = acceptedPhoneNumber
            patientExists.givenName = firstNameStack.tf.text!
            patientExists.familyName = lastNameStack.tf.text!
            patientExists.birthDate = dateBirthStack.tf.text!
            
            patientExists.therapySchedule = therapyScheduleSelected.rawValue
            patientExists.garmentSize = garmentDropdown.contentLabel.text ?? ""
            
            if singleStudyID != nil{
                patientExists.studyId = singleStudyID
            }
            else if studyRowSelected != nil{
                patientExists.studyId = studyValues[studyRowSelected!]
            }
            
            patientExists.middleName = middleNameStack.tf.text
            patientExists.suffix = suffixDropdownStack.contentLabel.text
            
            if let mostBothersomeSymptomRow = demoSelectedRow[.mostBothersomeSymptom]{
                patientExists.mostBothersomeSymptom = demoIds[.mostBothersomeSymptom]?[mostBothersomeSymptomRow]
            }
            if let diagnosisRow = demoSelectedRow[.diagnosisCode]{
                patientExists.diagnosisCode = demoIds[.diagnosisCode]?[diagnosisRow]
            }
            patientExists.heightInches = getHeightTotal()
            
            patientExists.weightPounds = getWeight()
            
            if let comorbidityRow = demoSelectedRow[.comorbidity]{
                patientExists.comorbidity = comorbidityDropdown.contentLabel.text == "" ? nil : demoIds[.comorbidity]?[comorbidityRow - 1]
            }
            
            patientExists.smoking = smokingSelected.getBool()
            
            if let raceRow = demoSelectedRow[.race]{
                patientExists.race = raceDropdown.contentLabel.text == "" ? nil : demoIds[.race]?[raceRow - 1]
            }
            
            if let genderRow = demoSelectedRow[.gender]{
                patientExists.gender = demoIds[.gender]?[genderRow]
            }
            
            
            return patientExists
        } catch{
            return nil
        }
    }
    func findClinic(val: Int) -> Int?{
        var pos = 0
        for item in studyValues{
            if item == val{
                return pos
            }
            pos += 1
        }
        return nil
    }
    
    func loadClinics(){
        let clinicList = ScreeningManager.sharedInstance.clinicList
        
        for item in clinicList{
            studyValues.append(item.id)
            let name = (item.groupName == nil || item.groupName == "") ? item.name : item.groupName! + " " + item.name
            studyNames.append(name)
            therapyScheduleNumValues.append(item.studySchedules!.schedules)
        }
        studyDropdown.isHidden = studyValues.count < 2
        loadScheduleValues()
    }
    
    func findSchedule(val: Int) -> Int?{
        var pos = 0
        for item in therapyScheduleNumValues[therapyScheduleIndex]{
            if item == val{
                return pos
            }
            pos += 1
        }
        return nil
    }
    
    
    func loadScheduleValues(){
        var outerIndex = 0
        for groupSchedule in therapyScheduleNumValues{
            therapyScheduleNames.append([])
            for singleSchedule in groupSchedule{
                let therSch = TherapySchedules(rawValue: singleSchedule)
                therapyScheduleNames[outerIndex].append(therSch.getStr())
            }
            outerIndex += 1
        }
    }
    
    //when editing
    func loadValues(){
        firstNameStack.tf.text = patientData?.givenName
        lastNameStack.tf.text = patientData?.familyName
        let dateStr = patientData?.birthDate ?? ""
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        if let date = dateFormat.date(from: dateStr){
            datePicker.date = date
            displayDate(date: date)
            dob = date
        }
        
        emailStack.tf.text = patientData?.email
        var phone = patientData?.phoneNumber ?? ""
        phone.remove(at: phone.startIndex)
        phone.remove(at: phone.startIndex)
        phoneStack.tf.text = phone
        
        subjectLabel.text = patientData?.patientId
        
        if patientData?.garmentSize == "Medium"{
            garmentSelected = .medium
            garmentDropdown.selectRow(ind: 1)
        }
        else if patientData?.garmentSize == "Small"{
            garmentSelected = .small
            garmentDropdown.selectRow(ind: 0)
        }
        
        if ScreeningManager.sharedInstance.hasClinic{
            if studyValues.count == 0{
                loadClinics()
                studyDropdown.setup(title: "Study", options: studyNames)
                therapyScheduleDropdown.setup(title: "Therapy schedule", options: therapyScheduleNames[therapyScheduleIndex])
            }
            
            studyRowSelected = findClinic(val: (patientData?.studyId)!)
            if studyRowSelected != nil{
                studyDropdown.selectRow(ind: studyRowSelected!)
                therapyScheduleIndex = studyRowSelected ?? 0
                
                let chosenNum = patientData?.therapySchedule ?? 0
                therapyScheduleSelected = TherapySchedules(rawValue: chosenNum)
                therapyScheduleDropdown.contentLabel.text = therapyScheduleSelected.getStr()
                therapyScheduleDropdown.dropDown.dataSource = therapyScheduleNames[studyRowSelected!]
                
                var therapyInd = 0
                for therapySchedStr in therapyScheduleNames[studyRowSelected!]{
                    if therapyScheduleSelected.getStr() == therapySchedStr{
                        break
                    }
                    therapyInd += 1
                }
                therapyScheduleDropdown.selectRow(ind: therapyInd)
            }
        }
        
        middleNameStack.tf.text = patientData?.middleName
        
        if let suffixExists = patientData?.suffix{
            suffixSelected = SuffixType.none.getSuffixFromString(suf: suffixExists)
            suffixDropdownStack.selectRow(ind: suffixSelected.rawValue)
        }
        
        if let botherSomeCode = patientData?.mostBothersomeSymptom{
            if let symptomsIds = demoIds[.mostBothersomeSymptom]{
                var row = 0
                var foundMatch = false
                for symptom in symptomsIds{
                    if symptom == botherSomeCode{
                        foundMatch = true
                        break
                    }
                    row += 1
                }
                if foundMatch{
                    demoSelectedRow[.mostBothersomeSymptom] = row
                    mostBothersomeSymptomDropdown.selectRow(ind: row)
                }
            }
        }
        
        if let diagnosisCode = patientData?.diagnosisCode{
            if let symptomsIds = demoIds[.diagnosisCode]{
                var row = 0
                var foundMatch = false
                for symptom in symptomsIds{
                    if symptom == diagnosisCode{
                        foundMatch = true
                        break
                    }
                    row += 1
                }
                if foundMatch{
                    demoSelectedRow[.diagnosisCode] = row
                    diagnosisDropdown.selectRow(ind: row)
                }
            }
        }
        
        if let height = patientData?.heightInches{
            let feet = height / 12
            heightFeetSelected = HeightFeetValues(rawValue: feet) ?? .none
            heightFeetDropdown.selectRow(ind: heightFeetSelected.rawValue)
            
            let inch = height % 12
            heightInchesSelected = HeightInchesValues(rawValue: inch) ?? .none
            heightInchesDropdown.selectRow(ind: heightInchesSelected.rawValue)
        }
        
        let diff = ScreeningManager.sharedInstance.minWeight // weight starts at 50 lbs
        if let weight = patientData?.weightPounds{
            weightDropdown.selectRow(ind: (weight - diff) + 1)
        }
        
        if let comorbidityCode = patientData?.comorbidity{
            if let symptomsIds = demoIds[.comorbidity]{
                var row = 0
                var foundMatch = false
                for symptom in symptomsIds{
                    if symptom == comorbidityCode{
                        foundMatch = true
                        break
                    }
                    row += 1
                }
                if foundMatch{
                    demoSelectedRow[.comorbidity] = row + 1
                    comorbidityDropdown.selectRow(ind: row + 1)
                }
            }
        }
        
        
        if let smokingVal = patientData?.smoking{
            smokingSelected = smokingVal ? .yes : .no
            smokingDropdown.selectRow(ind: smokingSelected.rawValue)
        }
        
        if let raceCode = patientData?.race{
            if let symptomsIds = demoIds[.race]{
                var row = 0
                var foundMatch = false
                for symptom in symptomsIds{
                    if symptom == raceCode{
                        foundMatch = true
                        break
                    }
                    row += 1
                }
                if foundMatch{
                    demoSelectedRow[.race] = row + 1
                    raceDropdown.selectRow(ind: row + 1)
                }
            }
        }
        
        if let genderCode = patientData?.gender{
            if let symptomsIds = demoIds[.gender]{
                var row = 0
                var foundMatch = false
                for symptom in symptomsIds{
                    if symptom == genderCode{
                        foundMatch = true
                        break
                    }
                    row += 1
                }
                if foundMatch{
                    demoSelectedRow[.gender] = row
                    genderDropdown.selectRow(ind: row)
                }
            }
        }
    }
    
    func preSelect(){
        if singleStudyID == nil{
            var ind = 0
            for stVal in studyNames{
                if (stVal.caseInsensitiveCompare("Registry") == .orderedSame){
                    //dropSelected(ind: ind, option: stVal, sender: studyDropdown)
                    studyRowSelected = ind
                    break
                }
                ind += 1
            }
            studyDropdown.selectRow(ind: studyRowSelected!)
        }
        
        //preselct 3/week
        if studyRowSelected != nil{
            therapyScheduleSelected = .threeTimes
            therapyScheduleDropdown.contentLabel.text = therapyScheduleSelected.getStr()
            therapyScheduleDropdown.dropDown.dataSource = therapyScheduleNames[studyRowSelected!]
            
            var therapyInd = 0
            for therapySchedStr in therapyScheduleNames[studyRowSelected!]{
                if therapyScheduleSelected.getStr() == therapySchedStr{
                    break
                }
                therapyInd += 1
            }
            therapyScheduleDropdown.selectRow(ind: therapyInd)
        }
    }
    
    //MARK: Validation
    func validateAllFields() -> Bool {
        if !validateRequiredFields(){
            return false
        }
        if !ScreeningManager.sharedInstance.validateBirth(birthday: dob){
            dateBirthStack.setErrorMessage(message: "Invalid Date of Birth")
            return false
        }
        //will need to add one for optionals
        return true
    }
    
    func validateRequiredFields() -> Bool{
        firstNameStack.resetErrorMessage()
        lastNameStack.resetErrorMessage()
        dateBirthStack.resetErrorMessage()
        phoneStack.resetErrorMessage()
        emailStack.resetErrorMessage()
        genderDropdown.resetErrorMessage()
        
        var success = true
        
        if firstNameStack.tf.text?.isEmpty ?? true{
            firstNameStack.setErrorMessage(message: "First name required")
            success = false
        }
        if lastNameStack.tf.text?.isEmpty ?? true{
            lastNameStack.setErrorMessage(message: "Last name required")
            success = false
        }
        if dateBirthStack.tf.text?.isEmpty ?? true{
            dateBirthStack.setErrorMessage(message: "Date of birth required")
            success = false
        }
        if phoneStack.tf.text?.isEmpty ?? true{
            phoneStack.setErrorMessage(message: "Phone number required")
            success = false
        }
        else{
            do{
                _ = try PhoneNumberKit().parse(phoneStack.tf.text!, withRegion: "US", ignoreType: true)
            } catch{
                phoneStack.setErrorMessage(message: "Invalid Phone number")
                success = false
            }
        }
        
        if emailStack.tf.text?.isEmpty ?? true{
            emailStack.setErrorMessage(message: "Email required")
            success = false
        }
        
        if genderDropdown.dropDown.selectedItem == nil{
            genderDropdown.errorLabel.text = "Gender required"
            genderDropdown.errorLabel.textAlignment = .left
            success = false
        }
        
        return success
    }
    
    func getHeightTotal() -> Int?{
        if heightFeetSelected == .none{
            return nil
        }
        let allInches = heightFeetSelected.rawValue * 12 + heightInchesSelected.rawValue
        return allInches
    }
    
    func getWeight() -> Int?{
        if weightDropdown.dropDown.indexForSelectedRow != nil{
            if weightValues.count - 1 == weightDropdown.dropDown.indexForSelectedRow!{
                return ScreeningManager.sharedInstance.maxWeight + 1
            }
            else if weightDropdown.dropDown.indexForSelectedRow == 0 {
                return nil
            }
            else if let selectedWeightStr = weightDropdown.dropDown.selectedItem{
                return Int(selectedWeightStr)
            }
        }
        return nil
    }
    
    func addPatientValidation()  {
        let allFieldsHaveText = !firstNameStack.tf.text!.isEmpty && !lastNameStack.tf.text!.isEmpty && !dateBirthStack.tf.text!.isEmpty && !emailStack.tf.text!.isEmpty && !phoneStack.tf.text!.isEmpty && !genderDropdown.contentLabel.text!.isEmpty

        addButton.isEnabled = allFieldsHaveText
        
        if !addButton.isEnabled
        {
            addButton.backgroundColor = UIColor.casperBlue
        }
    }
}

extension NewPatientTabletViewController: DropdownOriginViewDelegate{
    func dropSelected(ind: Int, option: String, sender: DropdownOriginView) {
        if sender == genderDropdown{
            demoSelectedRow[.gender] = ind
        }
        else if sender == therapyScheduleDropdown{
            if studyRowSelected == nil{
                studyRowSelected = 0
            }
            let chosenNum = therapyScheduleNumValues[studyRowSelected!][ind]
            therapyScheduleSelected = TherapySchedules(rawValue: chosenNum)
        }
        else if sender == mostBothersomeSymptomDropdown{
            demoSelectedRow[.mostBothersomeSymptom] = ind
        }
        else if sender == diagnosisDropdown{
            demoSelectedRow[.diagnosisCode] = ind
        }
        else if sender == studyDropdown{
            if studyRowSelected != ind{
                newStudyToChange = ind
                let vc = ChangeStudyPopupViewController()
                vc.study = studyNames[ind]
                vc.modalPresentationStyle = .overCurrentContext
                present(vc, animated: false)
            }
        }
        else if sender == heightFeetDropdown{
            heightFeetSelected = HeightFeetValues(rawValue: ind) ?? .none
            if heightFeetSelected != .none{
                if heightInchesSelected == .none{
                    heightInchesDropdown.selectRow(ind: 0)
                }
            }
        }
        else if sender == heightInchesDropdown{
            heightInchesSelected = HeightInchesValues(rawValue: ind) ?? .none
        }
        else if sender == smokingDropdown{
            smokingSelected = SmokingValues(rawValue: ind) ?? .none
        }
        else if sender == comorbidityDropdown{
            demoSelectedRow[.comorbidity] = ind
        }
        else if sender == raceDropdown{
            demoSelectedRow[.race] = ind
        }
    }
}

extension NewPatientTabletViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 10
        if textField == phoneStack.tf{
            // Get the full text with the replacement string
            var newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            
            // Remove any non-digit characters from the new text
            newText = newText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            
            let currentLength = newText.count
            if currentLength > maxLength {
                let index = newText.index(newText.startIndex, offsetBy: maxLength)
                newText = String(newText.prefix(upTo: index))
            }
            
            // Format the mobile number if it has at least 10 digits
            if newText.count >= 10 {
                let areaCodeEndIndex = newText.index(newText.startIndex, offsetBy: 3)
                let areaCode = newText[newText.startIndex..<areaCodeEndIndex]
                
                let middlePartStartIndex = newText.index(areaCodeEndIndex, offsetBy: 0)
                let middlePartEndIndex = newText.index(middlePartStartIndex, offsetBy: 3)
                let middlePart = newText[middlePartStartIndex..<middlePartEndIndex]
                
                let remainingDigitsStartIndex = newText.index(middlePartEndIndex, offsetBy: 0)
                let remainingDigits = newText[remainingDigitsStartIndex...]
                
                newText = "\(areaCode) \(middlePart) \(remainingDigits)"
            }
            
            // Set the formatted or limited text back to the text field
            textField.text = newText
            addPatientValidation()
            
            // Return false to prevent further text processing by the text field
            return false
        }
        return true
    }
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        // Enable the button if the text field has text, disable it otherwise
        addPatientValidation()
    }
}
