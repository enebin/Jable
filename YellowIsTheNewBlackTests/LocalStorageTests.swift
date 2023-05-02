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
    var storage: UserDefaults!

    override func setUpWithError() throws {
        guard let storage = UserDefaults(suiteName: "test") else {
            XCTFail("Fail to make UserDefaults suite")
            return
        }

        self.storage = storage
    }

    override func tearDownWithError() throws {
        storage.removePersistentDomain(forName: "test")
    }

    func testAVCatpureSessionPresetLoadAndSave() throws {
        var localConfig = LocalVideoSessionConfiguration(storage)

        // Testing value should not be same with default value
        let testingValue: AVCaptureSession.Preset = .low
        XCTAssertNotEqual(localConfig.videoQuality, testingValue)

        localConfig.videoQuality = .low
        XCTAssertEqual(localConfig.videoQuality, .low)
    }

    func testAVCatpureDevicePositionLoadAndSave() throws {
        var localConfig = LocalVideoSessionConfiguration(storage)

        let testingValue: AVCaptureDevice.Position = .front
        XCTAssertNotEqual(localConfig.cameraPosition, testingValue)

        localConfig.cameraPosition = .front
        XCTAssertEqual(localConfig.cameraPosition, .front)
    }
}
