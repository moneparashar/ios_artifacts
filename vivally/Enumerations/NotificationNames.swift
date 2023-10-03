/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

//TODO: check if all are still used
enum NotificationNames: String{
    //journal
    case journalAdd = "JournalEntryAddNotification"
    case journalEdit = "JournalEditNotification"
    case journalChangeTime = "JournalEntryChangeTimeNotification"
    case journalCloseViewController = "CloseJournalEntryMainViewController"
    case journalsUpdated = "JournalEntryNotification"
    case openSelectedJournalDate = "OpenSelectedJournalDate"

    case statusGo = "GoToStatusNotification"
    case checksGo = "StartChecksNotification"
    case impNot = "impNotification"
    case helpGo = "GoToHelpNotification"   //me
    case closePopup = "ClosePopup"
    case callSetupBatteryNotify = "CallSetupBatteryNotify"
    
    case eulaDeclinedOnce = "EulaDeclinedOnce"
    case setPasswordNotif = "SetPasswordNotif"
    case setPin = "SetPINNotif"
    
    case badTimestamp = "badTimestamp"
    
    case finishTherapyRecovery = "finishedTherapyRecovery"
    case otaUpdateAvailable = "otaUpdateAvailable"
    case otaUpdateUnavailable = "otaUpdateUnavailable"
    case updateAvailable = "updateAvailable"
    case finishUpdate = "finishUpdateNotification"
    case interuptDataRecovery = "interuptDataRecovery"
    
    case screenNotification = "ScreenNotification"
    case cancelChangeStudy = "ChangeStudyCancel"
    case changeStudy = "ChangeStudyOk"
    case screeningPrepGo = "ScreeningPrep"
    case screeningCreateFail = "ScreeningCreateFail"
    
    case diaryRequest = "RequestingPatientToStart3DayDiary"
    case diaryEventConfirm = "Accept3DayDiary"
    
    case pair = "PairController"
    case unpair = "Unpair Controller"
    case lockout = "Lockout"
    case firstPair = "FirstPair"
    
    case prepWrongFootDismissed = "prepWrongFootDismissed"
    case pairingTimeExpired = "PairingTimeExpired"
    case tryAgainTapped = "TryAgainTapped"
    case navigationBackScreen = "navigationBackScreen"
}
