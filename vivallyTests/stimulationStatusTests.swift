//
//  stimulationStatusTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 6/9/22.
//

import XCTest
@testable import vivally

class stimulationStatusTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStimulationStatusParse() throws {
        var parseData = Data()
        let state:StimStatusStates = .competed
        let runningState:StimStatusRunningStates = .idle
        let deviceTime:Int32 = 0x01
        let timeRemaining:Int16 = 0x02
        let pauseTimeRemaining:Int16 = 0x03
        let event:Int8 = 0x04
        let amplitude:Int16 = 0x05
        let percentageEMGDetection:Int8 = 0x04
        let percentagePulsesEMGNoisy:Int8 = 0x05
        let emgDetected:Bool = true
        let emgTarget:Int32 = 0x07
        let pulseWidth:Int16 = 0x08
        let pulseWidthMax:Int16 = 0x09
        let pulseWidthMin:Int16 = 0x01
        let pulseWidthAvg:Int16 = 0x02
        let emgStrength:Int32 = 0x03
        let emgStrengthMax:Int32 = 0x04
        let emgStrengthMin:Int32 = 0x05
        let emgStrengthAvg:Int32 = 0x06
        let impedanceStim:Int32 = 0x07
        let impedanceStimMax:Int32 = 0x08
        let impedanceStimMin:Int32 = 0x09
        let impedanceStimAvg:Int32 = 0x01
        let mainState:StimStatusMainState = .idle
        let footConnectionADC: Int16 = 0x02
        let tempPainThreshold: Int32 = 0x03
        let errorCodes: Int32 = 0x04
        let temperature: Int8 = 0x05
        let rawADCAtStimPulse: Int16 = 0x06
        let currentTick: Int8 = 0x07
        let dailyTherapyTime: Int16 = 0x08
        let lastCompletedTime:Int32 = 0x09
        
        parseData.append(Data(from:state.rawValue))
        parseData.append(Data(from:runningState))
        parseData.append(Data(from:deviceTime))
        parseData.append(Data(from:timeRemaining))
        parseData.append(Data(from:pauseTimeRemaining))
        parseData.append(Data(from:event))
        parseData.append(Data(from:amplitude))
        parseData.append(Data(from:percentageEMGDetection))
        parseData.append(Data(from:percentagePulsesEMGNoisy))
        parseData.append(Data(from:emgDetected))
        parseData.append(Data(from:emgTarget))
        parseData.append(Data(from:pulseWidth))
        parseData.append(Data(from:pulseWidthMax))
        parseData.append(Data(from:pulseWidthMin))
        parseData.append(Data(from:pulseWidthAvg))
        parseData.append(Data(from:emgStrength))
        parseData.append(Data(from:emgStrengthMax))
        parseData.append(Data(from:emgStrengthMin))
        parseData.append(Data(from:emgStrengthAvg))
        parseData.append(Data(from:impedanceStim))
        parseData.append(Data(from:impedanceStimMax))
        parseData.append(Data(from:impedanceStimMin))
        parseData.append(Data(from:impedanceStimAvg))
        parseData.append(Data(from:mainState.rawValue))
        parseData.append(Data(from:footConnectionADC))
        parseData.append(Data(from:tempPainThreshold))
        parseData.append(Data(from:errorCodes))
        parseData.append(Data(from:temperature))
        parseData.append(Data(from:rawADCAtStimPulse))
        parseData.append(Data(from:currentTick))
        parseData.append(Data(from:dailyTherapyTime))
        parseData.append(Data(from:lastCompletedTime))
        
        let ss = StimulationStatus()
        
        XCTAssertTrue(ss.parse(data: parseData))
        
        XCTAssertTrue(ss.state == state)
        XCTAssertTrue(ss.runningState == runningState)
        XCTAssertTrue(ss.deviceTime == deviceTime)
        XCTAssertTrue(ss.timeRemaining == timeRemaining)
        XCTAssertTrue(ss.pauseTimeRemaining == pauseTimeRemaining)
        XCTAssertTrue(ss.event == event)
        XCTAssertTrue(ss.amplitude == amplitude)
         XCTAssertTrue(ss.percentageEMGDetection == percentageEMGDetection)
         XCTAssertTrue(ss.percentagePulsesEMGNoisy == percentagePulsesEMGNoisy)
         XCTAssertTrue(ss.emgDetected == emgDetected)
         XCTAssertTrue(ss.emgTarget == emgTarget)
         XCTAssertTrue(ss.pulseWidth == pulseWidth)
         XCTAssertTrue(ss.pulseWidthMax == pulseWidthMax)
         XCTAssertTrue(ss.pulseWidthMin == pulseWidthMin)
         XCTAssertTrue(ss.pulseWidthAvg == pulseWidthAvg)
         XCTAssertTrue(ss.emgStrength == emgStrength)
         XCTAssertTrue(ss.emgStrengthMax == emgStrengthMax)
         XCTAssertTrue(ss.emgStrengthMin == emgStrengthMin)
         XCTAssertTrue(ss.emgStrengthAvg == emgStrengthAvg)
         XCTAssertTrue(ss.impedanceStim == impedanceStim)
         XCTAssertTrue(ss.impedanceStimMax == impedanceStimMax)
         XCTAssertTrue(ss.impedanceStimMin == impedanceStimMin)
         XCTAssertTrue(ss.impedanceStimAvg == impedanceStimAvg)
         XCTAssertTrue(ss.mainState == mainState)
         XCTAssertTrue(ss.footConnectionADC == footConnectionADC)
         XCTAssertTrue(ss.tempPainThreshold == tempPainThreshold)
         XCTAssertTrue(ss.errorCodes == errorCodes)
         XCTAssertTrue(ss.temperature == temperature)
         XCTAssertTrue(ss.rawADCAtStimPulse == rawADCAtStimPulse)
         XCTAssertTrue(ss.currentTick == currentTick)
         XCTAssertTrue(ss.dailyTherapyTime == dailyTherapyTime)
         XCTAssertTrue(ss.lastCompletedTime == lastCompletedTime)
    }


}
