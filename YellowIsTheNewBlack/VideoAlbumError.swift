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
            return "앨범에 접근할 수 없습니다. 권한을 확인해주세요."
        }
    }
}

