//
//  commandTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 6/9/22.
//

import XCTest
@testable import vivally

class commandTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCommandToDataModel() throws {
        let command = Command()
        
        let data = command.toDataModel(command: 0x01, parameter: [0x02])
        
        XCTAssertTrue(data.subdata(in: 0..<2).to(type: UInt16.self) == 0x01 )
        XCTAssertTrue(data[2] == 0x02)
    }
    
    func testCommandParse() throws {
        let command = Command()
        
        let data = command.toDataModel(command: 0x01, parameter: [0x02])
        
        XCTAssertTrue(command.parse(data: data))
        XCTAssertTrue(command.command == 0x01)
        XCTAssertTrue(command.parameters[0] == 0x02)
    }

    

}
