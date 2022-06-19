//
//  CameraViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import AVFoundation
import UIKit

/// 카메라세션
class VideoRecoderViewModel: NSObject {
    // Dependencies
    private let sessionManager: VideoSessionManager
    
    // MARK: - Public methods and vars
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        sessionManager.previewLayer
    }
    
    func setupSession() throws {
        try sessionManager.setupSession()
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
