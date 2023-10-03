//
//  encodableExtenstionTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 5/23/22.
//

import XCTest
@testable import vivally

class encodableExtenstionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncodableAsDictionary() throws {
        let testToken = Token()
        
        let testTokenString = "This is a test token"
        
        testToken.token = testTokenString
        
        let tokenDictionary = try testToken.asDictionary()
        
        XCTAssertNotNil(tokenDictionary)
        
        let tokenFromDictionary = tokenDictionary["token"] as! String
        
        XCTAssertNotNil(tokenFromDictionary)
        XCTAssertEqual(tokenFromDictionary, testTokenString)
        
    }


}
