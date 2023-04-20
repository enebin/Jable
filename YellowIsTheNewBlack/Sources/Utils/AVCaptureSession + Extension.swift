//
//  AVCaptureSession.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/11/13.
//

import AVFoundation

extension AVCaptureSession.Preset {
    var toIntData: Int {
        switch self {
        case .high:
            return 1
        case .medium:
            return 2
        case .low:
            return 3
        default:
            return 0
        }
    }
    
    static func from(_ number: Int) -> AVCaptureSession.Preset {
        switch number {
        case 1:
            return .high
        case 2:
            return .medium
        case 3:
            return .low
        default:
            return .high
        }
    }
}
