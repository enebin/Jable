//
//  VideoRecorderError.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import Foundation

enum VideoRecorderError: LocalizedError {
    case invalidDevice
    case unableToSetInput
    case unableToSetOutput
    
    var errorDescription: String? {
        switch self {
        case .invalidDevice:
            return "카메라 설정 중 에러가 발생했습니다."
        case .unableToSetInput:
            return "영상을 저장할 수 없습니다."
        case .unableToSetOutput:
            return "영상을 녹화할 수 없습니다."
        }
    }
}