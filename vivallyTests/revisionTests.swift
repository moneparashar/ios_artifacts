//
//  revisionTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 6/9/22.
//

import XCTest
@testable import vivally

class revisionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRevisionParse() throws {
        var parseData = Data()
        let major:UInt8 = 0x01
        let minor:UInt8 = 0x02
        let patch:UInt8 = 0x03
        let blMajor:UInt8 = 0x04
        let blMinor:UInt8 = 0x05
        let blPatch:UInt8 = 0x06
        
        parseData.append(Data(from: major))
        parseData.append(Data(from: minor))
        parseData.append(Data(from: patch))
        parseData.append(Data(from: blMajor))
        parseData.append(Data(from: blMinor))
        parseData.append(Data(from: blPatch))
        
        let revision = Revision()
        
        XCTAssertTrue(revision.parse(data: parseData))
        XCTAssertTrue(revision.major == 0x01)
        XCTAssertTrue(revision.minor == 0x02)
        XCTAssertTrue(revision.patch == 0x03)
        XCTAssertTrue(revision.bootloaderMajor == 0x04)
        XCTAssertTrue(revision.bootloaderMinor == 0x05)
        XCTAssertTrue(revision.bootloaderPatch == 0x06)
    }

   

}
