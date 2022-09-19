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
    
    func test() {
        photoLibrary.
    }
    
    
    init(_ albumManager: AlbumManager = VideoAlbumManager.shared,
         _ photoLibrary: PHPhotoLibrary = PHPhotoLibrary.shared()) {
        self.albumManager = albumManager
        self.photoLibrary = photoLibrary
    }
}
