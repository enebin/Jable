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
    func getAlbum() -> PHAssetCollection?
    func createAlbum() async throws -> PHAssetCollection
}

class VideoAlbumManager: AlbumManager {
    static let shared = VideoAlbumManager()

    // Dependencies
    private let photoLibrary: PHPhotoLibrary

    // Consts and vars
    private let albumName: String

    // Methods
    func getAlbum() -> PHAssetCollection? {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)

        return collection.firstObject ?? nil
    }

    func createAlbum() async throws -> PHAssetCollection {
        var _album: PHAssetCollection?

        try photoLibrary.performChangesAndWait {
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
            _album = self.getAlbum()
        }

        guard let album = _album else {
            throw VideoAlbumError.unabledToAccessAlbum
        }

        return album
    }

    init(_ albumName: String = "BLBX",
         _ photoLibrary: PHPhotoLibrary = PHPhotoLibrary.shared()) {
        self.photoLibrary = photoLibrary
        self.albumName = albumName
    }

}
