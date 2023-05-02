//
//  GallerySection.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/20.
//

import Foundation
import RxDataSources

struct GallerySection {
    var header: String
    var items: [Item]
}

extension GallerySection: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = VideoFileInformation

    var identity: String {
        return header
    }

    init(original: GallerySection, items: [Item]) {
        self = original
        self.items = items
    }
}
