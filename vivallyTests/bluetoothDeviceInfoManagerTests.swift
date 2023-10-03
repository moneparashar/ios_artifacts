//
//  bluetoothDeviceInfoManagerTests.swift
//  vivallyTests
//
//  Created by Joe Sarkauskas on 5/25/22.
//

import XCTest
@testable import vivally

class bluetoothDeviceInfoManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBluetoothDeviceInfoManager() throws {
       
        BluetoothDeviceInfoManager.sharedInstance.clearDevice()
        
        XCTAssertTrue(BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac == "")
        XCTAssertTrue(BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceName == "")
        XCTAssertTrue(BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceID == "")
        
        BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac = "1"
        BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac = "2"
        BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac = "3"
        
        BluetoothDeviceInfoManager.sharedInstance.saveData()
        
        BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac = "4"
        BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac = "5"
        BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac = "6"
        
        BluetoothDeviceInfoManager.sharedInstance.setupManager()
        
        XCTAssertTrue(BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceMac == "1")
        XCTAssertTrue(BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceName == "2")
        XCTAssertTrue(BluetoothDeviceInfoManager.sharedInstance.deviceInfo.deviceID == "3")
    }

   

}
