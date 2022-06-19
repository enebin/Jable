//
//  VideoFileManager.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/19.
//

import Foundation

final class VideoFileManager {
    // Dependencies
    private let fileManager: FileManager
    private let pathManager: VideoFilePathManager
        
    var fileDiretoryPath: URL {
        return pathManager.fileDiretoryPath
    }
    
    var filePath: URL {
        return pathManager.filePath
    }
    
    
    
    init(
        _ fileManager: FileManager = FileManager.default,
        _ pathManager: VideoFilePathManager = VideoFilePathManager()
    ) {
        self.fileManager = fileManager
        self.pathManager = pathManager
    }
}
