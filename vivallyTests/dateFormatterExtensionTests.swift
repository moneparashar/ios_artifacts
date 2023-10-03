//
//  dateFormatterExtensionTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 5/23/22.
//

import XCTest
@testable import vivally

class dateFormatterExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDateExtension() throws {
        let dateTestDateString = "2020-07-10T15:00:00.00Z"
        let df = DateFormatter.iso8601Full
        let date = df.date(from: dateTestDateString)
        
        XCTAssertNotNil(date, "Date is nil")
        
    }
}
