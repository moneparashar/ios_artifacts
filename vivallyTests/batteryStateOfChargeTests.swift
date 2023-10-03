//
//  batteryStateOfChargeTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 5/25/22.
//

import XCTest
@testable import vivally

class batteryStateOfChargeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBatteryIsGreen() throws {
       let batteryStateOfCharge = BatteryStateOfCharge()
        
        batteryStateOfCharge.voltage = 0
        
        XCTAssertFalse(batteryStateOfCharge.isBatteryGreen())
        
        batteryStateOfCharge.voltage = Int32(batteryStateOfCharge.batteryLowLevelMax)
        
        XCTAssertFalse(batteryStateOfCharge.isBatteryGreen())
        
        batteryStateOfCharge.voltage = batteryStateOfCharge.voltage + 1
        
        XCTAssertTrue(batteryStateOfCharge.isBatteryGreen())
    }
    
    func testCalcLevel() throws {
       let batteryStateOfCharge = BatteryStateOfCharge()
        
        batteryStateOfCharge.voltage = 0
        batteryStateOfCharge.calcLevel()
        
        XCTAssertTrue(batteryStateOfCharge.level == 0)
        
        batteryStateOfCharge.voltage = Int32(batteryStateOfCharge.batteryHighLevelMax)
        batteryStateOfCharge.calcLevel()
        
        XCTAssertTrue(batteryStateOfCharge.level == 100)
        
        
        batteryStateOfCharge.voltage = Int32(batteryStateOfCharge.batteryLowLevelMax)
        batteryStateOfCharge.calcLevel()
        
        XCTAssertTrue(batteryStateOfCharge.level == 50)

    }
    
    func testBatteryStateOfChartParse() throws {
        var parseData = Data()
        let charging:Bool = true
        let voltage:UInt32 = 0x01
        
        
        parseData.append(Data(from: charging))
        parseData.append(Data(from: voltage))
        
        let batteryStateOfCharge = BatteryStateOfCharge()
        
        XCTAssertTrue(batteryStateOfCharge.parse(data: parseData))
        XCTAssertTrue(batteryStateOfCharge.charging == true)
        XCTAssertTrue(batteryStateOfCharge.voltage == 0x01)
    }

   

}
