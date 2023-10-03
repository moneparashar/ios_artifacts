//
//  otaAddressTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 6/9/22.
//

import XCTest
@testable import vivally

class otaAddressTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOTAAddressToDataModel() throws {
        let otaAddress = OTAAddress()
        
        otaAddress.action = .startWirelessFileUpload
        otaAddress.address1 = 0x01
        otaAddress.address2 = .userApplication
        otaAddress.address3 = 0x03
        
        let data = otaAddress.toDataModel()
        
        print(data.map { String(format: "%02x", $0) }.joined())
        
        XCTAssertTrue(data[0] == 0x01)
        XCTAssertTrue(data[1] == 0x01)
        XCTAssertTrue(data[2] == 0x70)
        XCTAssertTrue(data[3] == 0x03)
    }

    func testOTAAddressToStartDataModel() throws {
        let otaAddress = OTAAddress()
        
       
        
        let data = otaAddress.toDataStartModel()
        
        print(data.map { String(format: "%02x", $0) }.joined())
        
        XCTAssertTrue(data[0] == 0x02)
        XCTAssertTrue(data[1] == 0x00)
        XCTAssertTrue(data[2] == 0x70)
        XCTAssertTrue(data[3] == 0x00)
    }
    
    func testOTAAddresstoDataFinishModel() throws {
        let otaAddress = OTAAddress()
        
       
        
        let data = otaAddress.toDataFinishModel()
        
        print(data.map { String(format: "%02x", $0) }.joined())
        
        XCTAssertTrue(data[0] == 0x07)
        
    }

}
