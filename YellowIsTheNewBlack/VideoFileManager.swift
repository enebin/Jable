//
//  VideoFileManager.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/19.
//

import Foundation

final class VideoFileManager {
    static let shared = VideoFileManager()
    
    // Dependencies
    private let fileManager: FileManager
    private let pathManager: VideoFilePathManager
    private let informationMaker: VideoFileInformationMaker
    
    private(set) var informations: [VideoFileInformation]
        
    var fileDiretoryPath: URL {
        return pathManager.fileDiretoryPath
    }
    
    var filePath: URL {
        return pathManager.filePath
    }
    
    /// Path를 이용해서 비디오를 받아오고 내부에서 쓸 수 있게 래퍼로 인코드?함
    func addAfterEncode(at path: URL) {
        let info = informationMaker.makeInformationFile(for: path)
        self.informations.append(info)
    }
    
    /// 앨범에서 삭제되는 케이스
    @discardableResult
    func delete(_ info: VideoFileInformation) -> [VideoFileInformation] {
        guard let index = self.informations.firstIndex(of: info) else {
            return self.informations
        }
        
        self.informations.remove(at: index)
        return self.informations
    }
    
    init(
        _ fileManager: FileManager = FileManager.default,
        _ pathManager: VideoFilePathManager = VideoFilePathManager(),
        _ informationMaker: VideoFileInformationMaker = VideoFileInformationMaker()
    ) {
        self.fileManager = fileManager
        self.pathManager = pathManager
        self.informationMaker = informationMaker
        
        self.informations = [VideoFileInformation]()
    }
}
