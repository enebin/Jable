//
//  AVCaptureDevice + Extension.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/11/13.
//

import AVFoundation

extension AVCaptureDevice.Position {
    var toIntData: Int {
        switch self {
        case .back:
            return 1
        case .front:
            return 2
        default:
            return 1
        }
    }

    static func from(_ number: Int) -> AVCaptureDevice.Position {
        switch number {
        case 1:
            return .back
        case 2:
            return .front
        default:
            return .back
        }
    }
}
