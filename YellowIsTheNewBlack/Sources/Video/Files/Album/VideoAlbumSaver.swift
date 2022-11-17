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
    
    // Methods
    private func add(_ videoURL: URL, to album: PHAssetCollection) async throws -> Void {
        async let task: Void = photoLibrary.performChanges {
            if let assetChangeRequest =
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL),
               let placeholder = assetChangeRequest.placeholderForCreatedAsset {
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                let enumeration = NSArray(object: placeholder)
                albumChangeRequest?.addAssets(enumeration)
            }
        }
        
        return try await task
    }
    
    /// Recommended to be executed on background queue
    func save(videoURL: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    print("앨범 접근 권한이 없습니다.")
                    continuation.resume(throwing: VideoAlbumError.unabledToAccessAlbum)
                    return
                }
                
                continuation.resume()
            }
        }

        do {
            if let album = albumManager.getAlbum() {
                try await self.add(videoURL, to: album)
            } else {
                let album = try await albumManager.createAlbum()
                try await self.add(videoURL, to: album)
            }
        } catch let error {
            print("동영상을 저장하는데 실패했습니다: \(error.localizedDescription)")
        }
    }
    
    init(_ albumManager: AlbumManager = VideoAlbumManager.shared,
         _ photoLibrary: PHPhotoLibrary = PHPhotoLibrary.shared()) {
        self.albumManager = albumManager
        self.photoLibrary = photoLibrary
    }
}
