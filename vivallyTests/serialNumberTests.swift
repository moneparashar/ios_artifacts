//
//  serialNumberTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 6/9/22.
//

import XCTest
@testable import vivally

class serialNumberTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSerialNumberParse() throws {
        var parseData = Data()
        let serialNumber:UInt32 = 0x01020304
      
        
        parseData.append(Data(from: serialNumber))
          
        let sn = SerialNumber()
        
        XCTAssertTrue(sn.parse(data: parseData))
        XCTAssertTrue(sn.serialNum == 0x01020304)
    }

    

}
