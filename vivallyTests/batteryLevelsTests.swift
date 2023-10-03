//
//  batteryLevelsTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 6/9/22.
//

import XCTest
@testable import vivally

class batteryLevelsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBatteryLevelParse() throws {
        var parseData = Data()
        let empty:UInt32 = 0x01
        let low:UInt32 = 0x02
        let half:UInt32 = 0x03
        let high:UInt32 = 0x04
        let full:UInt32 = 0x05
        
        parseData.append(Data(from: empty))
        parseData.append(Data(from: low))
        parseData.append(Data(from: half))
        parseData.append(Data(from: high))
        parseData.append(Data(from: full))
        
        let batteryLevels = BatteryLevels()
        
        XCTAssertTrue(batteryLevels.parse(data: parseData))
        XCTAssertTrue(batteryLevels.empty == 0x01)
        XCTAssertTrue(batteryLevels.low == 0x02)
        XCTAssertTrue(batteryLevels.half == 0x03)
        XCTAssertTrue(batteryLevels.high == 0x04)
        XCTAssertTrue(batteryLevels.full == 0x05)
    }


}
