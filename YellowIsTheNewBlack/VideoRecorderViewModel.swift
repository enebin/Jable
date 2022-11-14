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
class VideoRecoderViewModel: NSObject {
    // Dependencies
    let videoConfiguration: VideoSessionConfiguration
    private let sessionManager: SingleVideoSessionManager
    private let videoAlbumFethcher: VideoAlbumFetcher
    
    // vars and lets
    private var bag = DisposeBag()
    private var isObservablesBound = false
    
    private let workQueue = SerialDispatchQueueScheduler(qos: .userInitiated)
    
    let statusPublisher = ReplayRelay<Error>.create(bufferSize: 1)
    
    // MARK: - Public methods and vars
    let previewLayer = PublishRelay<AVCaptureVideoPreviewLayer?>()
    var thumbnailObserver: Observable<UIImage?>
    
    func startRecordingVideo() throws {
        try sessionManager.startRecordingVideo(nil)
    }
    
    func stopRecordingVideo() throws {
        try sessionManager.stopRecordingVideo(nil)
    }
    
    @objc func setZoomFactorFromPinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let maxZoomFactor = sessionManager.maxZoomFactor,
              let currentZoomFactor = sessionManager.currentZoomFactor
        else {
            return
        }
        
        let sensitivity: CGFloat = 4
        
        switch sender.state {
        case .began: fallthrough
        case .changed:
            let scale = sender.scale

            videoConfiguration.zoomFactor.accept(
                max(min(currentZoomFactor * ((scale + (sensitivity-1))/sensitivity), maxZoomFactor), 1.0)
            )
        default:
            break
        }
    }
    
    private func updatePreview(with session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        DispatchQueue.main.async {
            self.previewLayer.accept(previewLayer)
        }
    }
    
    private func checkPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else {
                return
            }
            
            print("@W", status == .authorized)
            
            guard status == .authorized else {
                self.statusPublisher.accept(VideoAlbumError.unabledToAccessAlbum)
                print("앨범 접근 권한이 없습니다.")
                return
            }
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
    
    init(_ sessionManager: SingleVideoSessionManager = SingleVideoSessionManager.shared,
         _ videoConfiguration: VideoSessionConfiguration = VideoSessionConfiguration(),
         _ videoAlbumFetcher: VideoAlbumFetcher = VideoAlbumFetcher.shared) {
        self.sessionManager = sessionManager
        self.videoConfiguration = videoConfiguration

        self.videoAlbumFethcher = videoAlbumFetcher
        self.thumbnailObserver = videoAlbumFetcher.getObserver()
            .map { thumbnails in
                return thumbnails.last?.thumbnail
            }
        
        super.init()
        
        self.bindObservables()
        self.checkPermission()

        Task {
            try await self.sessionManager.setupSession()
        }
    }
}
