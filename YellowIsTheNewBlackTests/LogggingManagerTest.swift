//
//  LogggingManagerTest.swift
//  YellowIsTheNewBlackTests
//
//  Created by 프라이빗 on 2022/06/15.
//

import XCTest

class LogggingManagerTest: XCTestCase {
    let logger = LoggingManager()

    func testLog() throws {
        logger.log(message: "test")
    }
    
    func testError() throws {
        logger.log(error: URLError(.badURL))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
