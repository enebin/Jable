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
    case notConfigured
    
    var errorDescription: String? {
        switch self {
        case .invalidDevice:
            return "카메라 디바이스를 설정할 수 없습니다.\n카메라 사용 권한을 확인해주세요."
        case .unableToSetInput:
            return "영상을 저장할 수 없습니다."
        case .unableToSetOutput:
            return "영상을 녹화할 수 없습니다."
        case .notConfigured:
            return "카메라 세션이 생성되지 않았습니다."
        }
    }
}
