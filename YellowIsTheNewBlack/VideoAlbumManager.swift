//
//  VideoFileAlbumManager.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/19.
//

// async let - async throw reference
// - https://forums.swift.org/t/async-await-how-to-async-let-void-functions/58653/6

import Photos
import UIKit

protocol AlbumManager {
    func save(videoURL: URL) async throws
}

class VideoAlbumManager: AlbumManager {
    static let shared = VideoAlbumManager()
    
    private var album: PHAssetCollection?
    
    private let albumName: String
    private let photoLibrary: PHPhotoLibrary

    init(_ albumName: String = "BLBX",
         _ photoLibrary: PHPhotoLibrary = PHPhotoLibrary.shared()) {
        self.photoLibrary = photoLibrary
        self.albumName = albumName

        if let album = getAlbum() {
            self.album = album
            return
        }
    }

    private func getAlbum() -> PHAssetCollection? {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        return collection.firstObject ?? nil
    }
    
    private func createAlbum() async throws -> Void {
        async let task: Void = photoLibrary.performChanges {
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
            self.album = self.getAlbum()
        }
        
        return try await task
    }
    
    private func add(_ videoURL: URL) async throws -> Void {
        async let task: Void = photoLibrary.performChanges {
            if let assetChangeRequest =
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL),
               let album = self.album,
               let placeholder = assetChangeRequest.placeholderForCreatedAsset {
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                let enumeration = NSArray(object: placeholder)
                albumChangeRequest?.addAssets(enumeration)
            }
        }
        
        return try await task
    }
    
    /// Recommended to be executed on background queue
    func save(videoURL: URL) async {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("앨범 접근 권한이 없습니다.")
                return
            }
        }

        do {
            if self.album == nil {
                try await self.createAlbum()
            }
            
            try await self.add(videoURL)
        } catch let error {
            print("동영상을 저장하는데 실패했습니다: \(error.localizedDescription)")
        }
    }
}
