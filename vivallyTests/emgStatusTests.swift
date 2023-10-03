//
//  emgStatusTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 6/9/22.
//

import XCTest
@testable import vivally

class emgStatusTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testemgStatusTests() throws {
        var parseData = Data()
        let timestamp:UInt32 = 0x01
        let index:UInt8 = 0x02
        
        parseData.append(Data(from: timestamp))
        parseData.append(Data(from: index))
        for i in 0 ..< 32{
            parseData.append(Data(from:Int32(i)))
        }
        
        
        let emgStatus = EMGStatus()
        
        XCTAssertTrue(emgStatus.parse(data: parseData))
        XCTAssertTrue(emgStatus.timestamp == 0x01)
        XCTAssertTrue(emgStatus.index == 0x02)
        for i in 0 ..< 32{
            XCTAssertTrue(emgStatus.theData[i] == i)
        }
    }

  

}
