//
//  therapySessionTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 6/9/22.
//

import XCTest
@testable import vivally

class therapySessionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTherapySessionParse() throws {
        var parseData = Data()
        let startTime:Int32 = 0x01
        let isNewSession:UInt8 = 0x02
        let isComplete:UInt8 = 0x03
        let pauseCount:UInt16 = 0x04
        let duration:UInt16 = 0x05
        let detectedEMGCount:UInt16 = 0x06
        let avgEMGStrength:Int32 = 0x07
        let avgStimPulseWidth:Int32 = 0x08
        let maxStimPulseWidth:Int32 = 0x09
        let overallAvgImpedance:Int32 = 0x10
        let batteryLevelAtStart:Int32 = 0x11
        let foot:UInt8 = 0x12
        
        parseData.append(Data(from:startTime))
        parseData.append(Data(from:isNewSession))
        parseData.append(Data(from:isComplete))
        parseData.append(Data(from:pauseCount))
        parseData.append(Data(from:duration))
        parseData.append(Data(from:detectedEMGCount))
        parseData.append(Data(from:avgEMGStrength))
        parseData.append(Data(from:avgStimPulseWidth))
        parseData.append(Data(from:maxStimPulseWidth))
        parseData.append(Data(from:overallAvgImpedance))
        parseData.append(Data(from:batteryLevelAtStart))
        parseData.append(Data(from:foot))
    
        let ts = TherapySession()
        
        XCTAssertTrue(ts.parse(data: parseData))
        XCTAssertTrue(ts.startTime == startTime)
        XCTAssertTrue(ts.isNewSession == isNewSession)
        XCTAssertTrue(ts.pauseCount == pauseCount)
        XCTAssertTrue(ts.isComplete == isComplete)
        XCTAssertTrue(ts.duration == duration)
        XCTAssertTrue(ts.detectedEMGCount == detectedEMGCount)
        XCTAssertTrue(ts.avgEMGStrength == avgEMGStrength)
         XCTAssertTrue(ts.avgStimPulseWidth == avgStimPulseWidth)
         XCTAssertTrue(ts.maxStimPulseWidth == maxStimPulseWidth)
         XCTAssertTrue(ts.overallAvgImpedance == overallAvgImpedance)
         XCTAssertTrue(ts.batteryLevelAtStart == batteryLevelAtStart)
         XCTAssertTrue(ts.foot == foot)
       }


}
