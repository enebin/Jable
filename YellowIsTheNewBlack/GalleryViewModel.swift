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
    let videoInformationsRelay: BehaviorRelay<[VideoFileInformation]>
    
    var videoInformations: [VideoFileInformation] {
        return self.videoInformationsRelay.value
    }
    
    init(_ videoFileManager: VideoFileManager = VideoFileManager.default,
         _ videoAlbumFetcher: VideoAlbumFetcher = VideoAlbumFetcher()) {
        self.videoFileManager = videoFileManager
        self.videoAlbumFetcher = videoAlbumFetcher
        self.videoInformationsRelay = videoFileManager.informations
        
        
        videoAlbumFetcher.fetch { fetchResult in
            self.videoInformationsRelay.accept(fetchResult)
        }
    }
}

