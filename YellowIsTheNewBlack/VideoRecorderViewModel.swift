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
    private let sessionManager: VideoSessionManager
    let videoConfiguration: RecorderConfiguration
    
    // vars and lets
    private var videoSession: AVCaptureSession?
    private var bag = DisposeBag()
    private var isObservablesBound = false
    private var isSessionInProgress = false
    
    private let workQueue = SerialDispatchQueueScheduler(qos: .userInitiated)
    
    // MARK: - Public methods and vars
    let previewLayer = PublishRelay<AVCaptureVideoPreviewLayer?>()
    
    @discardableResult
    func updateSession(configuration: RecorderConfiguration) async throws -> AVCaptureSession {
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
    
    private func bindObservables() {
        if isObservablesBound {
            fatalError("Observables have already been bound!")
        }

        self.isObservablesBound = true

        videoConfiguration.videoQuality
            .debounce(.milliseconds(500), scheduler: workQueue)
            .subscribe(on: workQueue)
            .bind { [weak self] quality in
                guard let self = self else { return }
                
                Task {
                    let session = try await self.updateSession(configuration: self.videoConfiguration)
                    let previewLayer = self.setupPreviewLayer(session: session)
                    
                    self.previewLayer.accept(previewLayer)
                    self.startRunningCamera()
                }
            }
            .disposed(by: bag)
        
        videoConfiguration.silentMode
            .subscribe(on: workQueue)
            .bind { [weak self] isMuted in
                guard let self = self else { return }

                Task {
                    let session = try await self.updateSession(configuration: self.videoConfiguration)
                    let previewLayer = self.setupPreviewLayer(session: session)

                    self.previewLayer.accept(previewLayer)
                    self.startRunningCamera()
                }
            }
            .disposed(by: bag)
    }
    
    init(_ sessionManager: VideoSessionManager = VideoSessionManager.shared,
         _ videoConfiguration: RecorderConfiguration = RecorderConfiguration.shared) {
        self.sessionManager = sessionManager
        self.videoConfiguration = videoConfiguration
        
        super.init()
        
        self.bindObservables()
    }
}
