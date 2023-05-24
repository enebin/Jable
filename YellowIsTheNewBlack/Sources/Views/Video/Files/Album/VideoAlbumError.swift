//
//  VideoAlbumError.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/19.
//

import Foundation

enum VideoAlbumError: LocalizedError {
    case unabledToAccessAlbum
    
    var errorDescription: String? {
        switch self {
        case .unabledToAccessAlbum:
            return "App can't access albums. App can't read or write videos without permission. Please grant permission in Settings.".localized
        }
    }
}

