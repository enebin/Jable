//
//  VideoFileManage.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/09.
//

import Foundation
import UIKit

/// Managing all stuffs related to local disk
class VideoFileManager {
    // Dependencies
    private let fileManager: FileManager
    private let dateFormatter: DateFormatter
    
    // Internal vars and consts
    private let path: URL
    
    var fileDiretoryPath: URL {
        return self.path
    }
    
    var filePath: URL {
        let directoryPath = self.path
        let fileName = self.dateFormatter.string(from: Date())
        
        let filePath = directoryPath.appendingPathComponent(fileName)
        return filePath
    }
    
    func save(path: URL) {
        UISaveVideoAtPathToSavedPhotosAlbum(path.path, nil, nil, nil)
    }
    
    // MARK: - Internal methos
    private func setDateFormatter(_ formatter: DateFormatter) {
        formatter.dateFormat = "yyyy-MM-dd-HH:mm"
    }

    init(
        _ fileManager: FileManager = FileManager.default,
        _ dateFormatter: DateFormatter = DateFormatter()
    ) {
        self.fileManager = fileManager
        self.dateFormatter = dateFormatter
        
        // set path
        let albumPath = fileManager.urls(for: .picturesDirectory, in: .userDomainMask).first! // FIXME: Remove force unwrap
        self.path = albumPath.appendingPathComponent("BiBlackBox", isDirectory: true)
        
        self.setDateFormatter(dateFormatter)
    }
}
