//
//  GalleryViewModel.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/16.
//

import UIKit
import RxSwift
import RxRelay

class GalleryViewModel {
    // Dependencies
    private let videoFileManager: VideoFileManager
    
    // Public vars and consts
    var thumbnails: [UIImage]
    
    init(_ videoFileManager: VideoFileManager = VideoFileManager.default) {
        self.videoFileManager = videoFileManager
        
        self.thumbnails = [UIImage]()
        self.thumbnails = videoFileManager.informations.map{
            return $0.thumbnail ?? UIImage(systemName: "xmark")!
        }
    }
}

