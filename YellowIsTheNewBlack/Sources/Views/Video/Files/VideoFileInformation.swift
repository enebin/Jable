//
//  VideoInformation.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/18.
//

import Foundation
import RxDataSources
import UIKit

struct VideoFileInformation: Identifiable, Equatable {
    let id = UUID()
    let path: URL
    let thumbnail: UIImage?
}

// for RxDataSource
extension VideoFileInformation: IdentifiableType {
    typealias Identity = UUID
    
    var identity: UUID {
        return self.id
    }
}
