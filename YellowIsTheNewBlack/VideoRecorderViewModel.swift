//
//  CameraViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import AVFoundation
import RxSwift
import UIKit

/// 카메라세션
class VideoRecoderViewModel: NSObject {
    // Dependencies
    private let sessionManager: VideoSessionManager
    var videoSession: AVCaptureSession?
    
    // MARK: - Public methods and vars
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setupSession() async throws {
        let session = try await sessionManager.setupSession()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoSession = session
    }
    
    func startRunningCamera() {
        sessionManager.startRunningCamera()
    }
    
    func startRecordingVideo() throws {
        try sessionManager.startRecordingVideo()
    }
    
    func stopRecordingVideo() throws {
        try sessionManager.stopRecordingVideo()
    }
    
    init(_ sessionManager: VideoSessionManager = VideoSessionManager.shared
    ) {
        self.sessionManager = sessionManager
    }
}
