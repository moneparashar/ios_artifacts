/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class UserModel: Codable {
    var userId:String?
    var username:String?
    var status:String?
    var sub:UUID?
    var email:String?
    var emailVerified:Bool?
    //var phoneNumber:String?       //will be added later
    var name:String?
    var givenName:String?
    var familyName:String?
    var middleName:String?
    var acceptedEULA:Bool?
    var roles:[String]?
    var therapySchedule:Int?
    var clinicId:Int?
    var clinicIds:[Int]?
    var viewTherapy:Bool?
    var viewJournal:Bool?
    var studyId:Int?
    var studyIds:[Int]?
    var id: Int?
    var trialPatient: Bool?
    var deviceMode: Int?
    var patientId: String?
    var clinicianId: String?
    var hasCompletedScreening: Bool?
    
    
    enum CodingKeys: CodingKey{
        case userId
        case username
        case status
        case sub
        case email
        case emailVerified
        case name
        case givenName
        case familyName
        case middleName
        case acceptedEULA
        case roles
        case therapySchedule
        case clinicId
        case clinicIds
        case viewTherapy
        case viewJournal
        case studyId
        case studyIds
        case id
        case trialPatient
        case deviceMode
        case patientId
        case clinicianId
        case hasCompletedScreening
    }
}
