/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit

class StimDataManager: NSObject {
    static let sharedInstance = StimDataManager()
    var stimData = StimData()
    var recordCount = 0
    var stimDataTimer:Timer?
    var stimDataCount = 0
    
    func postStimData(stimData:StimData, completion:@escaping (Bool, StimData?, String) -> ()) {
        APIClient.postStimData(stimData: stimData){ success, result, errorMessage in
            if success{
                completion(true, result, errorMessage)
                do{
                try StimDataDataHelper.insert(item: result!)
                } catch{
                    print("error with stimData insert")
                }
            }
            else{
                completion(success, result, errorMessage)
            }
        }
    }
    
    
    func postStimDataBulk(stimDataArray:[StimData], completion:@escaping (Bool, String) -> ()) {
        APIClient.postStimDataBulk(stimDataArray: stimDataArray){ success, errorMessage, authorized in
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
    
    func getBulkCount(completion:@escaping (Bool, BulkConfig?, String) -> ()) {
        APIClient.getStimDataBulkCount(){ [self] success, result, errorMessage, authorized in
            if success{
                completion(true, result, errorMessage)
                self.recordCount = result!.recordCount
            }
            else{
                if !authorized{
                    RefreshManager.sharedInstance.handleRefresh(after401Fail: true)
                }
                completion(success, result, errorMessage)
            }
            print(recordCount)
        }
    }
    
    func handleStimStatus(startingTime: Int32 = 0, stimStatus: StimulationStatus, therapy: Bool = true, screenGuid: UUID?, user: String, recoveryGuid: UUID? = nil){
        do{
            let newStimData = StimData()
            newStimData.dirty = true
            newStimData.modified = Date()
            newStimData.screeningGuid = screenGuid
            
            newStimData.state = stimStatus.state.rawValue
            newStimData.runningState = stimStatus.runningState.rawValue
            newStimData.deviceTime = Int32(stimStatus.deviceTime) == 0 ? 0 : Int32(stimStatus.deviceTime)
            newStimData.timeRemaining = stimStatus.timeRemaining == 0 ? stimData.timeRemaining : stimStatus.timeRemaining
            newStimData.pauseTimeRemaining = stimStatus.pauseTimeRemaining == 0 ? stimData.pauseTimeRemaining : stimStatus.pauseTimeRemaining
            newStimData.event  = stimStatus.event
            newStimData.currentAmplitude  = stimStatus.amplitude == 0 ? stimData.currentAmplitude : stimStatus.amplitude
            newStimData.percentEMGDetect  = stimStatus.percentageEMGDetection == 0 ? stimData.percentEMGDetect : stimStatus.percentageEMGDetection
            newStimData.percentNoiseDetect  = stimStatus.percentagePulsesEMGNoisy == 0 ? stimData.percentNoiseDetect : stimStatus.percentagePulsesEMGNoisy
            newStimData.emgDetected  = stimStatus.emgDetected ?  1 : (stimData.emgDetected)
            newStimData.emgTarget  = Int32(stimStatus.emgTarget) == 0 ? stimData.emgTarget : Int32(stimStatus.emgTarget)
            newStimData.pulseWidth  = stimStatus.pulseWidth == 0 ? stimData.pulseWidth : stimStatus.pulseWidth
            newStimData.pulseWidthMax  = stimStatus.pulseWidthMax == 0 ? stimData.pulseWidthMax : stimStatus.pulseWidthMax
            newStimData.pulseWidthMin  = stimStatus.pulseWidthMin == 0 ? stimData.pulseWidthMin : stimStatus.pulseWidthMin
            newStimData.pulseWidthAvg  = stimStatus.pulseWidthAvg == 0 ? stimData.pulseWidthAvg : stimStatus.pulseWidthAvg
            newStimData.emgStrength  = Int32(stimStatus.emgStrength) == 0 ? stimData.emgStrength : Int32(stimStatus.emgStrength)
            newStimData.emgStrengthMax  = Int32(stimStatus.emgStrengthMax) == 0 ? stimData.emgStrengthMax : Int32(stimStatus.emgStrengthMax)
            newStimData.emgStrengthMin  = Int32(stimStatus.emgStrengthMin) == 0 ? stimData.emgStrengthMin : Int32(stimStatus.emgStrengthMin)
            newStimData.emgStrengthAvg  = Int32(stimStatus.emgStrengthAvg) == 0 ? stimData.emgStrengthAvg : Int32(stimStatus.emgStrengthAvg)
            newStimData.impedanceStim  = Int32(stimStatus.impedanceStim) == 0 ? stimData.impedanceStim : Int32(stimStatus.impedanceStim)
            newStimData.impedanceStimMax  = Int32(stimStatus.impedanceStimMax) == 0 ? stimData.impedanceStimMax : Int32(stimStatus.impedanceStimMax)
            newStimData.impedanceStimMin  = Int32(stimStatus.impedanceStimMin) == 0 ? stimData.impedanceStimMin : Int32(stimStatus.impedanceStimMin)
            newStimData.impedanceStimAvg  = Int32(stimStatus.impedanceStimAvg) == 0 ? stimData.impedanceStimAvg : Int32(stimStatus.impedanceStimAvg)
            newStimData.mainState = stimStatus.mainState.rawValue
            newStimData.footConnectionADC = stimStatus.footConnectionADC == 0 ? stimData.footConnectionADC : stimStatus.footConnectionADC
            newStimData.tempPainThreshold = Int32(stimStatus.tempPainThreshold) == 0 ? stimData.tempPainThreshold : Int32(stimStatus.tempPainThreshold)
            newStimData.errorCodes = Int32(stimStatus.errorCodes) == 0 ? stimData.errorCodes : Int32(stimStatus.errorCodes)
            newStimData.temperature = stimStatus.temperature == 0 ? stimData.temperature : stimStatus.temperature
            newStimData.rawADCAtStimPulse = stimStatus.rawADCAtStimPulse == 0 ? stimData.rawADCAtStimPulse : stimStatus.rawADCAtStimPulse
            if therapy{
                if recoveryGuid != nil {
                    if (try SessionDataDataHelper.find(uid: recoveryGuid!.uuidString)) != nil{
                        newStimData.sessionGuid = recoveryGuid
                    }
                    else{
                        return
                    }
                }
                else{
                    if let latestSession = try SessionDataDataHelper.getLatestRunning(startingTime: startingTime, name: user){
                        newStimData.sessionGuid = latestSession.guid
                    }
                    else{
                        return
                    }
                }
            }
            stimData = newStimData
            _ = try StimDataDataHelper.insert(item: stimData)
        } catch{
            Slim.error("fail to insert stim status")
        }
    }
    
    func startStimDataTimer(){
        if stimDataTimer != nil{
            stimDataTimer?.invalidate()
        }
        stimDataTimer = nil
        stimDataTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireStimDataTimer), userInfo: nil, repeats: true)
    }
    
    func stopStimDataTimer() {
        //DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            if stimDataTimer != nil{
                stimDataTimer?.invalidate()
            }
            stimDataTimer = nil
        //}
        
    }
    
    @objc func fireStimDataTimer(){
        print("StimDataTimerFired!")
        
        do{
            try StimDataDataHelper.insert(item: stimData)
        } catch{
            print("error with stimdata insert")
        }
    }
    
    //newer changes
    var stimSending = false
    func syncStimData(completion:@escaping() -> () ){
        //grab bulk count
        getBulkCount(){ success, count, errorMessage in
            if success{
                if count != nil{
                    self.recordCount = count!.recordCount
                    do{
                        let bulkToSend = try StimDataDataHelper.getLatestWithMax(bulkCount: self.recordCount)
                        if bulkToSend == []{
                            self.stimSending = false
                            completion()
                            return
                        }
                        self.stimSending = true
                        Slim.info("begin stim bulk send")
                        for stimbulk in bulkToSend{     //with current setup should send around 2 bulk counts for full therapy
                            if stimbulk != nil{
                                if stimbulk!.count > self.recordCount{
                                    Slim.info("Stim bulk exceeds max size")
                                }
                            }
                            self.postStimDataBulk(stimDataArray: stimbulk!){ success, errorMessage in
                                if success{
                                    do{
                                        try StimDataDataHelper.setSentClean(sentStimBulk: stimbulk!)
                                    } catch { print("Error with setting dirty clean after send")}
                                    if stimbulk == bulkToSend.last{
                                        self.stimSending = false
                                        Slim.info("end stim bulk send")
                                        self.checkStimDataLeft(originalBulkSent: bulkToSend)
                                        do{
                                            try StimDataDataHelper.clearClean()
                                        } catch{
                                            print("error with deleting clean records")
                                        }
                                        completion()
                                    }
                                }
                                else{
                                    Slim.error("stim bulk post error: \(errorMessage)")
                                    print("error with posting stim bulk")
                                    //don't need to retrigger send since syncStimData should call again every 15 min
                                    if stimbulk == bulkToSend.last{
                                        self.stimSending = false
                                        Slim.info("end stim bulk send")
                                        self.checkStimDataLeft(originalBulkSent: bulkToSend)
                                        do{
                                            try StimDataDataHelper.clearClean()
                                        } catch{
                                            print("error with deleting clean records")
                                        }
                                        completion()
                                    }
                                }
                            }
                        }
                    } catch {
                        print("failure with stim data sync")
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
    
    
    
    func checkStimDataLeft(originalBulkSent: [[StimDataDataHelper.T]?]){
        do{
            let recordsLeft = try StimDataDataHelper.getTotalRecordsLeftToSend()
            var originalRecords = 0
            var numOfBulks = 0
            for bulk in originalBulkSent{
                if bulk != nil{
                    let bulkrecords = bulk!.count
                    originalRecords += bulkrecords
                }
                numOfBulks += 1
            }
            //let progress = Double(originalRecords / (recordsLeft + originalRecords)) * 100
            
            //let percent = Double((originalRecords - recordsLeft) / originalRecords) * 100
            Slim.info("Records left to send: \(recordsLeft), # Records attempted to Send: \(originalRecords), bulks Sent: \(numOfBulks)")
        } catch{
            print("failure with checking how many stim records left to send")
        }
    }

}
