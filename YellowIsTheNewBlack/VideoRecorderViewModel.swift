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
    let videoConfiguration: RecorderConfiguration
    
    // vars and lets
    private var videoSession: AVCaptureSession?
    private var bag = DisposeBag()
    
    // MARK: - Public methods and vars
    var previewLayer: AVCaptureVideoPreviewLayer?
    let previewLayerObservable: PublishSubject<AVCaptureVideoPreviewLayer?>
    
    func setupSession(_ quality: AVCaptureSession.Preset = .medium,
                      _ position: AVCaptureDevice.Position) async throws {
        let session = try await sessionManager.setupSession(quality: quality, position: position)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayerObservable.onNext(previewLayer)
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
    
    private func bindObservables() {
        videoConfiguration.videoQuality
            .bind { [weak self] quality in
                guard let self = self else { return }
                
                Task {
                    let position = self.videoConfiguration.cameraPosition.value
                    try await self.setupSession(quality, position)
                }
            }
            .disposed(by: bag)
    }
    
    init(_ sessionManager: VideoSessionManager = VideoSessionManager.shared,
         _ videoConfiguration: RecorderConfiguration = RecorderConfiguration.shared) {
        self.sessionManager = sessionManager
        self.videoConfiguration = videoConfiguration
        self.previewLayerObservable = PublishSubject<AVCaptureVideoPreviewLayer?>()
        
        super.init()
        
        self.bindObservables()
    }
}
