//
//  VideoFileSaver.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/19.
//

import UIKit
import Photos

protocol AlbumSaver {
    func save(videoURL: URL) async throws
}

class VideoAlbumSaver: AlbumSaver {
    static let shared = VideoAlbumSaver()
    
    // Dependencies
    private let albumManager: AlbumManager
    private let photoLibrary: PHPhotoLibrary
    
    // MARK: - Methods
    /// Recommended to be executed on background queue
    func save(videoURL: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    let error = VideoAlbumError.unabledToAccessAlbum
                    
                    LoggingManager.logger.log(error: error)
                    continuation.resume(throwing: error)
                    
                    return
                }
                
                continuation.resume()
            }
        }
        
        let album = albumManager.getAlbum()
        if let album {
            try await self.add(videoURL, to: album)
        } else {
            let newAlbum = try await albumManager.createAlbum()
            try await self.add(videoURL, to: newAlbum)
        }
    }
    
    /// (내부사용) 앨범에 해당 비디오를 추가한다
    private func add(_ videoURL: URL, to album: PHAssetCollection) async throws -> Void {
        async let task: Void = photoLibrary.performChanges {
            if
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL),
                let placeholder = assetChangeRequest.placeholderForCreatedAsset
            {
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                let enumeration = NSArray(object: placeholder)
                albumChangeRequest?.addAssets(enumeration)
            }
        }
        
        return try await task
    }
    
    init(_ albumManager: AlbumManager = VideoAlbumManager.shared,
         _ photoLibrary: PHPhotoLibrary = PHPhotoLibrary.shared()) {
        self.albumManager = albumManager
        self.photoLibrary = photoLibrary
    }
}
