//
//  SessionManager.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/10/12.
//

import AVFoundation

protocol VideoSessionManaging {
    typealias Action = () -> Void
    associatedtype Session: AVCaptureSession
    
    var session: Session { get }
    
    /// 에러핸들링을 `init` 외에서 해 조금이나마 용이하게 하기 위함임.
    func setupSession() async throws
    
    func startRecordingVideo(_ completion: Action?) throws
    
    func stopRecordingVideo(_ completion: Action?) throws
}
