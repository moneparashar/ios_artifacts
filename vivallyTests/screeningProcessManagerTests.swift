//
//  screeningProcessManagerTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 5/24/22.
//

import XCTest
@testable import vivally

class screeningProcessManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConvertToInt() throws {
        let testInt32:[Int32] = [0xFFFF, 0, 1]
        
        let newInts = ScreeningProcessManager.sharedInstance.convertToInt(theData: testInt32)
        
        for newInt in newInts{
            XCTAssertTrue((newInt as Any) is Int)
            XCTAssertFalse((newInt as Any) is Int32)
        }
    }


}
