//
//  VideoRecorderError.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import Foundation

enum VideoRecorderError: LocalizedError {
    case invalidDevice
    case permissionDenied
    case unableToSetInput
    case unableToSetOutput
    case notConfigured
    case notSupportedDevice
    case notSupportedOS
    
    var errorDescription: String? {
        switch self {
        case .invalidDevice:
            return "카메라 디바이스를 설정할 수 없습니다.\n카메라 사용 권한을 확인해주세요."
        case .permissionDenied:
            return "카메라 사용 권한이 거부되어 동영상을 촬영할 수 없습니다."
        case .unableToSetInput:
            return "영상을 저장할 수 없습니다."
        case .unableToSetOutput:
            return "영상을 녹화할 수 없습니다."
        case .notConfigured:
            return "카메라 세션이 생성되지 않았습니다. 카메라 사용권한을 확인해주세요."
        case .notSupportedOS:
            return "지원되지 않는 iOS 버전입니다(iOS 15 이상에서 지원)"
        case .notSupportedDevice:
            return "지원되지 않는 디바이스입니다.(아이폰 XR 이상의 기기에서 지원)"
        }
    }
}
