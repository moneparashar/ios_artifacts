//
//  dataExtensionTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 5/23/22.
//

import XCTest
@testable import vivally

class dataExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDataExtensionHexEncodedString() throws {
                
        let dataTestValue:Int32 = 0x11223344
        let dataObject = Data(from: dataTestValue)
        let dataHexString = dataObject.hexEncodedString()
        XCTAssertEqual(dataHexString, "44332211", "Hex Endcoded String fail, dataObject: \(dataHexString)")
        
    }
    
    func testDataExtensionHexEncodedMACString() throws {
        let dataTestValue:Int32 = 0x11223344
        let dataObject = Data(from: dataTestValue)
        let dataHexString = dataObject.hexEncodedMACString()
        XCTAssertEqual(dataHexString, "44:33:22:11", "Hex Endcoded MAC String fail, dataObject: \(dataHexString)")
        
    }
    
    func testDataExtensionToAndFromInt() throws {
        let dataTestValue:Int32 = 0x11223344
        let dataObject = Data(from: dataTestValue)
        let testValue:Int32 = dataObject.to(type: Int32.self)
        XCTAssertEqual(testValue, dataTestValue, "Data to Int32 failed, dataTestValue: \(dataTestValue), testValue: \(testValue)")
        
    }
}
