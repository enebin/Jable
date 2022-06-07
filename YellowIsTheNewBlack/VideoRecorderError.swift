//
//  VideoRecorderError.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import Foundation

enum VideoRecorderError: LocalizedError {
    case invalidDevice
    
    var errorDescription: String? {
        switch self {
        case .invalidDevice:
            return "Error occurs while setting camera device."
        }
    }
}
