//
//  CameraViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import AVFoundation
import UIKit

import RxSwift
import RxRelay

/// 카메라세션
class VideoRecoderViewModel: NSObject {
    // Dependencies
    private let sessionManager: SingleVideoSessionManager
    let videoConfiguration: VideoSessionConfiguration
    
    // vars and lets
    private var videoSession: AVCaptureSession?
    private var bag = DisposeBag()
    private var isObservablesBound = false
    
    private let workQueue = SerialDispatchQueueScheduler(qos: .userInitiated)
    
    // MARK: - Public methods and vars
    let previewLayer = PublishRelay<AVCaptureVideoPreviewLayer?>()
    
    @discardableResult
    func updateSession(configuration: VideoSessionConfiguration) async throws -> AVCaptureSession {
        let session = try await sessionManager.setupSession(configuration: configuration)
        videoSession = session
        
        return session
    }
    
    private func setupPreviewLayer(session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        return previewLayer
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
    
    private func updateSessionAndPreview() async throws {
        let session = try await self.updateSession(configuration: self.videoConfiguration)
        let previewLayer = self.setupPreviewLayer(session: session)
        
        self.previewLayer.accept(previewLayer)
        self.startRunningCamera()
    }
    
    private func bindObservables() {
        if isObservablesBound {
            fatalError("Observables have already been bound!")
        }

        self.isObservablesBound = true
        videoConfiguration.videoQuality
            .debounce(.milliseconds(150), scheduler: workQueue)
            .subscribe(on: workQueue)
            .bind { [weak self] quality in
                guard let self = self else { return }
                
                Task {
                    try await self.updateSessionAndPreview()
                }
            }
            .disposed(by: bag)
        
        videoConfiguration.silentMode
            .subscribe(on: workQueue)
            .bind { [weak self] isMuted in
                guard let self = self else { return }

                Task {
                    try await self.updateSessionAndPreview()
                }
            }
            .disposed(by: bag)
        
        videoConfiguration.cameraPosition
            .subscribe(on: workQueue)
            .bind { [weak self] isMuted in
                guard let self = self else { return }

                Task {
                    try await self.updateSessionAndPreview()
                }
            }
            .disposed(by: bag)
    }
    
    init(_ sessionManager: SingleVideoSessionManager = SingleVideoSessionManager.shared,
         _ videoConfiguration: VideoSessionConfiguration = VideoSessionConfiguration.shared) {
        self.sessionManager = sessionManager
        self.videoConfiguration = videoConfiguration
        
        super.init()
        
        self.bindObservables()
    }
}
