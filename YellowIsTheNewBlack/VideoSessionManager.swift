//
//  SessionManager.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/10/12.
//

import AVFoundation

protocol VideoSessionManager {
    typealias Action = () -> Void
    associatedtype Session: AVCaptureSession
    
    /// 에러핸들링을 `init` 외에서 해 조금이나마 용이하게 하기 위함임.
    func setupSession(configuration: some VideoConfigurable) async throws -> Session
    
    /// 카메라를 돌리기 시작함
    func startRunningSession(_ completion: Action?) throws
    
    func startRecordingVideo(_ completion: Action?) throws
    
    func stopRecordingVideo(_ completion: Action?) throws
}
