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
    private let sessionManager: any VideoSessionManager
    let videoConfiguration: VideoSessionConfiguration
    private let videoAlbumFethcher: VideoAlbumFetcher
    
    // vars and lets
    private var bag = DisposeBag()
    private var isObservablesBound = false
    
    private let workQueue = SerialDispatchQueueScheduler(qos: .userInitiated)
    
    // MARK: - Public methods and vars
    let previewLayer = PublishRelay<AVCaptureVideoPreviewLayer?>()
    var thumbnailObserver: Observable<UIImage?>
    
    @discardableResult
    func updateSession(configuration: VideoSessionConfiguration) async throws -> AVCaptureSession {
        let session = try await sessionManager.setupSession(configuration: configuration)
        
        return session
    }
    
    private func setupPreviewLayer(session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        return previewLayer
    }
    
    func startRunningCamera() throws {
        try sessionManager.startRunningSession(nil)
    }
    
    func startRecordingVideo() throws {
        try sessionManager.startRecordingVideo(nil)
    }
    
    func stopRecordingVideo() throws {
        try sessionManager.stopRecordingVideo(nil)
    }
    
    private func updateSessionAndPreview() async throws {
        let session = try await self.updateSession(configuration: self.videoConfiguration)
        let previewLayer = self.setupPreviewLayer(session: session)
        
        self.previewLayer.accept(previewLayer)
        try self.startRunningCamera()
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
    
    init(_ sessionManager: any VideoSessionManager = SingleVideoSessionManager.shared,
         _ videoConfiguration: VideoSessionConfiguration = VideoSessionConfiguration.shared,
         _ videoAlbumFetcher: VideoAlbumFetcher = VideoAlbumFetcher.shared) {
        self.sessionManager = sessionManager
        self.videoConfiguration = videoConfiguration

        self.videoAlbumFethcher = videoAlbumFetcher
        self.thumbnailObserver = videoAlbumFetcher.getObserver()
            .map { thumbnails in
                thumbnails.last?.thumbnail
            }
        
        super.init()
        
        self.bindObservables()
    }
}
