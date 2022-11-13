//
//  LocalStorageTests.swift
//  YellowIsTheNewBlackTests
//
//  Created by Young Bin on 2022/11/13.
//

import XCTest
import AVFoundation
@testable import YellowIsTheNewBlack

final class LocalStorageTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_AVCatpureSessionPresetStorage() throws {
        guard let storage = UserDefaults(suiteName: "test") else {
            XCTFail("Fail to make UserDefaults suite")
            return
        }
        
        var localConfig = LocalVideoSessionConfiguration(storage)
        
        // Testing value should not be same with default value
        let testingValue: AVCaptureSession.Preset = .low
        XCTAssertNotEqual(localConfig.videoQuality, testingValue)
        
        localConfig.videoQuality = .low
        XCTAssertEqual(localConfig.videoQuality, .low)
        
        storage.removePersistentDomain(forName: "test")
    }
    
    func test_AVCatpureDevicePosition() throws {
        guard let storage = UserDefaults(suiteName: "test") else {
            XCTFail("Fail to make UserDefaults suite")
            return
        }
        
        var localConfig = LocalVideoSessionConfiguration(storage)
        
        let testingValue: AVCaptureDevice.Position = .front
        XCTAssertNotEqual(localConfig.cameraPosition, testingValue)
        
        localConfig.cameraPosition = .front
        XCTAssertEqual(localConfig.cameraPosition, .front)
        
        storage.removePersistentDomain(forName: "test")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
