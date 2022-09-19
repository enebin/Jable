//
//  VideoAlbumFethcer.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/19.
//

import UIKit
import Photos

protocol AlbumFetcher {
    
}

class VideoAlbumFetcher {
    // Dependencies
    private let albumManager: AlbumManager
    private let photoLibrary: PHPhotoLibrary
    
    func fetch(_ completion: @escaping ([VideoFileInformation]) -> Void) {
        guard let album = albumManager.getAlbum() else {
            return
        }

        self.loadVideosFromAlbum(album) { fetchResult in
            completion(fetchResult)
        }
    }
    
    private func loadVideosFromAlbum(_ album: PHAssetCollection, onCompleted: @escaping ([VideoFileInformation]) -> Void) {
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
                
                PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) { (asset, audioMix, info) in
                    if let urlAsset = asset as? AVURLAsset {
                        let information = VideoFileInformationMaker.makeInformationFile(for: urlAsset.url)
                        informations.append(information)
                    }
                    
                    if count == videoAssets.count - 1 {
                        DispatchQueue.main.async {
                            onCompleted(informations)
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
