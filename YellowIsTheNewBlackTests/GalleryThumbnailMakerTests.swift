//
//  GalleryThumbnailMakerTests.swift
//  YellowIsTheNewBlackTests
//
//  Created by 프라이빗 on 2022/06/17.
//

import XCTest
@testable import YellowIsTheNewBlack

class GalleryThumbnailMakerTests: XCTestCase {
    let instance = GalleryThumbnailMaker()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_getAllThumbnailsInVideoFileDirectory() throws {
        _ = try instance.getAllThumbnailsInVideoFileDirectory()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
