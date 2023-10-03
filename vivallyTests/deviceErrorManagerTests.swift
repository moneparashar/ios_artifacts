//
//  deviceErrorManagerTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 5/25/22.
//

import XCTest
@testable import vivally

class deviceErrorManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIsThereError() throws {
        DeviceErrorManager.sharedInstance.impedanceCheckRunning = true
        DeviceErrorManager.sharedInstance.resetAll()
        
        XCTAssertTrue(DeviceErrorManager.sharedInstance.impedanceCheckRunning == false)
    }

    
}
