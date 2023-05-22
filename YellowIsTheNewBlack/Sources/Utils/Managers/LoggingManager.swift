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
    
    func log(error: Error, file: String = (#file as NSString).lastPathComponent, method: String = #function) {
        if showLog {
            print("[BLBX : error] [\(file) : \(method)] - \(error) : \(error.localizedDescription)")
        }
    }
}
