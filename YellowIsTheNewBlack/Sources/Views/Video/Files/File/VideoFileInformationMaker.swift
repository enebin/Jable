//
//  VideoFileInformationMaker.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/19.
//

import UIKit
import AVFoundation

class VideoFileInformationMaker {
    // Dependencies
    /// none
    
    // MARK: - Public methods
    static func makeInformationFile(for path: URL) -> VideoFileInformation {
        let thumbnail = self.generateThumbnail(for: path)
        
        return VideoFileInformation(path: path, thumbnail: thumbnail)
    }
    
    // MARK: - Internal methods
    static private func generateThumbnail(for path: URL) -> UIImage? {
        let asset = AVURLAsset(url: path, options: nil)
        
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            LoggingManager.logger.log(error: error)
            return nil
        }
    }
    
    // MARK: - Inits
    init() {}
}
