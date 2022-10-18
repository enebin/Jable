//
//  MultiCameraSessionTests.swift
//  YellowIsTheNewBlackTests
//
//  Created by Young Bin on 2022/10/18.
//

import XCTest
import AVFoundation
@testable import YellowIsTheNewBlack

final class MultiCameraSessionTests: XCTestCase {

    func test__Configure_multicamera_session() async throws {
        let expectation = XCTestExpectation(description: "Waiting for background queue")
        
        let manager = MultiVideoSessionManager.shared
        XCTAssertThrowsError(try manager.startRunningSession())
        
//        try await manager.setupSession(configuration: VideoSessionConfiguration.shared)
        manager.session = AVCaptureMultiCamSession() // Inject mock session
        XCTAssertNoThrow(try manager.startRunningSession {
            expectation.fulfill()
        })

        let session = try XCTUnwrap(manager.session)
        
        XCTAssertTrue(session.isRunning)
        wait(for: [expectation], timeout: 5)
    }
}
