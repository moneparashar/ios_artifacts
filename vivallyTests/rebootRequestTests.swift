//
//  rebootRequestTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 6/9/22.
//

import XCTest
@testable import vivally

class rebootRequestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetOTAReboot() throws {
        let rebootRequest = RebootRequest()
        
        rebootRequest.getOTAReboot(sizeInBytes: 20480)
        
        XCTAssertTrue(rebootRequest.bootMode == 0x01)
        XCTAssertTrue(rebootRequest.sectorIndex == 0x07)
        XCTAssertTrue(rebootRequest.numberofSectorsToErase == 0x06)
        
        rebootRequest.bootMode = 0x03
        rebootRequest.sectorIndex = 0x08
        
        rebootRequest.getOTAReboot(sizeInBytes: 0)
        
        XCTAssertTrue(rebootRequest.bootMode == 0x01)
        XCTAssertTrue(rebootRequest.sectorIndex == 0x07)
        XCTAssertTrue(rebootRequest.numberofSectorsToErase == 127)
    }

    func testToDataModel() throws {
        let rebootRequest = RebootRequest()
        rebootRequest.getOTAReboot(sizeInBytes: 0)
        
        let data = rebootRequest.toDataModel()
        print(data.map { String(format: "%02x", $0) }.joined())
        XCTAssertTrue(data[0] == 0x01)
        XCTAssertTrue(data[1] == 0x07)
        XCTAssertTrue(data[2] == 127)
    }

}
