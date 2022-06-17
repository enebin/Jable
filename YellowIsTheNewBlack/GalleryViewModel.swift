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
    private let galleryThumbnailMaker: GalleryThumbnailMaker
    
    // Public vars and consts
    var thumbnails: [UIImage]
    
    init(_ galleryThumbnailMaker: GalleryThumbnailMaker = GalleryThumbnailMaker()) {
        self.galleryThumbnailMaker = galleryThumbnailMaker
        
        self.thumbnails = galleryThumbnailMaker.getAllThumbnailsInVideoFileDirectory()
    }
}

