//
//  SessionManager.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/10/12.
//

import AVFoundation

protocol VideoSessionManager {
    /// 에러핸들링을 `init` 외에서 해 조금이나마 용이하게 하기 위함임.
    func setupSession(configuration: some VideoConfigurable) async throws -> AVCaptureSession
    
    /// 카메라를 돌리기 시작함
    func startRunningCamera()
    
    /// '녹화'를 시작함
    func startRecordingVideo() throws
    
    func stopRecordingVideo() throws
}
