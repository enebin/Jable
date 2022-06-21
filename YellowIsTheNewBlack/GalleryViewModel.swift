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
    
    // Public vars and consts
    let videoInformationsRelay: BehaviorRelay<[VideoFileInformation]>
    
    var videoInformations: [VideoFileInformation] {
        return self.videoInformationsRelay.value
    }
    
    init(_ videoFileManager: VideoFileManager = VideoFileManager.default) {
        self.videoFileManager = videoFileManager
        self.videoInformationsRelay = videoFileManager.informations
    }
}

