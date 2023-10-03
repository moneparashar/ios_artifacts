//
//  otaRevisionTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 6/9/22.
//

import XCTest
@testable import vivally

class otaRevisionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOTARevisionParse() throws {
        var parseData = Data()
        let major:UInt8 = 0x01
        let minor:UInt8 = 0x02
        let patch:UInt8 = 0x03
        
        parseData.append(Data(from: major))
        parseData.append(Data(from: minor))
        parseData.append(Data(from: patch))
        
        
        
        let otaRevision = OTARevision()
        
        XCTAssertTrue(otaRevision.parse(data: parseData))
        XCTAssertTrue(otaRevision.major == 0x01)
        XCTAssertTrue(otaRevision.minor == 0x02)
        XCTAssertTrue(otaRevision.patch == 0x03)
        
    }

    
}
