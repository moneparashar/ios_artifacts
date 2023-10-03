/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class EMGDataManager: NSObject {
    static let sharedInstance = EMGDataManager()
    var EMGDataTimer:Timer?
    var EMGDataCount = 0
    //var emgData = EMGData()
    
    func postEMGData(emgData:EMGData, completion:@escaping (Bool, EMGData?, String) -> ()) {
        APIClient.postEMGData(emgData: emgData){ success, result, errorMessage in
            if success{
                completion(true, result, errorMessage)
            }
            else{
                completion(success, result, errorMessage)
            }
        }
    }
    
    
    func postEMGDataBulk(emgDataArray:[EMGData], completion:@escaping (Bool, String) -> ()) {
        APIClient.postEMGDataBulk(emgData: emgDataArray){ success, errorMessage, authorized in
            if success{
                completion(true, errorMessage)
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, errorMessage)
            }
        }
    }
    
    func handleEMGStatus(startingTime: Int32 = 0, status: EMGStatus, therapy: Bool = true, screenGuid: UUID?, user: String){
        //let eval = EvaluationCriteriaManager.sharedInstance.loadEvalCritData()
        //let user = KeychainManager.sharedInstance.accountData?.username ?? ""
        do{
            let emgData = EMGData()
            emgData.dirty = true
            emgData.modified = Date()
            //emgData.screeningGuid = eval?.screeningGuid
            emgData.screeningGuid = screenGuid
            emgData.index = status.index
            emgData.dataTimestamp = Int(status.timestamp)
            emgData.data = convertToInt(theData: status.theData)
            emgData.sessionGuid = nil
            
            if therapy{
                if let latestSession = try SessionDataDataHelper.getLatestRunning(startingTime: startingTime, name: user){
                    emgData.sessionGuid = latestSession.guid
                }
                else{
                    return
                }
            }
            _ = try EMGDataDataHelper.insert(item: emgData)
        }
         catch{
            print("fail to to insert emg status")
        }
    }
    
    func convertToInt(theData:[Int32]) -> [Int] {
        var data = [Int]()
        for item in theData {
            let sub = Int(item)
            data.append(sub)
        }
        return data
    }
    
    var emgSending = false
    func syncEMGData(completion:@escaping() -> ()){
        //grab bulk count
        StimDataManager.sharedInstance.getBulkCount(){ success, count, errorMessage in
            if success{
                if count != nil{
                    StimDataManager.sharedInstance.recordCount = count!.recordCount
                    do{
                        let bulkToSend = try EMGDataDataHelper.getLatestWithMax(bulkCount: StimDataManager.sharedInstance.recordCount)
                        if bulkToSend == []{
                            self.emgSending = false
                            completion()
                            return
                        }
                        self.emgSending = true
                        Slim.info("begin emg bulk send")
                        Slim.log(level: LogLevel.error, category: [.deviceInfo], "EMG Data Transfer: Sending Bulk Data")
                        for emgBulk in bulkToSend{     //with current setup should send 2 bulk counts every full therapy
                            if emgBulk != nil{
                                self.postEMGDataBulk(emgDataArray: emgBulk!){ success, errorMessage in
                                    if success{
                                        do{
                                            try EMGDataDataHelper.setSentClean(sentEMGBulk: emgBulk!)
                                        } catch { Slim.error("Error with setting dirty clean after send")}
                                        if emgBulk == bulkToSend.last{
                                            self.emgSending = false
                                            Slim.info("end emg bulk send")
                                            self.checkEMGDataLeft(originalBulkSent: bulkToSend)
                                            do{
                                                try EMGDataDataHelper.clearClean()
                                            } catch{
                                                Slim.error("error with deleting clean records")
                                                Slim.log(level: LogLevel.error, category: [.deviceInfo], "EMG Data Transfer: Error Deleting Clean Records")
                                            }
                                            completion()
                                        }
                                    }
                                    else{
                                        Slim.error("emg bulk post error: \(errorMessage)")
                                        Slim.log(level: LogLevel.error, category: [.deviceInfo], "EMG Data Transfer: Bulk Post Error: \(errorMessage)")
                                        //don't need to retrigger send since syncEMGData should call again
                                        if emgBulk == bulkToSend.last{
                                            self.emgSending = false
                                            Slim.info("end emg bulk send")
                                            self.checkEMGDataLeft(originalBulkSent: bulkToSend)
                                            do{
                                                try EMGDataDataHelper.clearClean()
                                            } catch{
                                                Slim.error("error with deleting clean records")
                                            }
                                            completion()
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        Slim.error("failure with emg data sync")
                        completion()
                    }
                }
            }
            else{
                Slim.error("failure with finding bulk count")
                completion()
            }
        }
    }
    
    func checkEMGDataLeft(originalBulkSent: [[EMGDataDataHelper.T]?]){
        do{
            let recordsLeft = try EMGDataDataHelper.getTotalRecordsLeftToSend()
            var originalRecords = 0
            for bulk in originalBulkSent{
                if bulk != nil{
                    let bulkrecords = bulk!.count
                    originalRecords += bulkrecords
                }
            }
            let percent = Double((originalRecords - recordsLeft) / originalRecords) * 100
            Slim.info("Total EMG Data Sent: \(percent)%")
        } catch{
            Slim.log(level: LogLevel.warning, category: [.deviceInfo], "EMG Data Transfer: Sending Data = false")
            print("failure with checking how many emg records left to send")
        }
    }

}
