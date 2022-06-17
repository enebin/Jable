//
//  GalleryThumbnailMaker.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/16.
//

import UIKit
import AVFoundation

/// 갤러리 뷰에서 쓸 썸네일을 만드는 미들 클래스
/// 뷰모델로 썸네일을 넘겨줄 거임
class GalleryThumbnailMaker {
    // Dependencies
    private let videoFilePathManager: VideoFilePathManager
    private let fileManager: FileManager
    
    // TODO: Test
    func getAllThumbnailsInVideoFileDirectory() throws -> [UIImage] {
        var images = [UIImage]()
        
        let directoryPath = videoFilePathManager.fileDiretoryPath
        let filePaths = try fileManager.contentsOfDirectory(atPath: directoryPath.path)
        
        images = try filePaths.map {
            let path = directoryPath.appendingPathComponent($0)
            let thumbnail = try generateThumbnailOfVideo(at: path)
            return thumbnail
        }
        
        return images
    }
    
    // TODO: Test
    private func generateThumbnailOfVideo(at path: URL) throws -> UIImage {
        let asset = AVURLAsset(url: path, options: nil)
        
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        
        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        let thumbnail = UIImage(cgImage: cgImage)
        
        return thumbnail
    }
    
    init(
        _ videoFilePathManager: VideoFilePathManager = VideoFilePathManager.default,
        _ fileManager: FileManager = FileManager.default
    )
    {
        self.videoFilePathManager = videoFilePathManager
        self.fileManager = fileManager
    }
}
