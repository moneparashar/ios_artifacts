//
//  deviceTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 5/25/22.
//

import XCTest
@testable import vivally

class deviceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetErrorValue() throws {
       let device = Device()
        
        device.error = DeviceError.continuityBad.rawValue
        
        XCTAssertTrue(device.getErrorValue(bit: DeviceError.continuityBad))
        XCTAssertFalse(device.getErrorValue(bit: DeviceError.impedanceBad))
    }
    
    func testImpedenceCheck() throws {
       let device = Device()
        
        device.impedance = ImpedanceCheckValues.continuity.rawValue
        
        XCTAssertTrue(device.impedanceCheck(bit: .continuity))
        XCTAssertFalse(device.impedanceCheck(bit: .impedance))
    }
    
    func testVoluntaryEMGCheckValue() throws {
       let device = Device()
        
        device.voluntaryEMG = 0x08
        
        XCTAssertTrue(device.voluntaryEMGCheckValue(bit: 0x08))
        XCTAssertFalse(device.voluntaryEMGCheckValue(bit: 0x04))
    }

    func testDeviceParse() throws {
        var parseData = Data()
        let voluntaryEMG:UInt8 = 0x01
        let impedance:UInt8 = 0x02
        let error:UInt32 = 0x03
        let numberOfTicks:UInt8 = 0x04
        let originalStrengthTick:UInt8 = 0x05
        let currentStrengthTick:UInt8 = 0x06
        
        parseData.append(Data(from: voluntaryEMG))
        parseData.append(Data(from: impedance))
        parseData.append(Data(from: error))
        parseData.append(Data(from: numberOfTicks))
        parseData.append(Data(from: originalStrengthTick))
        parseData.append(Data(from: currentStrengthTick))
        
        let device = Device()
        
        XCTAssertTrue(device.parse(data: parseData))
        XCTAssertTrue(device.voluntaryEMG == 0x01)
        XCTAssertTrue(device.impedance == 0x02)
        XCTAssertTrue(device.error == 0x03)
        XCTAssertTrue(device.numberOfTicks == 0x04)
        XCTAssertTrue(device.originalStrengthTick == 0x05)
        XCTAssertTrue(device.currentStrengthTick == 0x06)
    }

}
