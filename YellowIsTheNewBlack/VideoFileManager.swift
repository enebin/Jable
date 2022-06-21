//
//  VideoFileManager.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/19.
//

import Foundation
import RxRelay

final class VideoFileManager {
    static let `default` = VideoFileManager()
    
    // Dependencies
    private let fileManager: FileManager
    private let pathManager: VideoFilePathManager
    private let informationMaker: VideoFileInformationMaker
    
    // Data
    private(set) var informations: BehaviorRelay<[VideoFileInformation]>
        
    
    var fileDiretoryPath: URL {
        return pathManager.fileDiretoryPath
    }
    
    var filePath: URL {
        return pathManager.filePath
    }
    
    /// Path를 이용해서 비디오를 받아오고 내부에서 쓸 수 있게 래퍼로 인코드?함
    func addAfterEncode(at path: URL) {
        let info = informationMaker.makeInformationFile(for: path)
        
        var informations = self.informations.value // old values
        informations.append(info)   // be new values
        
        self.informations.accept(informations)
    }
    
    /// 앨범에서 삭제되는 케이스
    @discardableResult
    func delete(_ info: VideoFileInformation) -> [VideoFileInformation] {
        var informations = self.informations.value
        
        guard let index = informations.firstIndex(of: info) else {
            LoggingManager.logger.log(message: "Video doesn't exist")
            return informations
        }
        
        // Delete from disk
        do {
            try fileManager.removeItem(at: info.path)
        }
        catch let error {
            LoggingManager.logger.log(error: error)
            return informations
        }
        
        // Delete from memory
        informations.remove(at: index)
        self.informations.accept(informations)
        return informations
    }
    
    /// Initialize the on memory data to on disk data
    @discardableResult
    func refresh() -> [VideoFileInformation] {
        let directoryPath = self.fileDiretoryPath
        
        do {
            // Returns file's name, not file's path, shit
            let filePaths = try fileManager.contentsOfDirectory(atPath: directoryPath.path)
                .map { name -> URL in
                    let directoryPath = self.fileDiretoryPath
                    return directoryPath.appendingPathComponent(name)
                }
            
            let infos = filePaths
                .map { filePath -> VideoFileInformation in
                    return informationMaker.makeInformationFile(for: filePath)
                }
            
            self.informations.accept(infos)
        } catch let error {
            LoggingManager.logger.log(error: error)
        }
        
        return self.informations.value
    }
    
    init(
        _ fileManager: FileManager = FileManager.default,
        _ pathManager: VideoFilePathManager = VideoFilePathManager(),
        _ informationMaker: VideoFileInformationMaker = VideoFileInformationMaker()
    ) {
        self.fileManager = fileManager
        self.pathManager = pathManager
        self.informationMaker = informationMaker
        
        self.informations = BehaviorRelay<[VideoFileInformation]>(value: [VideoFileInformation]())
        self.refresh()
    }
}
