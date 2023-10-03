/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class PatientExists: Codable {
    var cognitoGuid: String? = nil
    var patientId:String? = nil 
    var subjectId:String? = nil
    var garmentSize:String? = nil
    var studyId:Int? = nil
    var therapySchedule:Int = 0
    var sub:String? = nil
    var email:String = ""
    var phoneNumber:String = ""
    var phone:String = ""
    var givenName:String = ""
    var familyName:String = ""
    var birthDate:String = ""
    var deviceMode:Int? = nil
    
    var middleName:String? = nil
    var suffix:String? = ""
    var mostBothersomeSymptom:Int? = nil
    var diagnosisCode:Int? = nil
    var heightInches:Int? = nil
    var weightPounds:Int? = nil
    var comorbidity:Int? = nil
    var smoking:Bool? = nil
    var race:Int? = nil
    var gender:Int? = nil
    var username:String? = nil
    
    var firstName:String? = nil
    var lastName:String? = nil
    var hasCompletedScreening:Bool? = nil
    
    enum CodingKeys: CodingKey{
        case cognitoGuid
        case userId
        case patientId
        case subjectId
        case garmentSize
        case studyId
        case therapySchedule
        case sub
        case email
        case phoneNumber
        case givenName
        case familyName
        case birthDate
        case deviceMode
        
        case middleName
        case suffix
        case mostBothersomeSymptom
        case diagnosisCode
        case heightInches
        case weightPounds
        case comorbidity
        case smoking
        case race
        case gender
        case username
        
        case firstName
        case lastName
        case hasCompletedScreening
    }
    
    init(){
        cognitoGuid = nil
        username = nil
        patientId = nil
        subjectId = nil
        garmentSize = nil
        studyId = nil
        therapySchedule = 0
        sub = nil
        email = ""
        phoneNumber = ""
        givenName = ""
        familyName = ""
        birthDate = ""
        deviceMode = nil
        
        middleName = nil
        suffix = nil
        mostBothersomeSymptom = nil
        diagnosisCode = nil
        heightInches = nil
        weightPounds = nil
        comorbidity = nil
        smoking = nil
        race = nil
        gender = nil
        
        username = nil
        
        firstName = nil
        lastName = nil
        hasCompletedScreening = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(cognitoGuid, forKey: .cognitoGuid)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(patientId, forKey: .patientId)
        try container.encodeIfPresent(subjectId, forKey: .subjectId)
        try container.encodeIfPresent(garmentSize, forKey: .garmentSize)
        try container.encodeIfPresent(studyId, forKey: .studyId)
        try container.encodeIfPresent(therapySchedule, forKey: .therapySchedule)
        try container.encodeIfPresent(sub, forKey: .sub)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(givenName, forKey: .givenName)
        try container.encodeIfPresent(familyName, forKey: .familyName)
        try container.encodeIfPresent(birthDate, forKey: .birthDate)
        try container.encodeIfPresent(deviceMode, forKey: .deviceMode)
        
        try container.encodeIfPresent(middleName, forKey: .middleName)
        try container.encodeIfPresent(suffix, forKey: .suffix)
        try container.encodeIfPresent(mostBothersomeSymptom, forKey: .mostBothersomeSymptom)
        try container.encodeIfPresent(diagnosisCode, forKey: .diagnosisCode)
        try container.encodeIfPresent(heightInches, forKey: .heightInches)
        try container.encodeIfPresent(weightPounds, forKey: .weightPounds)
        try container.encodeIfPresent(comorbidity, forKey: .comorbidity)
        try container.encodeIfPresent(smoking, forKey: .smoking)
        try container.encodeIfPresent(race, forKey: .race)
        try container.encodeIfPresent(gender, forKey: .gender)
        
        try container.encodeIfPresent(username, forKey: .username)
        
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(hasCompletedScreening, forKey: .hasCompletedScreening)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        cognitoGuid = try container.decodeIfPresent(String.self, forKey: .cognitoGuid)
        username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        patientId = try container.decodeIfPresent(String.self, forKey: .patientId) ?? ""
        subjectId = try container.decodeIfPresent(String.self, forKey: .subjectId) ?? ""
        garmentSize = try container.decodeIfPresent(String.self, forKey: .garmentSize) ?? ""
        studyId = try container.decodeIfPresent(Int.self, forKey: .studyId) ?? 0
        therapySchedule = try container.decode(Int.self, forKey: .therapySchedule)
        sub = try container.decodeIfPresent(String.self, forKey: .sub)
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber) ?? ""
        givenName = try container.decodeIfPresent(String.self, forKey: .givenName) ?? ""
        familyName = try container.decodeIfPresent(String.self, forKey: .familyName) ?? ""
        birthDate = try container.decodeIfPresent(String.self, forKey: .birthDate) ?? ""
        deviceMode = try container.decodeIfPresent(Int.self, forKey: .deviceMode)
        
        middleName = try container.decodeIfPresent(String.self, forKey: .middleName)
        suffix = try container.decodeIfPresent(String.self, forKey: .suffix)
        mostBothersomeSymptom = try container.decodeIfPresent(Int.self, forKey: .mostBothersomeSymptom)
        diagnosisCode = try container.decodeIfPresent(Int.self, forKey: .diagnosisCode)
        heightInches = try container.decodeIfPresent(Int.self, forKey: .heightInches)
        weightPounds = try container.decodeIfPresent(Int.self, forKey: .weightPounds)
        comorbidity = try container.decodeIfPresent(Int.self, forKey: .comorbidity)
        smoking = try container.decodeIfPresent(Bool.self, forKey: .smoking)
        race = try container.decodeIfPresent(Int.self, forKey: .race)
        gender = try container.decodeIfPresent(Int.self, forKey: .gender)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        
        hasCompletedScreening = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedScreening)
    }
}
