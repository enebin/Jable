//
//  VideoAlbumFethcer.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/19.
//

import UIKit
import Photos
import RxRelay

protocol AlbumFetcher {
    associatedtype Data
    func getObserver() -> BehaviorRelay<Data>
}

class VideoAlbumFetcher: NSObject, AlbumFetcher {
    typealias VideoRelay = BehaviorRelay<[VideoFileInformation]>

    static let shared = VideoAlbumFetcher()

    // Dependencies
    private let albumManager: AlbumManager
    private let photoLibrary: PHPhotoLibrary
    private let changeObserer = VideoRelay(value: [])

    func getObserver() -> VideoRelay {
        guard let album = albumManager.getAlbum() else {
            return changeObserer
        }

        // Register observer delegate
        photoLibrary.register(self)

        // Fetch initial assets
        loadVideoInformationsFromAlbum(album, to: changeObserer)

        return changeObserer
    }

    private func loadVideoInformationsFromAlbum( _ album: PHAssetCollection, to observer: VideoRelay) {
        DispatchQueue.global(qos: .userInitiated).async {
            let videoAssets = PHAsset.fetchAssets(in: album, options: nil)
            var informations: [VideoFileInformation] = []

            videoAssets.enumerateObjects { (object: PHAsset, count: Int, _) in
                let asset = object

                if asset.mediaType != .video {
                    return
                }

                let videoOptions: PHVideoRequestOptions = PHVideoRequestOptions()
                videoOptions.version = .original

                PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) { (asset, _, _) in
                    if let urlAsset = asset as? AVURLAsset {
                        let information = VideoFileInformationMaker.makeInformationFile(for: urlAsset.url)
                        informations.append(information)
                    }

                    // if `count` is lastIndex
                    if count == videoAssets.count - 1 {
                        DispatchQueue.main.async {
                            observer.accept(informations)
                        }
                    }
                }
            }
        }
    }

    init(_ albumManager: AlbumManager = VideoAlbumManager.shared,
         _ photoLibrary: PHPhotoLibrary = PHPhotoLibrary.shared()) {
        self.albumManager = albumManager
        self.photoLibrary = photoLibrary
    }
}

extension VideoAlbumFetcher: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if
            let album = albumManager.getAlbum(),
            let albumChanges = changeInstance.changeDetails(for: album),
            let newAlbum = albumChanges.objectAfterChanges
        {
            loadVideoInformationsFromAlbum(newAlbum, to: self.changeObserer)
        }
    }
}
