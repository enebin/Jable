//
//  VideoFileManage.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/09.
//

import Foundation
import UIKit

/// Managing all stuffs related to local disk
class VideoFileManager: NSObject {
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
        
        let filePath = directoryPath
            .appendingPathComponent(fileName)
            .appendingPathExtension("mp4")
        
        return filePath
    }
    
    func saveVideoToAlbum(path: URL) {
        // TODO: Throw
        let strPath = path.path
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(strPath) {
            UISaveVideoAtPathToSavedPhotosAlbum(path.path, self, nil, nil)
        } else {
            return
        }
    }
    
    // MARK: - Internal methos
    private func setDateFormatter(_ formatter: DateFormatter) {
        formatter.dateFormat = "yyyy_MM_dd_HH-mm"
    }

    init(
        _ fileManager: FileManager = FileManager.default,
        _ dateFormatter: DateFormatter = DateFormatter()
    ) {
        self.fileManager = fileManager
        self.dateFormatter = dateFormatter
        
        // set paths
        let albumPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! // FIXME: Remove force unwrap
        self.path = albumPath.appendingPathComponent("BiBlackBox", isDirectory: true)

        super.init()
        
        self.setDateFormatter(dateFormatter)
        if fileManager.fileExists(atPath: self.path.path) == false {
            // Set directory if doesn't exist
            do {
                try FileManager.default.createDirectory(atPath: self.path.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch let error {
                print(error)
            }
        }
    }
}

extension VideoFileManager: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(#function, info)
    }
}
