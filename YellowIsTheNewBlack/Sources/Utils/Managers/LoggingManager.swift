//
//  LoggingManager.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/15.
//

import Foundation

class LoggingManager {
    static let logger = LoggingManager()
    
    private let showLog = true
    
    func log(message: String) {
        if showLog {
            print("[BLBX] \(message)")
        }
    }
    
    func log(error: Error) {
        if showLog {
            print("[BLBX] [Error] \(error) : \(error.localizedDescription)")
        }
    }
}
