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
            return "Unable to set up camera device.\nPlease check camera usage permission.".localized
        case .permissionDenied:
            return "Cannot take a video because camera permissions are denied.".localized
        case .unableToSetInput:
            return "Unable to save the video".localized
        case .unableToSetOutput:
            return "Unable to record video.".localized
        case .notConfigured:
            return "No camera session was created, please check your camera permissions.".localized
        case .notSupportedOS:
            return "Unsupported iOS version (supported on iOS 15 and later)".localized
        case .notSupportedDevice:
            return "Unsupported device (supported on iPhone XR and later devices)".localized
        }
    }
}
