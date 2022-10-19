//
//  MultiCameraSessionTests.swift
//  YellowIsTheNewBlackTests
//
//  Created by Young Bin on 2022/10/18.
//

import XCTest
import Quick
import Nimble
import Mockingbird

import AVFoundation
@testable import YellowIsTheNewBlack

final class MakeSessionSpec: QuickSpec {
    override func spec() {
        describe("Make camera session") {
            var manager = MultiVideoSessionManager()
        
            context("Trying to make camera without config") {
                beforeEach {
                    manager = MultiVideoSessionManager()
                }
                
                it("should throw error") {
                    expect { try manager.startRunningSession() }.to(throwError())
                }
            }
        }
    }
}

@MainActor
final class MultiCameraSessionTests: XCTestCase {
    func test__Configure_multicamera_session() async throws {
        let manager = MultiVideoSessionManager()
        
        let mockSession = mock(AVCaptureMultiCamSession.self)
        let mockInput = mock(AVCaptureInput.self)
        let mockBackOutput = mock(AVCaptureMovieFileOutput.self)
        let mockFrontOutput = mock(AVCaptureMovieFileOutput.self)

        given(mockSession.canAddInput(mockInput)).willReturn(true)
        given(mockSession.canAddOutput(mockBackOutput)).willReturn(true)
        given(mockSession.canAddOutput(mockFrontOutput)).willReturn(true)
        given(mockSession.isRunning).willReturn(true)

        manager.backCameraOutput = mockBackOutput
        manager.frontCameraOutput = mockFrontOutput
        manager.session = mockSession
        
        XCTAssertNoThrow(try manager.startRunningSession())
        let session = try XCTUnwrap(manager.session)
        XCTAssertTrue(session.isRunning)
    }
    
}
