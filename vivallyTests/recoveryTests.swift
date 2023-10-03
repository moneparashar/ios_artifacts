//
//  recoveryTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 6/9/22.
//

import XCTest
@testable import vivally

class recoveryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRecoveryParse() throws {
        let recovery = Recovery()
        
        recovery.patientSchedule = 0
        recovery.patientTimeSet = 1
        recovery.skinParesthesia = 2
        recovery.soleParesthesia = 3
        recovery.painThreshold = 4
        recovery.pulseWidthAtEmg = 5
        recovery.comfortLevelEMG = 6
        recovery.detectionLevelEMG = 7
        recovery.foot = 8
        recovery.amplitude = 9
        recovery.pulseWidthTarget = 10
        recovery.evalEmgTarget = 11
        recovery.patientInfoComplete = 12
        recovery.pulseWidthStrengthMax = 13
        recovery.strengthMax = 14
        recovery.pauseCount = 15
        recovery.tempPainThreshold = 16
        recovery.painThresholdMax = 17
        recovery.emgTargetIncrement = 18
        recovery.lastCompletedTime1 = 19
        recovery.lastCompletedTime2 = 20
        recovery.lastCompletedTime3 = 21
        recovery.nextAvailableTime = 22
        recovery.emgTargetUpdated = 23
        recovery.numTicks = 24
        recovery.currentTick = 25
        recovery.evalTick = 26
        recovery.pwIncrement = 27
        recovery.subjectID = "12345678901234567890"
        recovery.screenTime = 28
        recovery.dailyTherapyTime = 29
        
        var data = Data()
        
        data.append(Data(from:recovery.patientSchedule))
        data.append(Data(from:recovery.patientTimeSet))
        data.append(Data(from:recovery.skinParesthesia))
        data.append(Data(from:recovery.soleParesthesia))
        data.append(Data(from:recovery.painThreshold))
        data.append(Data(from:recovery.pulseWidthAtEmg))
        data.append(Data(from:recovery.comfortLevelEMG))
        data.append(Data(from:recovery.detectionLevelEMG))
        data.append(Data(from:recovery.foot))
        data.append(Data(from:recovery.amplitude))
        data.append(Data(from:recovery.pulseWidthTarget))
        data.append(Data(from:recovery.evalEmgTarget))
        data.append(Data(from:recovery.patientInfoComplete))
        data.append(Data(from:recovery.pulseWidthStrengthMax))
        data.append(Data(from:recovery.strengthMax))
        data.append(Data(from:recovery.pauseCount))
        data.append(Data(from:recovery.tempPainThreshold))
        data.append(Data(from:recovery.painThresholdMax))
        data.append(Data(from:recovery.emgTargetIncrement))
        data.append(Data(from:recovery.lastCompletedTime1))
        data.append(Data(from:recovery.lastCompletedTime2))
        data.append(Data(from:recovery.lastCompletedTime3))
        data.append(Data(from:recovery.nextAvailableTime))
        data.append(Data(from:recovery.emgTargetUpdated))
        data.append(Data(from:recovery.numTicks))
        data.append(Data(from:recovery.currentTick))
        data.append(Data(from:recovery.evalTick))
        data.append(Data(from:recovery.pwIncrement))
        data.append(recovery.subjectID.data(using: .utf8)!)
        data.append(Data(from:recovery.screenTime))
        data.append(Data(from:recovery.dailyTherapyTime))
        
        let recovery2 = Recovery()
        
        XCTAssertTrue(recovery2.parse(data: data))
    
        XCTAssertTrue(recovery.patientSchedule == recovery2.patientSchedule)
        XCTAssertTrue(recovery.patientTimeSet == recovery2.patientTimeSet)
        XCTAssertTrue(recovery.skinParesthesia == recovery2.skinParesthesia)
        XCTAssertTrue(recovery.soleParesthesia == recovery2.soleParesthesia)
        XCTAssertTrue(recovery.painThreshold == recovery2.painThreshold)
        XCTAssertTrue(recovery.pulseWidthAtEmg == recovery2.pulseWidthAtEmg)
        XCTAssertTrue(recovery.comfortLevelEMG == recovery2.comfortLevelEMG)
        XCTAssertTrue(recovery.detectionLevelEMG == recovery2.detectionLevelEMG)
        XCTAssertTrue(recovery.foot == recovery2.foot)
        XCTAssertTrue(recovery.amplitude == recovery2.amplitude)
        XCTAssertTrue(recovery.pulseWidthTarget == recovery2.pulseWidthTarget)
        XCTAssertTrue(recovery.evalEmgTarget == recovery2.evalEmgTarget)
        XCTAssertTrue(recovery.patientInfoComplete == recovery2.patientInfoComplete)
        XCTAssertTrue(recovery.pulseWidthStrengthMax == recovery2.pulseWidthStrengthMax)
        XCTAssertTrue(recovery.strengthMax == recovery2.strengthMax)
        XCTAssertTrue(recovery.pauseCount == recovery2.pauseCount)
        XCTAssertTrue(recovery.tempPainThreshold == recovery2.tempPainThreshold)
        XCTAssertTrue(recovery.painThresholdMax == recovery2.painThresholdMax)
        XCTAssertTrue(recovery.emgTargetIncrement == recovery2.emgTargetIncrement)
        
        XCTAssertTrue(recovery.lastCompletedTime1 == recovery2.lastCompletedTime1)
        XCTAssertTrue(recovery.lastCompletedTime2 == recovery2.lastCompletedTime2)
        XCTAssertTrue(recovery.lastCompletedTime3 == recovery2.lastCompletedTime3)
        XCTAssertTrue(recovery.nextAvailableTime == recovery2.nextAvailableTime)
        XCTAssertTrue(recovery.emgTargetUpdated == recovery2.emgTargetUpdated)
        XCTAssertTrue(recovery.numTicks == recovery2.numTicks)
        XCTAssertTrue(recovery.currentTick == recovery2.currentTick)
        XCTAssertTrue(recovery.evalTick == recovery2.evalTick)
        XCTAssertTrue(recovery.pwIncrement == recovery2.pwIncrement)
        XCTAssertTrue(recovery.subjectID == recovery2.subjectID)
        XCTAssertTrue(recovery.screenTime == recovery2.screenTime)
        XCTAssertTrue(recovery.dailyTherapyTime == recovery2.dailyTherapyTime)
        
       
    }


}
