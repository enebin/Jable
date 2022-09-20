//
//  GalleryViewModel.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/16.
//

import UIKit
import RxSwift
import RxRelay
import RxDataSources

class GalleryViewModel {
    // Dependencies
    private let videoFileManager: VideoFileManager
    private let videoAlbumFetcher: VideoAlbumFetcher
    
    // Public vars and consts
    /// It's `relay` type. `relay` type has some advantages in terms of continuity because
    /// it doesn't quit subscribing when an error happens.
    let videoInformationsRelay: BehaviorRelay<[VideoFileInformation]>
    
    var videoInformations: [VideoFileInformation] {
        return self.videoInformationsRelay.value
    }
    
    init(_ videoFileManager: VideoFileManager = VideoFileManager.default,
         _ videoAlbumFetcher: VideoAlbumFetcher = VideoAlbumFetcher()) {
        self.videoFileManager = videoFileManager
        self.videoAlbumFetcher = videoAlbumFetcher
        self.videoInformationsRelay = videoAlbumFetcher.getObserver()
    }
}

