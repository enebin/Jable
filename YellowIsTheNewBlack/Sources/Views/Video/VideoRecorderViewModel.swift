//
//  CameraViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import AVFoundation
import UIKit
import Photos

import RxSwift
import RxRelay

/// 카메라세션
class VideoRecoderViewModel {
    typealias StatusRelay = ReplayRelay<Error>
    
    // Dependencies
    let videoConfiguration: VideoSessionConfiguration
    private let sessionManager: SingleVideoSessionManager
    private let videoAlbumFetcher: VideoAlbumFetcher
    
    // MARK: Private propertieds
    private var bag = DisposeBag()
    private var isObservablesBound = false
    
    private let workQueue = SerialDispatchQueueScheduler(qos: .userInitiated)
        
    // MARK: Public properties(outputs)
    let previewLayerRelay = PublishRelay<AVCaptureVideoPreviewLayer?>()
    var thumbnailObserver: Observable<UIImage?>
    
    private let statusRelay = ReplayRelay<Error>.create(bufferSize: 1)
    private(set) var statusObservable: Observable<Error>
    private var previousZoomFactor: CGFloat = 1.0

    // MARK: - Public methods
    func startRecordingVideo() throws {
        try sessionManager.startRecordingVideo()
    }
    
    func stopRecordingVideo() throws {
        try sessionManager.stopRecordingVideo()
    }
    
    func pauseRecordingVideo() throws {
//        try sessionManager.pauseRecordingVideo()
    }
    
    @objc func setZoomFactorFromPinchGesture(_ sender: UIPinchGestureRecognizer) {
        let videoZoomFactor = sender.scale * previousZoomFactor
        let minZoomFactor = 1.0
        
        guard
            let maxZoomFactor = sessionManager.maxZoomFactor
        else {
            return
        }
        
        switch sender.state {
        case .ended:
            previousZoomFactor = videoZoomFactor >= 1 ? videoZoomFactor : 1
        case .changed:
            if (videoZoomFactor <= maxZoomFactor) {
                let newZoomFactor = max(minZoomFactor, min(videoZoomFactor, maxZoomFactor))
                videoConfiguration.zoomFactor.accept(newZoomFactor)
            }
        default:
            break
        }
    }
    
    // MARK: - Private methods
    private func updatePreview(
        with session: AVCaptureSession,
        orientation: AVCaptureVideoOrientation = .portrait
    ) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.connection?.videoOrientation = orientation
        
        DispatchQueue.main.async {
            self.previewLayerRelay.accept(previewLayer)
        }
    }
    
    private func checkPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else {
                return
            }
            
            guard status == .authorized else {
                self.statusRelay.accept(VideoAlbumError.unabledToAccessAlbum)
                print("앨범 접근 권한이 없습니다.")
                return
            }
            
            // Update thumbnail observser after permission granted
            self.thumbnailObserver = getThumbnailObserver(from: self.videoAlbumFetcher.getObserver())
        }
    }
    
    private func bindObservables() {
        if isObservablesBound {
            fatalError("Observables have already been bound!")
        }

        self.isObservablesBound = true
        videoConfiguration.videoQuality
            .debounce(.milliseconds(150), scheduler: workQueue)
            .subscribe(on: workQueue)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] quality in
                guard let self = self else {
                    return
                }
                
                self.sessionManager.setVideoQuality(quality) { session in
                    self.updatePreview(with: session)
                }
                    
            }
            .disposed(by: bag)
        
        videoConfiguration.silentMode
            .debounce(.milliseconds(150), scheduler: workQueue)
            .subscribe(on: workQueue)
            .bind { [weak self] isEnabled in
                guard let self = self else { return }
                
                self.sessionManager.setSlientMode(isEnabled,
                                                  currentCamPosition: self.videoConfiguration.cameraPosition.value) { session in
                    self.updatePreview(with: session)
                }
            }
            .disposed(by: bag)

        videoConfiguration.cameraPosition
            .debounce(.milliseconds(150), scheduler: workQueue)
            .subscribe(on: workQueue)
            .bind { [weak self] position in
                guard let self = self else { return }
                
                self.sessionManager.setCameraPosition(position) { session in
                    self.updatePreview(with: session)
                }
            }
            .disposed(by: bag)
        
        videoConfiguration.zoomFactor
            .subscribe(on: workQueue)
            .bind { [weak self] factor in
                guard let self = self else { return }
                
                self.sessionManager.setZoom(factor)
            }
            .disposed(by: bag)
        
        
        if #available(iOS 16, *), self.sessionManager.session.isMultitaskingCameraAccessSupported {
            videoConfiguration.backgroundMode
                .debounce(.milliseconds(150), scheduler: workQueue)
                .subscribe(on: workQueue)
                .bind { [weak self] enabled in
                    guard let self = self else { return }
                    
                    self.sessionManager.setBackgroundMode(enabled) { session in
                        self.updatePreview(with: session)
                    }
                }
                .disposed(by: bag)
        }
    }
    
    init(
        _ sessionManager: SingleVideoSessionManager = SingleVideoSessionManager.shared,
        _ videoConfiguration: VideoSessionConfiguration = VideoSessionConfiguration(),
        _ videoAlbumFetcher: VideoAlbumFetcher = VideoAlbumFetcher.shared
    ) {
        self.sessionManager = sessionManager
        sessionManager.statusObsrever = self.statusRelay
        
        self.videoConfiguration = videoConfiguration
        
        self.videoAlbumFetcher = videoAlbumFetcher
        self.thumbnailObserver = videoAlbumFetcher.getObserver().map { $0.first?.thumbnail }
        
        self.statusObservable = statusRelay.asObservable()
        
        self.bindObservables()
        self.checkPermission()
        
        self.statusObservable = statusRelayInterceptor(statusRelay)
        
        Task {
            try await self.sessionManager.setupSession()
        }
    }
}

extension VideoRecoderViewModel {
    private func getThumbnailObserver(from videoRelay: BehaviorRelay<[VideoFileInformation]>) -> Observable<UIImage?> {
        return videoRelay.map { $0.first?.thumbnail }
    }
    
    private func statusRelayInterceptor(_ statusRelay: StatusRelay) -> Observable<Error> {
        return statusRelay.do { _ in
            try self.stopRecordingVideo() // Duplicated maybe(inside session manager)
        }
    }
}
